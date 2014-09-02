package Pod::Readme::Filter;

use v5.10.1;

use Moose;

use Carp;
use File::Slurp qw/ read_file /;
use IO::Handle;

has encoding => (
  is => 'ro',
  isa => 'Str',
  default => ':utf8',
);

# TODO: target format names should be \w+

has target => (
    is      => 'ro',
    isa     => 'Str',
    default => 'readme',
);

has in_target => (
    is => 'ro',
    isa => 'Bool',
    traits => [qw/ Bool /],
    init_arg => undef,
    default => 1,
    handles => {
        pod_readme_start => 'set',
        pod_readme_stop  => 'unset',
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
    is      => 'rw',
    isa     => 'Str',
    default => 'default',
    init_arg => undef,
);

has input_fh => (
    is  => 'ro',
    isa => 'IO::Handle',
    lazy => 1,
    default => sub {
        my $self = shift;
        my $fh = IO::Handle->new;
        if ($fh->fdopen(fileno(STDIN), 'r')) {
            return $fh;
        } else {
            croak "Cannot get a filehandle for STDIN";
        }
    },
);

has _line_no => (
    is => 'ro',
    isa => 'Int',
    traits => [qw/ Counter /],
    default => 0,
    handles => {
        _inc_line_no => 'inc',
    },
);

has output_fh => (
    is  => 'ro',
    isa => 'IO::Handle',
    lazy => 1,
    default => sub {
        my $self = shift;
        my $fh = IO::Handle->new;
        if ($fh->fdopen(fileno(STDOUT), 'w')) {
            return $fh;
        } else {
            croak "Cannot get a filehandle for STDOUT";
        }
    },
);

sub write_line {
    my ($self, $line) = @_;
    my $fh = $self->output_fh;
    # $line = sprintf('%4d %s', $self->_line_no + 1, $line);
    print {$fh} $line;
}

sub in_pod {
    my ($self) = @_;
    $self->mode eq 'pod';
}

has _for_buffer => (
  is => 'rw',
  isa => 'Str',
  init_arg => undef,
  default => '',
  traits => [qw/ String /],
    handles => {
        _append_for_buffer => 'append',
        _clear_for_buffer  => 'clear',
    },
);

has _begin_args => (
    is => 'rw',
    isa => 'Str',
  init_arg => undef,
  default => '',
  traits => [qw/ String /],
    handles => {
        _clear_begin_args  => 'clear',
    },
);

sub process_for {
    my ($self, $data) = @_;

    my ($target, @args) = grep { $_ ne '' } split /\s+/, $data;

    if ($target && $target =~ $self->_target_regex) {

        if (my $cmd = shift @args) {

            $cmd =~ s/-/_/g;
            if (my $method = $self->can("pod_readme_${cmd}")) {
                $self->$method(@args);
            } else {
                die sprintf("Unknown command: '\%s' at input line \%d\n", $cmd, $self->_line_no);
            }

        }

    }
    $self->_clear_for_buffer;
}

sub filter_line {
    my ($self, $line) = @_;

    # Modes:
    #
    # pod         = POD mode
    #
    # pod:for     = buffering text for =for command
    #
    # pod:begin = don't print this line, skip next line
    #
    # target:*    = begin block for something other than readme
    #
    # default     = code
    #

    state $blank = qr/^\s*\n$/;

    my $mode = $self->mode;

    if ($mode eq 'pod:for') {
        if ($line =~ $blank) {
            $self->process_for($self->_for_buffer);
            $mode = $self->mode('pod');
        } else {
            $self->_append_for_buffer($line);
        }
        return 1;
    } elsif ($mode eq 'pod:begin') {

        unless ($line =~ $blank) {
            die sprintf("Expected new paragraph after command at line \%d\n", $self->_line_no);
        }

        $self->mode('pod');
        return 1;
    }

    return if $line =~ /^__?(:DATA|END)__/;

    if ($line =~ /^=(\w+)\s/) {
        my $cmd = $1;
        $mode = $self->mode( $cmd eq 'cut' ? 'default' : 'pod' );

        if ($self->in_pod) {

            if ($cmd eq 'for') {

                $self->mode('pod:for');
                $self->_for_buffer(substr($line, 4));

            } elsif ($cmd eq 'begin') {

                my ($target, @args) = grep { $_ ne '' }
                  split /\s+/, substr($line, 6);

                if ($target =~ $self->_target_regex) {

                    if (@args) {
                        $self->_begin_args("@{args}");
                        $self->write_line("=begin @{args}\n");
                    }

                    $self->mode('pod:begin');

                } else {
                    $self->mode('target:' . $target);
                }


            } elsif ($cmd eq 'end') {


                my ($target, @args) = grep { $_ ne '' }
                  split /\s+/, substr($line, 4);

                if ($target =~ $self->_target_regex) {
                    my $buffer = $self->_begin_args;
                    if ($buffer ne '') {
                        $self->write_line("=end ${buffer}\n");
                        $self->_clear_begin_args;
                    }
                }

                $self->mode('pod:begin');
            }
        }


    }

    $self->write_line($line) if $self->in_target && $self->in_pod;

    return 1;
}

sub filter_file {
    my ($self) = @_;

    foreach my $line (read_file($self->input_fh, binmode => $self->encoding )) {
        $self->filter_line($line)
            or last;
        $self->_inc_line_no;
    }
}

sub pod_readme_continue {
    my $self = shift;
    $self->pod_readme_start(@_);
}

package main;

use v5.10.1;

=head NAME

main - this is for testing

=begin readme

Foo

=end readme

=for readme stop

This is a para

=for readme start

=head2 Test

=for bobobo goo
boobo

=for readme continue

Hello

=cut

my $prf = Pod::Readme::Filter->new();

$prf->filter_file;

__END__

use v5.10.1;

use Moose;

use Carp;
use File::Slurp qw/ read_file /;


# TODO: target format names should be \w+

has 'target' => (
    is      => 'ro',
    isa     => 'Str',
    default => 'readme',
);

# TODO: begin/end is not nested, so this needs to be redone

has '_format' => (
    is => 'ro',
    isa => 'ArrayRef[Str]',
    traits => [qw/ Array /],
    handles => {
      enable  => 'push',
      disable => 'pop',
    },
    lazy    => 1,
    default => sub {
        my ($self) = @_;
        [ $self->target ],
    },
    init_arg => undef,
);

sub in_target {
    my ($self) = @_;
    my $format = $self->_format->[-1] // '';
    $format eq $self->target;
}

has 'in_pod' => (
    is => 'ro',
    isa => 'Bool',
    traits => [qw/ Bool /],
    handles => {
      is_pod  => 'set',
      is_perl => 'unset',
    },
    default => 0,
    init_arg => undef,
);

has 'in_for' => (
    is => 'ro',
    isa => 'Bool',
    traits => [qw/ Bool /],
    handles => {
      set_in_for  => 'set',
      unset_in_for => 'unset',
    },
    default => 0,
    init_arg => undef,
);

sub pod_readme_stop {
    my ($self) = @_;
    my $format = $self->_format->[-1] // '';
    $self->disable if ($format eq $self->target);
}

sub pod_readme_start {
    my ($self) = @_;
    my $format = $self->_format->[-1] // '';
    $self->enable($self->target)
        unless ($format eq $self->target);
}

sub pod_readme_for {
    my ($self, $cmd, $args) = @_;
    if (my $method = $self->can("pod_readme_" . $cmd)) {
        $self->$method($args); # TODO
    } else {
        croak "Unsupported command: ${cmd}";
    }
}


sub filter_line {
    my ($self, $line) = @_;

    if ($self->in_pod) {

        my $cmd = '';
        my $arg = '';
        if ($line =~ /^[=](\w+)(?:\s+(.+))?/) {
            ($cmd, $arg) = ($1, $2);
        } elsif ($line =~ /^\s*\n$/) {
            if ($self->in_for) {
                return $self->unset_in_for;
            }
        };

        state $target = $self->target;
        state $format = qr/^[:]?(\w+)\b/;

        if ($cmd eq 'pod:for') {

            $self->set_in_for;
            if ($arg =~ $format) {
                if ($1 eq $self->target) {

                    if ($line =~ /^[=]for\s+[:]?${target}\s+(\w+)(?:\s+(.+))?\n?$/) {
                        $self->pod_readme_for($1, $2);
                    } else {
                        croak "Malformed line: ${line}";
                    }

                }
            }

        } elsif ($cmd eq 'begin') {

            if ($arg =~ $format) {
                $self->enable($1);
            } else {
                croak "Malformed format in line ${line}";
            }

        } elsif ($cmd eq 'end') {

            if ($arg =~ $format) {

                my $format = $self->disable;
                if ($format ne $1) {
                    croak "Expected =end ${format} in line ${line}";
                }

           } else {
                croak "Malformed format in line ${line}";
            }

        } else {

            print $line if $self->in_target;

            return $self->is_perl if ($cmd eq 'cut');

        }

    } else {

        if ($line =~ /^[=]/) {
            $self->is_pod;
            $self->filter_line($line);
        }

    }
}

sub filter_file {
    my ($self, $file) = @_;

    foreach my $line (read_file($file, binmode => $self->encoding )) {
        $self->filter_line($line);
    }
}

1;

package main;

use strict;
use warnings;

use Pod::Abstract;

=head1 NAME

Test

=cut

=begin :foo

=head2 Foo

This shouldn't be here.

=end :foo

=begin :readme

=head2 Para

This is a test.

=end :readme

=for readme stop

Boo!

=for readme start

=cut

my $prf = Pod::Readme::Filter->new();
$prf->filter_file($0);
