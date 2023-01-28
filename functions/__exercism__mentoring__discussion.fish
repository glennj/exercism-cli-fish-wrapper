# List a mentoring discussion
# - https://exercism.org/mentoring/discussions/UUID
#
# Using `html-to-text` to render post as text
# https://www.npmjs.com/package/html-to-text

function __exercism__mentoring__discussion
    set help 'Usage: exercism mentoring discussion [options] <id>

Display the posts of a mentoring discussion.

The required argument <id> is either
- the UUID of a discussion, or
- the index number of the discussion from the most recent `exercism mentoring inbox` call

Options:
    --dump      Display the raw JSON response only.'

    argparse --name="exercism mentoring discussion" \
        'dump' -- $argv
    or return 1

    if test (count $argv) -eq 0
        echo $help
        return 1
    end

    function __exercism__mentoring_student_objective
        echo $argv[1] on $argv[2] by $argv[3]
        set track (
            # not all track slugs are just the title lower-cased
            __exercism__api_call /tracks \
            | jq --arg title $argv[2] -r '
                .tracks[] | select(.title == $title) | .slug
              '
        )
        set uri "/mentoring/students/$argv[3]?track_slug=$track"
        set json (__exercism__api_call $uri)
        echo
        echo $json | jq -r '.student.track_objectives' | fold -s | sed 's/^/    /'
        echo
    end

    if string match -q --regex '^[[:xdigit:]]{32}$' $argv[1]
        set uuid $argv[1]
        for disc in $__EXERCISM__MENTORING_DISCUSSIONS
            echo $disc | read -d\v _uuid exercise track_title student
            if test $_uuid = $uuid
                break
            end
            set -e exercise track_title student
        end
    else if string match -q --regex '^[[:digit:]]+$' $argv[1]
        if not set -q __EXERCISM__MENTORING_DISCUSSIONS
           or test (count $__EXERCISM__MENTORING_DISCUSSIONS) -eq 0
                echo "call `exercism mentoring inbox` first" >&2
                return 1
        end
        if test $argv[1] -gt (count $__EXERCISM__MENTORING_DISCUSSIONS)
            echo "invalid index" >&2
            echo "call `exercism mentoring inbox` first" >&2
            return 1
        end
        echo $__EXERCISM__MENTORING_DISCUSSIONS[$argv[1]] \
        | read -d\v uuid exercise track_title student
    end

    if not set -q uuid
        echo $help
        return 1
    end

    if set -q exercise
        __exercism__mentoring_student_objective $exercise $track_title $student
    end

    set uri "/mentoring/discussions/$uuid"
    set json (__exercism__api_call "$uri/posts")
    if set -q _flag_dump
        echo $json | jq .
        return
    end

    echo "https://exercism.org$uri"

    # Clearly, ruby can do what I'm using jq for here,
    # but I've already got that `duration` function, so ...

    echo $json \
    | jq -r '
        def duration: (now - .) as $d |
            if   ($d < 3600)       then "\($d / 60 | floor) minutes"
            elif ($d < 86400)      then "\($d / 3600 | floor) hours"
            elif ($d < 86400 * 30) then "\($d / 86400 | floor) days"
            else                        "\($d / (365 * 86400) * 12 | floor) months"
            end;

        [
          .items[] |
          { author_handle,
            date: (.updated_at | fromdateiso8601 | duration),
            content_html
          }
        ]
    ' \
    | ruby -ropen3 -rjson -rcolorize -e '
        hr = "-" * 86
        JSON.parse(STDIN.read).each do |post|
          puts hr
          puts post["author_handle"].green.bold + " - " + post["date"].green
          puts ""
          Open3.popen2("html-to-text") do |i, o, t|
            i << post["content_html"]
            i.close
            puts o.read.gsub(/^/m, "    ")
          end
        end
      '
end
