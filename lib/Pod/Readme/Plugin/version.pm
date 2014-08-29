package Pod::Readme::Plugin::version;

use Moose::Role;

use CPAN::Meta;

has 'version_meta_file' => (
    is      => 'rw',
    isa     => 'Str',
    default => 'MYMETA.json',
);

has 'version_title' => (
    is      => 'rw',
    isa     => 'Str',
    default => 'VERSION',
);

sub pod_readme_version {
    my ( $self, $file ) = @_;

    $file //= $self->version_meta_file;

    my $meta = CPAN::Meta->load_file($file);

    $self->_elem_wrap( 'head1', $self->version_title );

    $self->_elem_wrap( 'Para', $meta->version );
}

1;
