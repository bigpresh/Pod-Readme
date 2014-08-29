package Pod::Readme::Plugin::changes;

use Moose::Role;
use CPAN::Changes;

=head1 NAME

Pod::Readme::Plugin::changes - include latest Changes in README

=head1 SYNOPSIS

  =pod

  =for readme plugin changes

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
    default => 0,
);

sub pod_readme_changes {
    my ($self, $file) = @_;

    $file //= $self->changes_file;

    my $changes = CPAN::Changes->load($file);
    my $latest = ($changes->releases)[-1];

    my $element = $self->_pop_element;

    $self->_elem_wrap('head1', $self->changes_title);

    if ($self->changes_verbatim) {

        $self->_elem_wrap('Verbatim', $latest->serialize);

    } else {

        foreach my $group ($latest->groups) {

            $self->_elem_wrap('head2', $group)
                if ($group ne '');

            $self->start_over_bullet();
            foreach my $items ($latest->get_group($group)->changes) {
                foreach my $item (@{$items}) {
                    $self->_elem_wrap('item_bullet', $item);
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
