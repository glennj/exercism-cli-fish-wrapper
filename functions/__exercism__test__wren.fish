function __exercism__test__wren
    argparse t/track= -- $argv
    __exercism__test__validate_runner $_flag_track wrenc; or return 1
    set slug $argv[1]
    set spec $slug.spec.wren

    set _sed sed
    # Homebrew on MacOS installs GNU sed as "gsed"
    type -q gsed; and set _sed gsed

    $_sed -i 's/skip.test/do.test/' $spec
    __echo_and_execute wrenc package.wren install
    __echo_and_execute wrenc $spec
end
