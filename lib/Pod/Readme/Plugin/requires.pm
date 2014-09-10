package Pod::Readme::Plugin::requires;

use Moose::Role;

use version 0.77;

use CPAN::Meta;
use Module::CoreList;
use Path::Class;

=head1 NAME

Pod::Readme::Plugin::requires - include requirements in README

=head1 SYNOPSIS

  =for readme plugin requires

=head1 DESCRIPTION

This is a plugin for L<Pod::Readme> that includes module requirements
from the F<META.yml> file.

=head1 ARGUMENTS

=head2 C<file>

  =for readme plugin version file='MYMETA.yml'

By default, it will extract the version from the F<META.yml> file. If,
for some reason, this file is in a non-standard location, then you
should specify it here.

=head2 C<no-omit-coree>

By default, core modules for the version of Perl specified in the
F<META.yml> file are omitted from this list.  If you prefer to lise
all requirements, then specify this option.

=head2 C<title>

  =for readme plugin version title='REQUIREMENTS'

This argument allows you to change the title of the heading.

=cut

requires 'parse_cmd_args';

has 'requires_from_file' => (
    is      => 'rw',
    isa     => 'Path::Class::File',
    coerce  => 1,
    default => 'META.yml',
);

has 'requires_title' => (
    is      => 'rw',
    isa     => 'Str',
    default => 'REQUIREMENTS',
);

has 'requires_omit_core' => (
    is      => 'rw',
    isa     => 'Bool',
    default => 1,
);

sub cmd_requires {
    my ( $self, @args ) = @_;

    my $res = $self->parse_cmd_args(
        [qw/ from-file title omit-core no-omit-core /], @args );
    foreach my $key ( keys %{$res} ) {
        ( my $name = "requires_${key}" ) =~ s/-/_/g;
        if ( my $method = $self->can($name) ) {
            $self->$method( $res->{$key} );
        } else {
            die "Invalid key: '${key}'";
        }
    }

    my $meta = CPAN::Meta->load_file(
        file( $self->base_dir, $self->requires_from_file ) );

    my %prereqs;
    foreach my $type ( values %{ $meta->prereqs } ) {
        $prereqs{$_} = $type->{requires}->{$_}
            for ( keys %{ $type->{requires} } );
    }
    my $perl = delete $prereqs{perl};
    if ( $self->requires_omit_core && $perl ) {
        foreach ( keys %prereqs ) {
            delete $prereqs{$_}
                if Module::CoreList->first_release($_)
                && version->parse( Module::CoreList->first_release($_) )
                <= version->parse($perl);
        }
    }

    if (%prereqs) {

        # TODO: option for setting the heading level

        $self->write_head1( $self->requires_title );

        if ($perl) {
            $self->write_para(
                sprintf( 'This distribution requires Perl %s.',
                    version->parse($perl)->normal )
            );
        }

        $self->write_para(
            'This distribution requires the following modules:');

        $self->write_over(4);
        foreach my $module ( sort keys %prereqs ) {
            $self->write_item( sprintf( '* L<%s>', $module ) );
        }
        $self->write_back;
    }

}

use namespace::autoclean;

1;
