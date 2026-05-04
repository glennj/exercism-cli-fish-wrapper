function __exercism__stats
    set help 'Usage: exercism stats [options] [exercise-slug]

Gather some statistics about Exercism exercises.

Options
    -d|--download
            Download all the track config.json files into the
            XDG_CACHE_HOME directory.
    -v|--verbose 
            Instead of stats, show the exercise difficulties for each track.
    -a|--all    Include exercises that only appear on one track.'

    argparse --name="exercism data" 'h/help' 'd/download' 'a/all' 'v/verbose' -- $argv
    or return 1

    if set -q _flag_help
        echo $help
        return
    end

    set cache_dir $XDG_CACHE_HOME
    if test -n $cache_dir; or not test -d $cache_dir
        set cache_dir $HOME/.cache
    end

    if not test -d $cache_dir/exercism/tracks
        set _flag_download true
    end

    if test (count $argv) -gt 0; and not set -q _flag_verbose
        exercism stats \
        | awk -v slug=$argv[1] 'NR == 1 || $1 == slug'
        return
    end

    if set -q _flag_download
        __exercism__api_call '/tracks' \
        | jq -r '.tracks[].slug' \
        | while read slug
            set track_dir $cache_dir/exercism/tracks/$slug
            set url https://raw.githubusercontent.com/exercism/{$slug}/refs/heads/main/config.json
            mkdir -p $track_dir
            printf "."
            curl --output $track_dir/config.json --silent --location $url
        end
        echo
        date > $cache_dir/exercism/tracks/latest_download
    end

    pushd $cache_dir/exercism/tracks

    jq -r '
        .slug as $track
        | .exercises.practice[]
        | select(.status != "deprecated")
        | [$track, .slug, .difficulty]
        | @csv
    ' */config.json \
    | if set -q _flag_verbose
        mlr --c2p --headerless-csv-input \
            label 'Track,Exercise,Difficulty' \
            then sort -f Exercise -n Difficulty -f Track \
        | if test (count $argv) -gt 0
            awk -v slug=$argv[1] 'NR == 1 || $2 == slug'
        else
            cat
        end

    else
        mlr --c2p --headerless-csv-input \
            label 'Track,Exercise,Difficulty' \
            then stats1 -a 'count,median,mean,stddev' -f Difficulty -g Exercise \
            then format-values -f '%.3f'\
            then sort -n Difficulty_median -f Exercise \
        | if set -q _flag_all
            cat
        else
            awk '$2 > 1'
        end
    end
    popd
end
