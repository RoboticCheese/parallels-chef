Parallels Cookbook
==================
[![Cookbook Version](https://img.shields.io/cookbook/v/parallels.svg)][cookbook]
[![Build Status](https://img.shields.io/travis/RoboticCheese/parallels-chef.svg)][travis]
[![Code Climate](https://img.shields.io/codeclimate/github/RoboticCheese/parallels-chef.svg)][codeclimate]
[![Coverage Status](https://img.shields.io/coveralls/RoboticCheese/parallels-chef.svg)][coveralls]

[cookbook]: https://supermarket.chef.io/cookbooks/parallels
[travis]: https://travis-ci.org/RoboticCheese/parallels-chef
[codeclimate]: https://codeclimate.com/github/RoboticCheese/parallels-chef
[coveralls]: https://coveralls.io/r/RoboticCheese/parallels-chef

A Chef cookbook for Parallels.

Requirements
============

An OS X machine that can run Parallels and Chef >= 12.5 (or Chef ~> 12.0 and
the compat_resource cookbook) are required.

Usage
=====

Either add the default recipe to your run_list or use the custom resources
directly in a recipe of your own.

Recipes
=======

***default***

Installs Parallels, with an optional license key and/or at an optional major
version.

Attributes
==========

***default***

A specific major version of Parallels (e.g. '11', '10', etc.) can be installed
if you so desire:

    default['parallels']['app']['version'] = nil

A valid license key can be provided:

    default['parallels']['config']['license'] = nil

Resources
=========

***parallels***

A parent resource that wraps both installation and configuration.

Syntax:

    parallels 'default' do
        version '11'
        license 'abcd-efgh-ijkl-mnop'
        action [:install, :configure]
    end

Actions:

| Action       | Description                           |
|--------------|---------------------------------------|
| `:install`   | Install the app                       |
| `:remove`    | Uninstall the app                     |
| `:configure` | Configure with a license, if provided |

Properties:

| Property | Default                  | Description                         |
|----------|--------------------------|-------------------------------------|
| version  | `nil`                    | A specific major version to install |
| license  | `nil`                    | A Parallels license key             |
| action   | `[:install, :configure]` | Action(s) to perform                |

***parallels_app***

Used to install or remove Parallels.

Syntax:

    parallels_app 'default' do
        version '9'
        action :install
    end

Actions:

| Action     | Description       |
|------------|-------------------|
| `:install` | Install the app   |
| `:remove`  | Uninstall the app |

Properties:

| Property | Default    | Description                         |
|----------|------------|-------------------------------------|
| version  | `'11'`\*   | A specific major version to install |
| action   | `:install` | Action(s) to perform                |

* Parallels Desktop 11 is the latest version as of this writing. The default
  version is hardcoded for now, but work may be done in the future to have it
  found dynamically during the Chef run.

***parallels_config***

Used to register an optional license with Parallels.

Syntax:

    parallels_config 'default' do
        license 'abcd-efgh-ijkl-mnop'
        action :create
    end

Actions:

| Action    | Description                           |
|-----------|---------------------------------------|
| `:create` | Configure with a license, if provided |

Properties:

| Property | Default   | Description             |
|----------|-----------|-------------------------|
| license  | `nil`     | A Parallels license key |
| action   | `:create` | Action(s) to perform    |

Contributing
============

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Add tests for the new feature; ensure they pass (`rake`)
4. Commit your changes (`git commit -am 'Add some feature'`)
5. Push to the branch (`git push origin my-new-feature`)
6. Create a new Pull Request

License & Authors
=================
- Author: Jonathan Hartman <j@p4nt5.com>

Copyright 2015-2016 Jonathan Hartman

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
