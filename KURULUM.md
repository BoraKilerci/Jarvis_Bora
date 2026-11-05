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

## 7. Modeli telefonda çalıştırmak (Android)

Model bilgisayar yerine **Android telefonda** çalışabilir; OpenJarvis da
bilgisayardan aynı Wi-Fi üzerinden telefona bağlanır. Bunun için telefonda
OpenAI uyumlu bir sunucu açan bir uygulama gerekir. Örneğin
[Ollama Local AI](https://play.google.com/store/apps/details?id=com.llmproxy)
(`com.llmproxy`). Adına rağmen bu uygulamanın Ollama projesiyle ilgisi yok;
GGUF modelleri llama.cpp ile telefonda çalıştırır.

> Bu adımlar OpenJarvis'in kodundaki `llamacpp` motoruna göre yazıldı, gerçek
> bir telefonla test edilmedi. Uygulamanın ekranındaki IP, port ve model adı
> senin cihazına göre farklı olacaktır.

### 7.1 Telefona uygun model seç

Modelin dosya boyutu telefonun **boş** RAM'inden küçük olmalı. Android RAM'in
yaklaşık %40–50'sini sisteme ayırır.

| Telefon RAM'i | Önerilen model (Q4_K_M GGUF) | Dosya boyutu |
|---|---|---|
| 4 GB | Qwen3.5 0.8B | ~0,5 GB |
| 6–8 GB | **Qwen3.5 2B** (en dengeli) veya Gemma 4 E2B | ~1,2–1,3 GB |
| 8 GB+ | Qwen3.5 4B veya Gemma 4 E4B | ~2,5–3 GB |
| 12 GB+ | Qwen3.5 9B | ~5,5 GB |

- Hugging Face'te model adı + `GGUF` ile arat (ör. `Qwen3.5-2B GGUF`) ve dosya
  adında **`Q4_K_M`** olanı indir.
- Bağlam uzunluğunu (context) önce **2048** ile başlat; yükseldikçe RAM tüketimi artar.

### 7.2 Telefonda sunucuyu başlat

1. Uygulamada modeli yükle ve sunucuyu başlat.
2. Ekranda görünen **IP adresini ve portu** not al (ör. `192.168.1.42:8080`).
3. Uygulama bir **API anahtarı** gösteriyorsa onu da not al.
4. Telefon ve bilgisayar **aynı Wi-Fi ağında** olmalı.

### 7.3 Bilgisayardan bağlantıyı test et

```bash
curl http://192.168.1.42:8080/v1/models
# API anahtarı varsa:
curl -H "Authorization: Bearer ANAHTARIN" http://192.168.1.42:8080/v1/models
```

Çıktıda bir model listesi (JSON) görmelisin. Listedeki `"id"` değerini not al.
OpenJarvis'te model adı olarak bunu kullanacaksın.

### 7.4 OpenJarvis'i telefona yönlendir

```bash
jarvis init --engine llamacpp --host http://192.168.1.42:8080 --force --no-download
```

Bu komut `~/.openjarvis/config.toml` dosyasına şunu yazar:

```toml
[engine]
default = "llamacpp"

[engine.llamacpp]
host = "http://192.168.1.42:8080"

[intelligence]
default_model = "qwen3.5:4b"   # ← bunu telefondaki modelin id'si ile değiştir
```

`default_model` satırını 7.3'te not aldığın `id` ile değiştir.

Uygulama API anahtarı istiyorsa, `jarvis`'i çalıştırmadan önce anahtarı
ortam değişkeni olarak ver (kalıcı olması için `~/.bashrc` / `~/.zshrc`'ye ekle):

```bash
export LLAMACPP_API_KEY=ANAHTARIN
```

### 7.5 Dene

```bash
jarvis doctor                     # motor bağlantısını kontrol eder
jarvis ask "Merhaba, nasılsın?"
jarvis                            # sohbet
```

Tek seferlik denemede ayarı değiştirmeden model/motor seçmek için:

```bash
jarvis ask -e llamacpp -m <model-id> "Merhaba"
```

### 7.6 Sorun giderme ve güvenlik

| Sorun | Çözüm |
|---|---|
| `curl` zaman aşımı / bağlantı reddedildi | Aynı Wi-Fi'de misin? Sunucu uygulamada açık mı? IP değişmiş olabilir; ekrandan tekrar bak |
| Bağlantı kısa süre sonra kopuyor | Android'de uygulama için **pil optimizasyonunu kapat**, ekranı açık tut |
| `401` / `403` hatası | API anahtarı eksik ya da yanlış: `LLAMACPP_API_KEY` |
| Model bulunamadı hatası | `default_model`, `/v1/models` çıktısındaki `id` ile birebir aynı olmalı |
| Çok yavaş / telefon ısınıyor | Daha küçük model veya daha kısa bağlam (context) kullan |
| Yerel Ollama'ya geri dönmek | `jarvis init --engine ollama --force` |

**Güvenlik:** Sunucuyu yalnızca ev Wi-Fi'si gibi güvendiğin ağlarda açık tut.
Kafe, okul gibi ortak ağlarda aynı ağdaki herkes modeline istek gönderebilir.
Kullanmadığında sunucuyu kapat.

---

## 8. Güncelleme

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

## 9. Sorun giderme

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
