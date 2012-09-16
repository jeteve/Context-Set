package Context::Role::Stored;
use Moose::Role;

=head1 NAME

Context::Role::Stored - A stored context holds a Context::Storage and uses it.

=cut

has 'storage' => ( is => 'rw' , isa => 'Context::Storage', weak_ref => 1  );

around 'set_property' => sub{
  my ($orig, $self, $prop , $v ) = @_;

  return $self->storage->set_context_property($self,
                                              $prop,
                                              $v,
                                              sub{
                                                $self->$orig($prop,$v);
                                              });
};

1;
