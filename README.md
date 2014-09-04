# NAME

Pod::Readme - generate README files from POD

# SYNOPSIS

TODO

# DESCRIPTION

This module filters POD to generate a `README` file.

# VERSION

v1.0.0\_01

# REQUIREMENTS

This distribution requires Perl v5.10.1.

This distribution requires the following modules:

- [CPAN::Changes](https://metacpan.org/pod/CPAN::Changes)
- [CPAN::Meta](https://metacpan.org/pod/CPAN::Meta)
- [File::Slurp](https://metacpan.org/pod/File::Slurp)
- [Moose](https://metacpan.org/pod/Moose)
- [MooseX::Object::Pluggable](https://metacpan.org/pod/MooseX::Object::Pluggable)
- [MooseX::Types::IO](https://metacpan.org/pod/MooseX::Types::IO)
- [MooseX::Types::Path::Class](https://metacpan.org/pod/MooseX::Types::Path::Class)
- [Path::Class](https://metacpan.org/pod/Path::Class)
- [Test::Most](https://metacpan.org/pod/Test::Most)
- [namespace::autoclean](https://metacpan.org/pod/namespace::autoclean)

# RECENT CHANGES

## Documentation

- Changes rewritten to conform to CPAN::Changes::Spec.
- README is now in markdown format.

## Incompatabilities

- Major rewrite, using modern Perl v5.10.1.
- This module is no longer a subclass of a POD parsing module. Instead, it is a simple POD filter.
- The "=for readme include" directive is no longer supported.

## New Features

- Added support for plugins.
- Added a "changes" plugin for parsing Changes files.
- Added a "version" plugin for including the current version.
- Added a "requires" plugin for listing module requirements.

## Other Changes

- Switched to semantic versioning.
- Added MANIFEST.SKIP to distribution.
- QA tests are no longer part of the distribution.
- Makefile.PL uses Module::Install.

See the `Changes` file for a longer revision history.

# SEE ALSO

See [perlpod](https://metacpan.org/pod/perlpod), [perlpodspec](https://metacpan.org/pod/perlpodspec) and [podlators](https://metacpan.org/pod/podlators).

# AUTHOR

Originally by Robert Rothenberg <rrwo at cpan.org>

Now maintained by David Precious <davidp@preshweb.co.uk>

## Suggestions, Bug Reporting and Contributing

This module is developed on GitHub at:

http://github.com/bigpresh/Pod-Readme

# LICENSE

Copyright (c) 2005-2014 Robert Rothenberg. All rights reserved.
This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.
