# Dump the solution's API metadata
#
# options:
#   -i --iterations : show iterations

function __exercism__metadata
    __exercism__has_metadata; or return 1
    set uuid (jq -r .id ./.exercism/metadata.json)
    set uri "/solutions/$uuid"

    argparse --name="exercism metadata" 'i/iterations' -- $argv
    or return 1

    set -q _flag_iterations
    and set uri "$uri?sideload=iterations"

    __exercism__api_call $uri | jq .
end
