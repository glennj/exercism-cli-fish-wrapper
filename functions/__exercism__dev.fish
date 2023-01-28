function __exercism__dev
    set help 'Usage: exercism dev <subcommand> [args...]

Track development subcommands.

  unimplemented  List the unimplemented practice exercises.'

    argparse --name="exercism dev" --stop-nonopt 'h/help' -- $argv
    or return 1

    if set -q _flag_help; or test (count $argv) -eq 0
        echo $help
        return
    end

    switch $argv[1]
        case help
            echo $help
        case unimplemented
            __exercism__dev__unimplemented $argv[2..]
        case '*'
            echo 'unknown subcommand' >&2
            return 1
    end
end
