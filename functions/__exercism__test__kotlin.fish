function __exercism__test__kotlin
    argparse --ignore-unknown help -- $argv
    set -q _flag_help; and return

    set _sed sed
    # Homebrew on MacOS installs GNU sed as "gsed"
    type -q gsed; and set _sed gsed

    $_sed -Ei 's,@Ignore,//&,' src/test/kotlin/*.kt
    sh ./gradlew test
end
