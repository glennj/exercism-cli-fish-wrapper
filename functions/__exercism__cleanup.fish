# Tidies exercises
# - typically, remove build artifacts
# - originally was to reclaim 100's of MB of javascript node_modules
#   before I found `pnpm`

function __exercism__cleanup
    __exercism__in_track_root; or return 1
    set root $PWD
    set track (basename $root)

    switch $track
        case javascript typescript
            find . -maxdepth 2 \
                    -name node_modules -o \
                    -name pnpm-lock.yaml -o \
                    -name package-lock.json -o \
                    -name yarn.lock | \
            while read path
                echo $path
                rm -rf $path
            end
        case java groovy kotlin
            find . -mindepth 2 -maxdepth 2 -type d -name build -o -name out | \
            while read path
                echo $path
                rm -rf $path
            end
        case nim
            find . -mindepth 2 -type f -executable -name test_\* -print -delete
        case '*'
            echo "don't know how to cleanup the $track track"
    end
end
