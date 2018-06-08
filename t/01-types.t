#!perl

use JSON;
use Test::More;

require Data::Dumper;

plan tests => 1;

use_ok('App::OAuth::Authenticator::Types');

eval { use App::OAuth::Authenticator::Types qw(GitHubUser GitHubEmail GitHubOrg) };

my $user_public = JSON::decode_json(<<'USER');
{
  "login": "doriantaylor",
  "id": 1181000,
  "node_id": "MDQ6VXNlcjExODEwMDA=",
  "avatar_url": "https://avatars3.githubusercontent.com/u/1181000?v=4",
  "gravatar_id": "",
  "url": "https://api.github.com/users/doriantaylor",
  "html_url": "https://github.com/doriantaylor",
  "followers_url": "https://api.github.com/users/doriantaylor/followers",
  "following_url": "https://api.github.com/users/doriantaylor/following{/other_user}",
  "gists_url": "https://api.github.com/users/doriantaylor/gists{/gist_id}",
  "starred_url": "https://api.github.com/users/doriantaylor/starred{/owner}{/repo}",
  "subscriptions_url": "https://api.github.com/users/doriantaylor/subscriptions",
  "organizations_url": "https://api.github.com/users/doriantaylor/orgs",
  "repos_url": "https://api.github.com/users/doriantaylor/repos",
  "events_url": "https://api.github.com/users/doriantaylor/events{/privacy}",
  "received_events_url": "https://api.github.com/users/doriantaylor/received_events",
  "type": "User",
  "site_admin": false,
  "name": "Dorian Taylor",
  "company": null,
  "blog": "https://doriantaylor.com/",
  "location": null,
  "email": null,
  "hireable": null,
  "bio": "still not completely sold on either git or github",
  "public_repos": 54,
  "public_gists": 1,
  "followers": 30,
  "following": 13,
  "created_at": "2011-11-08T15:43:23Z",
  "updated_at": "2018-05-20T19:06:16Z"
}
USER

my $user_private = JSON::decode_json(<<'USER');
{
  "login": "octocat",
  "id": 1,
  "node_id": "MDQ6VXNlcjE=",
  "avatar_url": "https://github.com/images/error/octocat_happy.gif",
  "gravatar_id": "",
  "url": "https://api.github.com/users/octocat",
  "html_url": "https://github.com/octocat",
  "followers_url": "https://api.github.com/users/octocat/followers",
  "following_url": "https://api.github.com/users/octocat/following{/other_user}",
  "gists_url": "https://api.github.com/users/octocat/gists{/gist_id}",
  "starred_url": "https://api.github.com/users/octocat/starred{/owner}{/repo}",
  "subscriptions_url": "https://api.github.com/users/octocat/subscriptions",
  "organizations_url": "https://api.github.com/users/octocat/orgs",
  "repos_url": "https://api.github.com/users/octocat/repos",
  "events_url": "https://api.github.com/users/octocat/events{/privacy}",
  "received_events_url": "https://api.github.com/users/octocat/received_events",
  "type": "User",
  "site_admin": false,
  "name": "monalisa octocat",
  "company": "GitHub",
  "blog": "https://github.com/blog",
  "location": "San Francisco",
  "email": "octocat@github.com",
  "hireable": false,
  "bio": "There once was...",
  "public_repos": 2,
  "public_gists": 1,
  "followers": 20,
  "following": 0,
  "created_at": "2008-01-14T04:33:35Z",
  "updated_at": "2008-01-14T04:33:35Z",
  "total_private_repos": 100,
  "owned_private_repos": 100,
  "private_gists": 81,
  "disk_usage": 10000,
  "collaborators": 8,
  "two_factor_authentication": true,
  "plan": {
    "name": "Medium",
    "space": 400,
    "private_repos": 20,
    "collaborators": 0
  }
}
USER

my $ghu = GitHubUser->assert_coerce($user_public);

diag Data::Dumper::Dumper($ghu);

my $email = JSON::decode_json(<<'EMAIL');
[
  {
    "email": "octocat@github.com",
    "verified": true,
    "primary": true,
    "visibility": "public"
  }
]
EMAIL

my $ghe = GitHubEmail->assert_coerce($email);

diag Data::Dumper::Dumper($ghe);

my $org = JSON::decode_json(<<'ORG');
{
  "login": "github",
  "id": 1,
  "node_id": "MDEyOk9yZ2FuaXphdGlvbjE=",
  "url": "https://api.github.com/orgs/github",
  "repos_url": "https://api.github.com/orgs/github/repos",
  "events_url": "https://api.github.com/orgs/github/events",
  "hooks_url": "https://api.github.com/orgs/github/hooks",
  "issues_url": "https://api.github.com/orgs/github/issues",
  "members_url": "https://api.github.com/orgs/github/members{/member}",
  "public_members_url": "https://api.github.com/orgs/github/public_members{/member}",
  "avatar_url": "https://github.com/images/error/octocat_happy.gif",
  "description": "A great organization",
  "name": "github",
  "company": "GitHub",
  "blog": "https://github.com/blog",
  "location": "San Francisco",
  "email": "octocat@github.com",
  "has_organization_projects": true,
  "has_repository_projects": true,
  "public_repos": 2,
  "public_gists": 1,
  "followers": 20,
  "following": 0,
  "html_url": "https://github.com/octocat",
  "created_at": "2008-01-14T04:33:35Z",
  "type": "Organization",
  "total_private_repos": 100,
  "owned_private_repos": 100,
  "private_gists": 81,
  "disk_usage": 10000,
  "collaborators": 8,
  "billing_email": "support@github.com",
  "plan": {
    "name": "Medium",
    "space": 400,
    "private_repos": 20
  },
  "default_repository_settings": "read",
  "members_can_create_repositories": true,
  "two_factor_requirement_enabled": true
}
ORG

my $gho = GitHubOrg->assert_coerce($org);
