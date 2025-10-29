# An `exercism` wrapper for fish

This provides additional subcommands that I find useful to improve my experience working locally.

## A typical workflow

```sh
(~)$ cd (exercism workspace)
(~/s/e/exercism)$ cd wren                    # working on the wren track
(~/s/e/e/wren)$ exercism exercises           # I've _almost_ finished it
+----------------------------+----------------------------+------------+-----------+
| title                      | slug                       | difficulty | status    |
+----------------------------+----------------------------+------------+-----------+
| Clock (*)                  | clock                      | easy       |           |
+----------------------------+----------------------------+------------+-----------+

+-----------+-------+
| completed | total |
+-----------+-------+
| 61        | 62    |
+-----------+-------+
(~/s/e/e/wren)$ exercism download -r     # get the "recommended" next exercise
(~/s/e/e/w/clock)$ #...edit/test...
(~/s/e/e/w/clock)$ exercism submit
(~/s/e/e/w/clock)$ exercism open         # see how it looks online
(~/s/e/e/w/clock)$ exercism publish      # Done!
```

## Subcommands

All gloriously tab-completed.

### override or augment existing `exercism` subcommands:

* `download`
    - after downloading, cd to the solution directory
    - you can omit the `--track` option if the function can figure it out
    - use the `--recommended` option to download the next recommended exercise
      (usually the first "available" exercise in the track)
* `test`
    - run test suite for this exercise
    - enhances the builtin `exercism test` with some custom behaviour for some tracks.
* `submit`
    - with no arguments, uploads the solution file from .exercism/config.json
* `open`
    - open your solution's iterations page in a browser

### additional subcommands for interacting with solutions

* `check`, `format`
    - run formatters and/or linters for this exercise
    - only some tracks currently supported
    - "format" is an alias for "check"
* `publish`
    - mark the exercise as complete, and enables comments on the public solution
* `refresh`
    - re-download the current solution (based on $PWD)
    - I use this mainly to refresh the .exercism/ directory
* `square1`
    - Destroy your current solution (!) and reset it back to its initial contents
* `iterations`
    - list the iterations for one or all solutions in a track
* `last-test-run`
    - show the data about the test run of the last iteration.
* `metadata`
    - a dump of the exercism backend's data about an exercise

### subcommands to feed my obsession at keeping up-to-date solutions

* `bulk-download`
    - bulk download all your solutions for a track.
    - handy for those who store their solutions in a git repo.
* `sync`
    - updates the exercise
        - this is like clicking "See what's changed" in the "This exercise has been updated..." banner, 
          then clicking the "Update exercise" button
    - requires the presence of the .exercism/ directory: you may need to `exercism refresh` first
* `test-all`
    - run test suite for all downloaded exercise in a track
    - only some tracks currently supported (the ones I've joined)
* `cleanup`
    - cleanup build artifacts from track exercises
    - useful to remove huge node_modules subdirectories (unless you use pnpm)
    - not all tracks supported
* `tracks`
    - list all Exercism tracks, and your progress through each.
* `exercises`
    - list the exercises, and your progress, for a track.
* `syllabus`
    - create a `_concepts` directory for a track,
      linking the Concept name to the exercise's README.
* `by-exercise`
    - create a `_by_exercise` directory mapping exercises you've
      completed to the tracks you've completed them in.

### commands related to your activity on exercism

* `achievements`
    - list your track trophies and badges
* `notifications`
    - list recent notifications
* `reputation`
    - recently awarded reputation

### mentoring sub- and sub-subcommands

This subcommand is itself subdivided.

* `mentoring queue`
    - show your current mentoring queue, sorted by age
* `mentoring request`
    - display a summary of a mentoring request
    - it is necessary to call `mentoring queue` first
* `mentoring inbox`
    - list the discussions in your mentoring workspace
* `mentoring discussion`
    - display the posts of the discussion
    - it is necessary to call `mentoring inbox` first
    - options exist to post to the thread, and to end the discussion.
* `mentoring overview`
    - display your unread notifications, mentoring queue and inbox.

### track development

* `dev unimplemented`
    - lists unimplemented, foregone or deprecated exercises.

### Github queries for the Exercism organization

* `github teams`
    - lists the teams you're a member of.
* `github team`
    - lists the members of a team.
* `github prs`
    - lists my open Exercism PRs
* `github issues`
    - lists my open Exercism issues

## fish setup

Add to `~/.config/fish/config.fish`:

```fish
set exercism_wrapper_home /path/to/the/exercism/wrapper/root
if not contains $exercism_wrapper_home/functions $fish_function_path
    set fish_function_path $exercism_wrapper_home/functions $fish_function_path
end
if not contains $exercism_wrapper_home/completions $fish_complete_path
    set fish_complete_path $exercism_wrapper_home/completions $fish_complete_path
end
set -e exercism_wrapper_home
```

## Tools used herein

- [exercism][exercism] and [fish][fish] of course!
- curl
- [jq][jq]
- [miller][miller]
    - to print tables with pretty boxes.
- [pup][pup] for parsing HTML (like jq for HTML)
- for `mentoring discussions` rendering of posts:
    - ruby
    - [colorize][colorize] gem
    - [@html-to/text-cli][html-to-text] npm package
- [gh][gh] for the Github queries

Assuming [fish][fish] and [Homebrew][brew] are already installed:
```sh
brew install exercism curl jq miller node gh
gem install colorize
npm install --global '@html-to/text-cli'
go install 'github.com/ericchiang/pup@latest'
```


[exercism]: https://exercism.org/docs/using/solving-exercises/working-locally
[fish]: https://fishshell.com
[jq]: https://stedolan.github.io/jq/
[miller]: https://miller.readthedocs.io/en/latest/
[optional-arg]: https://fishshell.com/docs/current/cmds/argparse.html?highlight=parse#note-optional-arguments
[colorize]: https://github.com/fazibear/colorize
[html-to-text]: https://github.com/html-to-text/node-html-to-text
[brew]: https://brew.sh
[pup]: https://github.com/ericchiang/pup
[gh]: https://cli.github.com
