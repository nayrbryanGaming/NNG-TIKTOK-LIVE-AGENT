# ⚡ QUICK FIX - ADB ERROR (IKUTI INI!)

## 🚨 Error yang Terjadi
```
Error: ADB exited with exit code 1
failed to install E:\...\app-debug.apk
Error launching application on 2405CPCFBG.
```

## ✅ FIX SEKARANG (Copas command ini)

### STEP 1: Buka Terminal CMD BARU
- Tekan Windows Key + R
- Ketik: `cmd`
- Tekan ENTER

### STEP 2: Copas command ini satu per satu

```cmd
cd "E:\0flutter androidstudio\nng_tiktok_live_agent"
```

```cmd
flutter uninstall
```

```cmd
flutter clean
```

```cmd
flutter pub get
```

```cmd
flutter run
```

---

## 🎯 Apa yang terjadi:

| Command | Fungsi |
|---------|--------|
| `flutter uninstall` | Hapus app dari device |
| `flutter clean` | Hapus cache build |
| `flutter pub get` | Ambil dependencies |
| `flutter run` | Build & install ulang |

---

## ✅ Jika berhasil:

- App akan install di device
- Logo NNG.png akan tampil
- Anda bisa gunakan app

---

## ❌ Jika masih error:

**Alternatif: Gunakan EMULATOR**

1. Buka Android Studio
2. Klik Device Manager
3. Pilih emulator, klik Play
4. Tunggu boot up
5. Jalankan: `flutter run`

---

## ⏱️ MULAI SEKARANG!

Coba step by step di atas. Report jika masih error! 💪

