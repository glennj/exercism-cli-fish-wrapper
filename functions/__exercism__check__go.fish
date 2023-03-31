function __exercism__check__go
    argparse --ignore-unknown t/track= -- $argv
    __exercism__test__validate_runner $_flag_track go ; or return 1

    set solution (jq -r '.files.solution[]' .exercism/config.json)

    __echo_and_execute go fmt $solution
    echo
    __echo_and_execute go vet .
    echo
    command -q staticcheck
    and __echo_and_execute staticcheck .

end
