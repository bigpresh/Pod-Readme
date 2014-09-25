package Pod::Readme::Test::Kit;

use Test::Kit;

include 'strict';
include 'warnings';

include 'Test::More';
include 'Test::Deep';
include 'Test::Exception';

include 'Cwd';

include 'File::Temp' => {
    import => [qw/ tempfile /],
};

# TODO: will this still work on Windows?

include 'File::Compare' => {
    import => [qw/ compare_text /],
};

include 'Path::Class';

include 'Pod::Readme::Test';

1;
