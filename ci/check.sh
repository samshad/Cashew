#!/usr/bin/env bash
# Usage: ci/check.sh format|analyze|duplicates   (BASE = target branch, default main)
set -euo pipefail

base=${BASE:-main}
added() {
  git diff --name-only --diff-filter=A "origin/$base...HEAD" -- 'budget/*.dart' ':!*.g.dart'
}
sdk() {
  local root=$1
  shift
  docker run --rm -v "$root/budget:/app" sdk "$@"
}
# Issues without line/column/length, so upstream issues survive shifting lines.
issues() {
  sdk "$1" sh -c 'flutter pub get --enforce-lockfile >&2 && { dart analyze --format=machine || [ $? -le 3 ]; }' |
    sed -E 's/^(([^|]*\|){4})[0-9]+\|[0-9]+\|[0-9]+\|/\1/' | sort
}

case ${1:-} in
format)
  files=$(added | sed 's|^budget/||')
  [ -n "$files" ] || { echo "No added Dart files."; exit 0; }
  # shellcheck disable=SC2086
  sdk "$PWD" dart format --output=none --set-exit-if-changed -- $files
  ;;
analyze)
  tmp=$(mktemp -d)
  trap 'docker run --rm -v "$tmp:/t" sdk rm -rf /t/base; rm -rf "$tmp"; git worktree prune' EXIT
  git worktree add --detach "$tmp/base" "origin/$base"
  issues "$tmp/base" >"$tmp/base.txt"
  issues "$PWD" >"$tmp/head.txt"
  comm -13 "$tmp/base.txt" "$tmp/head.txt" >"$tmp/new.txt"
  echo "Issues: base $(wc -l <"$tmp/base.txt"), head $(wc -l <"$tmp/head.txt"), new $(wc -l <"$tmp/new.txt")"
  if [ -s "$tmp/new.txt" ]; then
    echo "New analyzer issues:"
    cat "$tmp/new.txt"
    exit 1
  fi
  ;;
duplicates)
  files=$(added)
  [ -n "$files" ] || { echo "No added Dart files."; exit 0; }
  # shellcheck disable=SC2086
  npx --yes jscpd@4.0.5 --format dart --threshold 0 --reporters console -- $files
  ;;
*)
  echo "Usage: $0 format|analyze|duplicates" >&2
  exit 2
  ;;
esac
