function __exercism__api_call
    # Use --ignore-unknown to allow options that need to be passed to curl
    #
    argparse --ignore-unknown 'v/verbose' -- $argv
    or return 1
    set api_root "https://exercism.org/api/v2"
    set uri (string join "/" $api_root $argv[-1])
    set -e argv[-1]
	set Headers -H (__exercism__api_auth_header) \
				-H "User-Agent: exercism_cli_fish_wrapper/0.1"

    if set -q _flag_verbose
        echo curl -s $Headers $argv $uri >&2
    end
    curl -s $Headers $argv $uri
end


function __exercism__api_auth_header
    command exercism configure 2>&1 \
    | awk '$1 == "Token:" {print "Authorization: Bearer " $NF}'
end
