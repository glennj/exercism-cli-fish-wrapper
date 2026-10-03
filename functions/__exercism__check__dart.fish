function __exercism__check__dart
    argparse --ignore-unknown t/track= -- $argv
    __exercism__test__validate_runner $_flag_track dart ; or return 1

    __echo_and_execute dart analyze --fatal-infos lib/
    and __echo_and_execute dart format lib/
end
