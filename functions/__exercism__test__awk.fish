function __exercism__test__awk
    argparse t/track= -- $argv
    __exercism__test__validate_runner $_flag_t gawk; or return 1
    __exercism__test__bash --track=$_flag_track $argv
end
