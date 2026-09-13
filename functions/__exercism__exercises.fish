function __exercism__exercises
    set help 'Usage: exercism exercises

List your progress through the exercises in this track.

Options: 
    -a|--all      Show published exercises too.
    -v|--verbose  Extra verbosity'

    argparse --name="exercism exercises" 'h/help' 'a/all' 'v/verbose' -- $argv
    or return 1

    if set -q _flag_help
        echo $help
        return
    end

    set track_root (__exercism__get_current_track_root); or return 1
    set track (basename $track_root)
    set args /tracks/{$track}/exercises'?'sideload=solutions
    set -q _flag_verbose; and set args --verbose $args

    __exercism__api_get $args \
    | jq '
        .solutions as $s
        | .exercises
        | map({
            key: .slug,
            value: {
                title: (.title + if .is_recommended then " (*)" else "" end),
                slug: .slug,
                difficulty,
                status: ""
            }
        })
        | from_entries as $e
        | reduce $s[] as $soln ($e; .[$soln.exercise.slug]["status"] = $soln.status)
        | to_entries | map(.value)
    ' \
    | mlr --j2p --barred cat then put '
        @total = NR;
        $status == "published" || $status == "completed" {@completed += 1}
        end {emitf @completed, @total, @progress}
    ' \
    | if set -q _flag_all
        cat
    else
        grep -vEw 'published|deprecated'
    end
end
