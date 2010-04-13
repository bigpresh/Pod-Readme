#!/usr/bin/perl

use strict;

use Test::More;

my %L_ARGS = (
  'http://www.example.com/' => undef,
  'https://www.example.com/' => undef,
  'http://www.example.com/some/page?query=foo&bar=baz' => undef,
  'ftp://ftp.example.com/some/file'  => undef,
  # 'news://news.example.com/group.name' => undef,
  'svn://svn.cpan.org/foo/bar' => undef,
  'Some::Module'         => undef,
  'Some::Module/section' => 'Some::Module',
  'Module'               => undef,
  'Module/section'       => 'Module',
  '/Section'             => 'Section',
  'Text|Module'          => 'Text',
  'Text|Module/section'  => 'Text',
  'Text|http://www.cpan.org/' => 'Text',
  'Text|ftp://www.cpan.org/'  => 'Text',
  'Text|news://www.cpan.org/' => 'Text',
);

my @TYPES = qw( readme copying install hacking todo license );
my @INVALID = qw(
  test tests testing
  html xhtml xml docbook rtf man nroff dsr rno latex tex code
);

# These are methods supported by Pod::Text but not Pod::PlainText

my @METHODS = qw( cmd_head3 cmd_head4 );

plan tests => 2 + (19 * scalar(@TYPES)) + scalar(keys %L_ARGS) +
                  (2 * scalar(@INVALID)) + 
                  (1 * scalar(@METHODS));

use_ok("Pod::Readme", 0.06);

foreach my $type (@INVALID) {
  my $p;
  $@ = undef;
  eval { $p = Pod::Readme->new( readme_type => $type ); };
  ok($@, "new $type failed");
  ok(!defined $p, "undefined invalid type");
}

# TODO - test other document types than "readme"

foreach my $type (@TYPES) {
  my $p = Pod::Readme->new( readme_type => $type );
  ok(defined $p, "new $type");

  ok($p->{readme_type} eq $type, "readme_type");
  ok(!$p->{README_SKIP}, "README_SKIP");

  # TODO - test output method

  $p->cmd_for("$type stop");
  ok($p->{README_SKIP}, "$type stop");
  $p->cmd_for("$type continue");
  ok(!$p->{README_SKIP}, "$type continue");

  $p->cmd_for("$type stop");
  ok($p->{README_SKIP}, "$type stop");
  $p->cmd_for("$type");
  ok(!$p->{README_SKIP}, "$type");

  $p->cmd_for("$type stop");
  ok($p->{README_SKIP}, "$type stop");
  $p->cmd_begin("$type");
  ok(!$p->{README_SKIP}, "begin $type");
  $p->cmd_end("$type");

  $p->cmd_for("foobar stop");
  ok(!$p->{README_SKIP}, "foobar stop");
  $p->cmd_for("foobar continue");
  ok(!$p->{README_SKIP}, "foobar continue");
  $p->cmd_for("foobar stop");
  ok(!$p->{README_SKIP}, "foobar stop");
  $p->cmd_for("foobar");
  ok(!$p->{README_SKIP}, "foobar");

  $p->cmd_for("$type,foobar stop");
  ok($p->{README_SKIP}, "$type,foobar stop");
  $p->cmd_for("$type,foobar continue");
  ok(!$p->{README_SKIP}, "$type,foobar continue");

  $p->cmd_for("$type,foobar stop");
  ok($p->{README_SKIP}, "$type,foobar stop");
  $p->cmd_for("$type,foobar");
  ok(!$p->{README_SKIP}, "$type,foobar");

  $p->cmd_for("$type,foobar stop");
  ok($p->{README_SKIP}, "$type,foobar stop");
  $p->cmd_begin("$type,foobar");
  ok(!$p->{README_SKIP}, "begin $type,foobar");
  $p->cmd_end("$type,foobar");

}

# TODO - test for readme include

{
  my $p = Pod::Readme->new();
  ok(defined $p, "new");

  foreach my $arg (sort keys %L_ARGS) {
    my $exp = $L_ARGS{$arg} || $arg;
    my $r   = $p->seq_l($arg);
    ok($r eq $exp, "L<$arg>");
    # print STDERR "\x23 $r\n";
  };

}

{
  local $TODO = "unimplemented methods";
  my $p = Pod::Readme->new();
  foreach my $method (@METHODS) {
    ok($p->can($method), "method $method supported");
  }
}

