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

- [Usale](#Usage)
- [Deployment](#deployment)
- [Running Halpy Locally](#running-halpy-locally)
- [Configuration](#configuration)
- [Scripting](#scripting)
- [Notes](#notes)

## Usage
Halpy, like Hubot, understnads commands defined in indiivdual scripts. Thos scripts can be written by end users (like EDGI) or provided by external packages. Commands are issued by a user in a Slack channel who types `@halpy COMMANDNAME OPTIONS`.  So far we mostly use the commands we have written ourselves:

- `scripts/zoom-scratch.coffee` provides several new commands for interacting with the Zoom video conferencing software. For the time being they are named `zoom test` instead of just `zoom`, in order to distinguish them from previous generations of the commands.  The new commands are: 
  - `zoom test me now -t Meeting Topic` or `zoom test me [Date Descriptor] [for Time Descriptor] -t Meeting Topic`. Like the old `zoom me now` command, these commands create a new meeting, and recording can be turned on with either `-r` or `record` anywhere in the command. The exciting advance is that we can now provide a date for a future meeting, and we can also set the length of scheduled meetings with a time descriptor. Date descriptions are quite flexible, and take a vairety of forms such as "next Friday at 15:00", "September 15 at 3:00PM EDT," or "2019-09-15". ISO timestamps are also accepted. The time descriptor should take the form "for n minutes" or "for n hours", i.e., "for 120 minute" or "for 2 hours". The length `n` needs to be an integer so for 1.5 hr meetings please use `90 minutes` instead.
  - `zoom ls` and `zoom list` both return a list of upcoming zoom meetings along with their join links.  By defualt it lists meetings for the next 7 days, but this can be changed by providing a number anywhere after the command, e.g. `zoom ls next 14 days` or `zoom list 14`, which wil lboth list all upcoming meetings for the next 14 days.
  - A scond set of commands is also under development. These commands all start with `zoom report` and are aimed at producing recurring reminders for monthly reports.  We hope to use this work to allow for other recurring reminders; we might also take this opportunity to make more streamlined use of our slack channels, e.g. by creating an ew hcannel for reports only, and alerting select other channels when a working group report gets handed in.
    - In the current implementation, the report text is set within a halpy script. THe assumption is that someone will initiate a monthly report reminder and set the @-mentions to be used for the current month.  The initial reminder will go out on a set date -- most likely the 25th of them onth -- and subsequent reminders will be issued every following day until the report has been submitted. Users who hav ealready submitted their reports, or who have been added to the listo f @-mentions in error, can turn off subsequent messages by clicking a reaction emoji at the bottom of original message. Most of this is unimplemented and none of it has been user-tested!


## Deployment

- Halpy is auto-deployed to Heroku from `master` branch. (See: [Heroku Docs][autodeploy-docs]). THere is no CI testing set up, and we have not implemented any tests for any of the code(see "TODO" section) 

   [autodeploy-docs]: https://devcenter.heroku.com/articles/github-integration#automatic-deploys

## Running Halpy Locally

Halpy uses the `dotenv` package to facilitate local development. Make sure to run `npm install -d` to enstal lthe development dependencies, and then copy [sample.env](./sample.env) to **.env** and replace the dummy values with the real ones, which you can find on Halpy's Heroku deployment page.  It's recommended *not* to use Halpy's slack token, but instead to use the token associated with `halpy-ng`, which is a Slack integratin we set up for bot development purposes. If you need help finding these values, please ask in Slack.

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

Halpy scripts can be written in coffeescript or javascript, though mostexample scripts found on the web are in Coffeescript, so that may be an easier option for many purposes. Our in-house scripts are found in hte `scripts/` directory, and are probably the best place to start for new development.

It would be nice to have a slightly better architecture for these script iles, which currently are organized somewhat randomly.  

An example script is included at `scripts/example.coffee`, so check it out to
get started, along with the [Scripting Guide][scripting-docs].

Be a ltitle careful folowing examples from the web, as the Hubot API has changed rectnly and most scripts have not yet been updated.  

[scripting-docs]: https://github.com/github/hubot/blob/master/docs/scripting.md

## Notes

* We use the [Probot: Settings
  plugin](https://github.com/apps/settings) to allow repo settings via
  pull request using [`.github/settings.yml`](.github/settings.yml).
  
## TODO

There's lots of work left to do here, including:
- Set up Tests!
- Add the ability to modify/delete existing Zoom meetings, or at least provide the meeting edit link
- finish the report reminder!
- figure out what other tasks can be automated (e.g., can halpy listen to special channels & record certain messages to a doc for editing later)
