function __exercism__test__bash
    argparse --ignore-unknown track= help -- $argv
    set -q _flag_help; and return

    __exercism__test__validate_runner $_flag_track bats; or return 3

    # test all .bats files
    set -lx BATS_RUN_SKIPPED true
    find . -maxdepth 1 -mindepth 1 \
           \( -name \*_test.sh -o -name \*.bats \) \
           -exec echo bats --pretty '{}' + \
           -exec bats --pretty '{}' +
end
