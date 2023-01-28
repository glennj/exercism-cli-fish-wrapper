# List my mentoring workspace
# - https://exercism.org/mentoring/inbox
#
# option:
#   --inbox     get "Inbox" discussions
#   --student   get "Awaiting student" discussions
#   --finished  get "Finished" discussions
#   -o --order  sort the discussions
#               one of ["recent", "oldest", "student", "exercise"]
#   --max=n     return a max number of pages of discussions:
#               example: most recently ended discussion
#                 --finished --order=recent --num=1

function __exercism__mentoring_inbox
    argparse --name="exercism mentoring inbox" \
        'h/help' 'inbox' 'student' 'finished' 'o/order=' 'c/count' 'p/pages=' 'dump' -- $argv
    or return 1

    if set -q _flag_help
        echo "See: https://github.com/glennj/exercism-cli-fish-wrapper/blob/main/README.md#mentoring-sub--and-sub-subcommands"
        return
    end

    set -q _flag_pages; and set max $_flag_pages; or set max 5

    set num 0
    set -q _flag_inbox; and set num (math $num + 1)
    set -q _flag_student; and set num (math $num + 1)
    set -q _flag_finished; and set num (math $num + 1)
    if test $num -gt 1
        echo "Specify only one of {--inbox, --student, --finished}" >&2
        return 1
    end

    set box awaiting_mentor
    set -q _flag_student; and set box awaiting_student
    set -q _flag_finished; and set box finished

    set order recent
    switch "$_flag_order"
        case recent oldest student exercise
            set order $_flag_order
        case ""; true
        case '*'
            echo "order is one of: recent oldest student exercise"
            return 1
    end

    # remember the uuids for the next `exercism mentoring discussion` call
    set -g __exercism_mentoring_discussions

    set current 1
    while true
        set uri "/mentoring/discussions?status=$box&order=$order"
        if test $current -eq 1
            set uri "$uri&sideload=all_discussion_counts"
        else
            set uri "$uri&page=$current"
        end

        set json (__exercism__api_call $uri)

        echo $json \
        | jq -r '"\(.meta.current_page) \(.meta.total_pages)"' \
        | read current total

        if set -q _flag_dump
            echo $json | jq .
        else
            if test $current -eq 1
                test $total -lt $max; and set max $total
                echo $json \
                | jq '.meta | {awaiting_mentor_total, awaiting_student_total, finished_total}'
                set -q _flag_count; and return
            else
                echo "page: $current"
            end >&2

            echo $json \
            | jq -r '
                def duration: (now - .) as $d |
                    if   ($d < 3600)       then "\($d / 60 | floor) minutes"
                    elif ($d < 86400)      then "\($d / 3600 | floor) hours"
                    elif ($d < 86400 * 30) then "\($d / 86400 | floor) days"
                    else                        "\($d / (365 * 86400) * 12 | floor) months"
                    end;

                .results
                | to_entries[]
                | [
                    .key + 1,
                    .value.track.title,
                    .value.exercise.title,
                    .value.student.handle,
                    (.value.updated_at | fromdateiso8601 | duration),
                    .value.uuid,
                    .value.is_finished,
                    .value.is_unread
                  ]
                | @csv
            '
        end
        test $current -ge $max; and break
        set current (math $current + 1)
    end \
    | while read line
        set uuid (string split -f 6 , $line | string trim -c '"')
        set title (string split -f 3 , $line | string trim -c '"')
        set track (string split -f 2 , $line | string trim -c '"')
        set student (string split -f 4 , $line | string trim -c '"')
        set __exercism_mentoring_discussions $__exercism_mentoring_discussions (
            string join \v $uuid $title $track $student
        )
        echo $line
      end \
    | awk -F, -v OFS=, '{$1 = NR} 1' \
    | begin
        if set -q _flag_count; or set -q _flag_dump
            cat
        else
            mlr --c2p --barred --implicit-csv-header \
                label "Num,Track,Exercise,Student,Posted,UUID,finished,unread" \
                then put 'end {if (NR == 0) {print "No discussions '$box'"}}'
        end
    end
end
