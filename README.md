# App::OAuth::Authenticator - A (standalone) OAuth(2) authenticator

## Synopsis

    # on the shell

    $ plackup -e 'App::OAuth::Authenticator->config("auth.conf")->to_app'

## Description

This module is intended to be a pluggable bus for authenticating
people via OAuth(2) against an existing database. In other words, we
use information found in th API responses of the user's chosen
provider to match them against a set of known people and facts about
them. If a principal (a conventional term for "entity that accesses a
computer system") is found, the system associates that principal with
an ordinary HTTP cookie, which is subsequently retrieved through an
authentication handler. The handler uses the cookie to look up the
principal, and sets the Web server request object's `r->user` field,
and thus the `REMOTE_USER` environment variable, with the principal's
identifier. This can be used subsequently in authorization handlers
and likewise in the application layer, providing a vendor-neutral—and
even protocol-neutral—interface for access control on the Web.

The ultimate goal of this module is therefore to demonstrate a second
natural cleavage plane in Web development: We know about separating
content from presentation, hopefully this will demonstrate the value
in separating access control from the other two.

## License & Copyright

Copyright 2018 Dorian Taylor.

Licensed under the Apache License, Version 2.0 (the "License"); you
may not use this file except in compliance with the License. You may
obtain a copy of the License
at http://www.apache.org/licenses/LICENSE-2.0 .

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
implied.  See the License for the specific language governing
permissions and limitations under the License.

