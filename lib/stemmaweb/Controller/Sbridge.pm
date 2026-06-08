package stemmaweb::Controller::Sbridge;
use Moose;
use namespace::autoclean;
use Encode qw/ decode_utf8 /;
use JSON;
use LWP::UserAgent;
use TryCatch;
use URI;

#Begin is a Moose keywords/method and the Sbridge package inherits from Catalyst::Controller
BEGIN { extends 'Catalyst::Controller' }

#has is the way to declare a class
has sbridge_url => (
    is      => 'ro', #read only
    isa     => 'Str', #type safety, is a string
    default => 'http://localhost:8000', #Fallback server
);

=head1 NAME

stemmaweb::Controller::Sbridge - Catalyst Controller for s-bridge

=head1 DESCRIPTION

Catalyst Controller to interface with the s-bridge NLP pipeline.

=head1 METHODS

=head2 process_and_collate

 POST /sbridge/process_and_collate
 Content-Type: application/json

 Forwards the request to the s-bridge NLP server's /dts/process-and-collate endpoint.
 Expected JSON body: { "collection_url": "...", "ref": "..." }

=cut

# :Local matches the action name, exposing this at /sbridge/process_and_collate
# :Args(0) specifies that the action accepts no extra path parameters
sub process_and_collate :Local :Args(0) {
    # In Perl OO, the first arg is the class instance ($self) and the second is the Catalyst Context ($c)
    my ($self, $c) = @_;

    if ($c->request->method eq 'POST') {
        my $payload;
        try {
            # Parse the incoming JSON request
            my $body = $c->request->body;
            my $body_content = '';
            
            # Catalyst automatically writes larger POST request bodies to a File::Temp file on disk.
            # We check if $body is a File::Temp reference and read it, or handle it as a direct string.
            if (ref($body) eq 'File::Temp') {
                open(my $fh, '<', $body) or die "Cannot open temp file";
                local $/; # Enable slurp mode to read the whole file at once
                $body_content = <$fh>;
                close $fh;
            } else {
                $body_content = $body;
            }
            $payload = from_json($body_content);
        } catch {
            $c->response->status(400);
            $c->stash->{'result'} = { error => "Invalid JSON payload: $@" };
            $c->forward('View::JSON');
            return;
        }

        # Prepare LWP UserAgent (Perl's standard HTTP Client)
        my $ua = LWP::UserAgent->new();
        my $url = $self->sbridge_url . '/dts/process-and-collate';

        # Forward any query parameters (like ?normalization=...) to s-bridge
        my $req_uri = URI->new($url);
        my %query_params = %{ $c->request->query_parameters };
        $req_uri->query_form(%query_params) if keys %query_params;

        my $resp = $ua->post(
            $req_uri->as_string,
            'Content-Type' => 'application/json; charset=utf-8',
            Content        => encode_json($payload)
        );

        if ($resp->is_success) {
            # Parse s-bridge response and store it in the Catalyst "stash" (view model)
            my $result;
            try {
                $result = from_json($resp->decoded_content || $resp->content);
            } catch {
                $result = { result => $resp->decoded_content || $resp->content };
            }
            $c->stash->{'result'} = $result;
        } else {
            my $err;
            try {
                $err = from_json($resp->decoded_content || $resp->content);
            } catch {
                $err = { detail => $resp->decoded_content || $resp->content };
            }
            $c->response->status($resp->code);
            $c->stash->{'result'} = { error => 's-bridge API error', details => $err };
        }
    } else {
        $c->response->status(405);
        $c->stash->{'result'} = { error => 'Method not allowed. Use POST.' };
    }

    # Forward control to Catalyst's JSON View, which automatically serializes 
    # whatever is in $c->stash->{'result'} back to the client as a JSON HTTP response.
    $c->forward('View::JSON');
}

=head2 all_jobs

 # GET /sbridge/jobs

 Proxies the request to the s-bridge server's /dts/jobs endpoint to get recent jobs.

=cut

# :Path mounts this at /sbridge/jobs
sub all_jobs :Path('jobs') :Args(0) {
    my ($self, $c) = @_;

    my $ua = LWP::UserAgent->new();
    my $url = $self->sbridge_url . '/dts/jobs';

    # Forward any query parameters (like limit or offset) to s-bridge
    my $req_uri = URI->new($url);
    my %query_params = %{ $c->request->query_parameters };
    $req_uri->query_form(%query_params) if keys %query_params;

    my $resp = $ua->get($req_uri->as_string);

    if ($resp->is_success) {
        my $result;
        try {
            $result = from_json($resp->decoded_content || $resp->content);
        } catch {
            $result = { result => $resp->decoded_content || $resp->content };
        }
        $c->stash->{'result'} = $result;
    } else {
        $c->response->status($resp->code);
        $c->stash->{'result'} = { error => 's-bridge API error', details => $resp->decoded_content || $resp->content };
    }

    $c->forward('View::JSON');
}


=head2 cancel_job

 # POST /sbridge/jobs/cancel/:job_id

 Proxies the request to the s-bridge server's /dts/jobs/:job_id/cancel endpoint to cancel a job.

=cut

# :Path mounts this at /sbridge/jobs/cancel
# :Args(1) captures the next path segment and passes it as $job_id (e.g. /sbridge/jobs/cancel/123)
sub cancel_job :Path('jobs/cancel') :Args(1) {
    my ($self, $c, $job_id) = @_;

    require HTTP::Request;
    my $ua = LWP::UserAgent->new();
    my $url = $self->sbridge_url . "/dts/jobs/$job_id/cancel";

    # Translate the incoming POST request into a PUT request as expected by s-bridge
    my $req = HTTP::Request->new(PUT => $url);
    my $resp = $ua->request($req);

    if ($resp->is_success) {
        my $result;
        try {
            $result = from_json($resp->decoded_content || $resp->content); # || is a fallback. if not decoded -> get the undecoded content
        } catch {
            $result = { result => $resp->decoded_content || $resp->content };
        }
        $c->stash->{'result'} = $result;
    } else {
        $c->response->status($resp->code);
        $c->stash->{'result'} = { error => 's-bridge API error', details => $resp->decoded_content || $resp->content };
    }

    $c->forward('View::JSON');
}


=encoding utf8

=head1 AUTHOR

Stemmaweb developer

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable; #For runTime protection and speed

1;
