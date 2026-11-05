#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────
# Jarvis_Bora — OpenJarvis yerel kurulum scripti (macOS · Linux · WSL2)
#
# Upstream'in resmi kurulum scriptini (scripts/install/install.sh)
# bu repo (BoraKilerci/Jarvis_Bora) kaynak alınacak şekilde çalıştırır.
#
# Yaptıkları:
#   - uv (Python paket yöneticisi) kurar
#   - Bu repoyu ~/.openjarvis/src/ altına klonlar
#   - Python 3.11 sanal ortamı oluşturup OpenJarvis'i kurar
#   - Ollama'yı kurar, başlatır ve qwen3.5:2b modelini indirir
#   - ~/.openjarvis/config.toml dosyasını donanımına göre oluşturur
#   - `jarvis` komutunu ~/.local/bin altına bağlar
#   - Arka planda Rust eklentisini derler ve daha büyük modelleri indirir
#
# Kullanım:
#   ./kur.sh                  # normal kurulum
#   ./kur.sh --minimal        # model indirmeden kur
#   ./kur.sh --no-analytics   # analitik paylaşımını sormadan kapat
#   ./kur.sh --force          # tüm adımları baştan çalıştır
#
# Ortam değişkenleri:
#   JARVIS_REPO_URL   Klonlanacak repo (varsayılan: bu GitHub reposu)
#   OPENJARVIS_HOME   Kurulum dizini (varsayılan: ~/.openjarvis)
# ─────────────────────────────────────────────────────────────────────
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
INSTALLER="$SCRIPT_DIR/scripts/install/install.sh"

if [[ ! -f "$INSTALLER" ]]; then
    echo "[hata] $INSTALLER bulunamadı. Bu scripti repo kök dizininden çalıştır." >&2
    exit 1
fi

case "$(uname -s)" in
    Linux|Darwin) ;;
    *)
        echo "[hata] Bu script macOS, Linux veya WSL2 içindir." >&2
        echo "       Windows'ta WSL2 (Ubuntu) içinde çalıştır ya da KURULUM.md'deki" >&2
        echo "       'Windows' bölümüne bak." >&2
        exit 1
        ;;
esac

export OPENJARVIS_REPO_URL="${JARVIS_REPO_URL:-https://github.com/BoraKilerci/Jarvis_Bora.git}"

echo "[bilgi] Kaynak repo: $OPENJARVIS_REPO_URL"
echo "[bilgi] Kurulum dizini: ${OPENJARVIS_HOME:-$HOME/.openjarvis}"
echo

exec bash "$INSTALLER" "$@"
