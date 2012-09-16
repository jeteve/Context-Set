package Context::Storage::BlackHole;
use Moose;

=head1 NAME

Context::Storage::BlackHole - A Storage that doesnt do anything.

=cut

extends qw/Context::Storage/;


=head2 populate_context

See super class L<Context::Storage>

=cut

sub populate_context{}

=head2 set_context_property

See super class L<Context::Storage>

=cut

sub set_context_property{
  my ($self, $context, $prop , $v , $after) = @_;
  return &{$after}();
}

__PACKAGE__->meta->make_immutable();
1;
