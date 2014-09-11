package Pod::Readme;

=head1 NAME

Pod::Readme - generate README files from POD

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

This module filters POD to generate a F<README> file. It supports a
series of POD commands for specifying what is included or excluded
from the F<README> file.

=for readme plugin version

=for readme plugin requires

=for readme plugin changes

=begin :readme

See the L<Pod::Readme> documentation for more details on the POD
syntax that this module recognizes.

See L<pod2readme> command-line usage.

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

=head C<=for readme include>

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

=head1 METHODS

See L<Pod::Readme::Filter> for a description of methods.

=for readme start

=cut

use v5.10.1;

use Moose;
extends 'Pod::Readme::Filter';

use version 0.77; our $VERSION = version->declare('v1.0.0_01');

use namespace::autoclean;

1;

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
