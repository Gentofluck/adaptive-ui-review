#!/usr/bin/env bash
set -euo pipefail

action="${1:-deploy}"
branch="${GITHUB_REF_NAME:-$(git branch --show-current)}"
sha="${GITHUB_SHA:-$(git rev-parse HEAD)}"
root="${HELIOS_PATH:?}"
url="${HELIOS_URL:?}"

if [[ ! "$root" =~ ^public_html/[A-Za-z0-9_-]+$ ]]; then
  echo "Недопустимый каталог: $root" >&2
  exit 2
fi

if [[ "$branch" != main ]]; then
  slug="$(printf '%s' "$branch" | LC_ALL=C tr -c 'A-Za-z0-9._-' '-' | cut -c1-48)"
  suffix="$(printf '%s' "$branch" | shasum -a 256 | cut -c1-8)"
  root="$root-previews/$slug-$suffix"
  url="${url%/}-previews/$slug-$suffix/"
fi

previous="$root.previous"
staging="$root.next"

published_sha() {
  ssh helios sh -s -- "$1" <<'REMOTE' | grep -o 'BUILD-STAMP commit=[a-z0-9]*' | head -1 | cut -d= -f2
cat "$1/index.html"
REMOTE
}

rollback() {
  ssh helios sh -s -- "$root" "$previous" <<'REMOTE'
set -eu
current="$1"
previous="$2"
test -d "$current"
test -d "$previous"
test ! -e "$current.swap"
mv "$current" "$current.swap"
if ! mv "$previous" "$current"; then
  mv "$current.swap" "$current"
  exit 1
fi
mv "$current.swap" "$previous"
REMOTE
}

case "$action" in
  rollback)
    if [[ "$branch" != main ]]; then
      echo 'Откат разрешён только для main' >&2
      exit 2
    fi
    expected="$(published_sha "$previous")"
    rollback
    bash scripts/healthcheck.sh "$url" "$expected"
    ;;
  deploy)
    SITE_URL="$url" GITHUB_SHA="$sha" mkdocs build --strict
    ssh helios sh -s -- "$staging" <<'REMOTE'
mkdir -p "$1"
REMOTE
    rsync -rlvz --delete site/ "helios:$staging/"
    ssh helios sh -s -- "$root" "$previous" "$staging" <<'REMOTE'
set -eu
current="$1"
previous="$2"
staging="$3"
test -f "$staging/index.html"
chmod -R u=rwX,go=rX "$staging"
if [ -d "$current" ]; then
  rm -rf "$previous"
  mv "$current" "$previous"
fi
if ! mv "$staging" "$current"; then
  if [ -d "$previous" ]; then mv "$previous" "$current"; fi
  exit 1
fi
REMOTE
    if ! bash scripts/healthcheck.sh "$url" "$sha"; then
      if expected="$(published_sha "$previous")"; then
        rollback
        bash scripts/healthcheck.sh "$url" "$expected"
        echo 'Предыдущая версия восстановлена' >&2
      fi
      exit 1
    fi
    expected="${sha:0:12}"
    ;;
  *)
    echo 'Использование: deploy-helios.sh deploy|rollback' >&2
    exit 2
    ;;
esac

printf 'URL: %s\nВерсия: %s\n' "$url" "$expected"
if [[ -n "${GITHUB_OUTPUT:-}" ]]; then
  printf 'url=%s\nsha=%s\n' "$url" "$expected" >> "$GITHUB_OUTPUT"
fi
if [[ -n "${GITHUB_STEP_SUMMARY:-}" ]]; then
  printf 'Helios: [%s](%s), версия **%s**, действие **%s**.\n' "$url" "$url" "$expected" "$action" >> "$GITHUB_STEP_SUMMARY"
fi
