# Sync: update an out-of-date solution.
# - on the website, this is clicking "See what's changed" in the 
#   "This exercise has been updated..." banner, then clicking the
#   "Update exercise" button

function __exercism__sync
    __exercism__has_metadata; or return 1

    set solution (exercism metadata); or return 1

    echo
    if test "false" = (echo $solution | jq -r .solution.is_out_of_date)
        echo $solution | jq -r '"\(.solution.track.slug) \"\(.solution.exercise.title)\" is up to date"'
        return
    end

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
