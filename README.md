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

1. override or augment existing `exercism` subcommands:

    * `download`
        - after downloading, cd to the solution directory
    * `submit`
        - with no arguments, uploads the solution file from .exercism/config.json
    * `open`
        - open your solution's iterations page in a browser

2. additional subcommand for interacting with the website

    * `publish`
        - mark the exercise as complete, and enables comments on the public solution
    * `refresh`
        - re-download the current solution (based on $PWD)

3. subcommands to feed my obsession at keeping up-to-date solutions

    * `sync-status`
        - show which exercises in a track are out-of-date
    * `sync`
        - updates the exercise on the website
        - you must `exercism refresh` to download changes
    * `test-all`
        - run test suite for all downloaded exercise in a track
        - not all tracks currently supported
    * `missing`
        - show track exercises that are not currently downloaded
    * `cleanup`
        - cleanup build artifacts from track exercises 
        - useful to remove huge node_modules subdirectories (unless you use pnpm)
        - not all tracks supported

4. informational subcommands

    * `metadata`
        - a dump of the exercism backend's data about an exercise
    * `mentoring-queue`
        - show your current mentoring queue, sorted by age

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

## API calls

I have no special knowledge of the Exercism API. 
The enpoints were found just by reading https://github.com/exercism/website/blob/main/config/routes.rb

## Tools used herein

- curl
- [jq](https://stedolan.github.io/jq/)
- [miller](https://miller.readthedocs.io/en/latest/)
    - to print the mentoring queue with pretty boxes.
