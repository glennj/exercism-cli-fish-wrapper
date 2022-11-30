function __exercism__test__wren -a slug
    set spec $slug.spec.wren

    set _sed sed
    # Homebrew on MacOS installs GNU sed as "gsed"
    type -q gsed; and set _sed gsed

    $_sed -i 's/skip.test/do.test/' $spec
    wrenc package.wren install
    wrenc $spec
end
