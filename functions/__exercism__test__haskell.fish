function __exercism__test__haskell
    argparse --ignore-unknown track= help -- $argv
    set -q _flag_help; and return

    __exercism__test__validate_runner $_flag_track stack; or return 1
    __echo_and_execute stack test
end
