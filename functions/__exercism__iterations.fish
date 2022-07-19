# Info about a solution's iterations
#
# options:
#   -p --publish         : publish all iterations
#   -pidx --publish=idx  : publish a specific iteration index
#                          - short option requires no space
#                          - long option requires equal sign
#                          - see https://fishshell.com/docs/current/cmds/argparse.html?highlight=parse#note-optional-arguments

function __exercism__iterations
    __exercism__has_metadata; or return 1

    argparse --name="exercism iterations" 'p/publish=?' -- $argv
    or return 1

    if set -q _flag_publish
        test (count $_flag_publish) -eq 0; and set _flag_publish ""
        set uuid (jq -r '.id' .exercism/metadata.json)
        set uri "/solutions/$uuid/published_iteration?published_iteration_idx=$_flag_publish"
        echo $uri
        __exercism__api_call -X PATCH $uri > /dev/null
    end

    exercism metadata --iterations \
    | jq -r '
        .iterations[] | [
            .idx,
            (.created_at | fromdateiso8601 | localtime | mktime | strftime("%F %T")),
            (if .status == "no_automated_feedback" then "OK" else .status end),
            (if .tests_status == "not_queued" then "n/a" else .tests_status end),
            .is_published,
            .submission_method
        ] | @csv'  \
    | mlr --c2p --barred --implicit-csv-header label idx,date,status,tests,published,method
end
