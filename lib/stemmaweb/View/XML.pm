package stemmaweb::View::XML;

use strict;
use base 'Catalyst::View';
use Encode qw/ encode /;
use namespace::autoclean;

# use XML::Feed;

# OPEN IN BROSWER?
# sub rss : Local {
#     my ($self, $c) = @_;
#     $c->stash->{feed} = $feed_obj_or_data;
#     $c->forward('View::Feed');
# }

# DOWNLOAD IN BROWSER
sub process {
    my ($self, $c) = @_;
    $c->res->content_type('text/xml');
    $c->res->content_encoding('UTF-8');
    if ($c->stash->{download}) {
        $c->res->header('Content-Disposition',
            sprintf("attachment; filename=\"%s.xml\"", $c->stash->{name}));
    }
    $c->res->output(encode('UTF-8', $c->stash->{result}));
}

1;

=head1 NAME

stemmaweb::View::XML - Catalyst XML View

=head1 SYNOPSIS

See L<stemmaweb>

=head1 DESCRIPTION

Catalyst XML View.

=head1 AUTHOR

Renato Diaz

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.
