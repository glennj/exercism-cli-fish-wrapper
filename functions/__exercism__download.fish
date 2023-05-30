# wraps the `exercism download` command
# - change the current directory
# - perform any track-specific tasks

function __exercism__download
    argparse --ignore-unknown --name="exercism download" \
        't/track=' 'h/help' -- $argv
    or return 1

    if set -q _flag_help
        set argv --help $argv
    else if set -q _flag_track
        set argv --track=$_flag_track $argv
    else
        if __exercism__in_track_root 2>/dev/null
            set argv --track=(basename $PWD) $argv
        else if __exercism__has_metadata >/dev/null
            set argv --track=(jq -r '.track' ./.exercism/metadata.json) $argv
        end
    end

    set out (command exercism download $argv 2>&1)
    set rc $status
    printf "%s\n" $out
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
        end
    end
end
