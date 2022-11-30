function __exercism__test__javascript
    set _sed sed
    # Homebrew on MacOS installs GNU sed as "gsed"
    type -q gsed; and set _sed gsed

    $_sed -Ei '
        s/x(test|it|describe)/\1/
        s/(test|it).skip/\1/
    ' *.{spec,test}.{j,t}s
    #npm install
    #and npm run test
    pnpm install
    and pnpm run test
end
