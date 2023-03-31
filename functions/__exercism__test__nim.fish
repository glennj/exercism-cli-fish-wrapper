function __exercism__test__nim
    argparse --ignore-unknown track= help -- $argv
    set -q _flag_help; and return

    __exercism__test__validate_runner $_flag_track nim; or return 1
    __echo_and_execute nim c -r test_*.nim
end
