# *Append* my new subcommands to an existing completion

# Return immediately if we've sourced this file already
set -q __EXERCISM__ADDITIONAL_COMPLETIONS; and return
set -g __EXERCISM__ADDITIONAL_COMPLETIONS yes

# Find the "official" exercism completions in the complete path.
# This loop will find this script as well, which is why
# the guard above exists (to avoid infinite sourcing).
for dir in $fish_complete_path
    test -f "$dir/exercism.fish"
    and source "$dir/exercism.fish"
end

# Now, add the additional subcommands for completion
complete -f -c exercism -n "__fish_use_subcommand" -a "cleanup" -d "Clean up build artifacts (some tracks)"
complete -f -c exercism -n "__fish_use_subcommand" -a "dev" -d "Track development commands"
complete -f -c exercism -n "__fish_use_subcommand" -a "enable-comments" -d "Enable comments for this exercise"
complete -f -c exercism -n "__fish_use_subcommand" -a "iterations" -d "Open the exercise's iterations in the browser"
complete -f -c exercism -n "__fish_use_subcommand" -a "last-test-run" -d "Dump results of most recent test run"
complete -f -c exercism -n "__fish_use_subcommand" -a "mentoring" -d "Mentoring info"
complete -f -c exercism -n "__fish_use_subcommand" -a "metadata" -d "Show the metadata of the exercise"
complete -f -c exercism -n "__fish_use_subcommand" -a "missing" -d "List track exercises not downloaded"
complete -f -c exercism -n "__fish_use_subcommand" -a "notifications" -d "Show recent exercism notifications"
complete -f -c exercism -n "__fish_use_subcommand" -a "open" -d "Open the exercise's iterations in the browser"
complete -f -c exercism -n "__fish_use_subcommand" -a "publish" -d "Mark as complete and enable comments"
complete -f -c exercism -n "__fish_use_subcommand" -a "refresh" -d "Re-downloads a submitted exercise"
complete -f -c exercism -n "__fish_use_subcommand" -a "reputation" -d "Show recent exercism reputation awards"
complete -f -c exercism -n "__fish_use_subcommand" -a "sync" -d "Sync an exercise so it is up-to-date"
complete -f -c exercism -n "__fish_use_subcommand" -a "switch-user" -d "Switch user.json"
complete -f -c exercism -n "__fish_use_subcommand" -a "test" -d "Run the test suite for the current exercise"
complete -f -c exercism -n "__fish_use_subcommand" -a "check" -d "Run formatters/linters for the current exercise"
complete -f -c exercism -n "__fish_use_subcommand" -a "test-all" -d "Refresh and retest every exercise for a track"
complete -f -c exercism -n "__fish_use_subcommand" -a "tracks" -d "List all Exercism tracks"

# and subcommand options
complete -f -c exercism -n "__fish_seen_subcommand_from iterations" -s p -l publish -d "specify which iterations to publish"
complete -f -c exercism -n "__fish_seen_subcommand_from iterations" -s a -l all -d "publish all iterations"
complete -f -c exercism -n "__fish_seen_subcommand_from iterations" -s a -l all -d "publish all iterations"
complete -f -c exercism -n "__fish_seen_subcommand_from iterations" -s v -l verbose -d "verbose"
complete -f -c exercism -n "__fish_seen_subcommand_from metadata" -s i -l iterations -d "also show iteration data"
complete -f -c exercism -n "__fish_seen_subcommand_from notifications" -l all -d "show all notifications"
complete -f -c exercism -n "__fish_seen_subcommand_from publish" -l no-comment -d "don't enable comments"
complete -f -c exercism -n "__fish_seen_subcommand_from refresh" -s a -l all -d "refresh all exercises"
complete -f -c exercism -n "__fish_seen_subcommand_from reputation" -l all -d "show all reputation"
complete -f -c exercism -n "__fish_seen_subcommand_from reputation" -l mark -d "mark all as seen"
complete -f -c exercism -n "__fish_seen_subcommand_from sync" -s a -l all -d "sync all exercises"
complete -f -c exercism -n "__fish_seen_subcommand_from sync" -s h -l help -d "help"
complete -f -c exercism -n "__fish_seen_subcommand_from sync" -s s -l status -d "display sync status"
complete -f -c exercism -n "__fish_seen_subcommand_from sync" -s u -l update -d "perform sync"

# mentoring sub-subcommands
complete -f -c exercism -n "__fish_seen_subcommand_from mentoring" -a queue -d "List my queue"
complete -f -c exercism -n "__fish_seen_subcommand_from mentoring" -a inbox -d "List my inbox"
complete -f -c exercism -n "__fish_seen_subcommand_from mentoring" -a discussion -d "show the discussion posts"
complete -f -c exercism -n "__fish_seen_subcommand_from mentoring" -a overview -d "inbox and queue"
complete -f -c exercism -n "__fish_seen_subcommand_from queue" -s c -l count -d "just show counts"
complete -f -c exercism -n "__fish_seen_subcommand_from inbox" -l inbox -d "list inbox discussions"
complete -f -c exercism -n "__fish_seen_subcommand_from inbox" -l student -d "list awaiting student discussions"
complete -f -c exercism -n "__fish_seen_subcommand_from inbox" -l finished -d "list finished discussions"
complete -f -c exercism -n "__fish_seen_subcommand_from inbox" -s p -l pages -d "how many pages to fetch"
complete -f -c exercism -n "__fish_seen_subcommand_from inbox" -s o -l order -r -a "recent oldest student exercise" -k -d "sort order"
complete -f -c exercism -n "__fish_seen_subcommand_from discussion" -l end -d "end the discussion"
complete -f -c exercism -n "__fish_seen_subcommand_from discussion" -l post -d "add a post to the discussion"

# dev sub-subcommands
complete -f -c exercism -n "__fish_seen_subcommand_from dev" -a unimplemented -d "List unimplemented exercises"
