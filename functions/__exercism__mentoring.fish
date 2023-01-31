function __exercism__mentoring
    set help 'Usage: exercism mentoring <subcommand> [args...]

Mentoring subcommands.

  queue       Show your mentoring queue
  inbox       List your mentoring workspace.
  overview    Your notifications, queue and inbox.
  discussion  Display the posts of a mentoring session.'

    argparse --name="exercism mentoring" --stop-nonopt 'h/help' -- $argv
    or return 1

    if set -q _flag_help; or test (count $argv) -eq 0
        echo $help
        return
    end

    switch $argv[1]
        case help;    echo $help
        case queue;   __exercism__mentoring__queue $argv[2..]
        case inbox;   __exercism__mentoring__inbox $argv[2..]
        case discussion
            __exercism__mentoring__discussion $argv[2..]
        case overview
            __exercism__notifications
            __exercism__mentoring__queue
            __exercism__mentoring__inbox
        case '*'
            echo 'unknown subcommand' >&2
            return 1
    end
end
