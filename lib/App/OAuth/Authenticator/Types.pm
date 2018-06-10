package App::OAuth::Authenticator::Types;

use strict;
use warnings FATAL => 'all';

use URI;
use HTTP::Headers;

use Type::Library -base,
    -declare => qw(Type TinyType MooseType MooseXType MooseXUndef
                   NonEmptyStr NonEmptyToken MaybeBool MaybeToken TokenList
                   URIRef MaybeURIRef Email MaybeEmail
                   HTTPMethod HTTPHeaders HTTPRequest ResourceMap);
use Types::Standard qw(slurpy Any Defined Value Maybe Optional
                       Str Dict Enum ArrayRef HashRef);
use Type::Utils -all;
use Types::XSD  -all;

class_type TinyType,    { class => 'Type::Tiny' };
class_type MooseType,   { class => 'Moose::Meta::TypeConstraint' };
class_type MooseXType,  { class => 'MooseX::Types::TypeDecorator' };
class_type MooseXUndef, { class => 'MooseX::Types::UndefinedType' };

declare Type, as TinyType|MooseType|MooseXType|MooseXUndef;

coerce Boolean, from Defined, via { int $_ };
subtype MaybeBool, as Maybe[Boolean];
coerce MaybeBool, from Defined, via { int $_ };

subtype NonEmptyStr, from Str, via { my $x = $_; $x =~ s/\s+//gsm; length $x };

subtype NonEmptyToken, as Token, where { to_Token($_) ne '' };
subtype MaybeToken, as Maybe[Token];

sub _coerce_token {
    s/^\s*(.*?)\s*$/$1/sm;
    s/\s+//sm;
    $_;
}

coerce Token,      from Str, via \&_coerce_token;
coerce MaybeToken, from Str, via \&_coerce_token;

class_type URIRef, { class => 'URI' };
subtype MaybeURIRef, as Maybe[URIRef];

sub _coerce_uri {
    $_ =~ s/^\s*(.*?)\s*$/$1/sm;
    URI->new($_);
}

coerce MaybeURIRef, from NonEmptyStr, via \&_coerce_uri;
coerce URIRef, from NonEmptyStr, via \&_coerce_uri;

subtype Email, as URIRef,
    where { $_->can('scheme') and lc($_->scheme) eq 'mailto' };
subtype MaybeEmail, as Maybe[Email];

sub _coerce_email {
    my $em = to_Token($_);
    $em =~ s/^(mailto:)?(.*?)$/mailto:$2/i;
    URI->new($em);
}

coerce Email,      from NonEmptyStr, via \&_coerce_email;
coerce MaybeEmail, from NonEmptyStr, via \&_coerce_email;

# XXX fine for now
declare HTTPMethod, as Enum[qw(OPTIONS TRACE GET HEAD POST PUT DELETE)];

class_type HTTPRequest, { class => 'HTTP::Request' };
class_type HTTPHeaders, { class => 'HTTP::Headers' };
coerce HTTPHeaders,
    from HashRef, via { HTTP::Headers->new(%$_) },
    from ArrayRef[ArrayRef], via {
        my $a = shift;
        my $h = HTTP::Headers->new;
        for my $pair (@$a) {
            my @v = @$pair;
            my $k = shift @v;
            if ($k and @v) {
                $h->push_header($k, ref $v[0] ? $v[0] : \@v);
            }
        }
        require Data::Dumper;
        warn Data::Dumper::Dumper($h);
        $h;
    };

#my $tokens = declare as ArrayRef[Token];
#coerce $tokens, from Value, via { [$_] };
declare TokenList, as ArrayRef[Token];
coerce TokenList, from Value, via { [$_] };

declare ResourceMap, as Dict[
    menu => Optional[TokenList], validation => Optional[TokenList],
    slurpy Any], coercion => 1;

__PACKAGE__->meta->make_immutable;

1;
