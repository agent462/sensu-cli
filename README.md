sensu-cli
=========
```
#
# Welcome to the sensu-cli.
#          ______
#       .-'      '-.
#     .'     __     '.
#    /      /  \      \
#    ------------------
#            /\
#           '--'
#          SENSU
#
```
A sensu-cli for interacting with the sensu api.

What is Sensu? http://sensuapp.org/

Features
--------
* API interaction with info, health, stashes, events, clients, aggregates and checks
* Resolve Events
* Silence clients and checks
* Get Requests (get clients, stashes, events, etc.)
* Delete Requests (delete clients, stashes and events)


Usage and Configuration
-----------------------
* gem install sensu-cli

* There is one settings file for host, port and ssl that lives in your user directory ~/.sensu/settings.rb.  You can alternatively place this in /etc/sensu/sensu-cli/settings.rb.

````
host  "127.0.0.1"
port  "4567"
ssl   false
````
This format was chosen so you can do some ENV magic via your profile and setting up an alias. For details see the [wiki](https://github.com/agent462/sensu-cli/wiki)

* If your Sensu API has basic auth, add the parameters to the config.

````
host  "127.0.0.1"
port  "4567"
ssl   false
user "some_user"
password "some_secret_password"
````


Examples
-----------
````
Available subcommands: (for details, sensu SUB-COMMAND --help)

** Aggregate Commands **
sensu aggregate list (OPTIONS)
sensu aggregate show CHECK

** Check Commands **
sensu check list
sensu check show CHECK
sensu check request CHECK SUB1,SUB2

** Client Commands **
sensu client list (OPTIONS)
sensu client show NODE
sensu client delete NODE
sensu client history NODE

** Event Commands **
sensu event list
sensu event show NODE (OPTIONS)
sensu event delete NODE CHECK

** Health Commands **
sensu health (OPTIONS)

** Info Commands **
sensu info

** Silence Commands **
sensu silence NODE (OPTIONS)

** Stash Commands **
sensu stash list (OPTIONS)
sensu stash show STASHPATH
sensu stash delete STASHPATH

** Resolve Commands **
sensu resolve NODE CHECK

  --version, -v:   Print version and exit
     --help, -h:   Show this message
````

Contributions
-------------
Please provide a pull request.  I'm an ops guy, not a developer, so if you're submitting code cleanup, all I ask is that you explain the improvement so I can learn.
   
TODO
----
* support deletion of aggregate check
* cleanup the cli
* Once complete api support is implemented I'll add other features like filtering or issuing a event.
   
License and Author
==================

Author:: Bryan Brandau <agent462@gmail.com>

Copyright:: 2013, Bryan Brandau

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
