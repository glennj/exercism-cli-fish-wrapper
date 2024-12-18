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
  check, format         Execute any configured formatters and linters.
  publish               Mark the exercise as complete.
  refresh               Re-download the solution.
  square1               Reset the solution back to its initial contents.
  iterations            List the submitted iterations.
  last-test-run         Data about the most recent test run.
  metadata              Dump exercism\'s data.

Commands for keeping up-to-date solutions
  bulk-download         Bulk download new and updated solution for a track.
  sync                  Update the exercises for upstream changes.
  test-all              Test all downloaded exercises for a track.
  missing               List exercises not downloaded for a track.
  cleanup               Cleanup build artifacts.
  tracks                List exercism tracks and your progress.
  exercises             List the exercises and progress for a track.
  syllabus              Create a syllabus directory for a track.
  by-exercise           Create a directory mapping exercises to tracks.

Commands relating to your profile and activity
  achievements          List your track trophies and badges.
  notifications         List recent exercism notifications.
  reputation            Show your recent awards of reputation.

Mentoring subcommands
  mentoring queue       Show your mentoring queue.
  mentoring request     Show details of a mentoring request.
  mentoring inbox       List your mentoring workspace.
  mentoring discussion  Display the posts of a mentoring session.
  mentoring overview    Show notifications, queue and inbox.

Track development (WIP)
  dev unimplemented     List the unimplemented practice exercises.

Use `command exercism help` for help about the CLI itself.'
    end
end
