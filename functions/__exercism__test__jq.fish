function __exercism__test__jq
    argparse --ignore-unknown t/track= -- $argv
    __exercism__test__validate_runner $_flag_t jq; or return 1
    __exercism__test__bash --track=$_flag_track $argv
end
