#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────
# Jarvis_Bora — upstream OpenJarvis güncellemelerini bu repoya çeker.
#
# Bu repo open-jarvis/OpenJarvis'in tam git geçmişini taşır, bu yüzden
# upstream değişiklikleri normal bir `git merge` ile alınabilir.
#
# Kullanım (repo klonunun içinde):
#   ./guncelle.sh            # upstream/main'i birleştir
#   ./guncelle.sh --push     # birleştir ve origin'e gönder
# ─────────────────────────────────────────────────────────────────────
set -euo pipefail

UPSTREAM_URL="https://github.com/open-jarvis/OpenJarvis.git"
cd "$(dirname "$0")"

if ! git remote get-url upstream &>/dev/null; then
    git remote add upstream "$UPSTREAM_URL"
    echo "[bilgi] 'upstream' remote eklendi: $UPSTREAM_URL"
fi

if [[ -n "$(git status --porcelain)" ]]; then
    echo "[hata] Çalışma dizininde commit edilmemiş değişiklikler var. Önce commit et veya stash'le." >&2
    exit 1
fi

git fetch upstream main --no-tags
git merge --no-edit upstream/main

if [[ "${1:-}" == "--push" ]]; then
    git push origin HEAD
fi

echo
echo "[ok] Repo güncellendi. Kurulu Jarvis'i güncellemek için: jarvis self-update"
