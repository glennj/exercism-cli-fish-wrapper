# Test the current solution.
#
# Not implemented for every track.
#
# options:
#   n/a

function __exercism__test
    __exercism__test__command_version; or return 1

    set help 'Usage: exercism test

Run the tests for this exercise.

Options
    -a|--all    "Un-skip" all tests'

    argparse --ignore-unknown --name="exercism test" 'h/help' 'a/all' 'b/bench' -- $argv
    or return 1

    if set -q _flag_help
        echo $help
        return 1
        # command exercism test --help
    end

    __exercism__has_metadata; or return 1

    jq -r '.track, .exercise' .exercism/metadata.json | begin
        read track
        read slug
    end
    set test_files (jq -r '.files.test[]' .exercism/config.json)

    # for running all tests, unskip them
    if set -q _flag_all
        # Homebrew on MacOS installs GNU sed as "gsed"
        type -q gsed; and set _sed gsed; or set _sed sed

        switch $track
            case 8th
                set -fx RUN_ALL_TESTS true
            case awk bash jq
                set -fx BATS_RUN_SKIPPED true
            case ballerina
                perl -i -pe 's{(^|\s)(enable:\s*false)}{$1//$2}' $test_files
            case c x86-64-assembly
                perl -i -pe 's{^(\s+)(TEST_IGNORE)\b}{$1// $2}' $test_files
            case crystal
                perl -i -pe 's/\bpending\b/it/' $test_files
            case fsharp
                xargs perl -i -pe 's/\(Skip = .*?\)//' $test_files
            case groovy java kotlin
                $_sed -Ei 's,@(Ignore|Disabled),//&,' $test_files
            case javascript typescript
                $_sed -Ei '
                    s/x(test|it|describe)/\1/
                    s/(test|it).skip/\1/
                ' $test_files
            case ruby
                for t in $test_files
                    gawk -i inplace '1; /< Minitest::Test/ {print "  def skip; end"}' $t
                end
            case tcl
                set -fx RUN_ALL true
            case wasm
                $_sed -i 's/xtest/test/' $test_files
            case wren
                $_sed -i 's/skip.test/do.test/' $test_files
        end
    end

    # not covered by exercism CLI, or overriding, or adding extra behaviour
    switch $track
        case 8th
            8th test.8th
            return $status
        case awk
            set -q AWKPATH; and not contains . $AWKPATH; and set -fx AWKPATH $AWKPATH .
            # proceed to command exercism test
        case common-lisp
            __exercism__test__validate_runner -o $track ros; or return 1
            # roswell https://roswell.github.io/
            __echo_and_execute \
                ros run --load "$slug-test.lisp" \
                        --eval "(uiop:quit (if ($slug-test:run-tests) 0 5))"
            return $status
        case cobol
            for t in $test_files
                set test_dir (dirname $t)
                set test_file (basename $t)
                set files {$test_dir}/{,.}{$test_file}*
                if test (count $files) -gt 1
                    echo "Looks like you're editing $test_file: close it first"
                    return 1
                end
            end
            # proceed to command exercism test
        case fortran
            __exercism__test__validate_runner $track cmake; or return 1
            __exercism__test__validate_runner $track make; or return 1

            mkdir -p build
            cd build
            test -d ./testlib; or cmake -G "Unix Makefiles" ..
            make
            and ctest -V
            set test_status $status
            cd ..
            return $test_status
        case go
            __exercism__test__validate_runner $track go; or return 1
            if set -q _flag_bench
                __echo_and_execute go test --bench=. --benchmem $argv
                return $status
            end
            # proceed to command exercism test
        case groovy
            if test (java -version 2>&1 | grep -oP 'version "\K\d+') -gt 11
                echo "Groovy wants an older version"
                echo "  brew unlink openjdk@17 # perhaps"
                echo "  brew link openjdk@11"
                return 1
            end
            sh gradlew test
            return $status
        case javascript typescript wasm
            for runner in  pnpm  npm
                if __exercism__test__validate_runner -o $track $runner
                    test -d ./node_modules; or __echo_and_execute $runner install
                    __echo_and_execute $runner run test
                    return $status
                end
            end
            return 1
        case kotlin
            test -f ./gradlew
            and chmod u+x ./gradlew
            # proceed to command exercism test
        case perl5
            if test -f cpanfile
                __exercism__test__validate_runner $track carton; or return 1
                __echo_and_execute carton install
                __echo_and_execute carton exec prove . t/
                return $status
            end
            # proceed to command exercism test
        case tcl
            set verbosity "configure -verbose {body error usec}"
            for t in $test_files
                if not grep -q $verbosity $t
                    gawk -i inplace -v conf="$verbosity" '
                        {print}
                        /^[[:blank:]]*source .*\.tcl/ && !p {
                            print conf
                            p = 1
                        }
                    ' $t
                    echo "added test verbosity"
                end
            end
            # proceed to command exercism test
        case wren
            __exercism__test__validate_runner $track wrenc; or return 1
            wrenc package.wren install; or return 1
            # proceed to command exercism test
    end

    command exercism test $argv
end

function __echo_and_execute
    string join -- " " (string escape -- $argv)
    # env $argv
    # not using `env` allows the "tool" to be a shell function
    $argv
end

function __exercism__test__validate_runner
    argparse --ignore-unknown --name="exercism test validate runner" 'o/optional' -- $argv
    set -q _flag_optional; and set tool_type optional; or set tool_type required

    set track $argv[1]
    set tool  $argv[2]

    type -q $tool; and return

    echo "Can't find $tool_type tool '$tool'" >&2
    echo "See https://exercism.org/docs/tracks/$track/installation"
    return 1
end

function __exercism__test__command_version
    set required 3.2.0
    set min_ver (
        begin
            echo $required
            command exercism version | awk '{print $3}'
        end | sort -V | head -1
    )
    if test $min_ver != $required
        echo "exercism version $required is required." >&2
        echo "https://github.com/exercism/cli/releases" >&2
        return 1
    end
end
