package Context::Restriction;
use Moose;

extends qw/Context/;

has 'restricted' => ( is => 'ro' , isa => 'Context' , required => 1 , weak_ref => 1 );

=head1 NAME

Context::Restriction - A restriction of a Context.

=cut

1;
