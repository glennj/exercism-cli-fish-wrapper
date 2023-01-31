
function __exercism__notifications
    set help 'Usage: exercism notifications [options]

Show recent notifications from exercism.

Options
    --all   Show last 10 notifications.
            The default is to show only unread ones'

    argparse --name="exercism notifications" 'h/help' 'all' -- $argv
    or return 1

    if set -q _flag_help
        echo $help
        return
    end

    set results (
        __exercism__api_call /notifications \
        | jq -L (realpath (status dirname)/../lib) \
             --arg all "$_flag_all" \
             -r '
                  include "duration";
                  .results
                  | map(if $all == "" then select(.is_read == false) else . end)
                  | .[:10][]
                  | [
                      (.text | gsub("</?strong>"; "")),
                      (.created_at | fromdateiso8601 | duration),
                      .url,
                      (.is_read | not)
                      ]
                  | @tsv
                '
    )
    if test (count $results) -eq 0
        echo "No unread notifications"
    else
        string join \n $results \
        | while read -d \t text date url is_read
            printf '%s - ' $date
            test $is_read = true && set_color -o white
            echo $text
            test $is_read = true && set_color normal
            set_color green
            echo "    $url"
            set_color normal
            echo
        end
    end
end
