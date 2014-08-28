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

has 'changes_verbatim' => (
    is      => 'rw',
    isa     => 'Bool',
    default => 1,
);

sub pod_readme_changes {
    my ($self, $file) = @_;

    $file //= $self->changes_file;

    my $changes = CPAN::Changes->load($file);
    my $latest = ($changes->releases)[-1];

    my $element = $self->_pop_element;

    $self->start_head1();
    $self->handle_text($self->changes_title);
    $self->end_head1();

    if ($self->changes_verbatim) {

        my $text = $latest->serialize;
        $text =~ s/\s+$//g;

        $self->start_Verbatim();
        $self->handle_text($text);
        $self->end_Verbatim();

    } else {

        foreach my $group ($latest->groups) {

            if ($group ne '') {
                $self->start_head2();
                $self->handle_text($group);
                $self->end_head2();
            }

            $self->start_over_bullet();
            foreach my $items ($latest->get_group($group)->changes) {
                foreach my $item (@{$items}) {
                    $self->start_item_bullet();
                    $self->handle_text($item);
                    $self->end_item_bullet();
                }
            }
            $self->end_over_bullet();

        }

    }

    $self->_push_element($element);
}

sub _indent_changes {
}

1;
