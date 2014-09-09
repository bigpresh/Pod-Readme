package Pod::Readme::Plugin;

use v5.10.1;

use Moose::Role;

use Hash::Util qw/ lock_keys /;
use Try::Tiny;

=head1 NAME

Pod::Readme::Plugin - plugin role for Pod::Readme

=head1 DESCRIPTION

L<Pod::Readme> v1.0 and later supports plugins that extend the
capabilities of the module.

=head1 ATTRIBUTES

=head2 c<verbatim_indent>

The number of columns to indent a verbatim paragraph.

=cut

has verbatim_indent => (
    is      => 'ro',
    isa     => 'Int',
    default => 2,       # TODO: a minimum of 2
);

=head1 METHODS

=cut

sub _parse_arguments {
    my ( $self, $line ) = @_;
    my @args = ();

    my $i = 0;
    my $prev;
    my $in_quote = '';
    my $arg_buff = '';
    while ( $i < length($line) ) {

        my $curr = substr( $line, $i, 1 );
        if ( $curr !~ m/\s/ || $in_quote ) {
            $arg_buff .= $curr;
            if ( $curr =~ /["']/ && $prev ne "\\" ) {
                $in_quote = ( $curr eq $in_quote ) ? '' : $curr;
            }
        } elsif ( $arg_buff ne '' ) {
            push @args, $arg_buff;
            $arg_buff = '';
        }
        $prev = $curr;
        $i++;
    }

    if ( $arg_buff ne '' ) {
        push @args, $arg_buff;
    }

    return @args;
}

=head2 C<parse_cmd_args>

  $self->parse_cmd_args( \@allowed_keys, @args);

TODO

=cut

sub parse_cmd_args {
    my ( $self, $allowed, @args ) = @_;

    my ( $key, $val, %res );
    while ( my $arg = shift @args ) {

        state $eq = qr/=/;

        if ( $arg =~ $eq ) {
            ( $key, $val ) = split $eq, $arg;

            # TODO - better way to remove surrounding quotes
            if ( ( $val =~ /^(['"])(.*)(['"])$/ ) && ( $1 eq $3 ) ) {
                $val = $2 // '';
            }

        } else {
            $val = 1;
            if ( $arg =~ /^no[_-](\w+(?:[-_]\w+)*)$/ ) {
                $key = $1;
                $val = 0;
            } else {
                $key = $arg;
            }
        }

        $res{$key} = $val;
    }

    if ($allowed) {
        try {
            lock_keys( %res, @{$allowed} );
        }
        catch {
            if (/Hash has key '(.+)' which is not in the new key set/) {
                die sprintf( "Invalid argument key '\%s'\n", $1 );
            } else {
                die "Unknown error checking argument keys\n";
            }
        };
    }

    return \%res;
}

=head2 C<write_verbatim>

  $self->write_verbatim($text);

A utility method to write verbatim text, indented by
L</verbatim_indent>.

=cut

sub write_verbatim {
    my ( $self, $text ) = @_;

    my $indent = ' ' x ( $self->verbatim_indent );
    $text =~ s/^/${indent}/mg;
    $text =~ s/([^\n])\n?$/$1\n\n/;

    $self->write($text);
}

=begin :internal

=head2 C<_write_cmd>

  $self->_write_cmd('=head1 SECTION');

An internal utility method to write a command line.

=end :internal

=cut

sub _write_cmd {
    my ( $self, $text ) = @_;
    $text =~ s/([^\n])\n?$/$1\n\n/;

    $self->write($text);
}

=head2 C<write_para>

  $self->write_para('This is a paragraph');

Utility method to write a POD paragraph.

=cut

sub write_para {
    my ( $self, $text ) = @_;
    $text //= '';
    $self->write( $text . "\n\n" );
}

=head2 C<write_head1>

=head2 C<write_head2>

=head2 C<write_head3>

=head2 C<write_head4>

=head2 C<write_over>

=head2 C<write_item>

=head2 C<write_back>

=head2 C<write_begin>

=head2 C<write_end>

=head2 C<write_for>

=head2 C<write_encoding>

=head2 C<write_cut>

=head2 C<write_pod>

  $self->write_head1($text);

Utility methods to write POD specific commands to the C<output_file>.

These methods ensure the POD commands have extra newlines for
compatability with older POD parsers.

=cut

{
    my $meta = __PACKAGE__->meta;
    foreach my $cmd (
        qw/ head1 head2 head3 head4
        over item begin end for encoding /
        )
    {
        $meta->add_method(
            "write_${cmd}" => sub {
                my ( $self, $text ) = @_;
                $text //= '';
                $self->_write_cmd( '=' . $cmd . ' ' . $text );
            }
        );
    }

    foreach my $cmd (qw/ pod back cut  /) {
        $meta->add_method(
            "write_${cmd}" => sub {
                my ($self) = @_;
                $self->_write_cmd( '=' . $cmd );
            }
        );
    }

}

=head1 WRITING PLUGINS

Writing plugins is straightforward.  For example,

  package Pod::Readme::Plugin::myplugin;

  use Moose::Role;

  sub cmd_myplugin {
      my ($self, @args) = @_;
      ...
  }

When L<Pod::Readme> encounters POD with

  =for readme plugin myplugin arg1 arg2

the plugin role will be loaded, and the C<cmd_myplugin> method will be
run.

Note that you do not need to specify a C<cmd_myplugin> method.

Any method prefixed with "cmd_" will be a command that can be called
using the C<=for readme command> syntax.

A plugin parses arguments using the L</parse_cmd_arguments> method and
writes output using the write methods noted above.

=cut

use namespace::autoclean;

1;
