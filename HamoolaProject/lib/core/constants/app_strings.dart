/// Centralized Arabic strings for the Hamoola application.
/// Organized to facilitate future localization (e.g. English) without refactoring UI.
abstract final class AppStrings {
  // Brand & General
  static const String appName = 'حمولة';
  static const String appTagline = 'منصتك الذكية لربط الشحنات والشاحنات';
  static const String appVersion = 'الإصدار 1.0.0';

  // Navigation & Actions
  static const String skip = 'تخطي';
  static const String next = 'التالي';
  static const String back = 'رجوع';

  // Onboarding Screen 1
  static const String onboarding1Title = 'انقل حمولتك بكل سهولة';
  static const String onboarding1Desc =
      'اطلب نقل حمولتك، وتواصل مع مقدمي الخدمة المناسبين بسهولة وأمان.';

  // Onboarding Screen 2
  static const String onboarding2Title = 'نقل آمن وموثوق';
  static const String onboarding2Desc =
      'تحقق من بيانات الأطراف وتابع عملية النقل بثقة من بداية الطلب حتى التسليم.';

  // Onboarding Screen 3
  static const String onboarding3Title = 'ابدأ رحلتك مع حمولة';
  static const String onboarding3Desc =
      'أنشئ حسابك وابدأ في طلب ونقل حمولاتك بسهولة.';
  static const String startNow = 'ابدأ الآن';

  // Journey Start / Auth Gateway
  static const String journeyStartBadge = 'انطلاق ووصول موثوق';
  static const String journeyStartTitle = 'ابدأ رحلتك مع حمولة';
  static const String journeyStartDesc =
      'أنشئ حسابك وابدأ في طلب ونقل حمولاتك بسهولة وموثوقية.';

  // Login Screen
  static const String login = 'تسجيل الدخول';
  static const String loginWelcome = 'مرحباً بك مجدداً في منصة حمولة';
  static const String phoneNumber = 'رقم الهاتف';
  static const String phoneHint = '770 000 000';
  static const String yemenCountryCode = '+967';
  static const String password = 'كلمة المرور';
  static const String passwordHint = 'أدخل كلمة المرور';
  static const String forgotPassword = 'نسيت كلمة المرور؟';
  static const String biometricLogin = 'تسجيل الدخول بالبصمة';
  static const String offlineLogin = 'دخول بدون نت';
  static const String noAccountPrompt = 'ليس لديك حساب؟';
  static const String createAccount = 'إنشاء حساب';

  // Register Screen & Roles
  static const String register = 'إنشاء حساب جديد';
  static const String registerWelcome = 'انضم إلى مجتمع حمولة للنقل الثقيل';
  static const String selectRole = 'اختر نوع الحساب';
  static const String roleMerchant = 'تاجر';
  static const String roleDriver = 'سائق';
  static const String roleOffice = 'مكتب نقل';
  static const String fullName = 'الاسم الكامل';
  static const String fullNameHint = 'أدخل الاسم كاملاً';
  static const String confirmPassword = 'تأكيد كلمة المرور';
  static const String confirmPasswordHint = 'أعد إدخال كلمة المرور';
  static const String agreeToTerms = 'أوافق على';
  static const String termsAndConditions = 'الشروط والأحكام وسياسة الخصوصية';
  static const String registerSubmit = 'إنشاء الحساب';
  static const String haveAccountPrompt = 'لديك حساب بالفعل؟';

  // Quick Shortcuts & Company Communication Numbers
  static const String tollFree = 'الرقم المجاني';
  static const String companyTollFreeNumber = '800002026';
  static const String companyTollFreeDisplay = '800002026';
  static const String companyWhatsAppNumber = '783707104';
  static const String companyWhatsAppInternational = '967783707104';
  static const String companyWhatsAppDisplay = '+967 783 707 104';
  static const String servicePoints = 'نقاط الخدمة';
  static const String customerSupport = 'خدمة العملاء';

  // Form Validation
  static const String phoneRequiredError = 'يرجى إدخال رقم الهاتف';
  static const String phoneInvalidError = 'يرجى إدخال رقم هاتف يمني صحيح (9 أرقام)';
  static const String passwordRequiredError = 'يرجى إدخال كلمة المرور';
  static const String passwordMinLengthError = 'كلمة المرور يجب ألا تقل عن 6 خانات';
  static const String passwordMismatchError = 'كلمتا المرور غير متطابقتين';
  static const String nameRequiredError = 'يرجى إدخال الاسم الكامل';
  static const String termsRequiredError = 'يرجى الموافقة على الشروط والأحكام للمتابعة';

  // Merchant Module Tokens
  static const String merchantDashboard = 'لوحة تحكم التاجر';
  static const String merchantGreetingPrefix = 'مرحبًا، ';
  static const String merchantDefaultName = 'محمد أحمد';
  static const String merchantDefaultCompany = 'مؤسسة الأمل التجارية';
  static const String merchantWhatToMove = 'ماذا تريد أن تنقل اليوم؟';
  static const String merchantCreateOrderCta = 'إنشاء طلب نقل';
  static const String activeOrders = 'الطلبات النشطة';
  static const String newOffers = 'عروض جديدة';
  static const String pendingAction = 'بانتظار الإجراء';
  static const String needsAttention = 'يحتاج إلى انتباهك';
  static const String recentOrders = 'طلباتك الأخيرة';
  static const String viewAllOrders = 'عرض جميع الطلبات';
  static const String viewDetails = 'عرض التفاصيل';
  static const String reviewOffers = 'مراجعة العروض';
  static const String reviewRequest = 'مراجعة الطلب';
  static const String driverPrefix = 'السائق: ';
  static const String noOrdersTitle = 'لا توجد طلبات سابقة';
  static const String noOrdersDesc = 'لم تقم بإنشاء أي طلبات نقل بعد. أنشئ طلبك الأول لبدء استقبال العروض.';
  static const String createFirstOrder = 'إنشاء أول طلب نقل';
  static const String navHome = 'الرئيسية';
  static const String navOrders = 'طلباتي';
  static const String navCargos = 'حمولاتي';
  static const String navWallet = 'رصيدي';
  static const String navAccount = 'حسابي';
  static const String quickActions = 'إجراءات سريعة';
  static const String profileTitle = 'الملف الشخصي';
  static const String settingsTitle = 'الإعدادات';
  static const String logout = 'تسجيل الخروج';
  static const String verifiedMerchantAccount = 'حساب تاجر معتمد';
  static const String newBadge = 'جديد';

  // Cargo Module Tokens
  static const String myCargos = 'حمولاتي';
  static const String addCargo = 'إضافة حمولة';
  static const String weightLabel = 'الوزن';
  static const String quantityLabel = 'الكمية / الوحدات';
  static const String buildingMaterials = 'مواد بناء';
  static const String foodSupplies = 'مواد غذائية';
  static const String coveringRequired = 'تغطية أثناء النقل';
  static const String normalHandling = 'مناولة عادية';
  static const String perishableVentilation = 'قابلة للتلف (تتطلب تهوية)';
  static const String noCargosTitle = 'لا توجد حمولات بعد';
  static const String noCargosDesc = 'أضف حمولة لحفظ بياناتها واستخدامها عند إنشاء طلب نقل.';

  // Create Cargo Form Tokens
  static const String createCargoTitle = 'إنشاء حمولة';
  static const String cargoInfoSection = 'معلومات الحمولة';
  static const String cargoNameLabel = 'اسم الحمولة';
  static const String cargoNameHint = 'مثال: أجهزة كهربائية';
  static const String cargoNameRequiredError = 'يرجى إدخال اسم الحمولة';
  static const String cargoDescLabel = 'وصف الحمولة';
  static const String cargoDescHint = '200 كرتون أجهزة كهربائية منزلية';
  static const String categoryLabel = 'التصنيف';
  static const String categoryHint = 'اختر تصنيف البضاعة';
  static const String categoryRequiredError = 'يرجى اختيار تصنيف البضاعة';
  static const String weightRequiredError = 'يرجى إدخال وزن صحيح';
  static const String qtyRequiredError = 'يرجى إدخال كمية صحيحة واختيار الوحدة';
  static const String unitHint = 'الوحدة';
  static const String qtyUnitRequiredError = 'الوحدة مطلوبة';
  static const String customUnitLabel = 'اسم الوحدة المخصصة';
  static const String customUnitHint = 'اكتب اسم الوحدة (مثال: برميل، طبلية...)';
  static const String customUnitRequiredError = 'يرجى كتابة اسم الوحدة';
  static const String volumeLabel = 'الحجم التقريبي';
  static const String volumeHint = '0.0';
  static const String volumeUnit = 'م³';
  static const String volumeInvalidError = 'يرجى إدخال قيمة حجم صحيحة أو ترك الحقل فارغاً';
  static const String handlingRequirementsTitle = 'متطلبات المناولة';
  static const String handlingRequirementsSubtitle = 'اختر ما ينطبق على الحمولة';
  static const String handlingCooling = 'تحتاج تبريد';
  static const String handlingFragile = 'قابلة للكسر';
  static const String handlingCovering = 'تحتاج تغطية';
  static const String handlingHazardous = 'مواد خطرة';
  static const String handlingTimeSensitive = 'حساسة للوقت';
  static const String cargoPhotosTitle = 'صور الحمولة';
  static const String cargoPhotosSubtitle = 'يمكنك إضافة عدة صور للحمولة';
  static const String cargoPhotosUploadMain = 'اضغط لرفع صور الحمولة';
  static const String cargoPhotosUploadSub = 'PNG, JPG — رفع عدة صور';
  static const String cargoSamplePhotoPrompt = 'أو اختر صورة نموذجية:';
  static const String cargoSamplePort = 'بضائع الميناء';
  static const String cargoSampleIntercity = 'بضائع تجارية';
  static const String cargoDocsTitle = 'المستندات';
  static const String cargoDocsSubtitle = 'يمكنك إضافة المستندات المرتبطة بالحمولة إن وجدت';
  static const String cargoDocsUploadMain = 'اضغط لرفع وثيقة أو مستند';
  static const String cargoDocsUploadSub = 'PDF, DOC, صور المستندات';
  static const String cargoSampleDocPrompt = 'أو أضف نموذج مستند:';
  static const String cargoSampleWaybill = 'بوليصة شحن.pdf';
  static const String cargoSamplePermit = 'تصريح نقل.pdf';
  static const String saveCargoButton = 'حفظ الحمولة';
  static const String optionalTag = '(اختياري)';

  // Transport Order Creation Tokens
  static const String createOrderTitle = 'طلب نقل جديد';
  static const String createOrderSubtitle = 'أدخل بيانات الطلب للعثور على سائق مناسب';
  static const String orderValidationMissing = 'يرجى استكمال الحقول المطلوبة للمتابعة';
  static const String orderLocationsTitle = 'مواقع النقل';
  static const String originLocationLabel = 'موقع التحميل';
  static const String destLocationLabel = 'موقع التفريغ';
  static const String routeDistanceEstimate = 'المسافة 310 كم';
  static const String routeDurationEstimate = 'حوالي 5 س 20 د';
  static const String requestedCargoTitle = 'الحمولة المطلوبة';
  static const String selectCargoFromMine = 'اختر حمولة من حمولاتي';
  static const String addNewCargoBtn = 'إضافة حمولة جديدة';
  static const String transportRequirementsTitle = 'متطلبات النقل';
  static const String vehicleTypeLabel = 'نوع المركبة المطلوبة';
  static const String loadingDateLabel = 'تاريخ التحميل';
  static const String loadingTimeLabel = 'الوقت المفضل';
  static const String scheduleFlexibilityLabel = 'مرونة الموعد';
  static const String flexExact = 'دقيق';
  static const String flexPlusMinus6 = '±6 ساعات';
  static const String flexPlusMinus12 = '±12 ساعة';
  static const String expectedBudgetTitle = 'الميزانية المتوقعة للنقل';
  static const String budgetMaxLabel = 'الحد الأعلى';
  static const String budgetMinLabel = 'الحد الأدنى';
  static const String yemeniRialUnit = 'ر.ي';
  static const String budgetNegotiable = 'الميزانية قابلة للتفاوض';
  static const String budgetNegotiableHint = 'يمكن للسائق تقديم عرض مختلف';
  static const String publishOrderToTitle = 'نشر الطلب إلى';
  static const String targetAllDrivers = 'جميع السائقين';
  static const String targetSpecificDriver = 'سائق محدد';
  static const String targetAllOffices = 'جميع مكاتب النقل';
  static const String targetSpecificOffice = 'مكتب نقل محدد';
  static const String chooseDriverFromMap = '+ اختيار السائق من الخريطة';
  static const String chooseOfficeBtn = '+ اختيار مكتب النقل';
  static const String changeBtn = 'تغيير';
  static const String additionalInfoTitle = 'معلومات إضافية';
  static const String orderNotesHint = 'ملاحظات على الطلب (اختياري)\nمثال: يجب الالتزام بموعد التحميل ...';
  static const String contactInfoTitle = 'معلومات التواصل';
  static const String preferredContactLabel = 'طريقة التواصل المفضلة';
  static const String contactWhatsapp = 'واتساب';
  static const String contactCall = 'اتصال';
  static const String contactPhoneLabel = 'رقم الجوال';
  static const String submitTransportOrderBtn = 'نشر طلب النقل';

  // Review & Success Sheets
  static const String reviewOrderTitle = 'مراجعة طلب النقل';
  static const String reviewRouteLabel = 'المسار:';
  static const String reviewCargoLabel = 'الحمولة:';
  static const String reviewVehicleLabel = 'المركبة:';
  static const String reviewScheduleLabel = 'الموعد:';
  static const String reviewBudgetLabel = 'الميزانية:';
  static const String reviewPublishToLabel = 'النشر إلى:';
  static const String confirmPublishBtn = 'نشر طلب النقل';
  static const String cancelBtn = 'إلغاء';
  static const String orderPublishedSuccessTitle = 'تم نشر طلب النقل بنجاح!';
  static const String orderNumberTag = 'رقم الطلب:';
  static const String returnHomeBtn = 'العودة للرئيسية';
  static const String viewOffersBtn = 'متابعة العروض الواردة';

  // Select Office Tokens
  static const String selectOfficeTitle = 'اختيار مكتب النقل';
  static const String searchOfficeHint = 'ابحث باسم المكتب أو المدينة...';
  static const String allFilter = 'الكل';
  static const String officeListViewBtn = 'قائمة المكاتب';
  static const String officeMapViewBtn = 'عرض على الخريطة';
  static const String selectOfficeConfirmBtn = 'اختيار المكتب';
  static const String viewOfficeProfileBtn = 'عرض الملف';
  static const String fleetCountLabel = 'شاحنة وأسطول';

  // Driver Profile Tokens
  static const String driverProfileTitle = 'الملف الشخصي للسائق';
  static const String onlineNow = 'متاح الآن';
  static const String driverCompletedTrips = 'الرحلات المكتملة';
  static const String driverCommitmentRate = 'نسبة الالتزام';
  static const String driverExperience = 'سنوات الخبرة';
  static const String driverVehicleLabel = 'مركبة السائق';
  static const String directOrderForDriver = 'طلب مباشر لهذا السائق';
  static const String callDriver = 'اتصال';
  static const String messageDriver = 'مراسلة';

  // Merchant Map Tokens
  static const String merchantMapTitle = 'خريطة السائقين';
  static const String availableDriversCount = '24 سائقاً متاحاً الآن';
  static const String searchDriversHint = 'ابحث عن سائق أو مدينة أو منطقة...';
  static const String categoryTrucks = 'شاحنات';
  static const String categoryTrailers = 'قاطرات';
  static const String categoryDyna = 'دينات';
  static const String categoryReefer = 'تبريد';
  static const String categoryOther = 'أخرى';
  static const String currentLocateTooltip = 'موقعي الحالي';
  static const String scaleLabel = '100 كم';

  // Live Trip Tracking Tokens
  static const String liveTripTrackingTitle = 'متابعة الرحلة الحية';
  static const String tripOngoingBadge = 'رحلة جارية';
  static const String trackingLoadingPoint = 'نقطة التحميل';
  static const String trackingDestPoint = 'نقطة التسليم';
  static const String currentTripStatusLabel = 'الحالة الحالية:';
  static const String simulationControlTitle = 'تحكم المحاكاة للعرض التقديمي';
  static const String simulationStep1 = '1. إلى التحميل';
  static const String simulationStep2 = '2. تم التحميل';
  static const String simulationStep3 = '3. في طريق التسليم';
  static const String simulationStep4 = '4. تم الوصول';
  static const String tripTimelineTitle = 'محطات وخط سير الرحلة';
  static const String cargoSensorTitle = 'مستشعرات الحاوية والمناولة';
  static const String tempNormalStatus = 'سليمة ومطابقة';
  static const String recenterTruckTooltip = 'تمركز على الشاحنة';
  static const String fitRouteTooltip = 'عرض كامل المسار';
  static const String emergencyContactTooltip = 'اتصال طارئ';

  // Merchant Account Hub Tokens
  static const String merchantAccountTitle = 'حسابي';
  static const String merchantVerifiedBadge = 'معتمد';
  static const String completedTripsStatLabel = 'شحنة مكتملة';
  static const String ratingStatLabel = 'التقييم';
  static const String commitmentStatLabel = 'التزام بالدفع';
  static const String financeAndVerifyGroup = 'المالية والتوثيق';
  static const String myWalletMenuTitle = 'محفظتي';
  static const String walletAvailableBalanceSub = 'الرصيد المتاح:';
  static const String companyVerifyMenuTitle = 'بيانات المؤسسة والتوثيق';
  static const String companyVerifyMenuSub = 'الهوية، السجل التجاري، والتراخيص';
  static const String verificationCompleteBadge = 'مكتمل';
  static const String settingsAndHelpGroup = 'الإعدادات والمساعدة';
  static const String generalSettingsMenuTitle = 'الإعدادات العامة';
  static const String generalSettingsMenuSub = 'الإشعارات، اللغة، وتفضيلات الحساب';
  static const String customerSupportMenuTitle = 'الدعم الفني والمساعدة';
  static const String customerSupportMenuSub = 'تواصل مع خدمة عملاء حمولة';
  static const String termsAndPrivacyMenuTitle = 'الشروط وسياسة الاستخدام';
  static const String termsAndPrivacyMenuSub = 'بنود الخدمة وحماية البيانات';
  static const String logoutMenuTitle = 'تسجيل الخروج';
  static const String logoutMenuSub = 'العودة لشاشة تسجيل الدخول';

  // Merchant Wallet Tokens
  static const String merchantWalletTitle = 'محفظتي';
  static const String merchantWalletSub = 'المحفظة الرقمية لرصيد حمولة';
  static const String addBalanceBtn = 'إضافة رصيد';
  static const String currentBalanceLabel = 'الرصيد الحالي';
  static const String currencyYer = 'ريال يمني';
  static const String currencyYerShort = 'ر.ي';
  static const String currencyTagYer = 'YER';
  static const String pendingReviewLabel = 'قيد المراجعة:';
  static const String financialTransactionsSection = 'الحركات المالية';
  static const String txFilterAll = 'الكل';
  static const String txFilterDeposits = 'الإيداعات';
  static const String txFilterPayments = 'المدفوعات';
  static const String noTransactionsFound = 'لا توجد حركات مالية مسجلة في هذا القسم';

  // Add Balance & Payment Method Tokens
  static const String paymentMethodTitle = 'وسيلة الدفع';
  static const String transferredAmountLabel = 'المبلغ المحول';
  static const String amountPlaceholder = '00';
  static const String paymentMethodDropdownLabel = 'وسيلة الدفع';
  static const String subOptionPurchasesTitle = 'دفع مشتريات';
  static const String subOptionPurchasesDescPrefix = 'من دفع مشتريات - رقم النقطة:';
  static const String subOptionCodeTitle = 'عبر كود الشراء';
  static const String subOptionCodeDescSuffix = ' - الشراء أونلاين - كود الشراء';
  static const String pointNumberLabel = 'رقم النقطة:';
  static const String copyPointTooltip = 'نسخ رقم النقطة';
  static const String pointCopiedSuccess = 'تم نسخ رقم النقطة بنجاح';
  static const String trustAssuranceText = 'دفع موثوق إلى حسابات الشركة الرسمية فقط';
  static const String depositRefLabel = 'رقم الإيداع أو الحوالة';
  static const String depositRefHint = 'رقم الإيداع أو الحوالة';
  static const String senderNameLabel = 'اسم المرسل';
  static const String senderNameHint = 'اسم المرسل';
  static const String confirmPaymentBtn = 'تأكيد الدفع';
  static const String depositSuccessTitle = 'تم إرسال طلب الإيداع';
  static const String depositSuccessSubtitle = 'سيتم مراجعة العملية وتحديث رصيد المحفظة فوراً';
  static const String depositSuccessAmountLabel = 'المبلغ:';
  static const String depositSuccessWalletLabel = 'المحفظة:';
  static const String depositSuccessRefLabel = 'رقم المرجع:';
  static const String depositSuccessDateLabel = 'التاريخ:';
  static const String depositSuccessCloseBtn = 'العودة للمحفظة';

  // Home Screenshot UI Tokens
  static const String goodMorningGreeting = 'صباح الخير، مؤسسة الأمل 👋';
  static const String readyToTransportSubtitle = 'جاهز لنقل حمولتك اليوم؟';
  static const String newCargoBadge = 'شحنة جديدة';
  static const String doYouHaveNewCargoTitle = 'هل لديك شحنة جديدة؟';
  static const String createOrderHeroDesc = 'أنشئ طلب نقل وحدد وجهتك وموقعك';
  static const String quickServicesSection = 'الخدمات السريعة';
  static const String createTransportOrderBtn = 'إنشاء طلب نقل';
  static const String myCargosQuick = 'حمولاتي';
  static const String myOffersQuick = 'عروضي';
  static const String trackingQuick = 'التتبع';
  static const String historyQuick = 'السجل';
  static const String activitySummarySection = 'ملخص نشاطك';
  static const String accountNotVerifiedBannerTitle = 'حسابك بانتظار التوثيق';
  static const String accountNotVerifiedBannerSubtitle = 'أكمل توثيق المنشأة لتفعيل كافة خدمات النقل';
  static const String verifyNowBtn = 'توثيق الآن';
  static const String verificationRequiredTitle = 'توثيق الحساب مطلوب';
  static const String verificationRequiredDesc = 'لإنشاء ونشر طلبات النقل والتعامل المالي، يلزم إكمال توثيق الهوية والسجل التجاري لضمان الموثوقية.';
  static const String startVerificationBtn = 'بدء التوثيق الآن';
  static const String laterBtn = 'لاحقاً';

  // OTP Verification Tokens
  static const String otpTitle = 'التحقق من الهاتف';
  static const String otpSubtitle = 'أدخل رمز التحقق المكون من 6 أرقام المرسل إلى:';
  static const String editPhoneBtn = 'تعديل';
  static const String resendCodeIn = 'إعادة إرسال بعد';
  static const String didNotReceiveCode = 'لم تستلم الرمز؟';
  static const String resendCodeBtn = 'إعادة الإرسال';
  static const String verifyButton = 'تأكيد والتحقق';
  static const String otpResentSuccess = 'تم إعادة إرسال رمز التحقق بنجاح';
  static const String otpVerifyTitle = 'التحقق من الهاتف';
  static const String otpHeaderTitle = 'التحقق من رقم الهاتف';
  static const String otpHeaderSubtitle = 'أرسلنا رمز التحقق إلى رقم هاتفك';
  static const String otpVerifyBtn = 'تحقق';
  static const String otpResendBtn = 'إعادة إرسال الرمز';
  static const String otpEditPhoneBtn = 'تعديل رقم الهاتف';
  static const String otpInvalidCodeError = 'يرجى إدخال رمز التحقق المكون من 6 أرقام';

  // Merchant KYC & Verification Tokens
  static const String merchantKycTitle = 'توثيق بيانات المؤسسة والسجل التجاري';
  static const String merchantKycSubtitle = 'أدخل بيانات المنشأة والسجل التجاري لتوثيق الحساب واعتماده رسميًا';
  static const String kycStepPhone = '1. الهاتف (تم)';
  static const String kycStepCompany = '2. بيانات المنشأة';
  static const String kycStepReview = '3. التدقيق والاعتماد';
  static const String companyNameField = 'الاسم التجاري للمنشأة';
  static const String crNumberField = 'رقم السجل التجاري';
  static const String taxNumberField = 'الرقم الضريبي / الترخيص';
  static const String authorizedPersonField = 'اسم المفوض ورقم الهوية';
  static const String crDocTitle = 'صورة السجل التجاري';
  static const String crDocSub = 'ملف PDF أو صورة واضحة للسجل الساري';
  static const String nationalIdDocTitle = 'صورة هوية المفوض';
  static const String nationalIdDocSub = 'بطاقة الهوية الوطنية أو جواز السفر';
  static const String authorizationDocTitle = 'التفويض والختم الرسمي (اختياري)';
  static const String authorizationDocSub = 'خطاب تفويض رسمي مختوم من المنشأة';
  static const String submitKycBtn = 'إرسال طلب التوثيق للتدقيق';
  static const String kycPendingReviewStatus = 'قيد التدقيق والمراجعة';
  static const String kycVerifiedStatus = 'موثق ومعتمد رسميًا ✓';
  static const String kycInstantApproveDemoBtn = 'اعتماد فوري (للعرض التجريبي)';

  // Driver Offers & Review Tokens
  static const String offersReviewTitle = 'عروض السائقين الواردة';
  static const String offersReviewSubtitle = 'قارن عروض الأسعار والتقييمات لاختيار السائق الأنسب لشحنتك';
  static const String routeSanaaAden = 'صنعاء ← عدن (380 كم)';
  static const String cargoFoodstuff = 'مواد غذائية (24 طن)';
  static const String filterAllOffers = 'الكل';
  static const String filterLowestPrice = 'الأقل سعراً';
  static const String filterHighestRating = 'الأعلى تقييماً';
  static const String filterFastestPickup = 'الأسرع وصولاً';
  static const String bestPriceBadge = 'أفضل سعر';
  static const String topRatedBadge = 'الأعلى تقييماً';
  static const String fastestBadge = 'الأسرع';
  static const String acceptOfferBtn = 'قبول العرض والتعاقد';
  static const String negotiateOfferBtn = 'تفاوض';
  static const String counterOfferTitle = 'تقديم عرض سعر مضاد';
  static const String counterOfferDesc = 'أدخل السعر المقترح لإرساله مباشرة إلى السائق:';
  static const String sendCounterOfferBtn = 'إرسال العرض المضاد';
  static const String counterOfferSentSuccess = 'تم إرسال عرض السعر المضاد بنجاح إلى السائق';
  static const String contractConfirmTitle = 'تأكيد التعاقد مع السائق';
  static const String contractConfirmSubtitle = 'سيتم إسناد الطلب وإشعار السائق ببدء التوجه للتحميل وبدء التتبع.';
  static const String confirmAndDispatchBtn = 'تأكيد وبدء التتبع المباشر';

  // Notifications Center Tokens
  static const String notificationsTitle = 'مركز الإشعارات';
  static const String markAllAsReadBtn = 'تحديد الكل كمقروء';
  static const String allNotificationsReadSuccess = 'تم تحديد كافة الإشعارات كمقروءة';
  static const String notifFilterAll = 'الكل';
  static const String notifFilterBids = 'العروض والطلبات';
  static const String notifFilterTracking = 'التتبع والرحلات';
  static const String notifFilterFinance = 'المالية والتوثيق';
  static const String emptyNotificationsTitle = 'لا توجد إشعارات في هذا القسم';
  static const String emptyNotificationsSubtitle = 'ستظهر هنا تحديثات العروض والرحلات والعمليات المالية فور وصولها';
}

