# Get track trophies

function __exercism__achievements
    set help (string collect ' Usage: exercism achievements option [...]

List your trophies and badges.

Options: one or more of
    -b|--badges         List your badges
    -t|--trophies       List your trophies achieved
    -r|--reputation     (TODO) Chart your reputation
    -a|--all            All of the above
')

    argparse --name="exercism achievements" 'h/help' \
        't/trophies' 'r/reputation' 'b/badges' 'a/all' -- $argv
    or return 1

    if set -q _flag_help
        echo $help
        return
    end

    if set -q _flag_all
        set _flag_trophies yes
        set _flag_reputation yes
        set _flag_badges yes
    end
    if  begin
            not set -q _flag_trophies
            and not set -q _flag_reputation
            and not set -q _flag_badges
        end
            echo $help
            return
    end

    set -q _flag_reputation; and __exercism__achievements__reputation
    set -q _flag_badges;     and __exercism__achievements__badges
    set -q _flag_trophies;   and __exercism__achievements__trophies
end


function __exercism__achievements__trophies
    echo '##############'
    echo '#  Trophies  #'
    echo '##############'

    set refresh true
    set cache $HOME/.cache/exercism
    mkdir -p $cache
    set trophies $cache/trophies.jsonl

    if test -f $trophies
        set tdate (
            stat -c '%Y' $trophies 2>/dev/null      # Linux
            or stat -f '%m' $trophies               # Mac
        )
        if test (math (date '+%s') - $tdate) -le (math '86400 * 7')
            # less than a week
            date -d @$tdate '+As of %F'\n
            set refresh false
        end
    end

    if not $refresh
        cat $trophies
    else
        set tracks (
            __exercism__api_call "/tracks" \
            | jq -r '
                .tracks[]
                | select(.is_joined)
                | .slug
            '
        )
        begin
            set delay 0
            for track in $tracks
                sleep $delay     # play nicely with rate limiting
                set delay 5

                printf '.' >&2
                __exercism__api_call "/tracks/$track/trophies" \
                | jq -c '
                    .trophies[]
                    | select(.status == "revealed")
                    | "( in)? \(.track.title)" as $re
                    | [
                        .name,
                        (.criteria | sub($re; "")),
                        .num_awardees,
                        .track.title
                    ]
                '
            end
            echo >&2
        end \
        | tee $trophies
    end \
    | jq -rs '
        def percentage(num; den): (100 * num / den) * 100 | floor / 100;

        reduce .[] as [$trophy, $meaning, $total, $track] ({};
            if (has($trophy) | not) then .[$trophy] = {$meaning, $total, count: 0, tracks:[]} end
            | .[$trophy].count += 1
            | .[$trophy].tracks += [$track]
        )
        | to_entries
        | map(.value.pct = percentage(.value.count; .value.total))
        | sort_by(.value.pct)
        | .[]
        | .key,
          "\(.value.meaning).",
          "Achieved in \(.value.count) tracks, out of \(.value.total) awarded (\(.value.pct)%).",
          (.value.tracks | join(", ")),
          ""
    ' \
    | fold -s \
    | awk -v RS="" -F '\n' '{
        print $1
        print "    " $2
        print "    " $3
        for (i = 4; i <= NF; i++)
            print "      > " $i
        print ""
    }'
end

function __exercism__achievements__badges
    echo '############'
    echo '#  Badges  #'
    echo '############'

    begin
        set delay 0
        set -l page 1
        set -l total 99
        while test $page -le $total
            sleep $delay     # play nicely with rate limiting
            set delay 5

            printf '.' >&2
            set json (__exercism__api_call "/badges?page=$page")

            echo $json | jq -c '.results[]'

            set total (echo $json | jq -r '.meta.total_pages')
            set page (math $page + 1)
        end
        echo >&2
    end \
    | jq -rs '
        {"legendary": 1, "ultimate": 2, "rare": 3, "common": 4} as $rarity
        | sort_by($rarity[.rarity], .num_awardees)[]
        | [.rarity, .num_awardees, .name, .description]
        | @csv
    ' \
    | mlr --c2p --implicit-csv-header \
        label 'Type,Awardees,Name,Description' \
        then cat
    echo
end

function __exercism__achievements__reputation
    echo "TODO: reputation"
end
