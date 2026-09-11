# List all Exercism tracks, and the progress of each.
# - https://exercism.org/journey 

function __exercism__tracks
    set help 'Usage: exercism tracks [options]

List your progress through exercism\'s tracks.

Options
    -a|--all    Show all tracks; default is tracks you\'ve joined.
    -g|--get    Fetch track configs for all active tracks.
                They are cached in $XDG_CACHE_HOME/exercism/tracks/
    --students  Show the number of students enrolled.'

    argparse --name="exercism tracks" \
        'h/help' 'a/all' 'g/get' 'force' 'students' 'cache-dir' -- $argv
    or return 1

    if set -q _flag_help
        echo $help
        return
    end

    if set -q _flag_cache_dir
        __exercism__tracks__cache_dir
        return
    end

    if set -q _flag_get
        __exercism__tracks__get_configs $_flag_force
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

    __exercism__tracks__get_info $show_all \
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

function __exercism__tracks__cache_dir
    set cache_dir $XDG_CACHE_HOME
    if test -n $cache_dir; or not test -d $cache_dir
        set cache_dir $HOME/.cache
    end
    echo "$cache_dir/exercism/tracks"
end

function __exercism__tracks__get_configs -a force
    set cache_dir (__exercism__tracks__cache_dir)
    set track_slugs

    # invalidate cache after 30 days
    set last_download $cache_dir/latest_download
    if test (count $force) -gt 0; or not test -f $last_download
        set track_slugs (__exercism__tracks__get_slugs)
    else
        set past (cat $last_download)
        set now (date '+%s')
        if test (math $now - $past) -lt (math '30 * 24 * 60 * 60')
            echo "Track configs are relatively up-to-date. Use --force if needed" >&2
            return
        end
        set track_slugs (__exercism__tracks__get_info --slug)
    end

    for slug in $track_slugs
        set track_dir $cache_dir/$slug
        set url https://raw.githubusercontent.com/exercism/{$slug}/refs/heads/main/config.json
        mkdir -p $track_dir
        printf "."
        curl --output $track_dir/config.json --silent --location $url
    end
    echo
    date '+%s' > $last_download
end

function __exercism__tracks__get_slugs
    gh api graphql --paginate -f query='
        query($endCursor: String) {
        organization(login: "exercism") {
            repositories(first: 100, after: $endCursor) {
                pageInfo {
                    hasNextPage
                    endCursor
                }
                nodes {
                    name
                    object(expression: "HEAD:config.json") {
                        ... on Blob {
                            text
                        }
                    }
                }
            }
        }
    }' --jq '
        .data.organization.repositories.nodes[] 
        | select(.object.text != null) 
        | select((.object.text | try fromjson catch {}) .active == true) 
        | .name
    ' 
end

function __exercism__tracks__get_info -a show_all
    argparse --name="exercism track info" 's/slug' -- $argv
    or return 1

    set json (__exercism__api_get /tracks)

    if set -q _flag_slug
        echo $json | jq -r '.tracks[].slug'
    else
        echo $json \
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
        '
    end
end
