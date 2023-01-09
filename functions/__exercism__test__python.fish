function __exercism__test__python
    argparse t/track= -- $argv
    __exercism__test__validate_runner $_flag_t python3; or return 1

    __echo_and_execute python3 -m pytest *_test.py
end
