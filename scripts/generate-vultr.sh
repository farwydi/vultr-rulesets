#!/usr/bin/env bash
# Генерирует sing-box source rule-set (vultr.json) из всех анонсируемых
# подсетей Vultr/Choopa (AS20473) по данным RIPEstat.
set -euo pipefail

ASN="AS20473"
OUT="${1:-vultr.json}"
TMP="$(mktemp)"

echo ">> fetching announced prefixes for ${ASN} ..."
curl -fsS --max-time 60 \
  "https://stat.ripe.net/data/announced-prefixes/data.json?resource=${ASN}" \
  -o "${TMP}"

# Только IPv4-префиксы, уникальные, отсортированные.
grep -oE '"prefix": ?"[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/[0-9]+"' "${TMP}" \
  | grep -oE '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/[0-9]+' \
  | sort -u > "${TMP}.v4"

N="$(wc -l < "${TMP}.v4" | tr -d ' ')"
if [ "${N}" -lt 100 ]; then
  echo "!! got only ${N} prefixes — looks wrong, aborting" >&2
  exit 1
fi

{
  printf '{\n  "version": 3,\n  "rules": [\n    { "ip_cidr": [\n'
  awk 'NR>1{printf ",\n"} {printf "      \"%s\"", $0}' "${TMP}.v4"
  printf '\n    ] }\n  ]\n}\n'
} > "${OUT}"

rm -f "${TMP}" "${TMP}.v4"
echo ">> wrote ${OUT} with ${N} IPv4 prefixes"
