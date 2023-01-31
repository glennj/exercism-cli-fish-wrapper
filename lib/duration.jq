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
