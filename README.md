sensu-api
=========

A sensu-cli that currently supports get requests

Features
--------
* Get Requests
* API interaction with info, stashes, events, clients and checks


Usage and Configuration
-----------------------
* There is one settings file for host, port and ssl
   
````
{
  "host": "127.0.0.1",
  "port": "4567",
  "ssl": false
}

````

* chmod +x bin/sensu
* Add the bin folder to your path for simple command execution

Examples
-----------
sensu --help   
sensu clients   
sensu clients --help   
sensu clients --name servername   
sensu info   
   
Contributions
-------------
Please provide a pull request.  


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
