# see if we want something that's cached (cached via `exercism stats -d`)

function __exercism__api_get
    set -l uri $argv[1]
    __exercism__api_call $uri; and return

    set -l cache $XDG_CACHE_HOME
    test -z $cache; and set cache $HOME/.cache
    set cache $cache/exercism
    mkdir -p $cache

    switch $uri
        case '/tracks'
            test -d $cache/tracks/; or return 1
            echo "Using cached configs in $cache/tracks/" >&2
            set tracks (find $cache/tracks -mindepth 1 -type d -printf '%f\n')
            for track in $tracks
                jq -c '{
                    slug,
                    is_joined: true,
                    num_exercises: (.exercises.practice | length),
                    num_concepts: (.exercises.concept // [] | length)
                }' $cache/tracks/{$track}/config.json 
            end \
            | jq -s '{tracks: .}'

        case '/tracks/*/exercises'
            set track (path dirname $uri | path basename)
            set config $cache/tracks/{$track}/config.json
            test -f $config; or return 1
            echo "Using cached config $config" >&2
            jq --arg track $track '
                (.exercises.concept // [] | map(. + {type: "concept"}))
                + (.exercises.practice // [] | map(. + {type: "practice"}))
                | map({
                    type,
                    slug,
                    title: .name,
                    difficulty,
                    is_unlocked: true,
                    links: {self: "/tracks/\($track)/exercises/\(.slug)"}
                })
                | {exercises: .}
            ' $config

    end
end
