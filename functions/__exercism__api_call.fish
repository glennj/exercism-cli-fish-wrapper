function __exercism__api_call
    set api_root "https://exercism.org/api/v2"
    set uri (string join "/" $api_root $argv[-1])
    set -e argv[-1]
    curl -s -H (__exercism__api_auth_header) $argv $uri
end
