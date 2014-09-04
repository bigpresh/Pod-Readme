package Pod::Readme::Plugin::version;

use Moose::Role;

use ExtUtils::MakeMaker;

has 'version_from_file' => (
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
    my ( $self ) = @_;

    if (my $file = $self->input_file) {

        $self->write_head1($self->version_title);
        $self->write_para( MM->parse_version($file) );

    } else {

        die "Don't know what file to determine the version from";

    }
}

use namespace::autoclean;

1;
