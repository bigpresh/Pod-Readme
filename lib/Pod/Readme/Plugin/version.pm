package Pod::Readme::Plugin::version;

use Moose::Role;

use CPAN::Meta;

has 'version_meta_file' => (
    is      => 'rw',
    isa     => 'Str',
    default => 'META.yml',
);

has 'version_title' => (
    is      => 'rw',
    isa     => 'Str',
    default => 'VERSION',
);

sub cmd_version {
    my ( $self, $file ) = @_;

    $file //= $self->version_meta_file;

    my $meta = CPAN::Meta->load_file($file);

    $self->write_head1($self->version_title);
    $self->write( $meta->version . "\n\n");
}

use namespace::autoclean;

1;
