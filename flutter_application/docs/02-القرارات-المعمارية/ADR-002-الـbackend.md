# قرار معماري 002 — تقنية الـ Backend

**الحالة:** معتمد  
**التاريخ:** 2026-09-25

---

## السياق

مشروع حمولة يتطلب Backend مركزياً يخدم تطبيق Flutter الموبايل ولوحة تحكم الإدارة (Admin Dashboard). Backend مسؤول عن منطق الأعمال، إدارة المستخدمين، الطلبات، التوصيل، والتقارير.

---

## الخيارات التي تمت دراستها

- **ASP.NET Core (C#)** — Framework من Microsoft لبناء RESTful APIs عالية الأداء.
- **Node.js / Express** — بيئة JavaScript على الـServer.
- **Django / FastAPI (Python)** — Frameworks بلغة Python.
- **Laravel (PHP)** — Framework PHP شائع.

---

## القرار

**ASP.NET Core** هو الـFramework المعتمد لبناء الـ Backend في مشروع حمولة، مع الاعتماد على:

- **ASP.NET Core** لبناء RESTful API.
- **Entity Framework Core** كـORM للتعامل مع قاعدة البيانات.
- **RESTful API** كبروتوكول التواصل بين الـClients والـServer.

---

## مبدأ أساسي: API-Driven Architecture

```
[Flutter App]  ──────┐
                      ├──► [ASP.NET Core API] ──► [Database]
[Admin Dashboard] ───┘
```

- تطبيق Flutter **لا يتصل بقاعدة البيانات مباشرة**.
- Admin Dashboard **لا يتصل بقاعدة البيانات مباشرة**.
- **الـAPI هو البوابة الوحيدة** لجميع البيانات والعمليات.
- الـAPI هو المسؤول الوحيد عن تطبيق قواعد الأعمال (Business Logic).

---

## السبب

1. **خبرة الفريق** في .NET وC# وASP.NET Core.
2. **أداء مرتفع** — ASP.NET Core من أسرع الـFrameworks في التعامل مع HTTP Requests.
3. **نظام أنواع قوي** — C# مكتوبة بأنواع صارمة تقلل من الأخطاء.
4. **Entity Framework Core** يوفر ORM ناضج يدعم Migrations وCode-First.
5. **توافق ممتاز** مع قواعد البيانات العلائقية (SQL Server / PostgreSQL).
6. **تكامل مباشر** مع Azure وCI/CD pipelines.

---

## الآثار

- جميع الـEndpoints ستتبع نمط RESTful.
- الـAuthentication سيعتمد على JWT Tokens.
- الـAuthorization سيعتمد على نظام Roles (Admin, Trader, Driver, Office).
- Flutter وAdmin Dashboard سيتعاملان مع الـAPI عبر HTTP فقط.
- أي تغيير في Business Logic يتم في الـAPI لا في الـClients.

---

## البدائل المرفوضة

- **Node.js**: أداء جيد لكن JavaScript غير مكتوبة بأنواع صارمة بشكل افتراضي، مما يزيد احتمالية الأخطاء في Runtime.
- **Django/FastAPI**: لغة Python جيدة لكن خبرة الفريق في .NET أعلى.
- **Laravel**: لغة PHP أداؤها أقل في التطبيقات التجارية الكبيرة.

---

## ملاحظات مستقبلية

- عند الحاجة لـReal-time features (مثل تتبع السائق في الخريطة)، يمكن إضافة **SignalR** (مدمج مع ASP.NET Core) دون تغيير الـArchitecture الأساسية.
- قرار GraphQL أو gRPC بديلاً لـREST لم يتم دراسته وهو **غير محسوم** حالياً.
