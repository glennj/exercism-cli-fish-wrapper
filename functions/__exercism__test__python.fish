function __exercism__test__python
    argparse --ignore-unknown track= help -- $argv
    set -q _flag_help; and return

    __exercism__test__validate_runner $_flag_track python3; or return 1

    __echo_and_execute python3 -m pytest *_test.py
end
