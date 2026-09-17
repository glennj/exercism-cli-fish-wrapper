function __exercism__api_call
    # The _last_ argument will be the URI added to the exercism API root.
    # Anything before that will be taken as a curl option.
    # Example:
    #   set result (__exercism__api_call tracks/javascript/trophies); or return 1
    #   __exercism__api_call -v --output hello_world.export.zip tracks/javascript/exercises/hello-world/export_solutions

    argparse --ignore-unknown 'v/verbose' -- $argv
    or return 1

    set uri (string join "/" "https://exercism.org/api/v2" $argv[-1])
    set -e argv[-1]

    set user_agent "exercism_cli_fish_wrapper/0.1"
    if test -r $XDG_CONFIG_HOME/exercism/user_agent
        set user_agent (cat $XDG_CONFIG_HOME/exercism/user_agent)
    end

    set Headers -H (__exercism__api_auth_header) -H "User-Agent: $user_agent"

    set curl_opts --silent --include --location --write-out '\n%{response_code}'
    set -q _flag_verbose; and set curl_opts $curl_opts --verbose
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

    set output (curl $Headers $curl_opts $uri)
    set curl_exit_status $status

    set response_code $output[-1]
    set -e output[-1]
    if test $response_code -eq 0
        echo "Error: curl timed out waiting for $uri" >&2
        return 4
    else if test $response_code -eq 429
        echo "Error 429: take a break for a while." >&2
        return 1
    else if test $response_code -ge 400
        echo "Error $response_code: cannot fetch $uri" >&2
        return 2
    end

    printf '%s\n' $output | begin
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

    string collect $body
end


function __exercism__api_auth_header
    command exercism configure 2>&1 \
    | awk '$1 == "Token:" {print "Authorization: Bearer " $NF}'
end
