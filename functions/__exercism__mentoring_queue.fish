# List my current mentoring queue
# - https://exercism.org/mentoring/queue

function __exercism__mentoring_queue
    set queue (
        __exercism__api_call "/mentoring/requests" \
        | jq -r '
            .results[] |
            [.track_title, .exercise_title, .student_handle, (.updated_at | fromdateiso8601 | strflocaltime("%F %T")), .url] |
            @csv
        ' 
    ) 
    if test (count $queue) -gt 0
        printf '%s\n' "Track,Exercise,Student,Date,RequestURL" $queue \
        | mlr --c2p --barred sort -f Date then cat
    else
        echo "Queue is empty"
    end
end
