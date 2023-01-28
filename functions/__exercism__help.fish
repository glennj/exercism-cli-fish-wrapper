# Show some help for the wrapper, then show command exercism help

function __exercism__help
    if test (count $argv) -gt 0
        exercism $argv[1] --help
    else
        echo 'Usage: exercism <subcommand> [args...]

This is a wrapper around the Exercism command line interface.

Commands that override or augment CLI commands:
  download               Download the solution and change directory there.
  submit                 Submit your solution.
  open                   Open your solution\'s iterations in a browser.

Additional commands for interacting with solutions
  test                  Run the tests.
  publish               Mark the exercise as complete.
  refresh               Re-download the solution.
  iterations            List the submitted iterations.
  last-test-run         Data about the most recent test run.
  metadata              Dump exercism\'s data.

Subcommands for keeping up-to-date solutions
  sync                  Update the exercises for upstream changes.
  test-all              Test all downloaded exercises for a track.
  missing               List exercises not downloaded for a track.
  cleanup               Cleanup build artifacts.
  tracks                List exercism tracks and your progress.

Mentoring subcommands
  mentoring queue       Show your mentoring queue.
  mentoring inbox       List your mentoring workspace.
  mentoring discussion  Display the posts of a mentoring session.

Track development
  dev unimplemented     List the unimplemented practice exercises.

Use `command exercism help` for help about the CLI itself.'
    end
end
