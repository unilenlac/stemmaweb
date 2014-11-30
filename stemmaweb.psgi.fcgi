use strict;
use warnings;

use lib '/var/www/catalyst/stemmaweb/lib';
use stemmaweb;
my $app = stemmaweb->apply_default_middlewares(stemmaweb->psgi_app);
$app;
