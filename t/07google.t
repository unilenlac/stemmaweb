use warnings;
use strict;

use FindBin;
use lib ("$FindBin::Bin/lib");

use stemmaweb::Test::Common;

use stemmaweb;
use LWP::Protocol::PSGI;
use Test::WWW::Mechanize;

use Test::More;
use HTML::TreeBuilder;
use Data::Dumper;

use stemmaweb::Test::DB;

my $dir = stemmaweb::Test::DB->new_db;

# NOTE: this test uses Text::Tradition::Directory
# to check user accounts really have been created.
# It'll need to be changed once that is replaced...

my $scope = $dir->new_scope;

LWP::Protocol::PSGI->register(stemmaweb->psgi_app);

my $ua = Test::WWW::Mechanize->new;

$ua->get_ok('http://localhost/login');

# Creating an openID user.

local *Catalyst::Authentication::Credential::OpenID::authenticate = sub {
    my ( $self, $c, $realm, $authinfo ) = @_;

    return $realm->find_user({ url => 'https://www.google.com/accounts/o8/id' }, $c);
};

ok !$dir->find_user({ url => 'https://www.google.com/accounts/o8/id' }), 'No such user, yet.';

$ua->submit_form(
    form_number => 2,
    fields => {
        openid_identifier => 'https://www.google.com/accounts/o8/id',
    },
);

$ua->content_contains('You have logged in.', 'Openid login works');

$ua->get('/');

$ua->content_contains('Hello! https://www.google.com/accounts/o8/id!', 'We are logged in.');

ok $dir->find_user({ url => 'https://www.google.com/accounts/o8/id' }), 'The user is now there.';
$ua->get('/logout');

# Converting to Google ID.

local *stemmaweb::Authentication::Credential::Google::authenticate = sub {
    my ( $self, $c, $realm, $authinfo ) = @_;

    return $realm->find_user({
            openid_id => 'https://www.google.com/accounts/o8/id',
            sub        => 42,
        }, $c);
};
$ua->get_ok('http://localhost/login');

$ua->submit_form(
    form_number => 1,
    fields => {
        id_token => 'something',
        email    => 'email@example.org',
    },
);

$ua->content_contains('You have logged in.', 'G+ login works');

$ua->get('/');

$ua->content_contains('Hello! 42!', 'We are logged in.');


my $ouser =$dir->find_user({ url => 'https://www.google.com/accounts/o8/id' });

diag $ouser->id . "\n\n\n";


ok $dir->find_user({ sub => 42, openid_id => 'https://www.google.com/accounts/o8/id' }), 'The G+ user is there.';


$ua->get('/logout');

$ua->get_ok('http://localhost/login');

$ua->submit_form(
    form_number => 1,
    fields => {
        id_token => 'something',
        email   => 'email@example.org',
    },
);

$ua->content_contains('You have logged in.', 'We can now log in to our created user');

$ua->get('/');

$ua->content_contains('Hello! 42!', 'We are logged in.');

done_testing;