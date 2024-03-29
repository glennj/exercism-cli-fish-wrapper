# Test the current solution.
#
# Not implemented for every track.
#
# options:
#   n/a

function __exercism__check
    set help 'Usage: exercism check

Run formatters/linters for this exercise.'

    argparse --ignore-unknown --name="exercism check" 'h/help' -- $argv
    or return 1

    if set -q _flag_help
        echo $help
        echo
        echo 'Implemented for these tracks:'
        for file in (status dirname)/__exercism__check__*.fish
            string match -g --regex '__check__(.+)\.fish' $file
        end | paste - - - - | column -t | sed 's/^/    /'
        echo
        return
    end

    __exercism__has_metadata; or return 1

    jq -r '.track, .exercise' .exercism/metadata.json | begin
        read track
        read slug
    end

    set func __exercism__check__(string replace --all -- - _ $track)
    if not test -f (status dirname)/$func.fish
        echo "Don't know how to test the $track track."
        return 2
    end
    functions -q $func
    or source (status dirname)/$func.fish

    $func --track=$track $argv $slug 
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
