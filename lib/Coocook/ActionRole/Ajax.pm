package Coocook::ActionRole::Ajax;

# ABSTRACT: role for controller actions that respond with JSON and require a Session

use Moose::Role;
use namespace::autoclean;

before execute => sub {
    my ( $self, $controller, $c ) = @_;

    $c->stash( current_view => 'JSON' );
};

1;
