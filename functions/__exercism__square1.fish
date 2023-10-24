
function __exercism__square1
    set help 'Usage: exercism square1

DANGER: this is destructive!

Wipe out your current solution and download the initial files.'

    argparse --name="exercism square1" 'h/help' -- $argv
    or return 1

    if set -q _flag_help
        echo $help
        return
    end

    # delete all files!!
    find . -mindepth 1 -depth -print -delete
    exercism refresh >/dev/null

    __exercism__has_metadata; or return 1

    exercism sync --update
    exercism download --force -e (jq -r .exercise .exercism/metadata.json) >/dev/null

    set uuid (jq -r '.id' .exercism/metadata.json)
    set json (__exercism__api_call "/solutions/$uuid/initial_files")

    echo $json | jq -r '.files[] | .filename' | while read file
        echo "    Resetting $file ..."
        echo $json | jq -r --arg f $file '.files[] | select(.filename == $f) | .content' > $file
    end
end
