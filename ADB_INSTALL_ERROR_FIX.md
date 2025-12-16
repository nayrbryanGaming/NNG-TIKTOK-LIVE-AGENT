# 🔧 ADB INSTALL ERROR - TROUBLESHOOTING GUIDE

## ❌ Error yang Terjadi

```
Error: ADB exited with exit code 1
Performing Streamed Install
adb.exe: failed to install E:\0flutter androidstudio\nng_tiktok_live_agent\build\app\outputs\flutter-apk\app-debug.apk: 
Error launching application on 2405CPCFBG.
```

Device ID: `2405CPCFBG` (Physical Android Device)

---

## ✅ SOLUSI CEPAT (Pilih salah satu)

### SOLUSI 1: Uninstall App Lama & Install Ulang (RECOMMENDED)

**Step 1: Buka terminal baru di project folder**
```bash
cd "E:\0flutter androidstudio\nng_tiktok_live_agent"
```

**Step 2: Uninstall app lama dari device**
```bash
flutter uninstall
```

**Step 3: Clean build**
```bash
flutter clean
flutter pub get
```

**Step 4: Install baru**
```bash
flutter run
```

---

### SOLUSI 2: Disconnect & Reconnect Device

**Step 1: Disconnect USB device**
- Cabut kabel USB dari device

**Step 2: Tutup Android Studio atau IDE apapun**
- Close semua aplikasi yang akses device

**Step 3: Tunggu 10 detik**

**Step 4: Connect ulang USB**
- Hubungkan kabel USB lagi

**Step 5: Approve permission di device**
- Device akan minta "Allow USB Debugging?"
- Pilih "ALLOW"

**Step 6: Run flutter**
```bash
cd "E:\0flutter androidstudio\nng_tiktok_live_agent"
flutter run
```

---

### SOLUSI 3: Reset ADB

**Step 1: Kill ADB**
```bash
adb kill-server
```

**Step 2: Start ADB**
```bash
adb start-server
```

**Step 3: Check devices**
```bash
adb devices
```

**Step 4: Try flutter run again**
```bash
cd "E:\0flutter androidstudio\nng_tiktok_live_agent"
flutter run
```

---

### SOLUSI 4: Gunakan Emulator (Jika device tidak bekerja)

**Step 1: Buka Android Studio**

**Step 2: Click "Device Manager"**

**Step 3: Pilih emulator dan klik "Play"**

**Step 4: Tunggu emulator boot up**

**Step 5: Run flutter**
```bash
cd "E:\0flutter androidstudio\nng_tiktok_live_agent"
flutter run
```

---

### SOLUSI 5: Clear Device Cache

```bash
adb shell pm clear com.example.nng_tiktok_live_agent
adb uninstall com.example.nng_tiktok_live_agent
flutter run
```

---

## 🎯 PRIORITY (Coba urutan ini):

1. **FIRST:** Solusi 1 (Uninstall & Install Ulang) ← PALING SERING BERHASIL
2. **SECOND:** Solusi 2 (Disconnect & Reconnect)
3. **THIRD:** Solusi 3 (Reset ADB)
4. **FOURTH:** Solusi 4 (Gunakan Emulator)
5. **LAST:** Solusi 5 (Clear Cache)

---

## 📝 Apa yang Dilakukan Setiap Solusi?

| Solusi | Apa yang dilakukan | Kapan gunakan |
|--------|-------------------|---------------|
| 1 | Hapus app lama, build ulang | Cache issue, installation conflict |
| 2 | Reconnect device | USB connection unstable |
| 3 | Reset ADB daemon | ADB server stuck |
| 4 | Gunakan emulator | Device tidak detected |
| 5 | Clear app data | Data corruption |

---

## ✅ Ketika Berhasil

Anda akan melihat:
```
✓ Installing and launching...
I/Choreographer(12345): Skipped 60 frames!  The application may be doing too much work on its main thread.
✓ Application launched on device.
I/flutter ( 8172): flutter: App initialized
```

**Atau langsung melihat app di device dengan logo NNG yang baru!** 🎉

---

## 🚀 MULAI DARI SOLUSI 1 SEKARANG!

```bash
# Terminal baru di Windows CMD
cd "E:\0flutter androidstudio\nng_tiktok_live_agent"
flutter uninstall
flutter clean
flutter pub get
flutter run
```

Tunggu sampai selesai, jangan cabut USB atau close terminal!

---

## ✅ TENTANG LOGO

**GOOD NEWS:** Logo NNG.png sudah benar di code!
- ✅ main_screen.dart - menggunakan NNG.png
- ✅ main.dart - menggunakan NNG.png
- ✅ pubspec.yaml - asset NNG.png terdaftar
- ✅ assets/images/NNG.png - file exist

**ADB error saja yang perlu di-fix sekarang. Setelah install berhasil, logo akan tampil sempurna!**

---

## 📞 Jika masih error:

**Error message baru apa?**
- Copy-paste error dari terminal
- Saya bantu troubleshoot lebih lanjut

**Atau coba:**
1. Gunakan emulator (Solusi 4)
2. Atau build APK manual dan install via file manager

---

**LET'S FIX THIS! 💪**

Coba Solusi 1 sekarang dan report hasilnya! 🚀

