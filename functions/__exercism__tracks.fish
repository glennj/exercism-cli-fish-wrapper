# List all Exercism tracks, and the progress of each.
# - https://exercism.org/journey 

function __exercism__tracks
    set help 'Usage: exercism tracks [options]

List your progress through exercism\'s tracks.

Options
    -a|--all    Show all tracks; default is tracks you\'ve joined.
    --students  Show the number of students enrolled.'

    argparse --name="exercism tracks" 'h/help' 'a/all' 'students' -- $argv
    or return 1

    if set -q _flag_help
        echo $help
        return
    end

    set show_all false
    set -q _flag_all; and set show_all true
    set bar_wid 24
    set labels Track,Joined,Concepts,Exercises,Progress,Bar
    set -q _flag_students; and set labels "$labels,Students"

    # Having to query each slug page individually is slow.
    # Show progress with dots.
    set -q _flag_students; and printf . >&2

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
    | while read -d , -a fields
        set bar (string repeat -n (math "floor($bar_wid * $fields[-1] / 100)") '=')
        test $fields[-1] -eq 100; and set suffix '!'; or set suffix '>'
        string join ',' $fields (printf '%-*s' (math $bar_wid + 1) "$bar$suffix")
    end \
    | if set -q _flag_students
        while read -d , slug rest
            printf . >&2
            printf '%s,%s,"%s"\n' $slug $rest (__exercism__tracks__students $slug)
        end
        echo >&2
    else
        cat
    end \
    | mlr --c2p --right --implicit-csv-header \
        label $labels \
        then sort -r Joined -nr Progress -f Track
end

function __exercism__tracks__students -a slug
    if not type -q pup
        echo "This uses pup to parse HTML: https://github.com/ericchiang/pup" >&2
        return 1
    end
    sleep 1
    curl -s https://exercism.org/tracks/(string replace -a '"' '' $slug) \
    | pup 'div.students span text{}' \
    | string match -r '\b[\d,]+\b'
end
