function __exercism__test__validate_runner
    argparse --ignore-unknown --name="exercism test validate runner" 'o/optional' -- $argv
    set -q _flag_optional; and set tool_type optional; or set tool_type required

    set track $argv[1]
    set tool  $argv[2]

    type -q $tool; and return

    echo "Can't find $tool_type tool '$tool'" >&2
    echo "See https://exercism.org/docs/tracks/$track/installation"
    return 1
end

