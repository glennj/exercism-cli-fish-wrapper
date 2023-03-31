function __exercism__test__groovy
    argparse --ignore-unknown help -- $argv
    set -q _flag_help; and return

    set _sed sed
    # Homebrew on MacOS installs GNU sed as "gsed"
    type -q gsed; and set _sed gsed

    $_sed -Ei 's,@Ignore,//&,' src/test/groovy/*.groovy
    sh ./gradlew test
end
