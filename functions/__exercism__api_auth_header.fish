function __exercism__api_auth_header
    command exercism configure 2>&1 \
    | awk '$1 == "Token:" {print "Authorization: Bearer " $NF}'
end
