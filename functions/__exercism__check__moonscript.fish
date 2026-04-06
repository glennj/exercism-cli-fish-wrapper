function __exercism__check__moonscript
    argparse --ignore-unknown t/track= -- $argv

    if not type -q moonpick
        echo "moonpick not found: luarocks install --local moonpick" >&2
    else
        set solution (jq -r '.files.solution[]' .exercism/config.json)
        set files (find (dirname $solution[1]) -type f -name \*.moon -not -name \*_spec.moon)
        __echo_and_execute moonpick $files
    end
end
