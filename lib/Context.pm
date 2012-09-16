package Context;

our $VERSION = '0.01';

use Moose;

=head1 NAME

Context - A preference manager.

=head1 INTRODUCTION

Context is a preference manager that aims at solving the problem of storing configuration properties accross
an ever growing collection of contexts that often characterises enterprise systems.

For instance, you might want to have a 'page colour' setting that is global to your system,
but allow users to choose their own if they want.

Additionally, you might want to allow your users to specifically define a page color when
they view a specific 'list of stuff' in your system. Or allow the system to specify a page color
for all lists, or a specific one to certain lists, but still allowing users to override that.

Multiplication of preferences and management of their priorities can cause a lot of confusion
and headaches. This module is an attempt to help you to keep those things tidy and in control.

=head1 SYNOPSIS

To use Context, the best way is probably to use a Context::Manager that will
keep your contexts tidy for you.

  my $cm = Context::Manager->new();
  $cm->universe()->set_property('page.colour' , 'blue');

  my $users = $cm->restrict('users');
  $users->set_property('page.colour', 'green');

  my $user1 = $cm->restrict('users' , 1);
  $user1->set_property('page.colour' , 'red');


  $user1->get_property('page.colour'); # red

  my $user2 = $cm->restrict('users' , 2);
  $user2->get_property('page.colour') ; # green

  my $lists = $cm->restrict('lists');
  my $list1 = $cm->restrict->($lists, 1);

  my $u1l1 = $cm->unite($user1, list1);
  $u1l1->set_property('page.colour', 'purple');

  $u1l1->get_property('page.colour'); # purple

  my $u1l2 = $cm->unite($user1 , $cm->restrict('lists' , 2));
  $u1l2->get_property('page.colour') ; # red

=head1 VERSION

Version 0.01

=cut

has 'name' => ( is => 'ro', isa => 'Str', default => 'UNIVERSE' );
has 'properties' => ( is => 'rw' , isa => 'HashRef' , required => 1 , default => sub{ {}; } );


=head2 fullname

Returns the fully qualified name of this context. The fullname of a context identifies the context
in the UNIVERSE in a unique manner.

=cut

sub fullname{
  my ($self) = @_;
  return $self->name();
}

=head2 restrict

Produces a new Context::Restriction of this one.

Usage:

  ## Restrict to all users.
  my $context = $this->restrict('users');

  ## Further restriction to user 1
  $context = $context->restrict('1');

=cut

sub restrict{
  my ($self, $restriction_name) = @_;
  unless( $restriction_name ){
    confess("Missing restriction_name");
  }
  ## Avoid circular dependencies.
  require Context::Restriction;
  return Context::Restriction->new({ name => $restriction_name,
                                     restricted => $self });
}

=head2 unite

Returns the Context::Union of this and the other context.

usage:

  my $u = $this->unite($other_context);

=cut

sub unite{
  my ($self, $other) = @_;
  unless( $other && $other->isa('Context') ){
    confess("Missing other Context in unite");
  }
  require Context::Union;
  return Context::Union->new({ contexts => [ $self, $other ] });
}

=head2 set_property

Sets the given property to the given value. Never dies.

Usage:

  $this->set_property('pi' , 3.14159 );
  $this->set_property('fibo', [ 1, 2, 3, 5, 8, 12, 20 ]);


=cut

sub set_property{
  my ($self, $prop_name, $value) = @_;
  unless( defined $prop_name ){
    confess("prop_name has to be a defined value");
  }
  $self->properties()->{$prop_name} = $value;
}

=head2 get_property

Gets the property that goes by the given name. Dies if no property with the given name can be found.

my $pi = $this->get_property('pi');

=cut

sub get_property{
  my ($self, $prop_name) = @_;
  unless( $self->has_property($prop_name) ){
    confess("No property named $prop_name in ".$self->name());
  }
  return $self->properties()->{$prop_name};
}

=head2 has_property

Returns true if there is a property of this name in this context.

Usage:

 if( $this->has_property('pi') ){
    ...
 }

=cut

sub has_property{
  my ($self, $prop_name) = @_;
  return exists $self->properties()->{$prop_name};
}

=head1 AUTHOR

Jerome Eteve, C<< <jerome.eteve at gmail.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-context at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Context>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Context


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Context>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Context>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Context>

=item * Search CPAN

L<http://search.cpan.org/dist/Context/>

=back

=head1 LICENSE AND COPYRIGHT

Copyright 2012 Jerome Eteve.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut

__PACKAGE__->meta->make_immutable();
1;
