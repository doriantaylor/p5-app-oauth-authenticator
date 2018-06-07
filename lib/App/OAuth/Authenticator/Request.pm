package App::OAuth::Authenticator::Request;

use strict;
use warnings FATAL => 'all';

use Moo;
use Scalar::Util qw(blessed reftype);
use Params::Registry;

extends 'Plack::Request';
#use parent 'Plack::Request';


=head2 new

=over 4

=item registry

The L<Params::Registry> specification.

=cut

has registry => (
    is      => 'ro',
    default => sub { Params::Registry->new },
);

=item path

=cut

has _query_path => (
    is       => 'ro',
    isa      => sub { my $ref = ref $_; $ref and $ref =~ /^(ARRAY|CODE)$/ },
    init_arg => 'path',
    default  => sub { [] },
);

=item instance

The L<Params::Registry::Instance> associated with the request.

=cut

has _instance => (
    is       => 'rw',
    init_arg => undef,
);

sub instance {
    my $self = shift;
    my $ins  = $self->_instance;
    unless ($ins) {
        $ins = $self->registry->process($self->query_string);
        $self->_instance($ins);
    }
    $ins;
}

sub BUILDARGS {
    my ($class, @args) = @_;
    my %p;

    # environment and registry as objects
    $p{env}      = shift @args if @args and ref $args[0];
    $p{registry} = shift @args if @args and ref $args[0];

    %p = (@args, %p);

    \%p;
};

# fix for upstream constructor
sub FOREIGNBUILDARGS {
    # XXX why does this not do this by itself?
    $_[0]->BUILDARGS(@_[1..$#_])->{env};
}

=head2 real_path_info

=cut

# this is necessary because apparently when you reverse proxy a
# FastCGI script, the PATH_INFO does not get translated properly.
sub real_path_info {
    my $self = shift;
    my $sf = $self->env->{SCRIPT_FILENAME};
    return $self->path_info unless $sf and $sf =~ m!^proxy:(.+?://.*)$!;
    my $tmp = URI->new($1)->canonical;
    if ($tmp->can('path') and $tmp->path ne '/') {
        my $pi = $self->env->{PATH_INFO};
        return $tmp->path . $pi;
    }
    return $self->path_info;
}

=head2 abs_request_uri

=cut

# we want the absolute URI of the *request*, as it came in from the
# outside.
sub abs_request_uri {
    my $self = shift;
    my $orig = $self->base->canonical; # automatically clones, who knew
    my $ruri = $self->request_uri;
    $ruri = $ruri->path_query if blessed($ruri);
    $orig->path_query($ruri);
    $orig;
}

=head2 real_base

=cut

# might as well do the base while we're at it
sub real_base {
    my $self = shift;
    my $base = $self->abs_request_uri->clone;
    if (defined (my $pi = $self->real_path_info)) {
        $pi = substr($pi, 1) if substr($pi, 0, 1) eq '/';
        if (length $pi) {
            my $op = $base->path;
            if (my ($p) = ($op =~ m!^(.*?/)$pi$!)) {
                # OMG HEISENBUG just try this with $1
                $base->path($p);
            }
        }
    }
    $base;
}

=head2 uri_for

=cut

# this one is special because it unwinds the query parameters
sub abs_uri_for {
    my $self = shift;

    # get the ACTUAL REQUEST_URI FROM THE NETWORK
    my $orig = $self->abs_request_uri;

    # process input, which can either be:
    my $new;
    my $ins = $self->instance;
    if (@_) {
        my $ref = ref $_[0];
        if (!ref $_[0] or (blessed($_[0]) and $_[0]->isa('URI'))) {
            # * a string or URI as the first argument, in which case all
            #   subsequent arguments are considered query parameters, whether
            #   wrapped in a HASH/ARRAY reference or not, *

            # note $new is RELATIVE TO THE REQUEST URI, NOT THE BASE!
            $new = URI->new_abs(shift, $orig)->canonical;
        }

        # * a HASH, ARRAY, or Params::Registry::Instance reference of
        #   query parameters

        my (%p, $prune);
        if (@_) {
            if ($ref = ref $_[0] || '') {
                if ($ref eq 'HASH') {
                    %p = %{shift()};
                }
                elsif ($ref eq 'ARRAY') {
                    my @p = @{shift()};
                    pop @p if @p % 2; # just throw it away
                    %p = @p;
                }
                elsif (blessed($_[0])
                           and $_[0]->isa('Params::Registry::Instance')) {
                    $ins = shift;
                }
                else {
                    Carp::croak("Don't know what to do with $ref");
                }
            }

            # tell it to prune if applicable
            $prune = pop @_ if @_ % 2;
            # now if there is anything else:
            %p = (%p, @_);
        }

        # now special case for other sites
        if ($new and $orig->authority ne $new->authority) {
            $new->query_form_hash(\%p) if keys %p;
            return $new;
        }

        # now we do the parameter instance
        $p{-only} = [sort keys %p] if $prune;
        $ins = $ins->clone(\%p);
    }

    # * nothing, in which case it path-ifies the current query
    #   params).

    # (but first we just return this 
    return $ins->make_uri($new) if $new;

    # okay now the magic happens
    $new = $self->real_base;
    my $pq = $self->_query_path;
    if (ref $pq eq 'CODE') {
        return $pq->($new, $ins);
    }
    elsif (@$pq) {
        my @col;
        my @out = grep { $_ ne '' } $new->path_segments;
        for my $step (@$pq) {
            # we need all the params to be here
            last unless defined (my $v = $ins->get($step));
            my $t = $ins->template($step);
            my $x = $t->unprocess($v);
            $x = join ',', @$x if ref $x;
            push @out, split m!/+!, $x;
            push @col, $step;
        }
        $new->path_segments('', @out); #(@out[1..$#out]);

        # take them out of the parameter instance
        $ins->set({ map { $_ => undef } @col }) if @col;
    }

    $ins->make_uri($new);
}

=head2 uri_for

=cut

sub uri_for {
    $_[0]->abs_uri_for(@_[1..$#_])->rel($_[0]->abs_request_uri);
}

1;
