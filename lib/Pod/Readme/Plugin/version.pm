package Pod::Readme::Plugin::version;

use Moose::Role;

use ExtUtils::MakeMaker;

requires 'parse_cmd_args';

has 'version_file' => (
    is       => 'ro',
    isa      => 'Path::Class::File',
    required => 0,
    coerce   => 1,
    lazy     => 1,
    default  => sub {
        my ($self) = @_;
        $self->input_file;
    },
);

has 'version_title' => (
    is      => 'rw',
    isa     => 'Str',
    default => 'VERSION',
);

sub cmd_version {
    my ( $self, @args ) = @_;

  my $res = $self->parse_cmd_args(@args);
    foreach my $key (keys %{$res}) {
        (my $name = "version_${key}")  =~ s/-/_/g;
        if (my $method = $self->can($name)) {
            $self->$method( $res->{$key} );
        } else {
            die "Invalid key: '${key}'";
        }
    }

    if (my $file = $self->version_file) {

        $self->write_head1($self->version_title);
        $self->write_para( MM->parse_version($file) );

    } else {

        die "Don't know what file to determine the version from";

    }
}

use namespace::autoclean;

1;
