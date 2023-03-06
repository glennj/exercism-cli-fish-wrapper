function __exercism__test__go
    argparse --ignore-unknown t/track= b/bench -- $argv
    __exercism__test__validate_runner $_flag_track go ; or return 1

    if set -q _flag_bench
        __echo_and_execute go test -v --bench=. --benchmem
    else
        __echo_and_execute go test -v
    end
end
