# List my current mentoring queue
# - https://exercism.org/mentoring/queue

function __exercism__mentoring__queue
    set help 'Usage: exercism mentoring queue [options]

Display your mentoring queue.

Options
    -c|--count  List the counts of mentoring requests by track.
    --dump      Dump the JSON queue data.'

    argparse --name='exercism mentoring queue' \
        'c/count' 'dump' 'h/help' -- $argv
    or return 1

    if set -q _flag_help
        echo $help
        return
    end

    set tracks_mentored (__exercism__api_call mentoring/tracks/mentored)
    if set -q _flag_count
        echo $tracks_mentored \
        | jq -r '.tracks[] | [.slug, .num_solutions_queued] | @csv' \
        | mlr --c2p --barred --implicit-csv-header label Track,Count
    else
        set slugs (echo $tracks_mentored | jq -r '.tracks[] | .slug')
        echo "Queued on your tracks: "(string join ", " $slugs)

        set json (__exercism__api_call "mentoring/requests")
        if set -q _flag_dump
            echo $json | jq .
        else
            echo $json \
            | TZ=UTC jq -L (realpath (status dirname)/../lib) -r '
                include "duration";
                .results
                | to_entries[]
                | [
                    .key + 1,
                    .value.track_title,
                    .value.exercise_title,
                    .value.student_handle,
                    (.value.updated_at | fromdateiso8601 | duration),
                    .value.uuid
                ]
                | @csv
            ' \
            | mlr --c2p --barred --implicit-csv-header \
                label "Num,Track,Exercise,Student,Waiting,UUID" \
                then put 'end {if (NR == 0) {print "Queue is empty"}}'
        end
    end
end
