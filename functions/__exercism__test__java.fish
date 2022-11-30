function __exercism__test__javas
    set _sed sed
    # Homebrew on MacOS installs GNU sed as "gsed"
    type -q gsed; and set _sed gsed

    $_sed -Ei 's,@Ignore,//&,' src/test/java/*.java
    gradle test
end
