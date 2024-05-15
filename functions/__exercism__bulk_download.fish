function __exercism__bulk_download
    set help 'Usage: exercism bulk-download

Download all your solutions in this track.

Options
    -n|--dry-run   Just show what will be done
    -f|--force     Refresh existing downloaded solutions;
                   otherwise only new ones will be downloaded.'

    argparse --name="exercism download-all" 'h/help' 'n/dry-run' 'f/force' -- $argv
    or return 1

    if set -q _flag_help
        echo $help
        return
    end

    __exercism__in_track_root; or return 1
    set track_root (__exercism__get_current_track_root); or return 1
    set track (basename $track_root)

    set slugs (
        __exercism__api_call /tracks/{$track}/exercises'?'sideload=solutions \
	| jq -r '
            .solutions
            | map(
                select(.status | IN("published","iterated")) 
                | .exercise.slug
            )
            | sort
            | .[]
        ')

    cd $track_root
    for slug in $slugs
        if test -d $slug
            if set -q _flag_force
                if set -q _flag_n
                    echo "refresh   --> $slug"
                else
                    command exercism download --track=$track --exercise=$slug --force
                end
            end
        else
            if set -q _flag_n
                echo "download ===> $slug"
            else
                command exercism download --track=$track --exercise=$slug
            end
        end
    end
end
