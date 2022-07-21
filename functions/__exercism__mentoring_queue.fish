# List my current mentoring queue
# - https://exercism.org/mentoring/queue

function __exercism__mentoring_queue
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
            .url
        ] | @csv
    ' \
    | mlr --c2p --barred --implicit-csv-header \
        label "Track,Exercise,Student,Waiting,RequestURL" \
        then put 'end {if (NR == 0) {print "Queue is empty"}}'
end
