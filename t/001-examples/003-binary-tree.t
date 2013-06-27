#!perl

use strict;
use warnings;

use Test::More;
use Test::Fatal;

use mop;
use Scalar::Util qw[ isweak weaken ];

class BinaryTree {
    has $node;
    has $parent;
    has $left;
    has $right;

    submethod BUILD { weaken( $parent ) if $parent }

    method node ($n) {
        $node = $n if $n;
        $node;
    }

    method has_parent { defined $parent }
    method parent     { $parent }

    method left     { $left //= $class->new( parent => $self ) }
    method has_left { defined $left }

    method right     { $right //= $class->new( parent => $self ) }
    method has_right { defined $right }
}

{
    my $t = BinaryTree->new;
    ok($t->isa('BinaryTree'), '... this is a BinaryTree object');

    ok(!$t->has_parent, '... this tree has no parent');

    ok(!$t->has_left, '... left node has not been created yet');
    ok(!$t->has_right, '... right node has not been created yet');

    ok($t->left->isa('BinaryTree'), '... left is a BinaryTree object');
    ok($t->right->isa('BinaryTree'), '... right is a BinaryTree object');

    ok($t->has_left, '... left node has now been created');
    ok($t->has_right, '... right node has now been created');

    ok($t->left->has_parent, '... left has a parent');
    is($t->left->parent, $t, '... and it is us');
    #ok(isweak(${ $t->left->{'slots'}->{'$parent'} }), '... the value is weakened');

    ok($t->right->has_parent, '... right has a parent');
    is($t->right->parent, $t, '... and it is us');
    #ok(isweak(${ $t->right->{'slots'}->{'$parent'} }), '... the value is weakened');
}

class MyBinaryTree ( extends => 'BinaryTree' ) {}

{
    my $t = MyBinaryTree->new;
    ok($t->isa('MyBinaryTree'), '... this is a MyBinaryTree object');
    ok($t->isa('BinaryTree'), '... this is a BinaryTree object');

    ok(!$t->has_parent, '... this tree has no parent');

    ok(!$t->has_left, '... left node has not been created yet');
    ok(!$t->has_right, '... right node has not been created yet');

    # NOTE:
    # this next thing illustrates that $class is not
    # virtual, meaning that it fixed to be the class
    # it is defined in, and not the class of the 
    # invocant itself.
    # This deviates from the older prototype, but it
    # perhaps feels more correct and is similar to 
    # how __PACKAGE__ works.
    # - SL

    ok($t->left->isa('BinaryTree'), '... left is a BinaryTree object');
    ok($t->right->isa('BinaryTree'), '... right is a BinaryTree object');

    ok($t->has_left, '... left node has now been created');
    ok($t->has_right, '... right node has now been created');
}

done_testing;