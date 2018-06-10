package App::OAuth::Authenticator;

use 5.012;
use strict;
use warnings FATAL => 'all';

use parent 'Plack::Component';

use App::OAuth::Authenticator::Request;
use App::OAuth::Authenticator::DBIC;
use App::OAuth::Authenticator::Types qw(ResourceMap);

use Try::Tiny;
use Throwable::Error;

use String::RewritePrefix ();
use Class::Load           ();
use Data::UUID::NCName    ();
use MIME::Base64          ();

use RDF::Trine;

use Moo;
with 'Role::Markup::XML';

=head1 NAME

App::OAuth::Authenticator - A (standalone) OAuth(2) authenticator

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

=head1 SYNOPSIS

  # on the shell

  $ plackup `which app-oauth-authenticator.psgi`

=head1 METHODS

=head2 new

Loads the internal state and bootstraps

=over 4

=item provider

=cut

sub IS ($$) {
    my ($thing, $type) = @_;
    defined $thing or return;
    my $ref = ref $thing or return;
    Scalar::Util::blessed($thing) &&
          ($thing->isa($type) or $thing->can('does') && $thing->does($type))
              or $ref eq $type;
}

has registry => (
    is => 'ro',
    init_arg => undef,
    default => sub {
        Params::Registry->new(
            params => [
                {
                    name => 'state',
                    max  => 1,
                },
                {
                    name => 'action',
                    max  => 1,
                },
                {
                    name => 'target',
                    max  => 1,
                },
                {
                    name => 'code',
                    max  => 1,
                },
            ],
        );
    },
);

has provider => (
    is      => 'ro',
    default => sub { { } },
    # can't coerce this because it has a backreference, not a big deal
);

# reverse map links state tokens to oauth providers

has _provider_rev => (
    is      => 'ro',
    default => sub { { } },
);

=item model

The RDF model containing the reference structure for authenticating
and authorizing users.

=cut

has store => (
    is      => 'ro',
    default => sub { RDF::Trine::Store::Hexastore->new },
    coerce  => sub {
        my $thing = shift;
        if (defined $thing) {
            return $thing if IS($thing, 'RDF::Trine::Store');
            die 'Store must be a HASH' unless ref $thing eq 'HASH';
            return RDF::Trine::Store::Hexastore->new unless $thing->{storetype};
            return RDF::Trine::Store->new_with_config($thing);
        }
    }
);

has model => (
    is       => 'ro',
    lazy     => 1,
    default  => sub { RDF::Trine::Model->new($_[0]->store) },
);

=item state

The state database that contains the various API keys, cookies, etc.

=cut

has state => (
    is => 'ro',
    required => 1,
    coerce => sub {
        my $thing = shift;
        return $thing if IS($thing, 'App::OAuth::Authenticator::DBIC');
        die 'State must be a HASH' unless ref $thing eq 'HASH';
        my %h = %$thing;
        my ($dsn, $user, $pass) = delete @h{qw(dsn user password)};
        App::OAuth::Authenticator::DBIC->connect($dsn, $user, $pass, \%h);
    },
);

=item resources

=over 4

=item menu

The relative path for the menu page. Defaults to nothing.

=item validation

The relative path for the validation page. Defaults to C<validate>.

=back

=cut

my %RESOURCE_DEFAULTS = (menu => [''], validation => ['validate']);

has resources => (
    is      => 'ro',
    isa     => ResourceMap,
    coerce  => 1,
    default => sub { {%RESOURCE_DEFAULTS} },
);

has _resource_rev => (
    is       => 'ro',
    init_arg => undef,
    default  => sub { [] },
);


=item cookie

The authentication cookie key. Defaults to C<authenticator>.

=cut

has cookie => (
    is      => 'ro',
    default => 'authenticator',
);


sub BUILD {
    my $self = shift;

    # deal with resources

    %{$self->resources} = (%RESOURCE_DEFAULTS, %{$self->resources});

    my %rev;
    while (my ($k, $a) = each %{$self->resources}) {
        for my $v (@$a) {
            App::OAuth::Authenticator::Error::Config->throw(
                object  => $self->resources,
                message => "Duplicate path $v for $k") if defined $rev{$v};
            $rev{$v} = $k;
        }
    }

    # sort from longest path to shortest
    # clip off the front of the uri path if it matches
    # split off the rest into e.g. target parameter
    # dispatch the call
    for my $k (sort { (length($b) <=> length($a)) || $a cmp $b } keys %rev) {
        my $nk = join '/+', '', map { quotemeta($_) } split /\/+/, $k;
        my $re = qr/^$nk(?:\/+(.*?))?$/;

        push @{$self->_resource_rev}, [$re, $rev{$k}];
    }

    # deal with providers
    my $p = $self->provider;
    while (my ($k, $v) = each %$p) {
        # load unless already loaded
        unless (IS($v, 'App::OAuth::Authenticator::Provider')) {

            # get class name
            my ($cn) = String::RewritePrefix->rewrite({
                ''  => 'App::OAuth::Authenticator::Provider::',
                '+' => '' }, $k);

            try {
                Class::Load::load_class($cn);
                $p->{$k} = $v = $cn->new(label => $k, %$v, app => $self);
            } catch {
                die "Could not load $cn: $_";
            };
        }

        # set the reverse value
        $self->_provider_rev->{$v->state} = $v;
    }

    #require Data::Dumper;
    #warn Data::Dumper::Dumper($self->_provider_rev);
}

=head2 configure $FILE

This class method loads the state from a configuration file. Useful
for formulations like:

  $ plackup -MApp::OAuth::Authenticator -e \
    'App::OAuth::Authenticator->configure("my.conf")->to_app'

=cut

sub configure {
    my ($class, $file) = @_;
    $class = ref $class if ref $class;

    my %cfg;
    try {
        require Config::Any;
        my $tmp = Config::Any->load_files
            ({ files => [$file], flatten_to_hash => 1, use_ext => 1 });
        # just smush this
        %cfg = map { %$_ } values %$tmp;
    } catch {
        Throwable::Error->throw("Must supply a valid file: $_");
    };

    $class->new(%cfg);
}

# We start and end with the authenticator:

# Simple conditional: if there's a cookie present with the specified
# key, look it up in the database. If there's a principal associated
# with the cookie (and it hasn't expired), set the special header to
# that (to be picked up by the apache module) and return 200.

# Otherwise, we can do one of two things: We can return 401 with the
# NASCAR page content, or we can redirect to it, taking care to
# provide it information about where to redirect back to.

# Note that the authenticator is not a conventional resource with a
# location like the other resources. It is run through a side channel
# and hooked via the FCGI_ROLE environment variable.

sub authenticator {
    my ($self, $req) = @_;

    my $resp = $req->new_response(200);
}

# ***

# Next: A NASCAR-esque menu of all the providers:

# This is really the only UI: a bunch of links to the different
# providers. Each link must contain enough information to resolve not
# only the provider (when the provider redirects the UA back to the
# confirmation target), but also the original resource the UA was
# coming from. (The latter should be checked for cleanliness.)

sub menu {
    my ($self, $req) = @_;

    my $resp = $req->new_response(200);

    # since this resource is probably what we're going to see if the
    # login process fails, we should consider some lozenge or other
    # for delivering an error message.

    my $doc  = $self->_DOC;
    my $root = $self->_XHTML(
        doc     => $doc,
        uri     => $req->abs_request_uri,
        title   => 'Choose an Authentication Provider',
        content => [
            { -name => 'h1', -content => 'Derp' },
            { -name => 'ul' },
        ],
    );
    $resp->body($doc);

    # generate the redirect uri
    my $valid = URI->new_abs($self->resources->{validation}[0],
                             $req->real_base);
    if (defined(my $target = $req->instance->get('target'))) {
        my @ps = $valid->path_segments;
        $valid->path_segments(@ps, $target);
    }

    # iterate over the providers to produce a list
    for my $provider (sort { $a->label cmp $b->label }
                          values %{$self->provider}) {

        my $href = $provider->prepare_login_uri(redirect => $valid);

        $self->_XML(
            parent => $root,
            spec => {
                -name => 'li',
                -content => { -content => $provider->label, href => $href },
            },
        );
        # all we need from the provider here is a URI

        # the provider should already know its own state and scope;
        # all it needs from us is the URI of the validation target.

        # other than that all we are doing here is creating a link so
        # maybe there should be some kind of label in the config.
    }

    # punt out a page which is literally just a list of links and
    # maybe an error message at the top

    $resp;
}

# ***

# Finally: The confirmation/validation target:

# This is the resource that the UA gets redirected back to with the
# nonce (or 'code' in OAuth 2), which behind the scenes gets traded
# with the provider for an access token. This should be a
# meta-resource with two parameters, in addition to the OAuth ones:
# something to positively identify the provider (e.g. a slug,
# otherwise we won't know which provider the nonce belongs to), and
# the original requested URI to finally redirect to upon successful
# validation of the principal. The latter ought to have been along for
# the ride ever since being set by the authenticator.

# (Note that since this original URI can contain a query string, we
# should probably Base64-encode it. Likewise, we shouldn't trust the
# OAuth providers to faithfully relay any extraneous query parameters,
# and thus just encode our parameters into the path of the target URI.)

# Example: /oauth/confirm/$PROVIDER/$REDIRECT_BASE64?oauth=params

# Better: /oauth/confirm/$REDIRECT_BASE64?state=$provider&other=params

# Resolution/validation of the principal can proceed once we have the
# access token from the provider. This process will be distinct and
# proprietary to each provider, and thus handled by provider-specific
# plugins. The common thread is that we query the provider's API for
# some positively-identifying information that we can match to our
# existing whitelist. (Alternatively we can skip the whitelist and
# just 'sign up' whoever comes along. This alternative may entail an
# additional piece of UI, so for now let's just leave it out of scope.)

# Validation against the whitelist is done (for now) against an RDF
# graph. We identify (through configuration) one or more resources in
# the graph to be "origins". A valid principal either *is* an origin,
# or it is somehow topologically connected to one.

# Since the information we get from the provider's API may not match
# directly to a property of a principal, and since either the provider
# or ourselves may not have every conceivable matching pair of
# identifiers, we may need to make multiple comparisons, and
# ultimately multiple *calls* to the provider's API. This matching
# process should nevertheless be encapsulated into a single method. If
# successful, the graph may be augmented (i.e., any applicable blanks
# filled in) with the information found in the API responses. If this
# method fails to produce a principal, the UA should be shown the
# NASCAR page (either in situ or via redirect) to select a different
# provider. (We can include a parameter to discount the providers
# which have been exhausted.)

# The validation function should return the matching principal(s) if
# successful, `undef` if no principal was found, and raise an
# exception in all other cases. Exceptions should contain details
# about the nature of the failure, in particular whether they are
# temporary or permanent. In the case of multiple principals
# identified, consider a `300 Multiple Choices` response, `406 Not
# Acceptable`, or `409 Conflict`. (This will be a policy issue whether
# or not to let the OAuth-authenticated user specify who they are.) If
# the API calls fail, appropriate response codes are `502 Bad Gateway`,
# `503 Service Unavailable`, or `504 Gateway Timeout`.

# An option to consider is to use the provider to gather intel on
# other members of the whitelist to fill in data gaps and facilitate
# matching. For example, both GitHub and Slack have 'organizations'
# and 'teams', respectively, which can be used to triangulate other
# members of the whitelist and give the system an easier time
# identifying them. However, in almost all cases this would require
# more API privileges than are needed to simply identify the
# principal, so we would need some explicit UI and content to
# carefully explain what the hell is going on.

sub error_page {
    my ($self, $message) = @_;
    my $doc = $self->_DOC;
    $self->_XHTML(
        doc     => $doc,
        title   => 'Handshake error',
        content => $message,
    );
    $doc;
}

sub validate {
    my ($self, $req) = @_;

    my $ins  = $req->instance;
    my $uri  = $req->uri;
    my $resp = $req->new_response(409);

    # we are using the `state` parameter to identify what the hell
    # provider we're using, so if we don't have that, this is a 409
    # right out of the gate. (may as well check for the existence of
    # `code` parameter here too.)

    my $code  = $ins->get('code') or do {
        my $doc = $self->error_page(
            { -name => 'p', -content => [
                'The required parameter ',
                { -name => 'code', -content => 'code' },
                ' is missing. This page was likely accessed outside ',
                ' of the normal OAuth handshake process.'] });
        $resp->body($doc);
        return $resp;
    };

    my $state = $ins->get('state') or do {
        my $doc = $self->error_page(
            { -name => 'p', -content => [
                'The required parameter ',
                { -name => 'code', -content => 'state' },
                ' is missing. This page was likely accessed outside ',
                ' of the normal OAuth handshake process.'] });
        $resp->body($doc);
        return $resp;
    };

    # resolve the provider using the `state` parameter or return 409.

    my $provider = $self->_provider_rev->{$state} or do {
        my $doc = $self->error_page(
            { -name => 'p', -content => [
                'We could not match a provider to the state ',
                { -name => 'samp', -content => $state },
                '. This is either an error in the OAuth process, ',
                'or this page has been accessed outside the normal flow.' ]});
        $resp->body($doc);
        return $resp;
    };

    # before we validate the user, we check the redirect target, which
    # will be encoded as the terminal path segment using base64url.

    my $target = $ins->get('target');
    if (defined $target and $target ne '') {
        warn $target;
    }

    # * if it isn't there, this is a 409. (or is it? do we want to
    #   have a default redirecton target?)
    #
    # * if it decodes to anything other than a valid (maybe relative)
    #   HTTP(S) URL, then this is a 409.
    #
    # * if the URI's authority points to any domain other than the the
    #   Host: or any configured domains, this is a 409. (we assume
    #   here that the Host: header has already been validated upstream)
    #
    # *now* we feed the `code` parameter into the oauth request, which
    # of course if we aren't given, is another 409 error.

    # get the token or this is a 502
    my $token;
    try { $token = $provider->get_access_token($code) } catch {
        $resp->code(502);
        my $doc = $self->error_page({ -name => 'p', -content => [
            'Dongs: ', $_->object,
        ]});
        $resp->body($doc);
    };
    return $resp if $resp->code == 502;

    warn "got token $token";

    my $principal;
    try {
        # the call to the provider will either return the principal,
        # return nothing, or throw an exception.

        $principal = $provider->resolve_principal($token);
    } catch {
        # the provider has failed in some technical way; return 5xx
        $resp->code(502);
        $resp->body('lol fail');
    };
    return $resp if $resp->code >= 500;

    unless ($principal) {
        # 403, we see you but you aren't on the whitelist

        # here's a question: do we want to let people try another
        # provider?
        $resp->code(403);

        my $doc = $self->error_page({ -name => 'p', -content => [
            'We found your account at ',
            { -name => 'strong', -content => $provider->label },
            ', but we couldn\'t associate it with any people we know about.',
        ] });
        $resp->body($doc);
        return $resp;
    }

    # congratulations, you're in. mint up a new state record, set the
    # cookie and redirect to the target.
    my $cookie = $self->state->state_for($principal);

    $resp->cookies->{$self->cookie} = {
        value    => $cookie,
        httponly => 1,
#        domain   => $derp,
    };

    $resp->redirect($target, 303) if $target;

    $resp;
}

=head2 some_thing

=cut

sub state_for {
}

sub principal_for {
}

=head2 call

=cut

my %DISPATCH = (
    menu       => \&menu,
    validation => \&validate,
);

sub call {
    my ($self, $req) = @_;

    # the FCGI_ROLE is a misnomer; the authenticator authenticates.
    my $role = $req->env->{FCGI_ROLE} || '';
    return $self->authenticator($req) if $role eq 'AUTHORIZER';

    # dispatch based on request URI

    my $pi = $req->real_path_info || '/';
    for my $pair (@{$self->_resource_rev}) {
        my ($re, $dispatch) = @$pair;
        next unless $pi =~ $re;
        my $target = $1;
        $req->instance->set(target => $target);
        return $DISPATCH{$dispatch}->($self, $req);
    }

    my $resp = $req->new_response(504);
    $resp->content_type('text/plain');
    $resp->body("Gone off the rails, no dispatch for $pi");
    $resp;
}

around call => sub {
    my ($orig, $self, $env) = @_;
    my $req  = App::OAuth::Authenticator::Request->new
        ($env, $self->registry, path => [qw(action target)]);
    my $ins  = $req->instance;

    # don't stick application logic in here; this is strictly infrastructure

    # now run the original call
    my $resp = $orig->($self, $req);
    my $body = $resp->body;
    if (IS($body, 'XML::LibXML::Node')) {
        $resp->content_type('application/xml');
        $resp->body($body->toString(1));
    }
    $resp->finalize;
};

=head1 AUTHOR

Dorian Taylor, C<< <dorian at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to
L<https://github.com/doriantaylor/p5-app-oauth-authenticator/issues> .

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

  perldoc App::OAuth::Authenticator

You can also look for information at:

=over 4

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/App-OAuth-Authenticator>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/App-OAuth-Authenticator>

=item * Search CPAN

L<http://search.cpan.org/dist/App-OAuth-Authenticator/>

=back

=head1 LICENSE AND COPYRIGHT

Copyright 2018 Dorian Taylor.

Licensed under the Apache License, Version 2.0 (the "License"); you
may not use this file except in compliance with the License.  You may
obtain a copy of the License at
L<http://www.apache.org/licenses/LICENSE-2.0>.

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
implied. See the License for the specific language governing
permissions and limitations under the License.

=cut

1; # End of App::OAuth::Authenticator
