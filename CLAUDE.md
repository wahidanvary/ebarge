# پروژه فلاتر (Flutter Android Project)

## 🏗️ معماری و الگوی طراحی
- **معماری:** MVC (Model-View-Controller)
- **مدیریت وضعیت (State Management):** Provider
- **پلتفرم هدف:** Android (Google Play & Cafe Bazaar)

## 📁 ساختار پوشه‌ها (Folder Structure)
- `lib/models/`: مدل‌های داده (Data Models)
- `lib/screens/`: صفحات اصلی برنامه (Views)
- `lib/widgets/`: ویجت‌های قابل استفاده مجدد (Reusable UI Components)
- `lib/providers/`: کلاس‌های کنترل‌کننده و مدیریت وضعیت (Controllers / Logic)
- `lib/services/`: ارتباط با APIها یا سرویس‌های جانبی
- `lib/database/`: مدیریت دیتابیس محلی
- `lib/utils/`: توابع کمکی و کاربردی
- `lib/azbazi/`: ماژول‌ها یا بخش‌های خاص پروژه
- فایل‌های ثابت: `const.dart`, `icons.dart`, `styles.dart`, `main.dart`

## 🛠️ قوانین کدنویسی (Guidelines)
- تمام تغییرات باید با معماری MVC و الگوی Provider هماهنگ باشند.
- کدهای مربوط به UI در `screens` و `widgets` باقی بمانند و منطق برنامه در `providers` قرار گیرد.
- ترجیحاً از ویجت‌های `const` برای بهینه‌سازی عملکرد استفاده شود.
- تغییرات به‌صورت گام‌به‌گام و بدون شکستن کدهای قبلی انجام شود.