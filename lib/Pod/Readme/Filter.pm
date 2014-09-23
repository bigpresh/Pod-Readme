package Pod::Readme::Filter;

use v5.10.1;

# TODO: change to use Moo as per ETHER's suggestion

use Moose;
with 'MooseX::Object::Pluggable';
with 'Pod::Readme::Plugin';

use Carp;
use File::Slurp qw/ read_file /;
use IO qw/ File Handle /;
use MooseX::Types::IO 'IO';
use MooseX::Types::Path::Class;
use Try::Tiny;

has encoding => (
    is      => 'ro',
    isa     => 'Str',
    default => ':utf8',
);

has base_dir => (
    is      => 'ro',
    isa     => 'Path::Class::Dir',
    coerce  => 1,
    default => '.',
);

has input_file => (
    is       => 'ro',
    isa      => 'Path::Class::File',
    required => 0,
    coerce   => 1,
);

has output_file => (
    is       => 'ro',
    isa      => 'Path::Class::File',
    required => 0,
    coerce   => 1,
);

has input_fh => (
    is      => 'ro',
    isa     => IO,
    lazy    => 1,
    coerce  => 1,
    default => sub {
        my ($self) = @_;
        if ( $self->input_file ) {
            $self->input_file->openr;
        } else {
            my $fh = IO::Handle->new;
            if ( $fh->fdopen( fileno(STDIN), 'r' ) ) {
                return $fh;
            } else {
                croak "Cannot get a filehandle for STDIN";
            }
        }
    },
);

has output_fh => (
    is      => 'ro',
    isa     => IO,
    lazy    => 1,
    coerce  => 1,
    builder => '_build_output_fh',
);

sub _build_output_fh {
    my ($self) = @_;
    if ( $self->output_file ) {
        $self->output_file->openw;
    } else {
        my $fh = IO::Handle->new;
        if ( $fh->fdopen( fileno(STDOUT), 'w' ) ) {
            return $fh;
        } else {
            croak "Cannot get a filehandle for STDOUT";
        }
    }
}

# TODO: target format names should be \w+

has target => (
    is      => 'ro',
    isa     => 'Str',
    default => 'readme',
);

has in_target => (
    is       => 'ro',
    isa      => 'Bool',
    traits   => [qw/ Bool /],
    init_arg => undef,
    default  => 1,
    handles  => {
        cmd_start => 'set',
        cmd_stop  => 'unset',
    },
);

has _target_regex => (
    is       => 'ro',
    isa      => 'Regexp',
    init_arg => undef,
    lazy     => 1,
    default  => sub {
        my $self   = shift;
        my $target = $self->target;
        qr/^[:]?${target}$/;
    },
);

has mode => (
    is       => 'rw',
    isa      => 'Str',
    default  => 'default',
    init_arg => undef,
);

has _line_no => (
    is      => 'ro',
    isa     => 'Int',
    traits  => [qw/ Counter /],
    default => 0,
    handles => { _inc_line_no => 'inc', },
);

sub write {
    my ( $self, $line ) = @_;
    my $fh = $self->output_fh;
    print {$fh} $line;
}

sub in_pod {
    my ($self) = @_;
    $self->mode eq 'pod';
}

has _for_buffer => (
    is       => 'rw',
    isa      => 'Str',
    init_arg => undef,
    default  => '',
    traits   => [qw/ String /],
    handles  => {
        _append_for_buffer => 'append',
        _clear_for_buffer  => 'clear',
    },
);

has _begin_args => (
    is       => 'rw',
    isa      => 'Str',
    init_arg => undef,
    default  => '',
    traits   => [qw/ String /],
    handles  => { _clear_begin_args => 'clear', },
);

sub process_for {
    my ( $self, $data ) = @_;

    my ( $target, @args ) = $self->_parse_arguments($data);

    if ( $target && $target =~ $self->_target_regex ) {
        if ( my $cmd = shift @args ) {
            $cmd =~ s/-/_/g;
            if ( my $method = $self->can("cmd_${cmd}") ) {
                try {
                    $self->$method(@args);
                }
                catch {
                    s/\n$//;
                    die sprintf( "\%s at input line \%d\n",
                        $_, $self->_line_no );
                };
            } else {
                die sprintf( "Unknown command: '\%s' at input line \%d\n",
                    $cmd, $self->_line_no );
            }

        }

    }
    $self->_clear_for_buffer;
}

sub filter_line {
    my ( $self, $line ) = @_;

    # Modes:
    #
    # pod         = POD mode
    #
    # pod:for     = buffering text for =for command
    #
    # pod:begin   = don't print this line, skip next line
    #
    # target:*    = begin block for something other than readme
    #
    # default     = code
    #

    state $blank = qr/^\s*\n$/;

    my $mode = $self->mode;

    if ( $mode eq 'pod:for' ) {
        if ( $line =~ $blank ) {
            $self->process_for( $self->_for_buffer );
            $mode = $self->mode('pod');
        } else {
            $self->_append_for_buffer($line);
        }
        return 1;
    } elsif ( $mode eq 'pod:begin' ) {

        unless ( $line =~ $blank ) {
            die sprintf( "Expected new paragraph after command at line \%d\n",
                $self->_line_no );
        }

        $self->mode('pod');
        return 1;
    }

    if ( $line =~ /^=(\w+)\s/ ) {
        my $cmd = $1;
        $mode = $self->mode( $cmd eq 'cut' ? 'default' : 'pod' );

        if ( $self->in_pod ) {

            if ( $cmd eq 'for' ) {

                $self->mode('pod:for');
                $self->_for_buffer( substr( $line, 4 ) );

            } elsif ( $cmd eq 'begin' ) {

                my ( $target, @args )
                    = $self->_parse_arguments( substr( $line, 6 ) );

                if ( $target =~ $self->_target_regex ) {

                    if (@args) {

                        my $buffer = join( ' ', @args );

                        if ( substr( $target, 0, 1 ) eq ':' ) {
                            die sprintf( "Can only target POD at line \%d\n",
                                $self->_line_no + 1 );
                        }

                        $self->write_begin( $self->_begin_args($buffer) );
                    }

                    $self->mode('pod:begin');

                } else {
                    $self->mode( 'target:' . $target );
                }

            } elsif ( $cmd eq 'end' ) {

                my ( $target, @args )
                    = $self->_parse_arguments( substr( $line, 4 ) );

                if ( $target =~ $self->_target_regex ) {
                    my $buffer = $self->_begin_args;
                    if ( $buffer ne '' ) {
                        $self->write_end($buffer);
                        $self->_clear_begin_args;
                    }
                }

                $self->mode('pod:begin');
            }
        }

    }

    $self->write($line) if $self->in_target && $self->in_pod;

    return 1;
}

sub filter_file {
    my ($self) = @_;

    foreach
        my $line ( read_file( $self->input_fh, binmode => $self->encoding ) )
    {
        $self->filter_line($line)
            or last;
        $self->_inc_line_no;
    }
}

sub run {
    my ($self) = @_;
    $self->filter_file;
}

sub cmd_continue {
    my ($self) = @_;
    $self->cmd_start;
}

sub cmd_include {
    my ( $self, @args ) = @_;

    my $res = $self->parse_cmd_args( [qw/ file stype start stop /], @args );

    my $start = $res->{start};
    $start = qr/${start}/ if $start;
    my $stop = $res->{stop};
    $stop = qr/${stop}/ if $stop;

    my $type = $res->{type} // 'pod';
    unless ( $type =~ /^(?:text|pod)$/ ) {
        die "Unsupported include type: '${type}'\n";
    }

    my $file = $res->{file};
    my $fh = IO::File->new( $file, 'r' )
        or die "Unable to open file '${file}': $!\n";

    $self->write("\n");

    while ( my $line = <$fh> ) {

        next if ( $start && $line !~ $start );
        last if ( $stop  && $line =~ $stop );

        $start = undef;

        if ( $type eq 'text' ) {
            $self->write_verbatim($line);
        } else {
            $self->write($line);
        }

    }

    $self->write("\n");

    close $fh;

}

around _build_plugin_app_ns => sub {
    my ( $orig, $self ) = @_;
    my $names = $self->$orig;
    [ @{$names} ];
};

sub cmd_plugin {
    my ( $self, $plugin, @args ) = @_;
    my $name = "cmd_${plugin}";
    $self->load_plugin($plugin) unless $self->can($name);
    if ( my $method = $self->can($name) ) {
        $self->$method(@args);
    }
}

use namespace::autoclean;

1;
