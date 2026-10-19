# KlenCode Project Finder

## الخطوات داخل Klencode

التطبيق يبحث في GitHub عن مشاريع Flutter التي تحتوي على `pubspec.yaml`، ثم يعرض ملخصًا عربيًا وطريقة بنائها على Klencode IDE.

بعد ذلك شغّل:

```bash
flutter pub get
flutter build apk --debug
```

ملف التطبيق:

```text
build/app/outputs/flutter-apk/app-debug.apk
```

البحث يستخدم GitHub API العام. قد يظهر حدّ للطلبات عند كثرة البحث. التلخيص الحالي محلي ولا يحتاج مفتاح ذكاء اصطناعي.
