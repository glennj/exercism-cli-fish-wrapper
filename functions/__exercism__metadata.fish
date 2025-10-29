# Dump the solution's API metadata
#
# options:
#   -i --iterations : show iterations

function __exercism__metadata
    set help 'Usage: exercism metadata [options]

Dump the solution\'s API metadata.

Options
    -i|--iterations     Show iteration metadata as well.'

    argparse --name="exercism metadata" 'h/help' 'i/iterations' -- $argv
    or return 1

    if set -q _flag_help
        echo $help
        return
    end

    __exercism__has_metadata; or return 1
    set uuid (jq -r .id ./.exercism/metadata.json)
    set uri "/solutions/$uuid"

    set -q _flag_iterations
    and set uri "$uri?sideload=iterations"

    set json (__exercism__api_call $uri); or return 1
    echo $json | jq .
end
