function __exercism__test__javas
    argparse --ignore-unknown t/track= -- $argv
    __exercism__test__validate_runner $_flag_t gradle; or return 4
    set _sed sed
    # Homebrew on MacOS installs GNU sed as "gsed"
    type -q gsed; and set _sed gsed

    $_sed -Ei 's,@Ignore,//&,' src/test/java/*.java
    gradle test
end
