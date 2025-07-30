import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('tr')
  ];

  /// Uygulamanın başlığı
  ///
  /// In tr, this message translates to:
  /// **'Vize Danışmanlık CRM'**
  String get appTitle;

  /// No description provided for @login.
  ///
  /// In tr, this message translates to:
  /// **'Giriş Yap'**
  String get login;

  /// No description provided for @logout.
  ///
  /// In tr, this message translates to:
  /// **'Çıkış Yap'**
  String get logout;

  /// No description provided for @email.
  ///
  /// In tr, this message translates to:
  /// **'E-posta'**
  String get email;

  /// No description provided for @password.
  ///
  /// In tr, this message translates to:
  /// **'Şifre'**
  String get password;

  /// No description provided for @forgotPassword.
  ///
  /// In tr, this message translates to:
  /// **'Şifremi Unuttum'**
  String get forgotPassword;

  /// No description provided for @dashboard.
  ///
  /// In tr, this message translates to:
  /// **'Ana Sayfa'**
  String get dashboard;

  /// No description provided for @customers.
  ///
  /// In tr, this message translates to:
  /// **'Müşteriler'**
  String get customers;

  /// No description provided for @applications.
  ///
  /// In tr, this message translates to:
  /// **'Başvurular'**
  String get applications;

  /// No description provided for @calendar.
  ///
  /// In tr, this message translates to:
  /// **'Takvim'**
  String get calendar;

  /// No description provided for @reports.
  ///
  /// In tr, this message translates to:
  /// **'Raporlar'**
  String get reports;

  /// No description provided for @settings.
  ///
  /// In tr, this message translates to:
  /// **'Ayarlar'**
  String get settings;

  /// No description provided for @notifications.
  ///
  /// In tr, this message translates to:
  /// **'Bildirimler'**
  String get notifications;

  /// No description provided for @profile.
  ///
  /// In tr, this message translates to:
  /// **'Profil'**
  String get profile;

  /// No description provided for @search.
  ///
  /// In tr, this message translates to:
  /// **'Arama'**
  String get search;

  /// No description provided for @help.
  ///
  /// In tr, this message translates to:
  /// **'Yardım'**
  String get help;

  /// No description provided for @support.
  ///
  /// In tr, this message translates to:
  /// **'Destek'**
  String get support;

  /// No description provided for @darkTheme.
  ///
  /// In tr, this message translates to:
  /// **'Karanlık Tema'**
  String get darkTheme;

  /// No description provided for @lightTheme.
  ///
  /// In tr, this message translates to:
  /// **'Açık Tema'**
  String get lightTheme;

  /// No description provided for @language.
  ///
  /// In tr, this message translates to:
  /// **'Dil'**
  String get language;

  /// No description provided for @turkish.
  ///
  /// In tr, this message translates to:
  /// **'Türkçe'**
  String get turkish;

  /// No description provided for @english.
  ///
  /// In tr, this message translates to:
  /// **'İngilizce'**
  String get english;

  /// No description provided for @profileInfo.
  ///
  /// In tr, this message translates to:
  /// **'Profil Bilgileri'**
  String get profileInfo;

  /// No description provided for @profileInfoSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Hesap bilgilerinizi görüntüleyin ve düzenleyin'**
  String get profileInfoSubtitle;

  /// No description provided for @appearanceAndLanguage.
  ///
  /// In tr, this message translates to:
  /// **'Görünüm ve Dil'**
  String get appearanceAndLanguage;

  /// No description provided for @appearanceAndLanguageSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Tema, dil ve görünüm tercihlerinizi ayarlayın'**
  String get appearanceAndLanguageSubtitle;

  /// No description provided for @notificationPreferences.
  ///
  /// In tr, this message translates to:
  /// **'Bildirim Tercihleri'**
  String get notificationPreferences;

  /// No description provided for @notificationPreferencesSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'E-posta ve sistem bildirimlerini yönetin'**
  String get notificationPreferencesSubtitle;

  /// No description provided for @systemAndSupport.
  ///
  /// In tr, this message translates to:
  /// **'Sistem ve Destek'**
  String get systemAndSupport;

  /// No description provided for @systemAndSupportSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Uygulama bilgileri, yardım ve destek'**
  String get systemAndSupportSubtitle;

  /// No description provided for @securityAndAccount.
  ///
  /// In tr, this message translates to:
  /// **'Güvenlik ve Hesap'**
  String get securityAndAccount;

  /// No description provided for @securityAndAccountSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Şifre değiştirme ve hesap yönetimi'**
  String get securityAndAccountSubtitle;

  /// No description provided for @systemNotifications.
  ///
  /// In tr, this message translates to:
  /// **'Sistem Bildirimleri'**
  String get systemNotifications;

  /// No description provided for @systemNotificationsSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Tüm bildirimleri aç/kapat'**
  String get systemNotificationsSubtitle;

  /// No description provided for @emailNotifications.
  ///
  /// In tr, this message translates to:
  /// **'E-posta Bildirimleri'**
  String get emailNotifications;

  /// No description provided for @emailNotificationsSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'E-posta ile bildirim al'**
  String get emailNotificationsSubtitle;

  /// No description provided for @appVersion.
  ///
  /// In tr, this message translates to:
  /// **'Uygulama Sürümü'**
  String get appVersion;

  /// No description provided for @storageUsage.
  ///
  /// In tr, this message translates to:
  /// **'Depolama Kullanımı'**
  String get storageUsage;

  /// No description provided for @helpAndSupport.
  ///
  /// In tr, this message translates to:
  /// **'Yardım ve Destek'**
  String get helpAndSupport;

  /// No description provided for @bugReport.
  ///
  /// In tr, this message translates to:
  /// **'Hata Bildirimi'**
  String get bugReport;

  /// No description provided for @changePassword.
  ///
  /// In tr, this message translates to:
  /// **'Şifre Değiştir'**
  String get changePassword;

  /// No description provided for @save.
  ///
  /// In tr, this message translates to:
  /// **'Kaydet'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In tr, this message translates to:
  /// **'İptal'**
  String get cancel;

  /// No description provided for @ok.
  ///
  /// In tr, this message translates to:
  /// **'Tamam'**
  String get ok;

  /// No description provided for @yes.
  ///
  /// In tr, this message translates to:
  /// **'Evet'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In tr, this message translates to:
  /// **'Hayır'**
  String get no;

  /// No description provided for @close.
  ///
  /// In tr, this message translates to:
  /// **'Kapat'**
  String get close;

  /// No description provided for @edit.
  ///
  /// In tr, this message translates to:
  /// **'Düzenle'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In tr, this message translates to:
  /// **'Sil'**
  String get delete;

  /// No description provided for @add.
  ///
  /// In tr, this message translates to:
  /// **'Ekle'**
  String get add;

  /// No description provided for @update.
  ///
  /// In tr, this message translates to:
  /// **'Güncelle'**
  String get update;

  /// No description provided for @newApplication.
  ///
  /// In tr, this message translates to:
  /// **'Yeni Başvuru'**
  String get newApplication;

  /// No description provided for @appointmentReminder.
  ///
  /// In tr, this message translates to:
  /// **'Randevu Hatırlatması'**
  String get appointmentReminder;

  /// No description provided for @applicationApproved.
  ///
  /// In tr, this message translates to:
  /// **'Başvuru Onaylandı'**
  String get applicationApproved;

  /// No description provided for @systemUpdate.
  ///
  /// In tr, this message translates to:
  /// **'Sistem Güncellemesi'**
  String get systemUpdate;

  /// No description provided for @viewAll.
  ///
  /// In tr, this message translates to:
  /// **'Tümünü Gör'**
  String get viewAll;

  /// No description provided for @markAllAsRead.
  ///
  /// In tr, this message translates to:
  /// **'Tümünü Okundu İşaretle'**
  String get markAllAsRead;

  /// No description provided for @notificationSettings.
  ///
  /// In tr, this message translates to:
  /// **'Bildirim Ayarları'**
  String get notificationSettings;

  /// No description provided for @performanceIndicators.
  ///
  /// In tr, this message translates to:
  /// **'Performans Göstergeleri'**
  String get performanceIndicators;

  /// No description provided for @conversionRate.
  ///
  /// In tr, this message translates to:
  /// **'Dönüşüm Oranı'**
  String get conversionRate;

  /// No description provided for @averageProcessingTime.
  ///
  /// In tr, this message translates to:
  /// **'Ortalama İşlem Süresi'**
  String get averageProcessingTime;

  /// No description provided for @customerSatisfaction.
  ///
  /// In tr, this message translates to:
  /// **'Müşteri Memnuniyeti'**
  String get customerSatisfaction;

  /// No description provided for @monthlyGrowth.
  ///
  /// In tr, this message translates to:
  /// **'Aylık Büyüme'**
  String get monthlyGrowth;

  /// No description provided for @totalCustomers.
  ///
  /// In tr, this message translates to:
  /// **'Toplam Müşteri'**
  String get totalCustomers;

  /// No description provided for @totalApplications.
  ///
  /// In tr, this message translates to:
  /// **'Toplam Başvuru'**
  String get totalApplications;

  /// No description provided for @assignedApplications.
  ///
  /// In tr, this message translates to:
  /// **'Atanan Başvurularım'**
  String get assignedApplications;

  /// No description provided for @applicationStatusDistribution.
  ///
  /// In tr, this message translates to:
  /// **'Başvuru Durumu Dağılımı'**
  String get applicationStatusDistribution;

  /// No description provided for @allRecentApplications.
  ///
  /// In tr, this message translates to:
  /// **'Tüm Son Başvurular'**
  String get allRecentApplications;

  /// No description provided for @assignedRecentApplications.
  ///
  /// In tr, this message translates to:
  /// **'Size Atanan Son Başvurular'**
  String get assignedRecentApplications;

  /// No description provided for @reminders.
  ///
  /// In tr, this message translates to:
  /// **'Hatırlatıcılar'**
  String get reminders;

  /// No description provided for @noReminders.
  ///
  /// In tr, this message translates to:
  /// **'Hatırlatıcı bulunmuyor.'**
  String get noReminders;

  /// No description provided for @quickAccess.
  ///
  /// In tr, this message translates to:
  /// **'Hızlı Erişim'**
  String get quickAccess;

  /// No description provided for @trash.
  ///
  /// In tr, this message translates to:
  /// **'Çöp Kutusu'**
  String get trash;

  /// No description provided for @automation.
  ///
  /// In tr, this message translates to:
  /// **'Otomasyon'**
  String get automation;

  /// No description provided for @taskManagement.
  ///
  /// In tr, this message translates to:
  /// **'Görev Yönetimi'**
  String get taskManagement;

  /// No description provided for @advancedReporting.
  ///
  /// In tr, this message translates to:
  /// **'Gelişmiş Raporlama'**
  String get advancedReporting;

  /// No description provided for @messages.
  ///
  /// In tr, this message translates to:
  /// **'Mesajlar'**
  String get messages;

  /// No description provided for @globalSearch.
  ///
  /// In tr, this message translates to:
  /// **'Global Arama'**
  String get globalSearch;

  /// No description provided for @settingsSaved.
  ///
  /// In tr, this message translates to:
  /// **'Ayarlar kaydedildi!'**
  String get settingsSaved;

  /// No description provided for @settingsError.
  ///
  /// In tr, this message translates to:
  /// **'Ayarlar kaydedilirken hata: {error}'**
  String settingsError(String error);

  /// No description provided for @darkThemeActive.
  ///
  /// In tr, this message translates to:
  /// **'Karanlık tema aktif!'**
  String get darkThemeActive;

  /// No description provided for @lightThemeActive.
  ///
  /// In tr, this message translates to:
  /// **'Açık tema aktif!'**
  String get lightThemeActive;

  /// No description provided for @languageChanged.
  ///
  /// In tr, this message translates to:
  /// **'Dil değiştirildi!'**
  String get languageChanged;

  /// No description provided for @themeColorSelection.
  ///
  /// In tr, this message translates to:
  /// **'Tema rengi seçimi yakında eklenecek!'**
  String get themeColorSelection;

  /// No description provided for @versionInfo.
  ///
  /// In tr, this message translates to:
  /// **'Sürüm Bilgisi'**
  String get versionInfo;

  /// No description provided for @storageInfo.
  ///
  /// In tr, this message translates to:
  /// **'Depolama Bilgisi'**
  String get storageInfo;

  /// No description provided for @helpDialog.
  ///
  /// In tr, this message translates to:
  /// **'Yardım ve Destek'**
  String get helpDialog;

  /// No description provided for @bugReportDialog.
  ///
  /// In tr, this message translates to:
  /// **'Hata Raporu'**
  String get bugReportDialog;

  /// No description provided for @logoutConfirm.
  ///
  /// In tr, this message translates to:
  /// **'Çıkış Yap'**
  String get logoutConfirm;

  /// No description provided for @logoutMessage.
  ///
  /// In tr, this message translates to:
  /// **'Hesaptan çıkış yapmak istediğinizden emin misiniz?'**
  String get logoutMessage;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
