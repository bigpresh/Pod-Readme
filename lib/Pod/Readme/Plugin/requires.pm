package Pod::Readme::Plugin::requires;

use Moo::Role;

use CPAN::Meta;
use Module::CoreList;
use Path::Class;
use Types::Standard qw/ Bool Str /;

use version 0.77; our $VERSION = version->declare('v1.0.1_01');

use Pod::Readme::Types qw/ File HeadingLevel /;

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

=head1 KNOWN ISSUES

=over

=item *

Trailing zeros in module versions may be dropped.

If you specify a minimum version of a module with a trailing zero,
e.g. "0.30", then it may be shown as "0.3".  A workaround is to
specify the module version in your F<Makefile.PL> as a string instead
of number:

  requires(
    'CPAN::Changes' => '0.30',
    ...
  );

=back

=cut

requires 'parse_cmd_args';

has 'requires_from_file' => (
    is      => 'rw',
    isa     => File,
    coerce  => 1,
    default => 'META.yml',
);

has 'requires_title' => (
    is      => 'rw',
    isa     => Str,
    default => 'REQUIREMENTS',
);

has 'requires_omit_core' => (
    is      => 'rw',
    isa     => Bool,
    default => 1,
);

has 'requires_heading_level' => (
    is      => 'rw',
    isa     => HeadingLevel,
    default => 1,
);

has 'requires_run' => (
    is      => 'rw',
    isa     => Bool,
    default => 0,
);

sub cmd_requires {
    my ( $self, @args ) = @_;

    die "The requires plugin can only be used once" if $self->requires_run;

    my $res = $self->parse_cmd_args(
        [qw/ from-file title omit-core no-omit-core heading-level /], @args );
    foreach my $key ( keys %{$res} ) {
        ( my $name = "requires_${key}" ) =~ s/-/_/g;
        if ( my $method = $self->can($name) ) {
            $self->$method( $res->{$key} );
        }
        else {
            die "Invalid key: '${key}'";
        }
    }

    my $file = file( $self->base_dir, $self->requires_from_file )->stringify;
    unless (-e $file) {
        die "Cannot find META.yml file at '${file}";
    }

    my $meta = CPAN::Meta->load_file($file);

    my ( $prereqs, $perl ) = $self->_get_prereqs( $meta, 'requires' );
    if ( %{$prereqs} ) {

        my $heading = $self->can( "write_head" . $self->requires_heading_level )
          or die "Invalid heading level: " . $self->requires_heading_level;

        $self->$heading( $self->requires_title );

        if ($perl) {
            $self->write_para(
                sprintf( 'This distribution requires Perl %s.',
                    version->parse($perl)->normal )
            );
        }

        $self->write_para('This distribution requires the following modules:');

        $self->_write_modules($prereqs);

        my ($recommends) = $self->_get_prereqs( $meta, 'recommends' );
        if ( %{$recommends} ) {

            $self->write_para(
                'This distribution recommends the following modules:');

            $self->_write_modules($recommends);

        }

    }

    $self->requires_run(1);
}

sub _get_prereqs {
    my ( $self, $meta, $key ) = @_;

    my %prereqs;
    foreach my $type ( values %{ $meta->prereqs } ) {

        # TODO: max version
        $prereqs{$_} = $type->{$key}->{$_} for ( keys %{ $type->{$key} } );
    }
    my $perl = delete $prereqs{perl};
    if ( $self->requires_omit_core && $perl ) {
        foreach ( keys %prereqs ) {
            delete $prereqs{$_}
              if Module::CoreList->first_release($_)
              && version->parse( Module::CoreList->first_release($_) ) <=
              version->parse($perl);
        }
    }
    return ( \%prereqs, $perl );
}

sub _write_modules {
    my ( $self, $prereqs ) = @_;
    $self->write_over(4);
    foreach my $module ( sort { lc($a) cmp lc($b) } keys %{$prereqs} ) {
        my $version = $prereqs->{$module};
        my $text = $version ? " (version ${version})" : '';
        $self->write_item( sprintf( '* L<%s>', $module ) . $text );
    }
    $self->write_back;
}

use namespace::autoclean;

1;
