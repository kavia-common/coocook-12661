package Coocook::Util;

# ABSTRACT: helper functions (not methods) for Coocook, independent from Catalyst or any class

use strict;
use warnings;

use feature 'fc';    # Perl v5.16

use Carp;

=head1 FUNCTIONS

=head2 url_name($name)

Returns a name with unsafe characters replaced by C<-> but B<not> foldcased.
Most useful for building new URLs.

=cut

sub url_name {
    my ($name) = @_;

    ( my $url_name = $name ) =~ s/\W+/-/g;

    return $url_name;
}

=head2 url_names_hashref($name)

Returns a hashref with C<url_name> and C<url_name_fc> keys
next to appropriate values. Useful for updating both rows in the database.

=cut

sub url_names_hashref {
    my ($name) = @_;

    ( my $url_name = $name ) =~ s/\W+/-/g;

    return {
        url_name    => $url_name,
        url_name_fc => fc($url_name),
    };
}

=head2 username_valid($username)

Returns a boolean value indicating whether string C<$username>
is a valid username or organization name.

=cut

sub username_valid {
    my $username = shift;

    defined $username
      or croak "username not defined";

    return $username =~ m/ \A [0-9a-zA-Z_]+ \z /x;
}

1;
