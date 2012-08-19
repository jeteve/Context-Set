package Context::Union;
use Moose;

extends qw/Context/;

has 'contexts' => ( is => 'ro' , isa => 'ArrayRef[Context]' , required => 1);

=head2 name

Dies all the time. Using name makes no sense on a Context::Union

=cut

sub name{
  my ($self) = @_;
  confess("It doesnt make sense to call name on $self");
}

=head1 NAME

Context::Union - A union of Contexts.

=cut

=head2 fullname

See superclass.

=cut

sub fullname{
  my ($self) = @_;
  return 'union('.join(',', map{ $_->fullname() } @{$self->contexts} ).')';
}

=head2 has_property

See superclass Context.

=cut

sub has_property{
  my ($self, $prop_name) = @_;
  if( exists $self->properties()->{$prop_name} ){
    return 1;
  }
  ## Try to hit the property in the contexts.
  foreach my $context  ( @{$self->contexts()} ){
    if( $context->has_property($prop_name) ){
      return 1;
    }
  }
  ## No hit, that's a no
  return 0;
}


=head2 get_property

See Super Class.

=cut

sub get_property{
  my ($self, $prop_name) = @_;
  if( exists $self->properties()->{$prop_name} ){
    return $self->properties()->{$prop_name};
  }

  ## Make a fist loop through the lower level properties only of
  ## the contexts.
  foreach my $context ( @{$self->contexts()} ){
    if( exists $context->properties()->{$prop_name} ){
      return $context->properties()->{$prop_name};
    }
  }

  ## No direct properties found, try to find
  ## properties in general.
  ## This will try to go up each context if necessary
  foreach my $context ( @{$self->contexts()} ){
    if( $context->has_property($prop_name) ){
      return $context->get_property($prop_name);
    }
  }
  confess("Cannot find property $prop_name anywhere in ".$self->fullname());
}

__PACKAGE__->meta->make_immutable();
1;
