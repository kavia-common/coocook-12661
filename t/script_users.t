use Test2::V0;

use Coocook::Script::Users;
use DateTime::Format::SQLite;

use lib 't/lib';
use Test::Coocook;    # makes Coocook::Script::Users not read real config files

ok my $script = Coocook::Script::Users->new();

like dies { Coocook::Script::Users->new( discard => 1, email_verified => undef )->run() },
  qr/discard/, "rejects discard=1 and email_verified=''";

like dies { Coocook::Script::Users->new( discard => 1, email_verified => 1 )->run() },
  qr/discard/, "rejects discard=1 and email_verified=1";

like dies { Coocook::Script::Users->new( discard => 0, blacklist => 1 )->run() },
  qr/blacklist/, "rejects blacklist=1 unless discard=1";

subtest _parse_created => sub {
    my $now = DateTime::Format::SQLite->parse_datetime('2000-01-01 12:34:56');

    like dies { $script->_parse_created( "foobar", $now ) }, qr/invalid/i;

    my @tests = (
        [ undef() => undef ],
        [ '+1d'   => { created => { '<=', '1999-12-31 12:34:56' } } ],
        [ '-1w'   => { created => { '>=', '1999-12-25 12:34:56' } } ],
        [ '+1m'   => { created => { '<=', '1999-12-01 12:34:56' } } ],
        [ '-1y'   => { created => { '>=', '1999-01-01 12:34:56' } } ],
    );

    for (@tests) {
        my ( $input => $expected ) = @$_;

        is $script->_parse_created( $input, $now ) => $expected, $input;
    }
};

done_testing;
