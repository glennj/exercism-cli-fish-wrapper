# List my current mentoring queue
# - https://exercism.org/mentoring/queue

function __exercism__mentoring__queue
    set help 'Usage: exercism mentoring queue [options]

Display your mentoring queue.

Options
    -c|--count       List the counts of mentoring requests by track.
    -t T|--track=T   Filter list by given track.
    --dump           Dump the JSON queue data.'

    argparse --name='exercism mentoring queue' \
        'c/count' 't/track=' 'dump' 'h/help' -- $argv
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
        return
    end

    # remember the data for the next `exercism mentoring request` call
    set -g __EXERCISM__MENTORING_REQUESTS

    set slugs (echo $tracks_mentored | jq -r '.tracks[] | .title')
    echo "Queued on your tracks: "(string join ", " $slugs)

    set json (__exercism__api_call "mentoring/requests")

    set __EXERCISM__MENTORING_REQUESTS (echo $json | jq -c '.results[]')

    if set -q _flag_dump
        echo $json | jq .
    else
        # TODO handle paginated response
        set results (
            echo $json \
            | TZ=UTC jq -L (realpath (status dirname)/../lib) \
                        --arg track "$(string lower $_flag_track)" \
                        -r \
            '
                include "duration";
                .results
                | to_entries[]
                | select(
                    $track == "" or
                    $track == (.value.track.title | ascii_downcase)
                )
                | [
                    .key + 1,
                    .value.track.title,
                    .value.exercise.title,
                    .value.student.handle,
                    (.value.updated_at | fromdateiso8601 | duration),
                    .value.url
                ]
                | @csv
            '
        )
        if test (count $results) -eq 0
            if set -q _flag_track
                echo "No $_flag_track requests in first $(count $__EXERCISM__MENTORING_REQUESTS)."
            else
                echo "Queue is empty"
            end
        else
            string join \n $results \
            | mlr --c2p --barred --implicit-csv-header \
                label "Num,Track,Exercise,Student,Waiting,URL"
        end
    end
end
