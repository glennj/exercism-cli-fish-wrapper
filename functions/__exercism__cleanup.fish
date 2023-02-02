# Tidies exercises
# - typically, remove build artifacts
# - originally was to reclaim 100's of MB of javascript node_modules
#   before I found `pnpm`

function __exercism__cleanup
    set help 'Usage: exercism cleanup

From the root of a track directory, recursively remove build artifacts.

Implemented for
- javascript, typescript
- java, groovy, kotlin
- nim
- wren'

    argparse --name="exercism cleanup" 'h/help' -- $argv
    or return 1

    if set -q _flag_help
        echo $help
        return
    end

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
        case wren
            find . -mindepth 2 -maxdepth 2 \
                   -name wren_modules -type d \
                   -print -exec rm -rf '{}' ';'
        case fsharp
            find . -mindepth 2 -maxdepth 2 \
                   \( -name bin -o -name obj \) -type d \
                   -print -exec rm -rf '{}' ';'
        case '*'
            echo "don't know how to cleanup the $track track"
    end
end
