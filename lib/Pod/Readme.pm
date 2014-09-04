package Pod::Readme;

=head1 NAME

Pod::Readme - generate README files from POD

=head1 SYNOPSIS

TODO

=head1 DESCRIPTION

TODO

=for readme plugin version

=for readme plugin changes

=for readme stop

=head1 METHODS

See L<Pod::Simple::Methody> for the base methods that this module
uses.

This module adds methods of the form C<pod_readme_CMD>, which are
triggered by the POD directives

  =for readme CMD

=for readme start

=cut

use 5.10.1;

use Moose;
extends 'Pod::Readme::Filter';

use version 0.77; our $VERSION = version->declare('v1.0.0_01');

use namespace::autoclean;

1;

=head1 SEE ALSO

See L<perlpod>, L<perlpodspec> and L<podlators>.

=head1 AUTHOR

Originally by Robert Rothenberg <rrwo at cpan.org>

Now maintained by David Precious <davidp@preshweb.co.uk>

=head2 Suggestions, Bug Reporting and Contributing

This module is developed on GitHub at:

http://github.com/bigpresh/Pod-Readme


=head1 LICENSE

Copyright (c) 2005-2014 Robert Rothenberg. All rights reserved.
This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
