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
* Get Requests
* Delete Requests (delete clients, stashes and events)
* API interaction with info, stashes, events, clients and checks
* Resolve Events
* Silence clients and checks


Usage and Configuration
-----------------------
* gem build sensu-cli.gemspec
* gem install ./{gem file created}

* There is one settings file for host, port and ssl that lives in your user directory ~/.sensu/settings.rb

````
host  "127.0.0.1"
port  "4567"
ssl   false
````
This format was chosen so you can do some ENV magic via your profile and setting up an alias. For details see the [wiki](https://github.com/agent462/sensu-cli/wiki)



Examples
-----------
````
sensu --help
sensu client list
sensu client show NODE
sensu silence NODE
sensu info
````
Contributions
-------------
Please provide a pull request.
   
TODO
----
* support post for all applicable endpoints      
   
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
