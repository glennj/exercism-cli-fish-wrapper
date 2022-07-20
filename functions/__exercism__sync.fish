# Sync: update an out-of-date solution.
# - on the website, this is clicking "See what's changed" in the 
#   "This exercise has been updated..." banner, then clicking the
#   "Update exercise" button

function __exercism__sync
    set opts 'h/help' \
             's/status' \
             'u/update' \
             'a/all'
    argparse --name='exercism sync' $opts -- $argv
    or return 1

    if set -q _flag_help
        echo "See: https://github.com/glennj/exercism-cli-fish-wrapper/blob/main/README.md#subcommands-to-feed-my-obsession-at-keeping-up-to-date-solutions"
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

    __exercism__has_metadata; or return 1

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
        if test $_status = "ok" 
            not set -q _flag_status
            and echo "$slug is already up to date"
        else
            set uuid (jq -r .id ./.exercism/metadata.json)
            set updated (__exercism__api_call -X PATCH "/solutions/$uuid/sync")

            if test "false" = (echo $updated | jq -r .solution.is_out_of_date)
                echo $updated | jq -r '"\(.solution.track.slug) \"\(.solution.exercise.title)\" has been updated"'
            else
                echo "Could not sync the exercise?" >&2
                echo $updated | jq . >&2
                return 1
            end
        end
    end
end
