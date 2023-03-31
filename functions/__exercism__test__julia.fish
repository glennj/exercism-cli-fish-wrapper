function __exercism__test__julia
    argparse --ignore-unknown track= help -- $argv
    set -q _flag_help; and return

    __exercism__test__validate_runner $_flag_track julia; or return 1
    __echo_and_execute julia runtests.jl
end
