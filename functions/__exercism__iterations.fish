function __exercism__iterations
    set help 'Usage: exercism iterations [options]

Information about a solution\'s iterations.

Options
    -p|--publish         Publish all iterations of this solution
    -pidx|--publish=idx  Publish a specific iteration index
                         - short option requires no space
                         - long option requires equal sign
                         - see https://fishshell.com/docs/current/cmds/argparse.html?highlight=parse#note-optional-arguments
    -a|--all             
    -v|--verbose         Extra verbosity.'

    argparse --name="exercism iterations" 'h/help' 'p/publish=?' 'a/all' 'v/verbose' -- $argv
    or return 1

    if set -q _flag_help
        echo $help
        return
    end

    if __exercism__in_track_root 2>/dev/null
        if not set -q _flag_all
            __exercism__has_metadata
        else
            if not set -q _flag_verbose; and not set -q _flag_publish
                echo "counting number of unpublished iterations:"
            end
            for d in */
                cd $d
                set count (
                    exercism metadata --iterations |
                    jq -r '
                        .iterations 
                        | map(select(.status != "deleted" and (.is_published|not))) 
                        | length
                    '
                )
                if not set -q _flag_publish
                    if set -q _flag_verbose
                        exercism iterations
                    else
                        printf "%5d  %s\n" $count $d
                    end
                else
                    if test $count -gt 0
                        exercism iterations -p
                        # For "publish all" for a whole track, we have to be kind to the
                        # server so we don't get rate limited:
                        # after changing the published iterations, exercism has to build 
                        # the solution's snippet and calculate the lines of code.
                        sleep 10
                    end
                end
                cd ..
            end
        end

    else if __exercism__has_metadata
        if set -q _flag_publish
            test (count $_flag_publish) -eq 0; and set _flag_publish "nil"
            set uuid (jq -r '.id' .exercism/metadata.json)
            set uri "/solutions/$uuid/published_iteration?published_iteration_idx=$_flag_publish"
            set output (__exercism__api_call -X PATCH $uri)
            if test $output = "Retry later"
                echo "API response: $output" >&2
            end
        end

        jq -r '"Iterations for \(.track) exercise \(.exercise)"' .exercism/metadata.json

        exercism metadata --iterations \
        | jq -r '
            .iterations[] | [
                .idx,
                (.created_at | fromdateiso8601 | localtime | mktime | strftime("%F %T")),
                (if .status == "no_automated_feedback" then "OK" else .status end),
                (if .tests_status == "not_queued" then "n/a" else .tests_status end),
                .is_published,
                .submission_method
            ] | @csv'  \
        | mlr --c2p --barred --implicit-csv-header label idx,date,status,tests,published,method
    end
end
