# List my current mentoring queue
# - https://exercism.org/mentoring/queue

function __exercism__mentoring_queue
    set queue (
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
                (.updated_at | fromdateiso8601 | strflocaltime("%F %T")),
                (.updated_at | fromdateiso8601 | duration),
                .url
            ] | @csv
        ' 
    ) 
    if test (count $queue) -eq 0
        echo "Queue is empty"
    else
        string join \n $queue \
        | mlr --c2p --barred --implicit-csv-header \
            label "Track,Exercise,Student,Date,Waiting,RequestURL" \
            then sort -f Date \
            then cut -xf Date
    end
end
