function __exercism__test__bash
    # test all .bats files
    set -lx BATS_RUN_SKIPPED true
    find . -maxdepth 1 -mindepth 1 \
           \( -name \*_test.sh -o -name \*.bats \) \
           -exec echo bats --pretty '{}' + \
           -exec bats --pretty '{}' +
end
