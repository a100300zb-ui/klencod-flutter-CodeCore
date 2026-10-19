# مشغّل بايثون (Flutter + Chaquopy)

تطبيق أندرويد بلغة Dart يشغّل سكربتات بايثون: تكتب الكود أو تفتح ملف `.py` وتضغط تشغيل.

## طريقة التركيب

### 1) أنشئ مشروع Flutter جديد
```bash
flutter create --org com.example py_runner
cd py_runner
```

### 2) انسخ الملفات دي فوق المشروع
- `pubspec.yaml`
- `lib/main.dart`
- `android/app/src/main/kotlin/com/example/py_runner/MainActivity.kt`
- `android/app/src/main/python/runner.py`

ثم شغّل:
```bash
flutter pub get
```

### 3) عدّل `android/settings.gradle` (أو `.kts`)
أضف داخل `plugins { ... }`:
```gradle
id "com.chaquo.python" version "16.0.0" apply false
```

### 4) عدّل `android/app/build.gradle`
في أول الملف داخل `plugins { ... }` أضف:
```gradle
id "com.chaquo.python"
```

وداخل `android { defaultConfig { ... } }` أضف:
```gradle
ndk {
    abiFilters "arm64-v8a", "x86_64"
}
```

وبعد بلوك `android { }` أضف:
```gradle
chaquopy {
    defaultConfig {
        version "3.11"
        // مكتبات بايثون اللي عايزها (اختياري):
        // pip {
        //     install "requests"
        //     install "numpy"
        // }
    }
}
```

> لو `minSdkVersion` أقل من 21 غيّره إلى 21 أو أعلى.

### 5) شغّل
```bash
flutter run
```

## ملاحظات
- Chaquopy بيدعم بايثون 3.8 إلى 3.13، وبيسمح بمكتبات pip كتير (ومنها numpy وrequests).
- أول build بياخد وقت لأنه بيحمّل مفسّر بايثون.
- `input()` مش مدعومة في النسخة دي (مفيش شاشة إدخال). لو عايزها قولي وأضيفها.
- الكود بيتشغّل داخل التطبيق نفسه بصلاحياته، فاتشغّل بس سكربتات تثق فيها.
- الملف بيتفتح ويتحط في المحرر، وبعدين تضغط تشغيل.
