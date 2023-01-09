function __exercism__test__nim
    argparse t/track= -- $argv
    __exercism__test__validate_runner $_flag_t nim; or return 1
    __echo_and_execute nim c -r test_*.nim
end
