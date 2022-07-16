# Dump the solution's API metadata

function __exercism__metadata
    __exercism__has_metadata; or return 1
    set uuid (jq -r .id ./.exercism/metadata.json)
    __exercism__api_call "/solutions/$uuid" | jq .
end
