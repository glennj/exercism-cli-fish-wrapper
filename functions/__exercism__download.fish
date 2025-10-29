# wraps the `exercism download` command
# - change the current directory
# - perform any track-specific tasks

function __exercism__download
    argparse --ignore-unknown --name="exercism download" \
        'uuid=' 't/track=' 'h/help' 'r/recommended' -- $argv
    or return 1

    set track ""
    if set -q _flag_help
        set argv --help $argv
    else if set -q _flag_uuid
        set argv --uuid=$_flag_uuid $argv
    else if set -q _flag_track
        set track $_flag_track
        set argv --track=$track $argv
    else if set track_root (__exercism__get_current_track_root)
        set track (basename $track_root)
        set argv --track=$track $argv
    end

    if set -q _flag_recommended
        set json (__exercism__api_call /tracks/{$track}/exercises); or return 1
        echo $json \
        | jq -r '.exercises[] | select(.is_recommended) | (.slug // ""), (.title // "")' \
        | begin; read exercise_slug; read exercise_name; end

        if test -n $exercise_slug
            echo "Recommended exercise: $exercise_name"
            set argv $argv --exercise=$exercise_slug
        end
    end

    set out (command exercism download $argv 2>&1)
    set rc $status
    printf "%s\n" $out

    if set -q _flag_help
        printf '\nAdditional Flags:\n'
        echo '  -r, --recommended    download the next recommended exercise.'
    end

    if test $rc -ne 0
        set out (string match -r -g "directory '(.+?)' already exists" $out)
        or return 1
    end
    if test -d $out[-1]
        cd $out[-1]
        switch $PWD
            case '*/users/*'
                # to avoid executing track-specific blocks for mentored solutions
                true
            case '*/nim/*'
                set dir (basename $PWD)
                set slug (string replace --all -- '-' '_' $dir)
                printf "%s\n" {,test_}$slug > .gitignore
            case '*/'{java,type}'script/*'
                #npm install
                #pnpm install
            case '*/reasonml/*'
                npm install
            case '*/d/*'
                echo "$(basename $PWD)-test-library" > .gitignore
            case '*/dart/*'
                dart pub add --dev lints
                if ! grep -q 'include: package:lints/recommended.yaml' analysis_options.yaml
                    begin
                        echo
                        echo 'include: package:lints/recommended.yaml'
                    end >> analysis_options.yaml
                end
        end
    end
end
