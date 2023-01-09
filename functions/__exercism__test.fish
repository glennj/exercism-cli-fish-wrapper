# Test the current solution.
#
# Not implemented for every track.
#
# options:
#   n/a

function __exercism__test
    __exercism__has_metadata; or return 1

    set info (jq -r '.track, .exercise' .exercism/metadata.json)
    set track $info[1]
    set slug  $info[2]

    set func __exercism__test__(string replace --all -- - _ $track)
    if not test -f (status dirname)/$func.fish
        echo "Don't know how to test the $track track."
        return 2
    end

    $func $slug
end

function __echo_and_execute
    string join -- " " $argv
    env $argv
end
