function __exercism__check__elm
    argparse --ignore-unknown t/track= -- $argv
    __exercism__test__validate_runner $_flag_track elm-format ; or return 1

    set solution (jq -r '.files.solution[]' .exercism/config.json)

    __echo_and_execute elm-format --yes $solution

end
