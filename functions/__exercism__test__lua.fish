function __exercism__test__lua
    argparse --ignore-unknown track= help -- $argv
    set -q _flag_help; and return

    __exercism__test__validate_runner $_flag_track busted; or return 3
    __echo_and_execute busted .
end
