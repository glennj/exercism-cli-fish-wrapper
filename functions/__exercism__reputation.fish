function __exercism__reputation
    set help 'Usage: exercism reputation [options]

Show recent reputation from exercism.

Options
    --all   Show last 10 reputation awards.
            The default is to show only unseen ones.
    --mark  Mark all unseen reputation as seen.'

    argparse --name="exercism reputation" \
        'h/help' 'all' 'mark' -- $argv
    or return 1

    if set -q _flag_help
        echo $help
        return
    end

    if set -q _flag_mark
        set json (__exercism__api_call -X PATCH reputation/mark_all_as_seen)
        set _flag_all yes
    end

    set results (
        __exercism__api_call reputation \
        | jq -L (realpath (status dirname)/../lib) \
             --arg all "$_flag_all" \
             -r '
                  include "duration";
                  .results
                  | map(if $all == "" then select(.is_seen == false) else . end)
                  | .[:10][]
                  | [
                      (.created_at | fromdateiso8601 | duration),
                      .value,
                      if .is_seen then "" else "*" end,
                      (.text | gsub("</?strong>"; ""))
                    ]
                  | @csv
                '
    )
    if test (count $results) -eq 0
        echo "No unseen reputation"
    else
        string join \n $results \
        | mlr --c2p --barred --implicit-csv-header label When,Amount,S,What
    end
end
