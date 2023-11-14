package Coocook::View::JSON;

# ABSTRACT: view for Coocook to create JSON responses

use Moose;

use MooseX::NonMoose;
use namespace::autoclean;

extends 'Catalyst::View::JSON';

__PACKAGE__->meta->make_immutable;

__PACKAGE__->config( expose_stash => 'json_data' );

1;
