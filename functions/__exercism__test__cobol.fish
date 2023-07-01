function __exercism__test__cobol
    argparse --ignore-unknown t/track= h/help -- $argv
    set -q _flag_help; and return
    __exercism__test__validate_runner $_flag_t cobc; or return 3

    jq -r '.files.test[]' .exercism/config.json \
    | while read test_path
        set test_dir (dirname $test_path)
        set test_file (basename $test_path)
        set files {$test_dir}/{,.}{$test_file}*
        if begin
            test (count $files) -gt 1
            and not test -f ./ALLTESTS
            or test $test_path -nt ./ALLTESTS
        end
            echo "Looks like you're editing $test_file: close it first"
            return 1
        end
    end

    __echo_and_execute bash ./test.sh
end
