# Jarvis_Bora — OpenJarvis Yerel Kurulum Rehberi

Bu repo, Stanford'un **[OpenJarvis](https://openjarvis.stanford.edu/)** projesinin
([open-jarvis/OpenJarvis](https://github.com/open-jarvis/OpenJarvis), Apache-2.0)
tam git geçmişiyle birlikte alınmış bir kopyasıdır. Üstüne Türkçe kurulum
rehberi ve iki yardımcı script eklendi:

| Dosya | Ne işe yarar |
|---|---|
| `kur.sh` | Resmi kurulum scriptini bu repoyu kaynak alacak şekilde çalıştırır (macOS / Linux / WSL2) |
| `guncelle.sh` | Upstream OpenJarvis'teki yenilikleri bu repoya birleştirir |
| `KURULUM.md` | Bu rehber |

OpenJarvis, yapay zekâyı **kendi bilgisayarında** çalıştıran bir asistan
çatısıdır: model varsayılan olarak [Ollama](https://ollama.com) ile yerelde
çalışır; buluta yalnızca sen istersen gider.

---

## 1. Gereksinimler

| | Minimum | Not |
|---|---|---|
| İşletim sistemi | macOS, Linux ya da Windows (WSL2 ile) | |
| RAM | 8 GB (16 GB önerilir) | Model boyutu RAM'e göre seçilir |
| Disk | ~5 GB boş alan | Başlangıç modeli ~1.5 GB |
| `git`, `curl` | Kurulu olmalı | |
| Python | **Gerekmez** | Script `uv` ile Python 3.11 ortamını kendisi kurar |
| Node.js 22+ | Sadece tarayıcı arayüzü (`jarvis gui`) için | |

---

## 2. Hızlı kurulum (önerilen) — macOS / Linux / WSL2

```bash
git clone https://github.com/BoraKilerci/Jarvis_Bora.git
cd Jarvis_Bora
./kur.sh
```

Yaklaşık 3 dakika sürer. Script şunları yapar:

1. `uv`'yi kurar (Python paket yöneticisi)
2. Bu repoyu `~/.openjarvis/src/` altına klonlar ve sanal ortama kurar
3. Ollama'yı kurar, başlatır ve `qwen3.5:2b` modelini indirir
4. Donanımını algılayıp `~/.openjarvis/config.toml` dosyasını yazar
5. `jarvis` komutunu `~/.local/bin` altına ekler
6. Arka planda Rust eklentisini (hafıza/güvenlik özellikleri) derler ve
   donanımına uygun daha büyük modelleri indirir

Kurulum sırasında isteğe bağlı analitik paylaşımı sorulur — **N** ile
reddedebilirsin (veya `./kur.sh --no-analytics`).

Bitince yeni bir terminal aç (veya `source ~/.bashrc` / `source ~/.zshrc`) ve:

```bash
jarvis            # sohbeti başlat
jarvis doctor     # her şey yolunda mı kontrol et
```

### Seçenekler

```bash
./kur.sh --minimal        # model indirmeden kur (ilk sohbet arka plan indirmesini bekler)
./kur.sh --no-analytics   # analitik sormadan kapalı
./kur.sh --force          # tüm adımları baştan çalıştır
OPENJARVIS_HOME=~/jarvis ./kur.sh   # farklı kurulum dizini
```

---

## 3. Tarayıcı arayüzü (GUI)

Grafik sohbet arayüzü için Node.js 22+ gerekir. Repo klonunun içinden:

```bash
./scripts/quickstart.sh
```

Bu script Python/Rust/Node bağımlılıklarını kurar, Ollama'yı başlatır,
backend'i (`http://localhost:8000`) ve frontend'i başlatıp
`http://localhost:5173` adresini tarayıcıda açar.

Kurulumdan sonra tek komutla da açabilirsin:

```bash
jarvis gui
```

Masaüstü uygulaması isteyenler için hazır `.dmg` / `.exe` / `.deb` / `.AppImage`
dosyaları upstream'in [Releases](https://github.com/open-jarvis/OpenJarvis/releases)
sayfasında.

---

## 4. Manuel kurulum (geliştirici yolu)

Her adımı kendin yapmak istersen (bu repo içinde, yerinde kurulum):

```bash
# 1) Araçlar
curl -LsSf https://astral.sh/uv/install.sh | sh                 # uv
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh   # Rust (1.89+)
# Ollama: https://ollama.com/download

# 2) Bağımlılıklar + Rust eklentisi
cd Jarvis_Bora
uv sync                       # GUI de istiyorsan: uv sync --extra desktop
uv run maturin develop --release -m rust/crates/openjarvis-python/Cargo.toml

# 3) Model
ollama serve &                # macOS uygulaması zaten çalışıyorsa gerekmez
ollama pull qwen3.5:2b

# 4) Yapılandırma ve çalıştırma
uv run jarvis init            # donanımı algılar, config.toml oluşturur
uv run jarvis doctor
uv run jarvis
```

> `uv run` yazmak istemiyorsan önce `source .venv/bin/activate` çalıştır.
> Python 3.10–3.13 desteklenir.

---

## 5. Windows

**Önerilen:** WSL2 (Ubuntu) kur, Ubuntu terminalinde 2. bölümdeki adımları uygula.

```powershell
wsl --install -d Ubuntu
```

**Yerel Windows** (PowerShell) için upstream'in resmi kurulumu:

```powershell
irm https://open-jarvis.github.io/OpenJarvis/install.ps1 | iex
```

> Not: Bu komut upstream (open-jarvis/OpenJarvis) reposunu kurar, bu repoyu değil.

---

## 6. Temel kullanım

```bash
jarvis                                   # sohbet (varsayılan: chat-simple)
jarvis ask "Bugün ne yapmalıyım?"        # tek seferlik soru
jarvis gui                               # tarayıcı arayüzü
jarvis model list                        # modelleri yönet
jarvis init --preset <ad> --force        # hazır yapılandırmaya geç
```

| Preset | Ne yapar |
|---|---|
| `chat-simple` | Araçsız, hafif sohbet |
| `code-assistant` | Kod çalıştırma, dosya ve kabuk erişimi olan ajan |
| `deep-research` | Dokümanlarında kaynak göstererek çok adımlı araştırma |
| `scheduled-monitor` | Hafızalı, zamanlanmış ajan |
| `morning-digest-mac` / `-linux` / `-minimal` | E-posta, takvim, haberlerden sesli günlük özet |

### Bulut modeli kullanmak (isteğe bağlı)

Kurulumdan veya `jarvis init`'ten önce şu anahtarlardan biri ortamda varsa,
OpenJarvis o sağlayıcıyı varsayılan yapar (öncelik: OpenRouter > Anthropic > OpenAI > Google):

```bash
export ANTHROPIC_API_KEY=...    # veya OPENROUTER_API_KEY / OPENAI_API_KEY / GOOGLE_API_KEY
jarvis init --force
```

Anahtar yoksa her şey yerelde kalır.

---

## 7. Güncelleme

**Bu repoyu upstream ile güncelle** (repo klonunun içinde):

```bash
./guncelle.sh --push      # upstream/main'i birleştirir ve GitHub'a gönderir
```

**Kurulu Jarvis'i güncelle:**

```bash
jarvis self-update
```

`self-update`, `~/.openjarvis/src` içindeki klonu bu GitHub reposundan çeker;
bu yüzden önce `guncelle.sh --push` ile repoyu güncelle.

---

## 8. Sorun giderme

| Sorun | Çözüm |
|---|---|
| `command not found: jarvis` | `source ~/.bashrc` (veya `~/.zshrc`) ya da yeni terminal aç |
| "memory features unavailable" | Rust eklentisi hâlâ derleniyor olabilir: `jarvis doctor`. Elle: `~/.openjarvis/.scripts/install-rust.sh && ~/.openjarvis/.scripts/build-extension.sh` |
| Model inmedi | `jarvis doctor`, sonra `~/.openjarvis/.scripts/pull-model.sh qwen3.5:2b` |
| Ollama'ya bağlanamıyor | `ollama serve` çalışıyor mu? `curl http://localhost:11434` |
| Şirket proxy'si arkasında | Kurulumdan önce `HTTPS_PROXY` ve `CURL_CA_BUNDLE` ayarla |

**Kaldırma:**

```bash
jarvis-uninstall
```

`~/.openjarvis/` ve `jarvis` komutlarını siler; Ollama, uv ve Rust'a dokunmaz.

---

## Kaynaklar

- Proje sitesi: <https://openjarvis.stanford.edu/>
- Dokümantasyon: <https://open-jarvis.github.io/OpenJarvis/>
- Upstream repo: <https://github.com/open-jarvis/OpenJarvis>
- Lisans: Apache-2.0 (bkz. `LICENSE`)
