# see if we want something that's cached (cached via `exercism tracks --get`)

function __exercism__api_get
    set -l uri $argv[1]
    __exercism__api_call $uri; and return

    set -l cache (exercism tracks --cache-dir)

    switch $uri
        case '/tracks'
            exercism tracks --get
            echo "Using cached configs in $cache/tracks/" >&2
            set tracks (path basename $cache/*/)
            # a track is joined if it exists as a directory in the workspace
            set workspace (exercism workspace)
            for track in $tracks
                jq -r '
                    "\(.slug),\(.exercises.practice | length),\(.exercises.concept // [] | length)"
                ' $cache/{$track}/config.json 
            end \
            | while read -d , slug np nc
                test -d "$workspace/$slug"; and set joined true; or set joined false
                jq  -nc \
                    --arg slug $slug \
                    --argjson is_joined $joined \
                    --argjson num_concepts $nc \
                    --argjson num_exercises $np \
                    '$ARGS.named'
            end \
            | jq -s '{tracks: .}'

        case '/tracks/*/exercises*'
            exercism tracks --get
            set track (path dirname $uri | path basename)
            set config $cache/{$track}/config.json
            test -f $config; or return 1
            echo "Using cached config $config" >&2
            set exercises (
                jq --arg track $track '
                    (.exercises.concept // [] | map(. + {type: "concept"}))
                    + (.exercises.practice // [] | map(. + {type: "practice"}))
                    | map({
                        type,
                        slug,
                        title: .name,
                        difficulty,
                        is_unlocked: true,
                        is_recommended: false,
                        links: {self: "/tracks/\($track)/exercises/\(.slug)"}
                    })
                    | {exercises: .}
                ' $config
            )

            set solutions '{}'
            if string match -q '*?sideload=solutions' $uri
                set downloaded (
                    path basename (exercism workspace)/$track/*/ \
                    | jq -Rc '[., inputs]'
                )
                # we'll assume if it's in the workspace it's published.
                set solutions (
                    echo $exercises \
                    | jq --argjson dl $downloaded '
                        .exercises
                        | map({
                            exercise: {slug: .slug},
                            status: (if (.slug | IN($dl[])) then "published" else "available" end)
                        })
                        | {solutions: .}
                    '
                )
            end
            begin; echo $exercises; echo $solutions; end | jq -s add
    end
end
