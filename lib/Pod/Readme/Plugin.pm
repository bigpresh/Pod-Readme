package Pod::Readme::Plugin;

use v5.10.1;

use Moose::Role;

use Hash::Util qw/ lock_keys /;
use Try::Tiny;

# TODO: docs on how to write plugins here


sub _parse_arguments {
    my ( $self, $line) = @_;
    my @args = ();

    my $i = 0;
    my $prev;
    my $in_quote = '';
    my $arg_buff = '';
    while ($i<length($line)) {

        my $curr = substr($line, $i, 1);
        if ($curr !~ m/\s/ || $in_quote) {
            $arg_buff .= $curr;
            if ($curr =~ /["']/ && $prev ne "\\") {
              $in_quote = ($curr eq $in_quote) ? '' : $curr;
            }
        } elsif ($arg_buff ne '') {
            push @args, $arg_buff;
            $arg_buff = '';
        }
        $prev = $curr;
        $i++;
    }

    if ($arg_buff ne '') {
      push @args, $arg_buff
    }

    return @args;
}

sub parse_cmd_args {
    my ($self, $allowed, @args) = @_;

    my ($key, $val, %res);
    while (my $arg = shift @args) {

        state $eq = qr/=/;

        if ($arg =~ $eq) {
            ($key, $val) = split $eq, $arg;

            # TODO - better way to remove surrounding quotes
            if (($val =~ /^(['"])(.*)(['"])$/) && ($1 eq $3)) {
                $val = $2 // '';
            }

        } else {
            $val = 1;
            if ($arg =~ /^no[_-](\w+(?:[-_]\w+)*)$/) {
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
            lock_keys(%res, @{$allowed});
        } catch {
            if (/Hash has key '(.+)' which is not in the new key set/) {
                die sprintf( "Invalid argument key '\%s' at input line \%d\n",
                             $1, $self->_line_no );
            } else {
                die sprintf( "Unknown error at input line \%d\n",
                             $self->_line_no );
            }
        };
    }

    return \%res;
}

sub write_verbatim {
    my ($self, $text) = @_;

    my $indent = ' ' x ($self->verbatim_indent);
    $text =~ s/^/${indent}/mg;
    $text =~ s/([^\n])\n?$/$1\n\n/;

    $self->write($text);
}

sub write_cmd {
    my ($self, $text) = @_;
    $text =~ s/([^\n])\n?$/$1\n\n/;

    $self->write($text);
}

sub write_para {
    my ($self, $text) = @_;
    $text //= '';
    $self->write($text . "\n\n");
}

{
    my $meta = __PACKAGE__->meta;
    foreach my $cmd (qw/ head1 head2 head3 head4
                         over item begin end for encoding /) {
        $meta->add_method(
            "write_${cmd}" => sub {
                my ($self, $text) = @_;
                $text //= '';
                $self->write_cmd('='. $cmd . ' ' . $text);
            });
    }

    foreach my $cmd (qw/ pod back cut  /) {
        $meta->add_method(
            "write_${cmd}" => sub {
                my ($self) = @_;
                $self->write_cmd('='. $cmd);
            });
    }

}


use namespace::autoclean;

1;
