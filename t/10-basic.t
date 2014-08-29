use Test::Most;

my $class = 'Pod::Readme';

use_ok($class);

{
    ok my $p = $class->new(), 'new';

    my $out;

    $p->output_string( \$out );

    $p->parse_string_document(
        "=pod\n\nBefore\n\n=for readme stop \n\nInside\n\n=for readme start\n\nAfter"
    );

    ok $p->content_seen, 'content_seen';

    like $out, qr/\s+Before\n\s+After\n/, 'expected output';

    note $out;
}

{
    ok my $p = $class->new(), 'new';

    my $out;

    $p->output_string( \$out );

    $p->parse_string_document(
        "=pod\n\nBefore\n\n=begin :readme\n\nInside\n\n=end :readme \n\nAfter\n\n"
    );

    ok $p->content_seen, 'content_seen';

    like $out, qr/\s+Before\n\s+Inside\s+After\n/, 'expected output';

    note $out;
}

{
    ok my $p = $class->new(), 'new';

    my $out;

    $p->output_string( \$out );

    $p->parse_string_document(
        "=pod\n\nBefore\n\n=begin readme\n\nInside\n\n=end readme \n\nAfter\n\n"
    );

    ok $p->content_seen, 'content_seen';

    like $out, qr/\s+Before\n\s+Inside\s+After\n/, 'expected output';

    note $out;
}

{
    ok my $p = $class->new(), 'new';

    my $out;

    $p->output_string( \$out );

    $p->parse_string_document("=pod\n\nLink to L<thing>\n");

    ok $p->content_seen, 'content_seen';

    like $out, qr/\s+Link to thing\n/, 'expected output';

    note $out;

}

{
    ok my $p = $class->new(), 'new';

    my $out;

    $p->output_string( \$out );

    $p->parse_string_document("=pod\n\nLink to L<text|thing>\n");

    ok $p->content_seen, 'content_seen';

    like $out, qr/\s+Link to text\n/, 'expected output';

    note $out;

}

{
    ok my $p = $class->new(), 'new';

    my $out;

    $p->output_string( \$out );

    $p->parse_string_document("=pod\n\nLink to L<http://www.example.com>\n");

    ok $p->content_seen, 'content_seen';

    like $out, qr/\s+Link to http:\/\/www\.example\.com\n/, 'expected output';

    note $out;

}

{
    ok my $p = $class->new(), 'new';

    my $out;

    $p->output_string( \$out );

    $p->parse_string_document(
        "=pod\n\nLink to L<text|http://www.example.com>\n");

    ok $p->content_seen, 'content_seen';

    like $out, qr/\s+Link to text \<http:\/\/www\.example\.com\>\n/,
        'expected output';

    note $out;

}

{
    ok my $p = $class->new(), 'new';

    my $out;

    $p->output_string( \$out );

    $p->parse_string_document("=pod\n\n=for readme plugin changes\n");

    my $title = quotemeta( $p->changes_title );
    like $out, qr/$title/, 'has changes title';

    note $out;

}

{
    ok my $p = $class->new(), 'new';

    my $out;

    $p->output_string( \$out );

    $p->parse_string_document("=pod\n\n=for readme plugin version\n");

    my $title = quotemeta( $p->version_title );
    like $out, qr/$title/, 'has version title';

    note $out;

}

done_testing;
