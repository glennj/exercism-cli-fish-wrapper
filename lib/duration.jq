# input: a time value (the output from `fromdateiso86801`)
# output: a human-readable string
#
def duration:
    (now - .) as $d |
    if   ($d < 3600)       then "\($d / 60 | floor) minutes"
    elif ($d < 86400)      then "\($d / 3600 | floor) hours"
    elif ($d < 86400 * 30) then "\($d / 86400 | floor) days"
    else                        "\($d / (365 * 86400) * 12 | floor) months"
    end;


# It seems jq has a DST problem (maybe something else? TBD)
#
# $ jq --arg d "2023-06-20T14:15:00Z" -n '[ $d, ($d | fromdateiso8601), ($d | fromdateiso8601 | todateiso8601)]'
# [
#   "2023-06-20T14:15:00Z",
#   1687274100,
#   "2023-06-20T15:15:00Z"
# ] #............^
#
# $ TZ=UTC jq --arg d "2023-06-20T14:15:00Z" -n '[ $d, ($d | fromdateiso8601), ($d | fromdateiso8601 | todateiso8601)]'
# [
#   "2023-06-20T14:15:00Z",
#   1687270500,
#   "2023-06-20T14:15:00Z"
# ] #............^
#
# Wherever this module is used, use UTC:
#   TZ=UTC jq -L /path 'include "duration"; ...'
