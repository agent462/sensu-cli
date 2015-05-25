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
#         SENSU-CLI
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
* Delete Requests (delete clients, stashes, aggregates and events)


Usage and Configuration
-----------------------
* gem install sensu-cli

* There is one settings file for host, port, ssl, and HTTP timeout that lives in your user directory ~/.sensu/settings.rb.  You can alternatively place this in /etc/sensu/sensu-cli/settings.rb.

````
host  "127.0.0.1"
port  "4567"
ssl   false
api_endpoint "/api"
read_timeout 20
open_timeout 20
````
This format was chosen so you can do some ENV magic via your profile and setting up an alias. For details see the [wiki](https://github.com/agent462/sensu-cli/wiki)

* All Configuration Settings    
`host` String - Required - Host of the Sensu API    
`port` String/Integer - Required - Port of the Sensu API    
`ssl`  Boolean - Optional - Defaults False    
`api_endpoint` String - Optional - Default ''    
`read_timeout` Integer - Optional - Default 15 (seconds)    
`open_timeout` Integer - Optional - Default 5 (seconds)    
`pretty_colors` Boolean - Optional - Default True    
`proxy_address` String - Optional    
`proxy_port` Integer - Optional    
`user` String - Optional - User for the Sensu API    
`password` String - Optional - Password for the Sensu API    

Examples
-----------
````
Available subcommands: (for details, sensu SUB-COMMAND --help)

** Aggregate Commands **
sensu-cli aggregate list (OPTIONS)
sensu-cli aggregate show CHECK (OPTIONS)
sensu-cli aggregate delete CHECK

** Check Commands **
sensu-cli check list
sensu-cli check show CHECK
sensu-cli check request CHECK SUB1,SUB2

** Client Commands **
sensu-cli client list (OPTIONS)
sensu-cli client show NODE
sensu-cli client delete NODE
sensu-cli client history NODE

** Event Commands **
sensu-cli event list
sensu-cli event show NODE (OPTIONS)
sensu-cli event delete NODE CHECK

** Health Commands **
sensu-cli health (OPTIONS)

** Info Commands **
sensu-cli info

** Silence Commands **
sensu-cli silence NODE (OPTIONS)

** Stash Commands **
sensu-cli stash list (OPTIONS)
sensu-cli stash show STASHPATH
sensu-cli stash delete STASHPATH
sensu-cli stash create PATH

** Resolve Commands **
sensu-cli resolve NODE CHECK

** Socket Commands **
sensu-cli socket create (OPTIONS)
sensu-cli socket raw INPUT

  --version, -v:   Print version and exit
     --help, -h:   Show this message
````

Filters
-------

Filters are strings in 'key,value' format.

````
Examples:

# show all events with name matching 'foo'
sensu-cli event list -i name,foo

# show all events whose output matches 'foo'
sensu-cli event list -i output,foo
````

Socket
-------
This command can only be used on a host that is running sensu-client.  sensu-client exposes a socket for arbritary check results.  For more information you can see the [sensu client documentation](https://sensuapp.org/docs/0.18/clients#client-socket-input).
````
# send a check result to the sensu server
sensu-cli socket create -name "host33" --output "Something broke really bad" --status 1

# send raw json check result to the sensu server
sensu-cli socket raw '{"name": "host34", "output": "Something broke even worse than on host33", "status": 1}'
````

Contributions
-------------
Please provide a pull request.  I'm an ops guy, not a developer, so if you're submitting code cleanup, all I ask is that you explain the improvement so I can learn.


License and Author
==================
I'm releasing this under the MIT or Apache 2.0 license.  You pick.

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
