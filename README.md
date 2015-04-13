sdk-ruby
========
Minimalistic [Elasticfeed SDK](http://elasticfeed.io) and cli client for ruby

Installation
------------
```
gem install elasticfeed
```

API coverage
------------
The Elasticfeed Public API follows the principles of the REST architectural style to expose a number of internal resources which enable programmatic access to [Elasticfeed’s features](http://elasticfeed.io/help/reference/api/). Current implementation support only a few of API features.

|Resource     |Get All |Get One |Create |Update |Delete |
|:------------|:------:|:------:|:-----:|:-----:|:-----:|
|Organisation | +      | +      | +     | +     | +     |
|Application  | +      | +      | +     | +     | +     |

Library usage
-------------

Source code itself is well-documented so when writing code it should auto-complete and hint in all supported usages.


### Client
Most important part of the api is client. In order to make any request you need to instantiate client with correct params.

```ruby
client = Elasticfeed::Client.new('username', 'api_key')
```

This client is used by all other classes connecting to api no matter if it's Resource or helper class like Agent.


### Agent
Agent is simple wrapper class for listing all accessible resources.

```ruby
client = Elasticfeed::Client.new('username', 'api_key')
agent = Elasticfeed::Agent.new(client)

agent.alerts.each do |alert|
    alert.ack('now')
end
```

List of resource-listing agent methods:
- groups
- hosts
- clusters
- snapshots
- alerts
- restorejobs

### Resources

You can find lists of resource by using agent as pointed above, or by various resource methods.
Each resource have a find method loading certain resource with provided id (plus corresponding parent ids), e.g.
```ruby
client = new Elasticfeed::Client.new('username', 'api_key')
host = Elasticfeed::Resource::Host.find(client, 'group_id', 'host_id')
```

Additionally some resources have additional instance methods to retrieve sub-resources, e.g.
```ruby
client = new Elasticfeed::Client.new('username', 'api_key')
group = Elasticfeed::Resource::Group.find(client, 'group_id')
hosts = group.hosts
```

Cli usage
---------

There is a built-in cli with several commands retrieving api resource lists.

### Configuration

Cli uses configuration with all values set to default ones.
Config itself has `config_file` property which merges itself with params from the file.
By default `config_file` points to home directory, but it can be changed to points to any file.

```
username=sysadmin@example.tld
apikey=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
apiurl=https://api.elasticfeed.io/api/public/v1.0
default_org_id=your-org-id
default_app_id=your-app-id
```

Additionally some options can be modified using cli options.

### Available commands


```bash
$ elasticfeed --help
Usage:
     [OPTIONS] SUBCOMMAND [ARG] ...

Parameters:
    SUBCOMMAND                    subcommand
    [ARG] ...                     subcommand arguments

Subcommands:
    groups                        Groups
    hosts                         Hosts
    clusters                      Clusters
    alerts                        Alerts
    snapshots                     Snapshots
    restorejobs                   Restorejobs

Options:
    -h, --help                    print help
    -u, --username <string>       Elasticfeed user
    -k, --apikey <string>         Elasticfeed api-key
    -a, --apiurl <string>         Elasticfeed api url. Full url including version: https://api.elasticfeed.io/api/public/v1.0
    -v, --version                 Version
    -g, --default-org-id <string> Default Elasticfeed organisation id
    -c, --default-app-id <string> Default Elasticfeed application id
    --cfg <string>                Config file path
    -i, --ignore                  Ignore flag of --group-id and -cluster-id (default: false)
    -j, --json                    Print JSON output (default: false)
    -l, --limit <integer>         Limit for result items
```
