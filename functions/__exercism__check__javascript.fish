function __exercism__check__javascript
    argparse --ignore-unknown t/track= -- $argv
    __exercism__test__validate_runner $_flag_track npm ; or return 1
    __echo_and_execute npm run lint
end
