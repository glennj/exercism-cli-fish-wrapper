# Test the current solution.
#
# Not implemented for every track.
#
# options:
#   n/a

function __exercism__test
    set help 'Usage: exercism test

Run the tests for this exercise.'

    argparse --name="exercism test" 'h/help' -- $argv
    or return 1

    if set -q _flag_help
        echo $help
        echo
        echo 'Implemented for these tracks:'
        for file in (status dirname)/__exercism__test__*.fish
            string match -g --regex '__test__(.+)\.fish' $file
        end | paste - - - - | column -t | sed 's/^/    /'
        return
    end

    __exercism__has_metadata; or return 1

    set info (jq -r '.track, .exercise' .exercism/metadata.json)
    set track $info[1]
    set slug  $info[2]

    set func __exercism__test__(string replace --all -- - _ $track)
    if not test -f (status dirname)/$func.fish
        echo "Don't know how to test the $track track."
        return 2
    end

    $func --track=$track $slug
end

function __echo_and_execute
    string join -- " " $argv
    env $argv
end

function __exercism__test__validate_runner -a track tool
    type -q $tool; and return

    echo "Can't find required tool '$tool'" >&2
    echo "See https://exercism.org/docs/tracks/$track/installation"
    return 1
end
