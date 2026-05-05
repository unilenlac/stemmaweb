package stemmaweb::Controller::Sbridge;
use Moose;
use namespace::autoclean;
use Encode qw/ decode_utf8 /;
use JSON;
use LWP::UserAgent;
use TryCatch;
use URI;

BEGIN { extends 'Catalyst::Controller' }

has sbridge_url => (
    is      => 'ro',
    isa     => 'Str',
    default => 'http://localhost:8000',
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

sub process_and_collate :Local :Args(0) {
    my ($self, $c) = @_;

    if ($c->request->method eq 'POST') {
        my $payload;
        try {
            # Parse the incoming JSON request
            my $body = $c->request->body;
            my $body_content = '';
            if (ref($body) eq 'File::Temp') {
                open(my $fh, '<', $body) or die "Cannot open temp file";
                local $/;
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

        # Prepare LWP UserAgent
        my $ua = LWP::UserAgent->new();
        my $url = $self->sbridge_url . '/dts/process-and-collate';

        # Forward any query parameters for format, strategy, etc if necessary
        my $req_uri = URI->new($url);
        my %query_params = %{ $c->request->query_parameters };
        $req_uri->query_form(%query_params) if keys %query_params;

        my $resp = $ua->post(
            $req_uri->as_string,
            'Content-Type' => 'application/json; charset=utf-8',
            Content        => encode_json($payload)
        );

        if ($resp->is_success) {
            # Try parsing the response JSON from s-bridge
            my $result;
            try {
                $result = from_json($resp->decoded_content || $resp->content);
            } catch {
                # Fallback to plain content
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

    $c->forward('View::JSON');
}

=encoding utf8

=head1 AUTHOR

Stemmaweb developer

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
