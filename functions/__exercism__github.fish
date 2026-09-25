function __exercism__github
    set help 'Usage: exercism github <subcommand> [args...]

Exercism github subcommands.

  team T        List the members of exercism team T
  teams         List my exercism teams
  teams -u userid       List exercism teams for the user
  maintainer-status R   Display the ruleset and topics for repo R
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
            set argv $argv[2..]
            argparse --name="exercism github" 'u/user=' -- $argv
            or return 1

            if set -q _flag_user
                echo "Exercism teams for $_flag_user:"
            else
                set _flag_user (gh auth status --json hosts --jq '.hosts."github.com"[0].login')
                echo "My exercism teams:"
            end

            gh api graphql --paginate -f user=$_flag_user -f query='
              query($user: String!, $endCursor: String) {
                organization(login: "exercism") {
                  teams(first:100, after: $endCursor, userLogins: [$user]) {
                    nodes {
                        slug
                        members(first: 1, query: $user) {
                          edges {
                            role
                          }
                        }
                    }
                    pageInfo {
                      hasNextPage
                      endCursor
                    }
                  }
                }
              }
            ' --jq '
              .data.organization.teams.nodes
                | map([.slug, .members.edges[0].role, ("https://github.com/exercism/" + .slug)])
                | sort
                | .[]
                | @csv
            ' \
            | mlr --c2p --implicit-csv-header label Team,Role,URL then cat

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
                        role
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
                | map([(.node.name // .node.login), .role, ("https://github.com/" + .node.login)])
                | .[]
                | @csv
            ' \
            | mlr --c2p --implicit-csv-header label Name,Role,URL then cat

        case 'maintainer-status'
            if test (count $argv) -ne 2
                echo $help
                return
            end
            set slug $argv[2]
            set ruleset_id (gh api /repos/exercism/{$slug}/rulesets --jq '.[0].id')
            gh api /repos/exercism/{$slug}/rulesets/{$ruleset_id}
            gh api /repos/exercism/{$slug}/topics

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
