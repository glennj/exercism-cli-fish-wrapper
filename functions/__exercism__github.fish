function __exercism__github
    set help 'Usage: exercism github <subcommand> [args...]

Exercism github subcommands.

  team T        List the members of exercism team T
  teams         List my exercism teams
  prs           List my open exercism PRs
  issues        List my open exercism issues'

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

        case 'prs'
            echo 'My open Exercism PRs:'
            gh api graphql --paginate -f query='
                query($endCursor: String) {
                  viewer {
                    pullRequests(first:10, after:$endCursor, states:OPEN) {
                      nodes {
                        number
                        repository {name}
                        title
                        permalink
                        createdAt
                      }
                    }
                  }
                }
            ' --jq '
                .data.viewer.pullRequests.nodes
                | sort_by(.createdAt)
                | .[]
                | select(.permalink | contains("/exercism/"))
                | [.repository.name, .number, .title, .permalink, .createdAt]
                | @csv
            ' \
            | mlr --c2p --implicit-csv-header label Repo,Num,Title,URL,Created then cat

        case 'issues'
            echo 'My open Exercism Issues:'
            gh api graphql --paginate -f query='
              query($endCursor: String) {
                viewer {
                  issues(first:10, after:$endCursor, states:OPEN) {
                    nodes {
                      number
                      repository {name}
                      url
                      title
                      createdAt
                    }
                  }
                }
              }
            ' \
            --jq '
                .data.viewer.issues.nodes
                | sort_by(.createdAt)
                | map(select(.url | contains("/exercism")) | [.repository.name, .number, .title, .url, .createdAt])
                | .[] | @csv
            ' \
            | mlr --c2p --implicit-csv-header label Repo,Num,Title,URL,Created then cat

        case '*'
            echo 'unknown subcommand' >&2
            return 1
    end
end
