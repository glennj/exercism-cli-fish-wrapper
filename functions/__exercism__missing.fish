
function __exercism__missing
    set help 'Usage: exercism missing

Show all exercises in this track that have not been downloaded.'

    argparse --name="exercism missing" 'h/help' -- $argv
    or return 1

    if set -q _flag_help
        echo $help
        return
    end

    __exercism__in_track_root; or return 1
    set track (basename $PWD)

    set json (__exercism__api_call /tracks/{$track}/exercises)
    set here (string trim --right --chars / */)
    set results (
        for type in concept practice
            echo $json | jq -r --arg type $type --args '
                .exercises[]
                | select(
                    (.type == $type) and
                    (.slug | IN($ARGS.positional[]) | not)
                )
                | [
                    $type,
                    .title,
                    .difficulty,
                    ( if .is_unlocked
                    then "https://exercism.org\(.links.self)"
                    else "[locked]"
                    end
                    )
                ]
                | @csv
            ' $here
        end
    )
    if test (count $results) -eq 0
        echo "All $track exercises are present!"
    else
        string join \n $results \
        | mlr --c2p --implicit-csv-header \
            label Type,Exercise,Difficulty,Link
    end
end
