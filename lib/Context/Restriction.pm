package Context::Restriction;
use Moose;

extends qw/Context/;

has 'restricted' => ( is => 'ro' , isa => 'Context' , required => 1 , weak_ref => 1 );

=head1 NAME

Context::Restriction - A restriction of a Context.

=cut

=head2 fullname

See superclass.

=cut

sub fullname{
  my ($self) = @_;
  return $self->restricted()->fullname().'/'.$self->name();
}

=head2 has_property

See superclass Context.

=cut

sub has_property{
  my ($self, $prop_name) = @_;
  return exists $self->properties()->{$prop_name} || $self->restricted->has_property($prop_name);
}


=head2 get_property

See Super Class.

=cut

sub get_property{
  my ($self, $prop_name) = @_;
  if( exists $self->properties()->{$prop_name} ){
    return $self->properties()->{$prop_name};
  }
  return $self->restricted()->get_property($prop_name);
}

1;
