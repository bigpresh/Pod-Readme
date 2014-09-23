package Pod::Readme;

=head1 NAME

Pod::Readme - generate README files from POD

=for readme plugin version

=head1 SYNOPSIS

  =head1 NAME

  MyApp - my nifty app

  =for readme plugin version

  =head1 DESCRIPTION

  This is a nifty app.

  =begin :readme

  =for readme plugin requires

  =head1 INSTALLATION

  ...

  =end :readme

  =for readme stop

  =head1 METHODS

  ...

=head1 DESCRIPTION

This module filters POD to generate a F<README> file, by using POD
commands to specify what parts of included or excluded from the
F<README> file.

=begin :readme

See the L<Pod::Readme> documentation for more details on the POD
syntax that this module recognizes.

See L<pod2readme> for command-line usage.

=for readme plugin requires

=for readme plugin changes

=end :readme

=for readme stop

=head1 POD COMMANDS

=head2 C<=for readme stop>

Stop including the POD that follows in the F<README>.

=head2 C<=for readme start>

=head2 C<=for readme continue>

Start (or continue to) include the POD that follows in the F<README>.

Note that the C<start> command was added as a synonym in version
1.0.0.

=head2 C<=for readme include>

  =for readme include file="INSTALL" type="text"

Include a text or POD file in the F<README>.  It accepts the following
options:

=over

=item C<file>

Required. This is the file name to include.

=item C<type>

Can be "text" or "pod" (default).

=item C<start>

An optional regex of where to start including the file.

=item C<stop>

An optional regex of where to stop including the file.

=back

=head2 C<=for readme plugin>

Loads a plugin, e.g.

  =for readme plugin version

Note that specific plugins may add options, e.g.

  =for readme plugin changes title='CHANGES'

See L<Pod::Readme::Plugin> for more information.

=head2 C<=begin :readme>

=head2 C<=end :readme>

Specify a block of POD to include only in the F<README>.

You can also specify a block in another format:

  =begin readme text

  ...

  =end readme text

This will be translated into

  =begin text

  ...

  =end text

and will only be included in F<README> files of that format.

Note: earlier versions of this module suggested using

  =begin readme

  ...

  =end readme

While this version supports that syntax for backwards compatability,
it is not standard POD.

=cut

use v5.10.1;

use Moose;
extends 'Pod::Readme::Filter';

use Carp;
use IO qw/ File Handle /;
use Module::Load qw/ load /;
use MooseX::Types::IO 'IO';
use MooseX::Types::Path::Class;
use Path::Class;

use version 0.77; our $VERSION = version->declare('v1.0.0_02');

=head1 ATTRIBUTES

This module extends L<Pod::Readme::Filter> with the following
attributes:

=head2 C<translation_class>

The class used to translate the filtered POD into another format,
e.g. L<Pod::Simple::Text>.

If it is C<undef>, then there is no translation.

Only subclasses of L<Pod::Simple> are supported.

=cut

has translation_class => (
    is      => 'ro',
    isa     => 'Maybe[Str]',
    default => undef,
);

=head2 C<translate_to_fh>

The L<IO::Handle> to save the translated file to.

=cut

has translate_to_fh => (
    is      => 'ro',
    isa     => IO,
    lazy    => 1,
    coerce  => 1,
    default => sub {
        my ($self) = @_;
        if ( $self->translate_to_file ) {
            $self->translate_to_file->openw;
        } else {
            my $fh = IO::Handle->new;
            if ( $fh->fdopen( fileno(STDOUT), 'w' ) ) {
                return $fh;
            } else {
                croak "Cannot get a filehandle for STDOUT";
            }
        }
    },
);

=head2 C<translate_to_file>

The L<Path::Class::File> to save the translated file to. If omitted,
then it will be saved to C<STDOUT>.

=cut

has translate_to_file => (
    is       => 'ro',
    isa      => 'Path::Class::File',
    coerce   => 1,
    lazy     => 1,
    builder  => 'default_readme_file',
);

=head2 C<output_file>

The L<Pod::Readme::Filter> C<output_file> will default to a temporary
file.

=cut

has '+output_file' => (
    lazy => 1,
    default => sub {
        my $tmp_dir = dir( $ENV{TMP} || $ENV{TEMP} || '/tmp' );
        file( ($tmp_dir->tempfile( SUFFIX => '.pod', UNLINK => 1 ))[1] );
    },
);

around '_build_output_fh' => sub {
    my ($orig, $self) = @_;
    if (defined $self->translation_class) {
        $self->$orig();
    } else {
        $self->translate_to_fh;
    }
};

=head1 METHODS

This module extends L<Pod::Readme::Filter> with the following methods:

=head2 C<default_readme_file>

The default name of the F<README> file, which depends on the
L</translation_class>.

=cut

sub default_readme_file {
    my ($self) = @_;

    my $name = uc($self->target);

    state $extensions = {
        'Pod::Man'           => '.1',
        'Pod::Markdown'      => '.md',
        'Pod::Simple::HTML'  => '.html',
        'Pod::Simple::LaTeX' => '.tex',
        'Pod::Simple::RTF'   => '.rtf',
        'Pod::Simple::Text'  => '',
        'Pod::Simple::XHTML' => '.xhtml',
    };

    my $class = $self->translation_class;
    if (defined $class) {
        if (my $ext = $extensions->{$class}) {
            $name .= $ext;
        }
    } else {
        $name .= '.pod';
    }

    file($self->base_dir, $name);
}

=head2 C<translate_file>

This method runs translates the resulting POD from C<filter_file>.

=cut

sub translate_file {
    my ($self) = @_;

    if (my $class = $self->translation_class) {

        load $class;
        my $converter = $class->new()
            or croak "Cannot instantiate a ${class} object";

        if ($converter->isa('Pod::Simple')) {

            my $tmp_file = $self->output_file->stringify;

            close $self->output_fh
                or croak "Unable to close file ${tmp_file}";

            $converter->output_fh($self->translate_to_fh);
            $converter->parse_file( $tmp_file );

        } else {

            croak "Don't know how to translate POD using ${class}";

        }

    }
}

=head2 C<run>

This method runs C<filter_file> and then L</translate_file>.

=cut

around 'run' => sub {
    my ($orig, $self) = @_;
    $self->$orig();
    $self->translate_file();
};

use namespace::autoclean;

1;

=for readme start

=head1 CAVEATS

This module is intended to be used by module authors for their own
modules.  It is not recommended for generating F<README> files from
arbitrary Perl modules from untrusted sources.

=head1 SEE ALSO

See L<perlpod>, L<perlpodspec> and L<podlators>.

=head1 AUTHORS

The original version was by Robert Rothenberg <rrwo@cpan.org> until
2010, when maintenance was taken over by David Precious
<davidp@preshweb.co.uk>.

In 2014, Robert Rothenberg rewrote the module to use filtering instead
of subclassing a POD parser.

=head2 Suggestions, Bug Reporting and Contributing

This module is developed on GitHub at
L<http://github.com/bigpresh/Pod-Readme>

=head1 LICENSE

Copyright (c) 2005-2014 Robert Rothenberg. All rights reserved.
This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
