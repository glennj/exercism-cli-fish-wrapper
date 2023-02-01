
function __exercism__publish
    set help 'Usage: exercism publish [options]

Mark the exercise as completed, and enable comments.

Option
    --no-comment    Prevent comments being enabled.'

    argparse --name="exercism publish" 'no-comment' 'h/help' -- $argv
    or return 1

    if set -q _flag_help
        echo $help
        return
    end

    __exercism__has_metadata; or return 1

    set uuid (jq -r '.id' .exercism/metadata.json)
    set json (__exercism__api_call -X PATCH "/solutions/$uuid/publish")
    and printf 'Solution published to\n\n    %s\n\n' (echo $json | jq -r .solution.public_url)
    and begin
        not set -q _flag_no_comment
        and exercism enable-comments
    end
end
