# List my current mentoring queue
# - https://exercism.org/mentoring/queue

function __exercism__mentoring_queue
    argparse --name='exercism mentoring queue' \
        'c/count' -- $argv
    or return 1

    set tracks (__exercism__api_call /mentoring/tracks/mentored)
    if set -q _flag_count
        echo $tracks \
        | jq -r '.tracks[] | [.slug, .num_solutions_queued] | @csv' \
        | mlr --c2p --barred --implicit-csv-header label Track,Count
    else
        set slugs (echo $tracks | jq -r '.tracks[] | .slug')
        echo "Queued on your tracks: "(string join ", " $slugs)

        __exercism__api_call "/mentoring/requests" \
        | jq -r '
            def duration: (now - .) as $d |
                if   ($d < 3600)       then "\($d / 60 | floor) minutes"
                elif ($d < 86400)      then "\($d / 3600 | floor) hours"
                elif ($d < 86400 * 30) then "\($d / 86400 | floor) days"
                else                        "\($d / (365 * 86400) * 12 | floor) months"
                end;

            .results[] |
            [
                .track_title,
                .exercise_title,
                .student_handle,
                (.updated_at | fromdateiso8601 | duration),
                .uuid
            ] | @csv
        ' \
        | mlr --c2p --barred --implicit-csv-header \
            label "Track,Exercise,Student,Waiting,UUID" \
            then put 'end {if (NR == 0) {print "Queue is empty"}}'
    end
end
