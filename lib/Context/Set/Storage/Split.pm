package Context::Set::Storage::Split;
use Moose;
extends qw/Context::Set::Storage/;

use Context::Set::Storage::Split::Rule;

=head1 NAME

Context::Set::Storage::Split - Split storage of Context::Set accross different L<Context::Set::Storage>'s

=head1 MANUAL

=cut


has 'rules' => ( is => 'ro', isa => 'ArrayRef[Context::Set::Storage::Split::Rule]', required => 1);



=head2 BUILDARGS

 See L<Moose>

 In moose, we override BUILDARGS, not new.

=cut

sub BUILDARGS{
  my ($class, $args) = @_;

  ## Replace rules by an array of real rules.
  my @new_rules = ();
  foreach my $rule ( @{ $args->{rules} // confess "Missing rules in args" } ){
    push @new_rules , Context::Set::Storage::Split::Rule->new($rule);
  }

  $args->{rules} = \@new_rules;
  return $args;
}

=head2 populate_context

See super class L<Context::Set::Storage>

=cut

sub populate_context{
  my ($self,$context) = @_;
  return $self->_matching_storage($context)->populate_context($context);
}

=head2 set_context_property

See superclass L<Context::Set::Storage>

=cut

sub set_context_property{
  my ($self, $context, $prop , $v , $after ) = @_;
  return $self->_matching_storage($context)->set_context_property($context,$prop,$v,$after);
}


sub _matching_storage{
  my ($self, $context) = @_;

  ## Scan the rules and return the first matching one.
  foreach my $rule ( @{$self->rules() } ){
    if( $rule->test->($context) ){
      return $rule->storage();
    }
  }
  confess("Could NOT find any matching rule for context ".$context->fullname());
}

__PACKAGE__->meta->make_immutable();
1;
