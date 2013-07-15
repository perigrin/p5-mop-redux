package mop::method;

use v5.16;
use warnings;

use mop::util qw[ init_attribute_storage ];
use Scalar::Util 'weaken';

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

use parent 'mop::object';

init_attribute_storage(my %name);
init_attribute_storage(my %body);
init_attribute_storage(my %associated_class);

sub new {
    my $class = shift;
    my %args  = @_;
    my $self = $class->SUPER::new;
    $name{ $self } = \($args{'name'});
    $body{ $self } = \($args{'body'});
    $self;
}

sub name { ${ $name{ $_[0] } } }
sub body { ${ $body{ $_[0] } } }
sub associated_class { ${ $associated_class{ $_[0] } } }
sub set_associated_class {
    $associated_class{ $_[0] } = \$_[1];
    weaken(${ $associated_class{ $_[0] } });
}

sub execute {
    my ($self, $invocant, $args) = @_;
    $self->body->( $invocant, @$args );
}

our $METACLASS;

sub __INIT_METACLASS__ {
    return $METACLASS if defined $METACLASS;
    require mop::class;
    $METACLASS = mop::class->new(
        name       => 'mop::method',
        version    => $VERSION,
        authority  => $AUTHORITY,
        superclass => 'mop::object'
    );

    $METACLASS->add_attribute(mop::attribute->new(
        name    => '$name',
        storage => \%name
    ));

    $METACLASS->add_attribute(mop::attribute->new(
        name    => '$body',
        storage => \%body
    ));

    $METACLASS->add_attribute(mop::attribute->new(
        name    => '$associated_class',
        storage => \%associated_class
    ));

    # NOTE:
    # we do not include the new method, because
    # we want all meta-extensions to use the one
    # from mop::object.
    # - SL
    $METACLASS->add_method( mop::method->new( name => 'name',                 body => \&name                 ) );
    $METACLASS->add_method( mop::method->new( name => 'body',                 body => \&body                 ) );
    $METACLASS->add_method( mop::method->new( name => 'associated_class',     body => \&associated_class     ) );
    $METACLASS->add_method( mop::method->new( name => 'set_associated_class', body => \&set_associated_class ) );

    $METACLASS->add_method( mop::method->new( name => 'execute', body => \&execute ) );

    $METACLASS;
}

1;

__END__

=pod

=head1 NAME

mop::method

=head1 DESCRIPTION

=head1 BUGS

All complex software has bugs lurking in it, and this module is no
exception. If you find a bug please either email me, or add the bug
to cpan-RT.

=head1 AUTHOR

Stevan Little <stevan@iinteractive.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Infinity Interactive.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut





