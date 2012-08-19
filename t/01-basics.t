#!perl -T
use strict;
use warnings;
use Test::More;
use Test::Fatal qw/dies_ok lives_ok/;
use Context;


my $universe = Context->new();
cmp_ok( $universe->name() , 'eq' , 'UNIVERSE'  , "Ok good universe name");

$universe->set_property('pi' , 3.14159 );
$universe->set_property('null');

ok( $universe->has_property('pi') , "Ok universe has property pi");
ok( $universe->has_property('null') , "Ok universe has property null");
ok( ! defined $universe->get_property('null') , "The value of property null is undef");
cmp_ok( $universe->get_property('pi') , '==' , 3.14159, "Ok can get pi");

ok( ! $universe->has_property('somethingelse') , "somethingelse is not there");
dies_ok { $universe->get_property('somethingelse') } "Fails to get a property that is not there";

my $users_context = $universe->restrict('users');

cmp_ok( $users_context->name() , 'eq' , 'users' , "Ok name is good");
cmp_ok( $users_context->restricted()->name() , 'eq' , $universe->name() , "Ok restricted right context");

my $user1_ctx = $users_context->restrict('1');
cmp_ok( $user1_ctx->name() , 'eq' , '1' , "Ok good name");

done_testing();
