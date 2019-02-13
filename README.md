[![Code of Conduct](https://img.shields.io/badge/%E2%9D%A4-code%20of%20conduct-blue.svg?style=flat)](https://github.com/edgi-govdata-archiving/overview/blob/master/CONDUCT.md)

# Halpy

Halpy is a chat bot used by the Environmental Data & Governance
Initiative (EDGI) to assist us in our Slack chat.

It is built on the [Hubot][hubot] framework and deployed on the [Heroku
platform][heroku] and lives here:
[`edgi-hubot.herokuapp.com`](https://edgi-hubot.herokuapp.com/)

[heroku]: http://www.heroku.com
[hubot]: http://hubot.github.com
[generator-hubot]: https://github.com/github/generator-hubot

## Table of Contents

- [Deployment](#deployment)
- [Running Halpy Locally](#running-halpy-locally)
- [Configuration](#configuration)
- [Scripting](#scripting)
- [Notes](#notes)

## Deployment

- Halpy is auto-deployed to Heroku from `master` branch. (See: [Heroku Docs][autodeploy-docs])

   [autodeploy-docs]: https://devcenter.heroku.com/articles/github-integration#automatic-deploys

## Running Halpy Locally

You can start Halpy locally by running this in your terminal:

    npm start

(Some plugins will not behave as expected unless the [environment
variables](#configuration) they rely upon have been set.)

You'll see some start up output and a prompt:

    [Sat Feb 28 2015 12:38:27 GMT+0000 (GMT)] INFO Using default redis on localhost:6379
    halpy>

Then you can interact with Halpy by typing `halpy help`.

    halpy> halpy help
    halpy help - Displays all of the help commands that halpy knows about.
    ...

It will also be serving a small website at:
[`localhost:8585`](http://localhost:8585)

### Configuration

A few scripts (including some installed by default) require environment
variables to be set as a simple form of configuration.

Each script should have a commented header which contains a "Configuration"
section that explains which values it requires to be placed in which variable.
When you have lots of scripts installed this process can be quite labour
intensive. The following shell command can be used as a stop gap until an
easier way to do this has been implemented.

    grep -o 'hubot-[a-z0-9_-]\+' external-scripts.json | \
      xargs -n1 -I {} sh -c 'sed -n "/^# Configuration/,/^#$/ s/^/{} /p" \
          $(find node_modules/{}/ -name "*.coffee")' | \
        awk -F '#' '{ printf "%-25s %s\n", $1, $2 }'

How to set environment variables will be specific to your operating system.
Rather than recreate the various methods and best practices in achieving this,
it's suggested that you search for a dedicated guide focused on your OS.

### Scripting

An example script is included at `scripts/example.coffee`, so check it out to
get started, along with the [Scripting Guide][scripting-docs].

For many common tasks, there's a good chance someone has already one to do just
the thing.

[scripting-docs]: https://github.com/github/hubot/blob/master/docs/scripting.md

## Notes

* We use the [Probot: Settings
  plugin](https://github.com/apps/settings) to allow repo settings via
  pull request using [`.github/settings.yml`](.github/settings.yml).
