function __exercism__test__go
    argparse --ignore-unknown track= help bench -- $argv
    
    # `exercism test --help` calls this func with --help
    if set -q _flag_help
        echo '
Go testing:
    1. can take a `--bench` option to run benchmarks.
          $ exercism test --bench
    2. can take "passthrough" options as well, example:
          $ exercism test -v -tags someTag
       becomes
          $ go test -v -tags someTag'
      return
    end

    #set slug $argv[-1]
    set -e argv[-1]
    __exercism__test__validate_runner $_flag_track go ; or return 1

    if set -q _flag_bench
        set argv --bench=. --benchmem $argv
    end
    __echo_and_execute go test $argv
end
