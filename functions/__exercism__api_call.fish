function __exercism__api_call
    # The _last_ argument will be the URI added to the exercism API root.
    # Anything before that will be taken as a curl option.
    # Example:
    #   __exercism__api_call tracks/javascript/trophies
    #   __exercism__api_call -v --output hello_world.export.zip tracks/javascript/exercises/hello-world/export_solutions

    argparse --ignore-unknown 'v/verbose' -- $argv
    or return 1

    set uri (string join "/" "https://exercism.org/api/v2" $argv[-1])
    set -e argv[-1]

    set Headers -H (__exercism__api_auth_header) \
                -H "User-Agent: exercism_cli_fish_wrapper/0.1"

    set curl_opts --silent --include
    set -q _flag_verbose; and set curl_opts --verbose
    set curl_opts $curl_opts $argv

    if set -q _flag_verbose
        begin
            command printf '%q ' curl $Headers $curl_opts $uri
            printf "\n----\n\n"
        end >&2
    end

    set seen_blank 0
    set header
    set body
    curl $Headers $curl_opts $uri | begin
        read x http_status x
        while read line
            set line (string replace --regex '\r$' "" $line)
            if test $line = ""
                set seen_blank 1
            else if test $seen_blank -eq 0
                set --append header $line
            else
                set --append body $line
            end
        end
    end

    if test $http_status -eq 429
        echo "Error 429: take a break for a while." >&2
        return 1
    end
    string collect $body
end


function __exercism__api_auth_header
    command exercism configure 2>&1 \
    | awk '$1 == "Token:" {print "Authorization: Bearer " $NF}'
end
