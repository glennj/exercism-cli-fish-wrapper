# test every downloaded exercise in the track
# - writes a "report" into the track's parent directory

function __exercism__test_all
    __exercism__in_track_root; or return 1
    set root $PWD
    set track (basename $root)

    echo "set a global variable `except` containing the list of directories to skip (use trailing '/')"
    ls
    echo "currently, `except` is:"
    if test (count $except) -eq 0
        echo "empty"
    else
        set -S except
    end
    read -P "hit Enter to proceed; or Ctrl-C to abort: "

    set _sed sed
    type -q gsed; and set _sed gsed

    for e in */
        if contains $e $except
            continue
        end
        begin
            cd $root/$e
            and exercism sync
            and exercism refresh
            and switch $track
                case bash
                    bats
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
            end
        end # of `begin`
        or set errs $errs $e
    end
    cd $root

    echo
    if test (count $errs) -eq 0
        echo "ALL OK!" | tee "../$track.ok."(date +%F)
    else
        echo "these exercises failed:"
        set -S errs | tee "../$track.broken."(date +%F)
    end
end
