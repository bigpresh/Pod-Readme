package Pod::Readme::Plugin::version;

use Moose::Role;

use ExtUtils::MakeMaker;

=head1 NAME

Pod::Readme::Plugin::version - include version in README

=head1 SYNOPSIS

  =for readme plugin version

=head1 DESCRIPTION

This is a plugin for L<Pod::Readme> that includes the release version.

=head1 ARGUMENTS

=head2 C<file>

  =for readme plugin version file='lib/My/App.pm'

By default, it will extract the version from the same file that the
F<README> is being extracted from.  If this is a different file, then
it should be specified.

=head2 C<title>

  =for readme plugin version title='VERSION'

This argument allows you to change the title of the heading.

=cut

requires 'parse_cmd_args';

has 'version_file' => (
    is       => 'rw',
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

        # TODO: option to change the heading level

        $self->write_head1($self->version_title);
        $self->write_para( MM->parse_version($file) );

    } else {

        die "Don't know what file to determine the version from";

    }
}

use namespace::autoclean;

1;
