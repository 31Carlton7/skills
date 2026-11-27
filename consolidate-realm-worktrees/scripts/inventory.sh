#!/usr/bin/env bash
set -euo pipefail

repo_dir="${1:-.}"
repo_dir=$(git -C "$repo_dir" rev-parse --show-toplevel)

printf 'BRANCH\tWORKTREE\tDIRTY\tAHEAD_MAIN\tBEHIND_MAIN\tHEAD\n'
worktree_dir=''
while IFS= read -r record; do
  case "$record" in
    'worktree '*) worktree_dir=${record#worktree } ;;
    'branch refs/heads/'*)
      branch_name=${record#branch refs/heads/}
      dirty_count=$(git -C "$worktree_dir" status --porcelain=v1 | /usr/bin/wc -l | /usr/bin/tr -d ' ')
      ahead_count=$(git -C "$repo_dir" rev-list --count main.."$branch_name")
      behind_count=$(git -C "$repo_dir" rev-list --count "$branch_name"..main)
      head_subject=$(git -C "$worktree_dir" log -1 --format='%s')
      printf '%s\t%s\t%s\t%s\t%s\t%s\n' "$branch_name" "$worktree_dir" "$dirty_count" "$ahead_count" "$behind_count" "$head_subject"
      ;;
  esac
done < <(git -C "$repo_dir" worktree list --porcelain)

printf '\nBRANCH\tLOCAL_BRANCHES_CONTAINED\n'
git -C "$repo_dir" worktree list --porcelain | while IFS= read -r record; do
  case "$record" in
    'branch refs/heads/'*)
      branch_name=${record#branch refs/heads/}
      contained_count=$(git -C "$repo_dir" branch --format='%(refname:short)' --merged "$branch_name" | /usr/bin/wc -l | /usr/bin/tr -d ' ')
      printf '%s\t%s\n' "$branch_name" "$contained_count"
      ;;
  esac
done | sort -t $'\t' -k2,2nr -k1,1
