# wraps the `exercism submit` command
# - selects the solution file if no args given

function __exercism__submit
    __exercism__has_metadata; or return 1

    if test (count $argv) -eq 0
        set argv (jq -r '.files.solution[]' .exercism/config.json)
    end
    echo exercism submit $argv
    command exercism submit $argv
end
