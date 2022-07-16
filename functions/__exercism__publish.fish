# Mark the exercise as completed, and enable comments

function __exercism__publish
    __exercism__has_metadata; or return 1
    set uuid (jq -r '.id' .exercism/metadata.json)
    set json (__exercism__api_call -X PATCH "/solutions/$uuid/publish")
    and printf 'Solution published to\n\n    %s\n\n' (echo $json | jq -r .solution.public_url)
    and exercism enable_comments
end
