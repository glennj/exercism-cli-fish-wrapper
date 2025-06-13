function __exercism__sync
    set help 'Usage: exercism sync [options]

Updates an out-of-date solution.
This is like, on the website, clicking "See what\'s changed" in the 
"This exercise has been updated..." banner, then clicking the
"Update exercise" button

Options
    --status    Display the current sync status of an exercise.
    --update    Perform the sync.
    --all       Consider all the exercises in the track.'

    set opts 'h/help' \
             's/status' \
             'u/update' \
             'a/all'
    argparse --name='exercism sync' $opts -- $argv
    or return 1

    if set -q _flag_help
        echo $help
        return
    end

    if not set -q _flag_status; and not set -q _flag_update
        echo "Specify at least one of --status and --update"
        return
    end

    if set -q _flag_all
        __exercism__in_track_root; or return 1
        set opts
        set -q _flag_update; and set opts $opts --update
        set -q _flag_status; and set opts $opts --status
        for dir in */
            cd $dir
            __exercism__sync $opts
            prevd
        end
        return
    end

    __exercism__has_metadata; or exercism refresh

    set solution (exercism metadata); or return 1
    set slug (echo $solution | jq -r '.solution.exercise.slug')

    set _status "ok"
    if test "true" = (echo $solution | jq -r .solution.is_out_of_date)
        set _status "OUT OF DATE"
    end

    if set -q _flag_status
        printf "%-11s %s\n" $_status $slug
    end

    if set -q _flag_update
        if test "$_status" = "ok" 
            not set -q _flag_status
            and echo "$slug is already up to date"
        else
            set uuid (jq -r .id ./.exercism/metadata.json)
            set updated (__exercism__api_call -X PATCH "/solutions/$uuid/sync")
            set out_of_date (echo $updated | jq -r '.solution.is_out_of_date')

            if test "$out_of_date" = "false"
                echo $updated | jq -r '"\(.solution.track.slug) \"\(.solution.exercise.title)\" has been updated"'
                exercism refresh
            else
                echo "Could not sync the exercise?" >&2
                set -S out_of_date
                echo $updated | jq . >&2
                return 1
            end
        end
    end
end
