function __exercism__dev
    set help 'Usage: exercism dev <subcommand> [args...]

Track development subcommands.

  difficulties   List the track\'s exercises and difficulties
  lychee         Run lychee lint checker
  unimplemented  List the unimplemented practice exercises.
  unimplemented --stats  List the unimplemented statistics from all tracks.
                         (uses `exercism stats`)'

    argparse --name="exercism dev" --stop-nonopt 'h/help' -- $argv
    or return 1

    if set -q _flag_help; or test (count $argv) -eq 0
        echo $help
        return
    end

    switch $argv[1]
        case help
            echo $help
        case difficulties
            __exercism__dev__difficulties $argv[2..]
        case lychee
            __exercism__dev__lychee
        case unimplemented
            __exercism__dev__unimplemented $argv[2..]
        case '*'
            echo 'unknown subcommand' >&2
            return 1
    end
end

function __exercism__dev__lychee
    __exercism__in_dev_root; or return 1
    set args --cache \
             --accept ..=299,429 \
             --suggest \
             --verbose \
             --require-https \
             --exclude-path /input/.lycheeignore \
             --user-agent "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/100.0.4896.75 Safari/537.36" \
          "/input/**/*.md" "/input/**/*.html" "/input/**/*.toml" "/input/**/*.json"
    docker run --init --rm -it --volume (pwd):/input lycheeverse/lychee $args
end


function __exercism__dev__difficulties
    argparse --name="exercism dev difficulties" 'h/help' 's/sort' -- $argv
    or return 1

    if set -q _flag_help
        exercism dev --help
        return
    end

    __exercism__in_dev_root; or return 1

    jq -r '.exercises.practice[] | [.slug, .difficulty] | @csv' config.json \
    | if set -q _flag_sort; sort -t, -n -k2; else; cat; end \
    | mlr --c2p --implicit-csv-header --barred --right-align-numeric \
        label exercise,diff \
        then cat -n \
    | less
end

function __exercism__dev_prob_specs_cache
    set -q XDG_CACHE_HOME
    and set cache_dir $XDG_CACHE_HOME
    or  set cache_dir $HOME/.cache

    set prob_specs_dir $cache_dir/exercism/configlet/problem-specifications
    echo $prob_specs_dir

    # this is taken from `configlet`
    # - not fully implemented in case of unclean working directory
    begin
        if test -d $prob_specs_dir
            pushd $prob_specs_dir
            git checkout main
            and git fetch --quiet
            and git merge --ff-only origin/main
        else
            mkdir -p $prob_specs_dir
            pushd (dirname $prob_specs_dir)
            git clone --depth 1 --single-branch -- https://github.com/exercism/problem-specifications
        end
        popd
    end >/dev/null 2>&1
end

# List track exercises with a different state than the problem specifications.

function __exercism__dev__unimplemented
    argparse --name="exercism dev unimplemented" 'h/help' 's/stats' -- $argv
    or return 1

    if set -q _flag_help
        exercism dev --help
        return
    end

    __exercism__in_dev_root; or return 1

    if set -q _flag_stats
        exercism stats | while read line
            echo $line | read slug rest
            test -d exercises/practice/$slug
            or echo $line
        end
        return
    end

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
