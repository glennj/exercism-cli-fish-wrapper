# List a mentoring request
# - https://exercism.org/mentoring/requests/UUID
#
# Using `html-to-text` to render post as text
# https://www.npmjs.com/package/html-to-text

function __exercism__mentoring__request
    set help 'Usage: exercism mentoring request [options] <id>

Display a summary of a mentoring request.

The required argument <id> is the index number of the request
from the most recent `exercism mentoring queue` call

Options:
    --dump         Display the raw JSON response only.'

    argparse --name="exercism mentoring request" \
        'h/help' 'dump' -- $argv
    or return 1

    if set -q _flag_help; or test (count $argv) -eq 0
        echo $help
        return 1
    end
    if not string match -q --regex '^[[:digit:]]+$' $argv[1]
        echo $help
        return 1
    end
    if not set -q __EXERCISM__MENTORING_REQUESTS
        or test (count $__EXERCISM__MENTORING_REQUESTS) -eq 0
            echo "call `exercism mentoring queue` first" >&2
            return 1
    end
    if test $argv[1] -gt (count $__EXERCISM__MENTORING_REQUESTS)
        echo "invalid index" >&2
        echo "call `exercism mentoring queue` first" >&2
        return 1
    end

    if set -q _flag_dump
        echo $__EXERCISM__MENTORING_REQUESTS[$argv[1]] | jq .
        return
    end

    set info (
        echo $__EXERCISM__MENTORING_REQUESTS[$argv[1]] \
        | jq -r '.exercise.title, .track.title, .url, .student.handle, .solution.uuid, .tooltip_url'
    )
    set exercise $info[1]
    set track $info[2]
    set url $info[3]
    set student $info[4]
    set solution_uuid $info[5]
    set tooltip $info[6]

    set json (__exercism__api_call (string replace '/api/v2/' "" $tooltip))
    set info (
        echo $json \
        | jq -r '.student | .reputation, .num_total_discussions, .num_discussions_with_mentor'
    )
    set rep $info[1]
    set nsess $info[2]
    set usess $info[3]

    echo "$exercise on $track by $student"
    echo
    echo $json | jq -r '.student.track_objectives' | fold -s | sed 's/^/    | /'
    echo
    echo "$rep rep, mentored $nsess times, $usess by you."
    echo
    echo "Request: $url"
    echo "Download: exercism download --uuid=$solution_uuid"
end
