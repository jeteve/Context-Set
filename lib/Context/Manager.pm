package Context::Manager;
use Moose;

use Context;
use Context::Union;

has '_localidx' => ( is => 'ro' , isa => 'HashRef[ArrayRef[Context]]', default => sub{ {}; });
has '_fullidx' => ( is => 'ro' , isa => 'HashRef' , default => sub{ {}; } );

has 'universe' => ( is => 'ro' , isa => 'Context' , required => 1 ,
                    lazy_build => 1 );

=head1 NAME

Context::Manager - A manager for your Contexts

=head1 SYNOPSIS

my $cm = Context::Manager->new();

my $users = $cm->restrict('users');
$users->set_property('page.color' , 'blue');

my $user1 = $cm->restrict('users' , 1 );
$user1->set_property('page.color' , 'pink');

$user1->get_property('page.color'); # pink.
$cm->restrict('users' , 2)->get_property('page.color'); # blue

=cut

sub _build_universe{
  my ($self) = @_;

  my $universe = Context->new();
  return $self->manage($universe);
}


=head2 manage

Adds the given Context to this manager (in case it was built outside).

Note that if a context with an identical fullname is already there, it
will return it. This is to ensure the unicity of contexts within the manager.

Usage:

  $context = $cm->manage($context);

=cut

sub manage{
  my ($self , $context) = @_;

  if( my $there = $self->_fullidx()->{$context->fullname()} ){
    return $there;
  }

  if( my $localname = $context->name() ){
    $self->_localidx->{$localname} //= [];
    push @{$self->_localidx->{$localname}},  $context;
  }
  return $self->_fullidx->{$context->fullname()} = $context;
}

=head2 restrict

Builds a restriction of the universe or of the given context.

 Usage:

  my $users = $cm->restrict('users'); ## This restricts the UNIVERSE
  my $user1 = $cm->restrict($users, 1); ## This restricts the users.
  my $user1 = $cm->restrict('users' , 1); ## Same thing
  my $user1 = $cm->restruct('UNIVERSE/users' , 1); ## Same thing.

=cut

sub restrict{
  my ($self, $c1, $new_name) = @_;
  unless( $new_name ){
    unless( $c1 ){
      confess("Missing restriction name");
    }
    return $self->_restrict_context($self->universe(), $c1);
  }

  if( my $context = $self->find($c1) ){
    unless( $new_name ){
      confess("Missing restriction name");
    }
    return $self->_restrict_context($self->find($c1) , $new_name);
  }
  confess("Cannot find context '".( $c1 // 'UNDEFINED' )."' to restrict");
}

=head2 unite

Returns the union of the given Contexts. You need to give at least two contexts.

Contexts can be given by name or by references.

Usage:

  my $ctx = $this->unite('context1' , $context2);
  my $ctx = $this->unite($context1, 'context2', $context3);

=cut

sub unite{
  my ($self , @contexts ) = @_;
  unless( scalar(@contexts) >= 2 ){
    confess("You need to unite at least 2 Contexts");
  }

  @contexts = map{ $self->find($_) or die "Cannot find Context to unite for '$_'" } @contexts;
  return $self->manage(Context::Union->new({ contexts => \@contexts }));
}


sub _restrict_context{
  my ($self, $c1 , $new_name) = @_;
  return $self->manage($c1->restrict($new_name));
}

=head2 find

Finds one context by the given name (local or full). Returns undef if nothing is found.

If the name only match a local name and there's more that one Context with this name, the latest one will be returned.

Usage:

 if( my $context = $this->find('a_name') ){

 $this->find('UNIVERSE/name1/name2');

=cut

sub find{
  my ($self ,$name) = @_;

  if( ref($name) ){ return $name; }

  ## Case of fullname match
  if( my $c = $self->_fullidx()->{$name} ){ return $c;}

  ## Case of local name match.
  return $self->_localidx()->{$name}->[-1];
}


__PACKAGE__->meta->make_immutable();
1;