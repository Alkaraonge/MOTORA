# تقرير التحليل التقني لتطبيق Kemet DBC 2.0.1

**نوع الفحص:** تحليل ثابت لملف APK المرفق دون تشغيله على سيارة حقيقية، ودون إجراء اتصالات بالخوادم.  
**هدف التقرير:** بناء خريطة وظائف دقيقة تصلح كأساس لإعادة تنفيذ مستقلة واختبار تكافؤ الوظائف، وليس نسخ شيفرة التطبيق أو آليات ترخيصه الخاصة.

## 1. هوية النسخة التي فُحصت

| الخاصية | النتيجة | مصدر الدليل |
|---|---|---|
| ملف العينة | `KemetDBC_V02.0.1.apk` | الملف المرفق |
| الاسم الظاهر | `Kemet DBC` | AndroidManifest.xml |
| معرف الحزمة | `com.kemet.dlink5` | AndroidManifest.xml |
| الإصدار | `2.0.1` (versionCode 9) | AndroidManifest.xml |
| الحد الأدنى | Android API 26 | AndroidManifest.xml |
| الهدف البرمجي | Android API 29، مع compileSdk 34 | AndroidManifest.xml |
| ملفات DEX | 18 | تعداد ZIP |
| ملفات داخل APK | 1,135 | تعداد ZIP |
| أصناف تتبع الحزمة `com.kemet` | 1,532 تقريبًا | تحليل جداول DEX |
| أسماء دوال مميزة في أصناف الحزمة | 7,323 | تحليل جداول DEX |
| عناصر المانيفست | 7 Activities، 15 Services، 16 Receivers، 3 Providers | AndroidManifest.xml |
| طلبات الصلاحيات | 32 | AndroidManifest.xml |
| SHA-256 | `d9719014854f1b79caf29b7ecacbc4f25d2de719398538f981061772c3e936ae` | بصمة العينة |

> **حدود الثقة:** أسماء الأصناف والدوال تثبت وجود مسارات برمجية بهذه الأسماء، لكنها وحدها لا تثبت نجاحها أو دعمها لكل موديلات السيارات. لم يتم اختبار ربط حي، صلاحيات نظام المصنع، المعايرة، توقيت الاستجابة، أو استقرار الخدمة.

## 2. صورة عامة للبنية

يظهر أن التطبيق أصلي لأندرويد ويستخدم مزيجًا من Views/XML وJetpack Compose، إضافة إلى Kotlin coroutines/StateFlow، مع بنية قريبة من MVVM وHilt dependency injection وRoom لتخزين الرحلات وWorkManager للمهام المجدولة. يوجد تكامل مع ميزات أندرويد ذات الصلاحيات العالية، وShizuku/ADB، وبوابات خاصة بسيارات BYD/DiLink. هذه الاستنتاجات مبنية على أسماء أصناف معروفة وملفات الموارد والتصريح، لا على تنفيذ تجريبي.

**مسار العمل المنطقي المستنتج:**
1. `ActivationActivity` → جمع معرف الجهاز واختيار اللغة ومحاولة التفعيل.
2. `LicenseManager` → تحقق محلي/بعيد حسب دوال `validateKeyOffline` و`checkRemoteLicense`.
3. `MainActivity` → التحقق من الحالة والصلاحيات ثم التنقل بين الشاشات.
4. `MainViewModel` → تجميع حالة السيارة والشبكات والرحلات والطاقة وتوفير إجراءات الواجهة.
5. قنوات بيانات مثل `BydLiveDataSource` و`BydBmsDataSource` و`KemetTelemetryBridgeImpl` → تحديث حالة `EvTelemetryState`.
6. `AppDatabase`/`TripDao` → الاحتفاظ بسجل الرحلات والإحصائيات.
7. خدمات مراقبة/تنبيهات/اتصالات تعمل بحسب الحاجة وامتيازات الجهاز.

## 3. مصفوفة نطاق الوظائف

**درجة الدليل:** «مؤكد بالملفات» = مكوّن أو دالة موجودة، «مستنتج» = وظيفة محتملة من الاسم؛ كلاهما يحتاج اختبار الاستخدام الفعلي.

| رقم | المجال | المكوّنات الظاهرة | الفحص اللازم قبل ادّعاء تطابق الوظيفة |
|---|---|---|---|
| 01 | تفعيل وترخيص | `ActivationActivity`, `LicenseRequestActivity`, `LicenseManager` | أول تشغيل، معرف الجهاز، انقطاع الإنترنت، رسالة الرفض/النجاح، شروط ترخيص مستقل |
| 02 | الواجهة الرئيسية | `MainActivity`, `ControlsFragment`, `ViewPagerAdapter`, `CustomNavAdapter` | كل شريط وقائمة وبطاقة واختصار وطريقة التنقل |
| 03 | التخصيص واللغات | `AppThemeManager`, `ThemeConfig`, `LocaleHelper`, `SettingsManager` | الخطوط والألوان وأوضاع اللغة والحفظ وإعادة التشغيل |
| 04 | بيانات BYD المباشرة | `BydLiveDataSource`, `BydBmsDataSource`, `EvTelemetryState` | الدقة والوحدات والتحديثات والبيانات الناقصة حسب موديل السيارة |
| 05 | البطارية والطاقة | `EnergyFragment`, `EnergyViewModel`, `BatteryDetailActivity`, `RangeCalculator` | SoC وSoH والجهد والحرارة ومجال المدى والسجل |
| 06 | الرحلات | `TripTrackingService`, `AutoTripDetector`, `ManualTripTracker`, `TripLogFragment` | البدء/الإيقاف التلقائي واليدوي والاسترجاع والتكرار والسجلات |
| 07 | الإحصاء والتعرفة | `StatisticsFragment`, `TripCalculator`, `TariffSettingsScreenKt` | الطاقة والكيلومترات والتكاليف والتجميع والتصدير |
| 08 | النوافذ/الأبواب | `DoorsWindowsFragment`, `KemetWindowController`, `CarActionActivity` | الواجهة والمحاكاة أولاً؛ التحقق الرسمي من نوع السيارة ووسيلة الربط |
| 09 | المناخ | `CarActionActivity`, دوال `toggleClimate...`, `cycleClimateFanSpeed` | الحالات، معلومات الواجهة، قيود وضع الوقوف، إمكانيات الطراز |
| 10 | الكاميرات/الرؤية | `CamerasVisionTab`, `AvmCameraProbe`, `CameraStateMonitor` | توفر كاميرات المصنع والواجهات والدقة وعمر الفريم وطرق الإغلاق |
| 11 | مراقبة النقطة العمياء | `BSDSentinelService`, `BlindSpotControllerKemet`, `BlindSpotPreferences` | اختبار محاكاة وقيود السلامة قبل أي استخدام على مركبة |
| 12 | الإضاءة/الصوت | `LightsFragment`, `AmbientLightController`, `AudioVisualizer`, `KemetAudioEngine` | التوافق مع أجهزة السيارة وتغيّر الصوت/الإضاءة ومخارج الصوت |
| 13 | الشبكات والشريحة | `NetworkController`, `ModemHubFragment`, `EsimController`, `HotspotFixHelper` | بيانات SIM/eSIM وAPN والاتصال والتجوال والواي فاي |
| 14 | السحابة في الوقوف | `CloudWifiManager`, `CloudParkedKeeperService`, دوال Cloud في ViewModel | التوفر، استعادة الاتصال، فشل الشبكة، استهلاك الطاقة |
| 15 | الصيانة/حالة النظام | `MaintenanceHubFragment`, `ServiceHubFragment`, `BatteryHealthMonitor` | القياسات، التنبيهات، حدود الصلاحية، سجلات الحالة |
| 16 | إدارة النظام | `AdbEngineHubFragment`, `ShizukuBridge`, `AdbRestoreManager`, `GuardianService` | محاكاة الأذونات والتراجع عن التغييرات؛ لا تُنقل امتيازات من دون تفويض |
| 17 | التعافي والتحديث | `AdbVerifyWorker`, `KemetMonitorService`, دوال OTA/ADAS في ViewModel | التحديثات والأخطاء والاستعادة والنسخ الاحتياطي |
| 18 | الواجهة العائمة | `FloatingWidgetService`, `KemetFloatingService`, `HomeWidgetManager` | الطبقات والشفافية والإغلاق وصلاحيات العرض |
| 19 | تقسيم الشاشة/العدادات | `SplitWorkspaceFragment`, `ClusterProjectionManager` | دعم الشاشات والمقاسات والتوافق مع تطبيقات النظام |
| 20 | إشعارات واختصارات | `KemetNotificationListener`, `BydVehicleEventReceiver`, `BootReceiver` | استمرار الخدمات وإشعاراتها وسلوك إعادة تشغيل الوحدة |
| 21 | الطقس والوقت | `WeatherRuntime`, `BydWeatherInjector`, `EgyptManualDSTCalculator` | صلاحية البيانات، المنطقة الزمنية، جودة الهواء، انعدام الشبكة |
| 22 | أوامر مخصصة وأحداث | `EventAutomationFragment`, `ShellFragment`, `WhitelistFragment` | نطاق الوظائف وشروط التفويض والعزل الأمني |
| 23 | الإعدادات والدعم | `SettingsFragment`, `SupportFragment`, `DiagnosticsActivity` | الإرشادات، سجلات الأخطاء، التحقق من الإعدادات، مراكز المساعدة |

**ملاحظة سلامة:** وظائف النوافذ، المناخ، عرض الكاميرات، واتصال وحدة السيارة يمكن أن تكون حساسة للسلامة. المرحلة الأولى لأي نسخة جديدة تكون **قراءة بيانات/محاكاة**؛ لا يصح تفعيل التحكم الحقيقي على سيارة قبل مراجعة واجهات موثقة، وصلاحيات المالك، واختبار مهني آمن.

## 4. عناصر التحكم الموجودة فعلاً في اسماء الدوال

### بيانات السيارة المقروءة
`BydLiveDataSource`: `queryVoltage12v`, `queryBatteryTemp`, `queryGear`, `queryLeftSignal`, `queryMaxBatteryTemp`, `queryMaxCellVoltage`, `queryMileage`, `queryMinCellVoltage`, `queryMotorTemp`, `queryPower`, `queryRange`, `queryRightSignal`, `querySoH`, `querySoc`, `querySpeed`.

`EvTelemetryState` يحتفظ بحالات `trueSoc`, `batterySoH`, `batteryTemp`, `maxCellV`, `minCellV`, `cellDeltaMv`, `mileage`, `motorTemp`, `powerKw`, `elecRange`, `voltage12v`, `chargingStatus`, `gear`, `aebActive`.

### تقنيات ترتبط بواجهة التحكم
`CarActionActivity` توجد فيه وظائف موجهة للمناخ والنوافذ والطاقة، ويقبل روابط تطبيق داخلية (Deep Links). `KemetWindowController` يذكر كل نافذة من النوافذ الأربع. `MainViewModel` يذكر أيضاً وظائف واجهة المناخ والتنقل وإدارة النافذة.

### دوال خدمات الصيانة والشبكات
`MainViewModel` يتضمن أسماء مثل `refreshOta`, `refreshNetwork`, `refreshTrafficStatus`, `syncHistory`, `refreshDashboardHealth`, `runDeepClean`, `refreshCloudDiagnostics`, `restoreMobileData`, `applyTheme`, `exportTripsAsync`. بعض هذه الوظائف قد تتطلب صلاحيات نظام خاص، وليس مجرد إذن أندرويد عادي.

## 5. نموذج بيانات الرحلة الظاهر

صنف `com.kemet.dlink5.data.Trip` يحتوي حقولاً موثقة من DEX:

- الهوية والوصف: `id`, `label`, `note`, `grade`, `tripMode`, `chargeType`, `isChargingSession`.
- الوقت والمسافة: `startTime`, `endTime`, `durationMin`, `distanceKm`.
- الطاقة: `startSoc`, `endSoc`, `energyKwh`, `efficiency`, `cellDelta`.
- التكلفة: `cost`.

الطبقة التخزينية `TripDao_Impl` تظهر دوال `insert`, `getAll`, `getLast3`, `getStatsSince`, `getAllTimeAvgEfficiency`, `clearAll`, `clearImportedSync` وغيرها. يجب اختبار علاقات الجدول وقواعد التحقق ومعنى كل وحدة قياس قبل استنساخ السلوك.

## 6. الواجهات المستخرجة من الموارد

**الشاشات الرئيسية:** `activity_activation`, `activity_license_request`, `activity_main`, `activity_battery_detail`, `activity_diagnostics`.

**أجزاء الواجهة:** `fragment_cameras_vision`, `fragment_cameras_vision_redesign`, `fragment_car_health`, `fragment_doors_windows`, `fragment_energy`, `fragment_event_automation`, `fragment_lights`, `fragment_maintenance_hub`, `fragment_modem_hub`, `fragment_service_hub`, `fragment_settings`, `fragment_shell`, `fragment_sound_equalizer`, `fragment_split_workspace`, `fragment_statistics`, `fragment_support`, `fragment_trip_log`, `fragment_trip_settings`, `fragment_tweaks`, `fragment_tyres`, `fragment_whitelist`, `fragment_adb_engine_hub`, `page_controls`.

قوائم: `bottom_nav_menu`, `drawer_menu`. توجد بعض الشاشات المصممة بـCompose فلا تتطلب ملف XML منفصلاً. تقرأ شاشة التفعيل من موارد HTML محلية لإرسال طلب ترخيص، لكن النموذج وحده لا يثبت سلوك خادم الترخيص.

## 7. الشبكة والتكاملات

- تظهر عناوين `api.open-meteo.com` و`air-quality-api.open-meteo.com` للطقس/جودة الهواء.
- يظهر نطاق مرتبط بالمشروع `byd.i-mosaics.com` ومسار metadata للتحديثات؛ وجود الرابط في الكود لا يثبت أنه ما زال مستخدماً فعلياً.
- يظهر عنوان محلي `http://localhost:8988/getDiPars` في نصوص DEX، وقد يكون منفذاً لتكامل محلي.
- توجد مؤشرات على خدمات اتصال السحابة، نوع الشريحة، الـVPN، والـAPN.
- إعادة بناء مستقلة تحتاج واجهات خدمة موثقة وخوادم يملكها صاحب المشروع، لا نسخ حسابات أو مفاتيح أو تجاوز تراخيص الأصل.

## 8. الأذونات والمخاطر البرمجية المطلوب تحسينها

- يطلب APK صلاحيات مثل الإنترنت والموقع والصوت والإشعارات وعرض نافذة فوق التطبيقات، بالإضافة إلى صلاحيات مقيّدة بالنظام مثل `WRITE_SECURE_SETTINGS`, `MODIFY_PHONE_STATE`, `REBOOT`, `WRITE_APN_SETTINGS`.
- `android:debuggable="true"` و`android:allowBackup="true"` موجودان في هذه النسخة؛ يُراجعان ويُغلق نمط التصحيح في أي إصدار إنتاجي جديد.
- توجد مكونات `exported=true`، لذا يلزم اختبار من يستطيع إرسال Intent إليها وماذا يمكن أن تنفذ بعد التحقق من الصلاحيات.
- لا يتأكد منح صلاحيات نظام المصنع من manifest وحده؛ يختلف ذلك بحسب توقيع التطبيق ووحدة DiLink وشكل النظام.
- لا ينبغي تخزين أسرار أو معرفات حساسة مباشرة ضمن تطبيق العميل.

## 9. ما الذي يمنع وعد «100% بلا أي خطأ» الآن؟

1. APK لا يحتوي المشروع الأصلي الكامل، سجلات البناء، اختبارات الوحدة، مفاتيح الخدمات، أو قواعد خادم الترخيص.
2. أسماء الدوال والواجهات لا تكشف كل منطق التنفيذ وتفرعات الأخطاء أو توافق نسخ BYD المختلفة.
3. لا توجد بيانات من جهاز سيارة حقيقي أو صور متسلسلة لكل صفحة وحالة تفاعل، وبالتالي لا يمكن تثبيت التطابق البصري أو الوظيفي.
4. شيفرة المصنع وإصدارات DiLink وأذونات النظام والشريحة والكاميرات قد تختلف بين المركبات.
5. نسخ ملفات التطبيق أو هويته أو آلية الترخيص الخاصة ليس الطريق المناسب؛ الحل تنفيذ مستقل مصمم وفق مواصفات وتجارب مصرح بها.

## 10. خطة العمل الموصى بها لبناء تطبيق مماثل وظيفياً

**المرحلة A — تجميد المواصفات:** لكل صفحة: صورة، كل حقل، حالاته، رسائل النجاح والفشل، التوافق مع اللغة، اختصارات التنقل. يُدوّن رقم صفحة فريد ويُربط بأحد بنود المصفوفة أعلاه.

**المرحلة B — تأسيس التطبيق:** مشروع Android Kotlin أصلي، MVVM + StateFlow + Hilt + Room، نظام ثيمات/لغة، تسجيل أخطاء محلي آمن، واجهات DataSource قابلة للاستبدال.

**المرحلة C — نموذج تجريبي آمن:** محاكاة كل قيم التليمترية والرحلات وحالات الشبكة، مع اختبارات تقارن النتيجة بالقيم النموذجية. لا إرسال أوامر إلى وحدات التحكم الحقيقية.

**المرحلة D — تكامل بيانات معتمد:** تحديد موديلات السيارة والشاشات وإصدارات DiLink وتوفير واجهات قراءة موثقة أو مصدر بيانات مرخّص. اختبار التحديث والانقطاع وعدم توافر القيم.

**المرحلة E — صلاحيات/وظائف حساسة:** مراجعة فنية وتخويل رسمي واختبارات متخصصة قبل أي تكامل قد يغير تشغيل السيارة أو واجهات السلامة.

**المرحلة F — اختبارات التطابق والتسليم:** جدول اختبار يضم السيناريو والنتيجة المتوقعة والنتيجة الفعلية والدليل (صورة/سجل) وحالة النجاح، مع APK تجريبي مستقل وملف أخطاء معروف.

### تعريف «الإنجاز»

لا توصف ميزة بأنها «100% مطابقة» إلا عندما تحقق: **مطابقة الواجهة + مطابقة البيانات + الحالات السعيدة وحالات الخطأ + العمل دون شبكة إذا كان متوقعاً + الاسترجاع بعد إعادة التشغيل + التوافق مع جهاز الاختبار + عدم التسبب بسلوك غير آمن**. ويتطلب ذلك توثيق اختبار حقيقي مستقل لكل ميزة. لا يوجد حالياً أساس لادعاء اجتياز هذا المعيار.

## 11. ملحق الأدلة الذي أُنشئ مع هذا التقرير

- `KemetDBC_app_methods.json`: أسماء الأصناف والدوال التي كشفها فهرس DEX.
- `KemetDBC_app_fields.json`: أسماء الحقول وأنواعها التقنية.
- `KemetDBC_manifest_readable.xml`: نسخة مقروءة من AndroidManifest.xml.
- `KemetDBC_app_classes.txt`: قائمة أصناف الحزمة.
- `KemetDBC_key_methods.txt`: عيّنة دوال الفئات المحورية.
- `مصفوفة_وظائف_KemetDBC.csv`: قائمة التدقيق بالميزات وحالة التحقق.

**آخر تحديث:** 30 أكتوبر 2026. **الحالة:** دراسة ثابتة متقدمة — ليست فكاً كاملاً لشيفرة المصدر، ولا نسخة APK مطابقة، ولا اختباراً على سيارة فعلية.