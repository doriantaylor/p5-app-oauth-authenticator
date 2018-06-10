package App::OAuth::Authenticator::Error;

use strict;
use warnings FATAL => 'all';

use Moo;
extends 'Throwable::Error';

has object => (
    is => 'ro',
);

has message => (
    is => 'ro',
);

around throw => sub {
    my ($orig, $class, @args) = @_;

    # special shorthand for sequential arguments
    if (@args and @args <= 2 and ref $args[0] and ref $args[0] ne 'HASH') {
        my %p;
        @p{qw(object message)} = @args;
        return $class->$orig(%p);
    }

    $class->$orig(@args);
};

# http error

package App::OAuth::Authenticator::Error::Network;

use Moo;
extends 'App::OAuth::Authenticator::Error';

package App::OAuth::Authenticator::Error::Server;
use Moo;

extends 'App::OAuth::Authenticator::Error::Network';

package App::OAuth::Authenticator::Error::Client;

use Moo;
extends 'App::OAuth::Authenticator::Error::Network';

# json formatting error

package App::OAuth::Authenticator::Error::Parsing;

use Moo;
extends 'App::OAuth::Authenticator::Error';

package App::OAuth::Authenticator::Error::Validation;

use Moo;
extends 'App::OAuth::Authenticator::Error';

# no principal

# ambiguous (more than one) principal


1;
