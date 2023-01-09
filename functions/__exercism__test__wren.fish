function __exercism__test__wren -a slug
    set spec $slug.spec.wren

    set _sed sed
    # Homebrew on MacOS installs GNU sed as "gsed"
    type -q gsed; and set _sed gsed

    $_sed -i 's/skip.test/do.test/' $spec
    __echo_and_execute wrenc package.wren install
    __echo_and_execute wrenc $spec
end
