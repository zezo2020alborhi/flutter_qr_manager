# مدير الرموز — Flutter Android

تطبيق Android مبني بـ Flutter لإدارة رموز QR ديناميكية للكتب التعليمية. افتح هذا المجلد كاملًا في Android Studio أو VS Code؛ ملف المشروع هو `pubspec.yaml`، ونقطة بدء التطبيق هي `lib/main.dart`. يستخدم Flutter مجلد `lib` القياسي بدل `src`. يتيح التطبيق إنشاء رمز ثابت الطباعة مع تعديل وجهته لاحقًا، ودعم الروابط والنصوص وPDF والصور والفيديو، وعرض إحصاءات المسح القادمة من ASP.NET Core API.

## التشغيل

يتطلب Flutter SDK وAndroid SDK. من مجلد التطبيق نفّذ:

```bash
flutter pub get
dart run flutter_launcher_icons
flutter test
flutter run
```

لبناء APK موقّع للإصدار، أضف إعداد توقيع Android الخاص بك ثم نفّذ:

```bash
flutter build apk --release
```

## إعداد الاتصال

ابدأ بوضع العرض التجريبي، ثم من شاشة **الإعدادات** أدخل عنوان API المنشور، والنطاق العام الثابت الذي سيظهر داخل رموز QR، ومفتاح الإدارة. يخزن التطبيق مفتاح الإدارة في Android Keystore عبر `flutter_secure_storage`، وليس في ملف إعدادات عادي.

| الإعداد | مثال |
|---|---|
| API | `https://api.yourdomain.com` |
| النطاق العام للرموز | `https://qr.yourdomain.com` |
| مفتاح الإدارة | نفس قيمة `Security__AdminApiKey` في الخادم |

يجب أن يشير النطاق العام إلى خادم ASP.NET Core بحيث يعالج المسار `/q/{publicKey}`. لا تجعل الرمز يشير مباشرة إلى YouTube أو Google Drive؛ هذا سيمنع التعديل وتسجيل المسح.

## Google Drive

بعد نشر API وإعداد OAuth في Google Cloud، أوقف وضع العرض التجريبي، واحفظ الإعدادات، ثم اضغط **ربط Google Drive**. يبدأ الخادم عملية OAuth ويحتفظ برمز التحديث محميًا على الخادم فقط. للتكامل الأمن، استخدم نطاق `drive.file` واستخدم رابط مشاركة ملف Drive عند إنشاء المحتوى. [1]

## بنية المصدر

| المجلد | الغرض |
|---|---|
| `lib/screens` | واجهات التطبيق وتدفقات إنشاء وتعديل QR |
| `lib/controllers` | حالة التطبيق وربط إعدادات API |
| `lib/services` | عميل HTTP ونسخة العرض التجريبي |
| `lib/models` | نماذج QR والمحتوى والإحصاءات والمسح |
| `android` | إعدادات Android وملف Manifest |

### المراجع

[1] [Google Drive API — Choose Google Drive API scopes](https://developers.google.com/workspace/drive/api/guides/api-specific-auth)
