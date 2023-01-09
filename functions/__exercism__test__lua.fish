function __exercism__test__lua
    argparse t/track= -- $argv
    __exercism__test__validate_runner $_flag_t busted; or return 3
    __echo_and_execute busted .
end
