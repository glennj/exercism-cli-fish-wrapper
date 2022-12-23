# An `exercism` wrapper for fish

This provides additional subcommands that I find useful to improve my experience working locally.

## A typical workflow

```sh
(~)$ cd (exercism workspace)
(~/s/e/exercism)$ cd wren             # working on the wren track
(~/s/e/e/wren)$ exercism missing      # I've _almost_ finished it
clock
(~/s/e/e/wren)$ exercism download --track=wren --exercise=clock
(~/s/e/e/w/clock)$ #...edit/test...
(~/s/e/e/w/clock)$ exercism submit
(~/s/e/e/w/clock)$ exercism open      # see how it looks online
(~/s/e/e/w/clock)$ exercism publish   # Done!
```
Now, what does Exercism know about this exercise?
```sh
(~/s/e/e/w/clock)$ exercism metadada
{
  "solution": {
    "uuid": "73af9a29bd774aca8f6ed4f0446d231b",
    "private_url": "https://exercism.org/tracks/wren/exercises/clock",
    "public_url": "https://exercism.org/tracks/wren/exercises/clock/solutions/glennj",
    "status": "published",
    "mentoring_status": "none",
    "published_iteration_head_tests_status": "passed",
    "has_notifications": false,
    "num_views": 0,
    "num_stars": 0,
    "num_comments": 0,
    "num_iterations": 3,
    "num_loc": 0,
    "is_out_of_date": false,
    "published_at": "2022-07-16T15:58:05Z",
    "completed_at": "2022-07-16T15:58:05Z",
    "updated_at": "2022-07-16T15:58:06Z",
    "last_iterated_at": "2022-07-16T15:57:55Z",
    "exercise": {
      "slug": "clock",
      "title": "Clock",
      "icon_url": "https://dg8krxphbh767.cloudfront.net/exercises/clock.svg"
    },
    "track": {
      "slug": "wren",
      "title": "Wren",
      "icon_url": "https://dg8krxphbh767.cloudfront.net/tracks/wren.svg"
    }
  }
}
```

## Subcommands

All gloriously tab-completed.

### override or augment existing `exercism` subcommands:

* `download`
    - after downloading, cd to the solution directory
* `submit`
    - with no arguments, uploads the solution file from .exercism/config.json
* `open`
    - open your solution's iterations page in a browser

### additional subcommands for interacting with solutions

* `test`
    - run test suite for this exercise
    - only some tracks currently supported (the ones I've joined)
* `publish`
    - mark the exercise as complete, and enables comments on the public solution
    - option `--no-comment` prevents enabling comments
* `refresh`
    - re-download the current solution (based on $PWD)
    - I use this mainly to refresh the .exercism/ directory
    - option `--all` to refresh all track solutions.
* `iterations`
    - list the iterations for a solution
        - option `-p|--publish` allows specifying which iteration(s) are published
            - bare `-p` publishes all iterations
            - option `-p3` (or `--publish=3`) publishes the 3rd one
            - [no space allowed between `-p` and the iteration][optional-arg] (this is a fish requirement)
    - in the track root
        - option `-a|--all` enables operations for all exercises
        - option `-p|--publish` publishes all iterations for all exercises
            - there is a sleep in the loop to avoid getting rate limited, so this can be slow.
        - without `-p`
            - option `-v|--verbose` will list iteration for each exercise
            - without `-v`, count the number of unpublished iterations for each exercise.
* `test-run`
    - show the data about the test run of the last iteration.
* `metadata`
    - a dump of the exercism backend's data about an exercise
    - option `-i` to also dump iteration data

### subcommands to feed my obsession at keeping up-to-date solutions

* `sync`
    - updates the exercise
        - this is like clicking "See what's changed" in the "This exercise has been updated..." banner, then clicking the "Update exercise" button
    - requires the presence of the .exercism/ directory: you may need to `exercism refresh` first
    - options:
        - `--status` to display current sync status
        - `--update` to perform the sync
        - `--all` to consider all exercises in the track
* `test-all`
    - run test suite for all downloaded exercise in a track
    - only some tracks currently supported (the ones I've joined)
* `missing`
    - show track exercises that are not currently downloaded
* `cleanup`
    - cleanup build artifacts from track exercises
    - useful to remove huge node_modules subdirectories (unless you use pnpm)
    - not all tracks supported
* `tracks`
    - list all Exercism tracks, and your progress through each.
    - option `-j|--joined` to limit the output to only tracks you've joined.

### mentoring sub- and sub-subcommands

This subcommand is itself subdivided.

* `mentoring queue`
    - show your current mentoring queue, sorted by age
    - option `-c|--count` shows only the count of requests by track
* `mentoring inbox`
    - list the discussions in your mentoring workspace
    - options:
        - `--inbox` shows the discussions awaiting you, the mentor
        - `--student` shows discussions awaiting them
        - `--finished` shows finished discussions
        - `-o|--order` specifies the sort order: recent, oldest, student, exercise
        - `-c|--count` shows only the count by status
        - `-p|--pages` max number of pages to fetch (default 5)
* `mentoring discussion`
    - display the posts of the discussion
    - it is necessary to call `mentoring inbox` first
    - options: one of these is required:
        - `-u|--uuid` to provide a uuid from the `inbox` output
        - `-i|--index` to provide an index number

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

- [exercism][exercism] of course!
- curl
- [jq][jq]
- [miller][miller]
    - to print tables with pretty boxes.
- specific commands for testing on your track (see the [`test-all`][test-all] function)
- for `mentoring discussions` rendering of posts:
    - ruby
    - [colorize][colorize] gem
    - [html-to-text][html-to-text]


[exercism]: https://exercism.org/docs/using/solving-exercises/working-locally
[jq]: https://stedolan.github.io/jq/
[miller]: https://miller.readthedocs.io/en/latest/
[optional-arg]: https://fishshell.com/docs/current/cmds/argparse.html?highlight=parse#note-optional-arguments
[colorize]: https://github.com/fazibear/colorize
[html-to-text]: https://github.com/html-to-text/node-html-to-text
[test-all]: ./functions/__exercism__test_all.fish
