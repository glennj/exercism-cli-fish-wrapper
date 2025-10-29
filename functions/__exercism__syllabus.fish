function __exercism__syllabus
    set help 'Usage: exercism syllabus

Create a concepts directory.'

    argparse --name="exercism syllabus" 'h/help' -- $argv
    or return 1

    if set -q _flag_help
        echo $help
        return
    end

    set track_root (__exercism__get_current_track_root); or return 1
    pushd $track_root
    set track (basename $track_root)

    mkdir -p _concepts
    and pushd _concepts

    set base https://raw.githubusercontent.com/exercism/{$track}/refs/heads/main

    curl -s {$base}/config.json \
    | jq -r '.concepts[] | [.slug, .name] | @tsv' \
    | while read -d \t slug name
        set filename {$name}.md
        if not test -f $filename
            set url {$base}/concepts/{$slug}/about.md 
            echo $url
            curl -s -o $filename $url
        end
    end

    popd
end
