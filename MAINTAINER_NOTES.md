# Maintainer notes

I may add this to a proper function. For now, let's just brain dump.

## Reviewing a PR with `gh`

```sh
set pr 'https://github.com/exercism/REPO/pull/NUM'
gh pr view $pr
gh pr checks $pr
gh pr diff $pr
gh pr edit $pr --add-label 'x:rep/small'
gh pr review $pr --approve
gh pr merge $pr --squash
```

