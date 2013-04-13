package Context::Set::Role::Stored;
use Moose::Role;

=head1 NAME

Context::Set::Role::Stored - A stored context holds a Context::Set::Storage and uses it.

=cut

has 'storage' => ( is => 'rw' , isa => 'Context::Set::Storage', weak_ref => 1  );

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
