# List all Exercism tracks, and the progress of each.
# - https://exercism.org/journey 

function __exercism__tracks
    set help 'Usage: exercism tracks [options]

List your progress through exercism\'s tracks.

Options
    -a|--all    Show all tracks; default is tracks you\'ve joined.'

    argparse --name="exercism tracks" 'h/help' 'a/all' -- $argv
    or return 1

    if set -q _flag_help
        echo $help
        return
    end

    set show_all false
    set -q _flag_all; and set show_all true

    __exercism__api_call "/tracks" \
    | jq -r --argjson show_all $show_all '
        .tracks[]
        | (.num_learnt_concepts//0) as $c
        | (.num_completed_exercises//0) as $e
        | [
            .slug,
            (if .is_joined then "yes" else "no" end),
            "\($c)/\(.num_concepts)",
            "\($e)/\(.num_exercises)",
            (100 * ($e / .num_exercises) | round)
        ]
        | select($show_all or .[1] == "yes")
        | @csv
    ' \
    | mlr --c2p --right --implicit-csv-header \
        label Track,Joined,Concepts,Exercises,Progress \
        then sort -r Joined -nr Progress -f Track
end
