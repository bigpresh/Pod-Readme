# NAME

Pod::Readme - generate README files from POD

# SYNOPSIS

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

# DESCRIPTION

This module filters POD to generate a `README` file. It supports a
series of POD commands for specifying what is included or excluded
from the `README` file.

See the [Pod::Readme](https://metacpan.org/pod/Pod::Readme) documentation for more details on the POD
syntax that this module recognizes.

See [pod2readme](https://metacpan.org/pod/pod2readme) command-line usage.

# VERSION

v1.0.0\_01

# REQUIREMENTS

This distribution requires Perl v5.10.1.

This distribution requires the following modules:

- [CPAN::Changes](https://metacpan.org/pod/CPAN::Changes)
- [CPAN::Meta](https://metacpan.org/pod/CPAN::Meta)
- [Exporter::Lite](https://metacpan.org/pod/Exporter::Lite)
- [File::Slurp](https://metacpan.org/pod/File::Slurp)
- [Getopt::Long::Descriptive](https://metacpan.org/pod/Getopt::Long::Descriptive)
- [IPC::System::Simple](https://metacpan.org/pod/IPC::System::Simple)
- [Moose](https://metacpan.org/pod/Moose)
- [MooseX::Object::Pluggable](https://metacpan.org/pod/MooseX::Object::Pluggable)
- [MooseX::Types::IO](https://metacpan.org/pod/MooseX::Types::IO)
- [MooseX::Types::Path::Class](https://metacpan.org/pod/MooseX::Types::Path::Class)
- [namespace::autoclean](https://metacpan.org/pod/namespace::autoclean)
- [Path::Class](https://metacpan.org/pod/Path::Class)
- [Test::Most](https://metacpan.org/pod/Test::Most)
- [Try::Tiny](https://metacpan.org/pod/Try::Tiny)

# RECENT CHANGES

## Documentation

- Changes rewritten to conform to CPAN::Changes::Spec.
- README is now in Markdown format.

## Incompatabilities

- Major rewrite, using modern Perl v5.10.1.
- This module is no longer a subclass of a POD parsing module. Instead, it is a simple POD filter.

## New Features

- Added support for plugins.
- Added a "changes" plugin for parsing Changes files.
- Added a "version" plugin for including the current version.
- Added a "requires" plugin for listing module requirements.
- The pod2readme script has been rewritten to take a variety of options, and can generate Markdown, POD or HTML files.

## Other Changes

- Switched to semantic versioning.
- Added MANIFEST.SKIP to distribution.
- QA tests are no longer part of the distribution.
- Makefile.PL uses Module::Install.

See the `Changes` file for a longer revision history.

# CAVEATS

This module is intended to be used by module authors for their own
modules.  It is not recommended for generating `README` files from
arbitrary Perl modules from untrusted sources.

# SEE ALSO

See [perlpod](https://metacpan.org/pod/perlpod), [perlpodspec](https://metacpan.org/pod/perlpodspec) and [podlators](https://metacpan.org/pod/podlators).

# AUTHORS

The original version was by Robert Rothenberg <rrwo@cpan.org> until
2010, when maintenance was taken over by David Precious
<davidp@preshweb.co.uk>.

In 2014, Robert Rothenberg rewrote the module to use filtering instead
of subclassing a POD parser.

## Suggestions, Bug Reporting and Contributing

This module is developed on GitHub at
[http://github.com/bigpresh/Pod-Readme](http://github.com/bigpresh/Pod-Readme)

# LICENSE

Copyright (c) 2005-2014 Robert Rothenberg. All rights reserved.
This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.
