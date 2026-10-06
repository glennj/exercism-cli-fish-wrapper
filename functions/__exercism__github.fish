function __exercism__github
    set help 'Usage: exercism github <subcommand> [args...]

Exercism github subcommands.

  audit <cmd>             Audit state of exercism repos
  issues                  List my open exercism issues
  maintainer-status <R>   Display the ruleset and topics for repo R
  prs                     List my open exercism PRs
  team <T>                List the members of exercism team T
  teams                   List my exercism teams
  teams -u userid         List exercism teams for the user
  tracks                  Info about track repos
  track-prs <R>           Data about a track\'s PRs'

    argparse --name="exercism github" --stop-nonopt 'h/help' -- $argv
    or return 1

    if set -q _flag_help; or test (count $argv) -eq 0
        echo $help
        return
    end

    switch $argv[1]
        case help
            echo $help

        case audit
            if test (count $argv) -lt 2
                echo $help
                return 1
            end
            __exercism__github_audit $argv[2..]

        case tracks
            __exercism__github_tracks $argv[2..]
        
        case track-prs
            if test (count $argv) -lt 2
                echo $help
                return 1
            end
            __exercism__github_track_prs $argv[2..]

        case teams
            __exercism__github_teams $argv[2..]

        case team
            if test (count $argv) -lt 2
                echo $help
                return 1
            end
            __exercism__github_team $argv[2..]

        case 'maintainer-status'
            if test (count $argv) -lt 2
                echo $help
                return 1
            end
            set slug $argv[2]
            set ruleset_id (gh api /repos/exercism/{$slug}/rulesets --jq '.[0].id')
            gh api /repos/exercism/{$slug}/rulesets/{$ruleset_id}
            gh api /repos/exercism/{$slug}/topics

            echo \n"Team's repos:"
            gh api /orgs/exercism/teams/$slug/repos --jq '.[] | .full_name'

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
            echo 'Open Exercism issues assigned to me:'
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

# -----------------------------------------------------
function __exercism__github_tracks
    argparse --name="exercism github audit" 'h/help' -- $argv
    or return 1

    if set -q _flag_help
        echo "Get track slugs"
        return
    end

    begin
        echo ... fetching active tracks >&2
        __exercism__tracks__get_slugs --with-config-date --topics \
        | awk 'BEGIN {FS=OFS="\t"} {$2 = "yes" OFS $2} 1'

        echo ... fetching inactive tracks >&2
        __exercism__tracks__get_slugs --with-config-date --topics --inactive \
        | awk 'BEGIN {FS=OFS="\t"} {$2 = "no" OFS $2} 1'
    end \
    | mlr --t2p --implicit-tsv-header label Repo,Active,ConfigDate,Topics then sort -f Repo
  end

# -----------------------------------------------------
function __exercism__github_track_prs -a slug

    set endCursor ""
    while true
		printf . >&2   # dots to show activity for long-running cmd
        set response (
            gh api graphql -F owner=exercism -F repo=$slug -F endCursor="$endCursor" -f query='
              query($owner: String!, $repo: String!, $endCursor: String) {
                repository(owner: $owner, name: $repo) {
                  pullRequests(first: 100, states: [OPEN, CLOSED, MERGED], after: $endCursor) {
                    edges {
                      node {
                        number
                        state
                        author {
                          login
                        }
                        createdAt
                        reviews(first: 10, states: APPROVED) {
                          edges {
                            node {
                              author {
                                login
                              }
                            }
                          }
                        }
                      }
                    }
                    pageInfo {
                      endCursor
                      hasNextPage
                    }
                  }
                }
              }
            '
        )

        # Output the rows
        echo "$response" | jq -r '
          .data.repository.pullRequests.edges[].node | [.number, .createdAt, .state, .author.login, (.reviews.edges | map(.node.author.login) | join(","))] | @csv
        '

        # Check if there are more pages
        set hasNextPage (echo "$response" | jq -r '.data.repository.pullRequests.pageInfo.hasNextPage')
        
        test "$hasNextPage" = "false"; and break

        # Get the cursor for the next page
        set endCursor (echo "$response" | jq -r '.data.repository.pullRequests.pageInfo.endCursor')
    end \
    | begin; echo; mlr --c2p --barred --implicit-csv-header label Num,Created,State,Author,Approver then sort -nr Num; end
end

# -----------------------------------------------------
function __exercism__github_teams
    argparse --name="exercism github" 'h/help' 'u/user=' -- $argv
    or return 1

    if set -q _flag_help
        echo "Usage: exercism github teams [-u userid]"
        return
    end

    if set -q _flag_user
        echo "Exercism teams for $_flag_user:"
    else
        set _flag_user (gh auth status --json hosts --jq '.hosts."github.com"[0].login')
        echo "My exercism teams:"
    end

    set endCursor ""

    while true
        set response (
            gh api graphql --paginate -f user=$_flag_user -f endCursor="$endCursor" -f query='
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
            '
        )

		echo "$response" | jq -r '
			.data.organization.teams.nodes
			| map([.slug, .members.edges[0].role, ("https://github.com/exercism/" + .slug)])
			| sort
			| .[]
			| @csv
		'

		set hasNextPage (echo "$response" | jq -r '.data.organization.teams.pageInfo.hasNextPage')
		test $hasNextPage = false; and break

        set endCursor (echo "$response" | jq -r '.data.organization.teams.pageInfo.endCursor')
    end \
    | mlr --c2p --implicit-csv-header label Team,Role,URL then cat
end

# -----------------------------------------------------
function __exercism__github_team -a team
    echo "Members of the $team team:"
    gh api graphql -F team=$team -f query='
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
        .data.organization.team.members.edges[]
        | [.node.login, .role, .node.name]
        | @csv
    ' \
    | mlr --c2p --implicit-csv-header label Login,Role,Name then cat

    echo \nTeam repos
    gh api /orgs/exercism/teams/{$team}/repos --paginate --jq '.[].full_name' | sort
end

# -----------------------------------------------------
function __exercism__github_audit
    set help 'Available subcommands:

community-contributions -- check the workflow vs the topics for repos'

    argparse --name="exercism github audit" --stop-nonopt 'h/help' -- $argv
    or return 1

    if set -q _flag_help; or test (count $argv) -eq 0
        echo $help
        return
    end

    switch $argv[1]
        case 'community-contributions'
			# TODO need a loop here?
            gh api graphql --paginate -f query='
              query($endCursor: String) {
                organization(login: "exercism") {
                  repositories(first: 100, isArchived: false, after: $endCursor) {
                    pageInfo {
                      hasNextPage
                      endCursor
                    }
                    nodes {
                      name
                      repositoryTopics(first: 10) {
                        nodes {
                          topic {
                            name
                          }
                        }
                      }
                      object(expression: "HEAD:.github/workflows/pause-community-contributions.yml") {
                        id
                        ... on Blob {
                          text
                        }
                      }
                    }
                  }
                }
              }
            ' --jq '
                .data.organization.repositories.nodes[]
                | select(.repositoryTopics.nodes as $topics | "exercism-track" | IN($topics[].topic.name))
                | [ .name
                  , (.repositoryTopics.nodes | map(.topic.name | select(test("maintained") or . == "wip-track")) | join(","))
                  , (.repositoryTopics.nodes | map(.topic.name | select(test("community-contributions"))) | join(","))
                  , if .object then "yes" else "no" end
                  , ((.object?.text // "") | (capture("forum_category: (?<cat>[a-z0-9]+)") // {}) | .cat)
                ]
                | . + [
                    if   (.[3] == "no"  and .[2] == "community-contributions-accepted") then "OK"
                    elif (.[3] == "yes" and .[2] == "community-contributions-paused") then "OK"
                    elif (.[3] == "no"  and .[2] == "community-contributions-paused") then "incorrect topic"
                    elif (.[3] == "yes" and .[2] == "community-contributions-accepted") then "incorrect topic"
                    elif (.[2] == "") then "missing topic"
                    else "?"
                    end                
                ]
                | @tsv
            ' \
            | mlr --t2p --barred --implicit-tsv-header \
                  label "Repo,MaintenanceTopic,CommunityContributionTopic,WF?,Forum,Status" \
                  then sort -f MaintenanceTopic,Repo

            echo \nNotes:
            echo "- 'WF?' == does the repo have the workflow"
            echo "- ForumCat == the forum category the workflow points to; _should_ be the slug"

        case '*'
            echo $help
            return 1
    end
end
