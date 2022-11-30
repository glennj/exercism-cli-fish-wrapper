function __exercism__test__bash
    # test all .bats files
    find . -maxdepth 1 -mindepth 1 \( -name \*_test.sh -o -name \*.bats \) \
    | xargs env BATS_RUN_SKIPPED=true bats --pretty
end
