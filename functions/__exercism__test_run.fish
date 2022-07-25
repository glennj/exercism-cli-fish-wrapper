# Dump the solution's most recent test run
#
# options:
#   n/a

function __exercism__test_run
    __exercism__has_metadata; or return 1
    set uri (
        exercism metadata -i \
        | jq -r '
            .solution.uuid as $soln |
            .iterations[-1].submission_uuid as $subm |
            "/solutions/\($soln)/submissions/\($subm)/test_run"
        '
    )
    __exercism__api_call $uri | jq .
end
