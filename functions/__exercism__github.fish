function __exercism__github
    set help 'Usage: exercism github <subcommand> [args...]

Exercism github subcommands.

  team T        List the members of exercism team T
  teams         List my exercism teams'

    argparse --name="exercism github" --stop-nonopt 'h/help' -- $argv
    or return 1

    if set -q _flag_help; or test (count $argv) -eq 0
        echo $help
        return
    end

    switch $argv[1]
        case help
            echo $help
        case teams
            echo "My exercism teams:"
            gh api graphql --paginate -f query='
              query($endCursor: String) {
                organization(login: "exercism") {
                  teams(first:100, after: $endCursor, role:MEMBER) {
                    edges {
                      node {
                        slug
                      }
                    }
                  }
                }
              }
            ' --jq '
                .data.organization.teams.edges
                | map(.node.slug)
                | sort
                | map([., "https://github.com/exercism/" + .])
                | .[]
                | @csv
            ' \
            | mlr --c2p --implicit-csv-header label Team,URL then cat

        case team
            if test (count $argv) -ne 2
                echo $help
                return
            end
            echo "Members of the $argv[2] team:"
            gh api graphql -F team=$argv[2] -f query='
              query($team: String!) {
                organization(login: "exercism") {
                  team(slug: $team) {
                    members {
                      edges {
                        node {
                          login
                          name
                        }
                      }
                    }
                  }
                }
              }
            ' \
            --jq '
                .data.organization.team.members.edges
                | map([(.node.name // .node.login), ("https://github.com/" + .node.login)])
                | .[]
                | @csv
            ' \
            | mlr --c2p --implicit-csv-header label Name,URL then cat

        case '*'
            echo 'unknown subcommand' >&2
            return 1
    end
end
