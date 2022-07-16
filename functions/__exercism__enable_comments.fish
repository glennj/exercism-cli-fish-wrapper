# Enable comments for this published solution
#
# - to enable comments for a whole track:
#
#       cd $workspace/$track
#       for e in */
#           cd $e
#           if not test -d .exercism
#               if not exercism refresh
#                   prevd
#                   continue
#               end
#           end
#           printf '%-26s: ' (string sub -s 1 -e -1 $e)
#           exercism enable_comments
#           sleep 0.1s
#           prevd
#       end

function __exercism__enable_comments
    __exercism__has_metadata; or return 1
    set endpoint (
        printf \
          '/tracks/%s/exercises/%s/community_solutions/%s/comments/enable' \
          (jq -r '"\(.track)\n\(.exercise)\n\(.handle)"' .exercism/metadata.json)
    )
    __exercism__api_call -X PATCH $endpoint >/dev/null
    and echo "Comments enabled."
end
