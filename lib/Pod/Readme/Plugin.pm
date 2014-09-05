package Pod::Readme::Plugin;

use v5.10.1;

use Moose::Role;

# TODO: docs on how to write plugins here

sub parse_cmd_args {
    my ($self, @args) = @_;

    my ($key, $val, %res);
    while (my $arg = shift @args) {

        state $eq = qr/=/;

        if ($arg =~ $eq) {
            ($key, $val) = split $eq, $arg;

            # FIXME - better way to remove surrounding quotes
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
