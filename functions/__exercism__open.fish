# Launch the iterations web page
# - uses the `open` command, may want `xdg-open` on Linux

function __exercism__open
    __exercism__has_metadata; or return 1
    open (jq -r .url .exercism/metadata.json)"/iterations"
end
