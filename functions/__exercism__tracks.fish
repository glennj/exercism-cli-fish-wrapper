# List all Exercism tracks, and the progress of each.
# - https://exercism.org/journey 

function __exercism__tracks
    __exercism__api_call "/tracks" \
    | jq -r ' 
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
        | @csv
    ' \
    | mlr --c2p --right --implicit-csv-header \
        label Track,Joined,Concepts,Exercises,Progress \
        then sort -r Joined -nr Progress -f Track
end
