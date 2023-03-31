function __exercism__test__r
    argparse --ignore-unknown track= help -- $argv
    set -q _flag_help; and return

    __exercism__test__validate_runner $_flag_track Rscript; or return 1

    __echo_and_execute Rscript test_*.R
end
