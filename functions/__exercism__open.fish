# Launch the iterations web page
# - uses the `open` command, may want `xdg-open` on Linux

function __exercism__open
    set help 'Usage: exercism open [options]

Opens the "Your iterations" tab for this exercise.

Options
    --overview    Open the Overview tab instead.
    --community   Open the Community Solutions tab instead.'

    __exercism__has_metadata; or return 1

    argparse --name="exercism open" 'h/help' 'overview' 'community' -- $argv
    or return 1

    if set -q _flag_help
        echo $help
        return
    end

    set page "/iterations"
    set -q _flag_overview; and set page ""
    set -q _flag_community; and set page "/solutions"
    set url "$(jq -r .url .exercism/metadata.json)$page"

    if      command -qv xdg-open;   xdg-open $url
    else if command -qv start;      start "" $url
    else;                           open     $url
    end
end
