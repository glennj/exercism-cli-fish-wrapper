# Reports on any out-of-date solutions

function __exercism__sync_status
    __exercism__in_track_root; or return 1
    set root $PWD
    set track (basename $root)

    set count 0
    for e in */
        test -d $root/$e; or continue
        cd $root/$e
        set solution (exercism metadata); or continue
        set _status "ok"
        if test "true" = (echo $solution | jq -r .solution.is_out_of_date)
            set _status "OUT OF DATE"
            set count (math $count + 1)
        end
        printf "%-11s %s\n" $_status $e
    end
    echo
    echo "$count solutions out of date"
    cd $root
end
