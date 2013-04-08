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

* There is one settings file for host, port and ssl that lives in your user directory ~/.sensu/settings.json

````
{
  "host": "127.0.0.1",
  "port": "4567",
  "ssl": false
}

````

Examples
-----------
````
sensu --help
sensu clients --name some_host --delete true
sensu clients --help
sensu clients --name servername
sensu silence --client some_host
sensu info
````
Contributions
-------------
Please provide a pull request.

TODO
----
* nicer output format
* support post for all applicable endpoints

Eventually I'd like to get to a cleaner input that mimicks the Chef Knife CLI   
current:   
sensu clients   
sensu clients --name NODE   
sensu clients --name NODE --delete true   
   
aspiration:   
sensu client list   
sensu client show NODE   
sensu client delete some_host   

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
