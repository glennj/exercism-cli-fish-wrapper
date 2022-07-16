# *Append* my new subcommands to an existing completion

# return immediately if we've sourced this file already
set -q __EXERCISM__ADDITIONAL_COMPLETIONS; and return
set -g __EXERCISM__ADDITIONAL_COMPLETIONS yes

for dir in $fish_complete_path
    test -f "$dir/exercism.fish"
    and source "$dir/exercism.fish"
end

complete -f -c exercism -n "__fish_use_subcommand" -a "refresh" -d "Re-downloads a submitted exercise"
complete -f -c exercism -n "__fish_use_subcommand" -a "test-all" -d "Refresh and retest every exercise for a track"
complete -f -c exercism -n "__fish_use_subcommand" -a "cleanup" -d "Clean up build artifacts (some tracks)"
complete -f -c exercism -n "__fish_use_subcommand" -a "sync" -d "Sync an exercise so it is up-to-date"
complete -f -c exercism -n "__fish_use_subcommand" -a "sync-status" -d "List out-of-date exercises in the track"
complete -f -c exercism -n "__fish_use_subcommand" -a "publish" -d "Mark as complete and enable comments"
complete -f -c exercism -n "__fish_use_subcommand" -a "metadata" -d "Show the metadata of the exercise"
complete -f -c exercism -n "__fish_use_subcommand" -a "iterations" -d "Open the exercise's iterations in the browser"
complete -f -c exercism -n "__fish_use_subcommand" -a "open" -d "Open the exercise's iterations in the browser"
complete -f -c exercism -n "__fish_use_subcommand" -a "enable-comments" -d "Enable comments for this exercise"
complete -f -c exercism -n "__fish_use_subcommand" -a "mentoring-queue" -d "List my mentoring queue"
complete -f -c exercism -n "__fish_use_subcommand" -a "missing" -d "List track exercises not downloaded"
