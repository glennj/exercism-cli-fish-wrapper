function __exercism__check__rescript
    argparse --ignore-unknown t/track= -- $argv
    __exercism__test__validate_runner $_flag_track npm ; or return 1
    test -d ./node_modules; or __echo_and_execute npm install
    __echo_and_execute npx rescript format
end
