function __exercism__test__julia
    argparse --ignore-unknown t/track= -- $argv
    __exercism__test__validate_runner $_flag_t julia; or return 1
    __echo_and_execute julia runtests.jl
end
