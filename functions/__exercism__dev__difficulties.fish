function __exercism__dev__difficulties
    argparse --name="exercism dev difficulties" 'h/help' 's/sort' -- $argv
    or return 1

    if set -q _flag_help
        exercism dev --help
        return
    end

    __exercism__in_dev_root; or return 1

    jq -r '.exercises.practice[] | [.slug, .difficulty] | @csv' config.json \
    | if set -q _flag_sort; sort -t, -n -k2; else; cat; end \
    | mlr --c2p --implicit-csv-header --barred \
        label exercise,difficulty \
        then cat -n \
    | less
end
