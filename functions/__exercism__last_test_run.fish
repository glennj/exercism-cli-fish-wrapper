function __exercism__last_test_run
    set help 'Usage: exercism last-test-run

Dump the solution\'s most recent test run.'

    argparse --name="exercism last-test-run" 'h/help' -- $argv
    or return 1

    if set -q _flag_help
        echo $help
        return
    end

    __exercism__has_metadata; or return 1
    set json (exercism metadata -i)
    if ! begin; echo $json | jq 'if has("error") then ("" | halt_error) else empty end'; end
        echo $json | jq -r .error.message
        return 1
    end
    set uri (
        echo $json \
        | jq -r '
            .solution.uuid as $soln |
            .iterations[-1].submission_uuid as $subm |
            "/solutions/\($soln)/submissions/\($subm)/test_run"
        '
    )
    __exercism__api_call $uri | jq .
end
