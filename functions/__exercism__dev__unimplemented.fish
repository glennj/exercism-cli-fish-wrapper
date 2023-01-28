# List track exercises with a different state than the problem specifications.

function __exercism__dev__unimplemented
    __exercism__in_dev_root; or return 1

    set prob_spec_dir (__exercism__dev_prob_specs_cache); or return 1

    set problem_specs (
        for e in $prob_spec_dir/exercises/*/
            printf '%s:%s\n' \
                (basename $e) \
                (test -f $e/.deprecated; and echo "deprecated"; or echo ok)
        end \
        | jq -Rs '
            rtrimstr("\n")
            | split("\n")
            | map(split(":"))
            | map({key: first, value: {problem_specifications: last}})
            | from_entries
        ' \
        | string collect
    )

    jq -r --argjson probspec $problem_specs '
        $probspec * (
          [
            ((.exercises.foregone // [])[] | {key: ., value: {track: "foregone"}}),
            (.exercises.practice[] | {key: .slug, value: {track: (.status // "ok")}})
          ]
          | from_entries
        )
        | map_values(select(.problem_specifications != .track))
        | map_values(select(.problem_specifications != "deprecated" or .track != null))
        | to_entries[]
        | [.key, (.value.problem_specifications // "-"), (.value.track // "-")]
        | @csv
    ' ./config.json \
    | mlr --c2p --barred --implicit-csv-header \
        cat -n \
        then label "#,Slug,ProbSpec,Track"
end
