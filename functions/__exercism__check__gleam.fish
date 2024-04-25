function __exercism__check__gleam
    argparse --ignore-unknown t/track= -- $argv
    __exercism__test__validate_runner $_flag_track gleam ; or return 1

    set solution (jq -r '.files.solution[]' .exercism/config.json)

    __echo_and_execute gleam check
    and __echo_and_execute gleam format $solution
end
