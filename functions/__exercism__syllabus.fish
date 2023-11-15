function __exercism__syllabus
    set help 'Usage: exercism syllabus

Create a concepts directory, linking the concept to the relevant exercise README.'

    argparse --name="exercism syllabus" 'h/help' -- $argv
    or return 1

    if set -q _flag_help
        echo $help
        return
    end

    set track_root (__exercism__get_current_track_root); or return 1
    pushd $track_root
    set track (basename $track_root)

    set config https://raw.githubusercontent.com/exercism/{$track}/main/config.json

    mkdir -p _concepts
    and pushd _concepts
    and begin
        curl -s $config | jq -r '
            (.concepts | map({key:.slug, value:.name}) | from_entries) as $C
            | .exercises.concept[]
            | .slug as $S
            | .concepts[]
            | select(in($C))
            | "ln -fs ../\($S)/README.md \"\($C[.] | gsub("/"; "-"))\""
        ' | source
    end
    and ls -l
    and popd

    popd
end
