sensu-cli
=========

Command-line interface to the Sensu monitoring framework's REST [API](https://github.com/sensu/sensu/wiki/Sensu%20API).


This is very very early stages. I would not suggest using this yet. It's being
put on github now for anyone in the Sensu community that may be interested in
hacking on it.

Config
------

- Set SENSU_API_URL environment variable or specify with --sensu-api-url=

Examples
--------

### Get Help

    ./sensu-cli.rb


### List active events

    ./sensu-cli.rb events  --sensu-api-url='http://sensu.dom.tld:4567'
    WARNING host1 http_check
    Output: HttpCheck WARNING: http://127.0.0.1/ did not return quickly enough.

    CRITICAL host2 https_check
    Output:  HttpsCheck CRITICAL: https://google.com timed out.

### Trigger a check execution

    ./sensu-cli.rb checks request check_name subscribers1,sub2

Author
------

* [Joe Miller](https://twitter.com/miller_joe) - http://joemiller.me / https://github.com/joemiller

License
-------

    Author:: Joe Miller (<joeym@joeym.net>)
    Copyright:: Copyright (c) 2012 Joe Miller
    License:: Apache License, Version 2.0

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.