function __exercism__enable_comments
    set help 'Usage: exercism enable-comments

Enable the comment feature on your published solution.

To enable comments for a whole track:

       cd $workspace/$track
       for e in */
           cd $e
           if not test -d .exercism
               if not exercism refresh
                   prevd
                   continue
               end
           end
           printf \'%-26s: \' (string sub -s 1 -e -1 $e)
           exercism enable_comments
           sleep 0.1s
           prevd
       end'

    argparse --name="exercism enable-comments" 'h/help' -- $argv
    or return 1

    if set -q _flag_help
        echo $help
        return
    end

    __exercism__has_metadata; or return 1
    set uri (
        printf \
          '/tracks/%s/exercises/%s/community_solutions/%s/comments/enable' \
          (jq -r '"\(.track)\n\(.exercise)\n\(.handle)"' .exercism/metadata.json)
    )
    __exercism__api_call -X PATCH $uri >/dev/null
    and echo "Comments enabled."
end
