#!/usr/bin/env perl
use strict;
use warnings;
use HTTP::Request::Common;
use JSON qw/ encode_json decode_json /;
use Test::More;
use HTTP::Response;
use LWP::UserAgent;

use Catalyst::Test 'stemmaweb';

# Verify controller exists and get configured API URL
my $sbridge_controller = stemmaweb->controller('Sbridge');
ok( $sbridge_controller, 'Sbridge controller is loaded' );
my $sbridge_url = $sbridge_controller->sbridge_url;

# Mock outgoing LWP requests in-memory
my $last_request; #Does Perl talk to s-bridge correctly?
my $mock_response;
no warnings 'redefine';
*LWP::UserAgent::request = sub {
    my ($self, $req) = @_;
    $last_request = $req; #Does the JS get the right answers from Perl?
    return $mock_response;
};

# 1. Test POST /sbridge/process_and_collate
$last_request = undef;
$mock_response = HTTP::Response->new(200, 'OK', ['Content-Type' => 'application/json'], '{"job_id":"job_123"}');
my $res1 = request POST '/sbridge/process_and_collate?normalization=lemma',
    'Content-Type' => 'application/json',
    'Content'      => '{"collection_url":"http://test"}';
is( $res1->code, 200, 'POST /process_and_collate returns 200' ); # verifies correct response to js browser
is( $last_request->uri->as_string, "$sbridge_url/dts/process-and-collate?normalization=lemma", 'Query parameters forwarded correctly' ); #intercepts outgoing message for s-bridge

# 2. Test GET /sbridge/jobs
$last_request = undef;
$mock_response = HTTP::Response->new(200, 'OK', ['Content-Type' => 'application/json'], '[]');
my $res2 = request GET '/sbridge/jobs?limit=5';
is( $res2->code, 200, 'GET /jobs returns 200' ); # to browser
is( $last_request->uri->as_string, "$sbridge_url/dts/jobs?limit=5", 'Jobs list query forwarded correctly' ); # to s-bridge

# 3. Test POST /sbridge/jobs/cancel/:job_id
$last_request = undef;
$mock_response = HTTP::Response->new(200, 'OK', ['Content-Type' => 'application/json'], '{"cancelled":true}');
my $res3 = request POST '/sbridge/jobs/cancel/job_xyz';
is( $res3->code, 200, 'POST /jobs/cancel/:job_id returns 200' );
is( $last_request->method, 'PUT', 'POST is correctly mapped to PUT' );
is( $last_request->uri->as_string, "$sbridge_url/dts/jobs/job_xyz/cancel", 'Correct cancellation endpoint targeted' );

done_testing();
