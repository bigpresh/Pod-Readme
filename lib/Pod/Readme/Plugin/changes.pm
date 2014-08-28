package Pod::Readme::Plugin::changes;

use Moose::Role;
use CPAN::Changes;

=head1 NAME

Pod::Readme::Plugin::changes - include latest Changes in README

=head1 SYNOPSIS

  =pod

  =for readme plugin changes

  =for readme changes

=head1 DESCRIPTION

This is a plugin for L<Pod::Readme> that includes the latest release
of a F<Changes> file that conforms to the L<CPAN::Changes::Spec>.

=cut

has 'changes_file' => (
   is      => 'rw',
   isa     => 'Str',
   default => 'Changes',
);

has 'changes_title' => (
    is      => 'rw',
    isa     => 'Str',
    default => 'CHANGES IN THIS RELEASE',
);

sub pod_readme_changes {
    my ($self, $file) = @_;

    $file //= $self->changes_file;

    my $changes = CPAN::Changes->load($file);
    my $latest = ($changes->releases)[-1];

    my $element = $self->_pop_element;

    $self->start_head1();
    $self->handle_text($self->changes_title . "\n\n");
    $self->end_head1();

    my $text = $latest->serialize;
    $text =~ s/\n+$//g;

    $self->start_Verbatim();
    $self->handle_text($text);
    $self->end_Verbatim();

    $self->_push_element($element);
}

sub _indent_changes {
}

1;
