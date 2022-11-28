# Test the current solution.
#
# Not implemented for every track.
#
# options:
#   n/a

function __exercism__test
    __exercism__has_metadata; or return 1

    set info (jq -r '.track, .exercise' .exercism/metadata.json)
    set track $info[1]
    set slug  $info[2]

    set _sed sed
    # Homebrew on MacOS installs GNU sed as "gsed"
    type -q gsed; and set _sed gsed

    switch $track
        case bash awk jq
            find . -maxdepth 1 -mindepth 1 \( -name \*_test.sh -o -name \*.bats \) \
            | xargs env BATS_RUN_SKIPPED=true bats --pretty
        case common-lisp
            sbcl --load "$slug-test" \
                 --eval "(let () ($slug-test:run-tests) (exit))"
        case elixir
            mix test --exclude slow --include pending
        case javascript typescript
            $_sed -Ei '
                s/x(test|it|describe)/\1/
                s/(test|it).skip/\1/
            ' *.{spec,test}.{j,t}s
            #npm install
            #and npm run test
            pnpm install
            and pnpm run test
        case java
            $_sed -Ei 's,@Ignore,//&,' src/test/java/*.java
            gradle test
        case groovy
            $_sed -i 's,@Ignore,//&,' src/test/groovy/*.groovy
            sh ./gradlew test
        case kotlin
            $_sed -Ei 's,@Ignore,//&,' src/test/kotlin/*.kt
            sh ./gradlew test
        case julia
            julia runtests.jl
        case lua
            busted .
        case nim
            nim c -r test_*.nim
        case perl5
            if test -f cpanfile
                carton install
                carton exec prove .
            else
                prove .
            end
        case python
            python3 -m pytest *_test.py
        case r
            Rscript test_*.R
        case ruby
            for t in *_test.rb
                gawk -i inplace '1; /< Minitest::Test/ {print "  def skip; end"}' $t
                ruby $t
            end
        case tcl
            RUN_ALL=1 tclsh *.test
        case wren
            set spec $slug.spec.wren
            $_sed -i 's/skip.test/do.test/' $spec
            wrenc package.wren install
            wrenc $spec
        case '*'
            echo "Don't know how to test the $track track."
            return 2
    end
end
