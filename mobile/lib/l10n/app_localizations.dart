import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';

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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
    Locale('hi'),
    Locale('hi', 'IN')
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'FluentSoul: Speak English Fluently & Confidently'**
  String get app_title;

  /// No description provided for @good_morning.
  ///
  /// In en, this message translates to:
  /// **'Good Morning'**
  String get good_morning;

  /// No description provided for @good_afternoon.
  ///
  /// In en, this message translates to:
  /// **'Good Afternoon'**
  String get good_afternoon;

  /// No description provided for @good_evening.
  ///
  /// In en, this message translates to:
  /// **'Good Evening'**
  String get good_evening;

  /// No description provided for @keep_showing_up.
  ///
  /// In en, this message translates to:
  /// **'Keep showing up'**
  String get keep_showing_up;

  /// No description provided for @tab_path.
  ///
  /// In en, this message translates to:
  /// **'Fluency Track'**
  String get tab_path;

  /// No description provided for @tab_practice.
  ///
  /// In en, this message translates to:
  /// **'Arena'**
  String get tab_practice;

  /// No description provided for @tab_challenges.
  ///
  /// In en, this message translates to:
  /// **'Daily Challenges'**
  String get tab_challenges;

  /// No description provided for @step_mode_title.
  ///
  /// In en, this message translates to:
  /// **'Practice Mode'**
  String get step_mode_title;

  /// No description provided for @step_partners_title.
  ///
  /// In en, this message translates to:
  /// **'AI Voice Partners'**
  String get step_partners_title;

  /// No description provided for @step_topic_title.
  ///
  /// In en, this message translates to:
  /// **'Category & Topic'**
  String get step_topic_title;

  /// No description provided for @step_difficulty_title.
  ///
  /// In en, this message translates to:
  /// **'Difficulty Level'**
  String get step_difficulty_title;

  /// No description provided for @mode_gd.
  ///
  /// In en, this message translates to:
  /// **'Group Discussion'**
  String get mode_gd;

  /// No description provided for @mode_gd_desc.
  ///
  /// In en, this message translates to:
  /// **'Practice with 2-4 AI participants in a realistic GD environment'**
  String get mode_gd_desc;

  /// No description provided for @mode_debate.
  ///
  /// In en, this message translates to:
  /// **'1:1 Debate'**
  String get mode_debate;

  /// No description provided for @mode_debate_desc.
  ///
  /// In en, this message translates to:
  /// **'Face a dedicated opponent who challenges your arguments directly'**
  String get mode_debate_desc;

  /// No description provided for @diff_beginner.
  ///
  /// In en, this message translates to:
  /// **'Beginner'**
  String get diff_beginner;

  /// No description provided for @diff_intermediate.
  ///
  /// In en, this message translates to:
  /// **'Intermediate'**
  String get diff_intermediate;

  /// No description provided for @diff_advanced.
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get diff_advanced;

  /// No description provided for @start_discussion.
  ///
  /// In en, this message translates to:
  /// **'Start Session'**
  String get start_discussion;

  /// No description provided for @start_debate.
  ///
  /// In en, this message translates to:
  /// **'Start Session'**
  String get start_debate;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @ai_speaking.
  ///
  /// In en, this message translates to:
  /// **'AI is speaking...'**
  String get ai_speaking;

  /// No description provided for @your_turn.
  ///
  /// In en, this message translates to:
  /// **'Your turn to speak'**
  String get your_turn;

  /// No description provided for @hold_to_speak.
  ///
  /// In en, this message translates to:
  /// **'Hold to Speak'**
  String get hold_to_speak;

  /// No description provided for @end_session.
  ///
  /// In en, this message translates to:
  /// **'End Discussion'**
  String get end_session;

  /// No description provided for @profile_title.
  ///
  /// In en, this message translates to:
  /// **'Profile & Settings'**
  String get profile_title;

  /// No description provided for @app_language.
  ///
  /// In en, this message translates to:
  /// **'App Content Language'**
  String get app_language;

  /// No description provided for @learner_track.
  ///
  /// In en, this message translates to:
  /// **'Learner Track'**
  String get learner_track;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @session_history.
  ///
  /// In en, this message translates to:
  /// **'Session History'**
  String get session_history;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logout;

  /// No description provided for @onboarding_welcome_title.
  ///
  /// In en, this message translates to:
  /// **'Welcome to FluentSoul'**
  String get onboarding_welcome_title;

  /// No description provided for @onboarding_welcome_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Your Personal AI Spoken English Coach'**
  String get onboarding_welcome_subtitle;

  /// No description provided for @onboarding_lang_title.
  ///
  /// In en, this message translates to:
  /// **'App & Practice Language'**
  String get onboarding_lang_title;

  /// No description provided for @onboarding_lang_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Select your preferred practice mode'**
  String get onboarding_lang_subtitle;

  /// No description provided for @onboarding_cefr_title.
  ///
  /// In en, this message translates to:
  /// **'Speaking Assessment'**
  String get onboarding_cefr_title;

  /// No description provided for @onboarding_cefr_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Select your current English speaking level'**
  String get onboarding_cefr_subtitle;

  /// No description provided for @onboarding_goals_title.
  ///
  /// In en, this message translates to:
  /// **'Primary Focus Areas'**
  String get onboarding_goals_title;

  /// No description provided for @onboarding_goals_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Select goals you wish to focus on'**
  String get onboarding_goals_subtitle;

  /// No description provided for @onboarding_time_title.
  ///
  /// In en, this message translates to:
  /// **'Daily Commitment'**
  String get onboarding_time_title;

  /// No description provided for @onboarding_time_subtitle.
  ///
  /// In en, this message translates to:
  /// **'How much time can you commit each day?'**
  String get onboarding_time_subtitle;

  /// No description provided for @onboarding_plan_title.
  ///
  /// In en, this message translates to:
  /// **'Personalized Plan'**
  String get onboarding_plan_title;

  /// No description provided for @onboarding_plan_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Building your customized learning path'**
  String get onboarding_plan_subtitle;

  /// No description provided for @get_started.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get get_started;

  /// No description provided for @error_network_failed.
  ///
  /// In en, this message translates to:
  /// **'Network error occurred.'**
  String get error_network_failed;

  /// No description provided for @auth_login_title.
  ///
  /// In en, this message translates to:
  /// **'Log In to FluentSoul'**
  String get auth_login_title;

  /// No description provided for @auth_register_title.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get auth_register_title;

  /// No description provided for @auth_email_label.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get auth_email_label;

  /// No description provided for @auth_password_label.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get auth_password_label;

  /// No description provided for @auth_name_label.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get auth_name_label;

  /// No description provided for @auth_submit_login.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get auth_submit_login;

  /// No description provided for @auth_submit_register.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get auth_submit_register;

  /// No description provided for @auth_switch_to_register.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? Sign up'**
  String get auth_switch_to_register;

  /// No description provided for @auth_switch_to_login.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Sign in'**
  String get auth_switch_to_login;

  /// No description provided for @history_title.
  ///
  /// In en, this message translates to:
  /// **'Session History'**
  String get history_title;

  /// No description provided for @history_empty.
  ///
  /// In en, this message translates to:
  /// **'No past practice sessions found.'**
  String get history_empty;

  /// No description provided for @report_title.
  ///
  /// In en, this message translates to:
  /// **'Session Report & Feedback'**
  String get report_title;

  /// No description provided for @report_overall_score.
  ///
  /// In en, this message translates to:
  /// **'Overall Performance Score'**
  String get report_overall_score;

  /// No description provided for @report_fluency.
  ///
  /// In en, this message translates to:
  /// **'Fluency'**
  String get report_fluency;

  /// No description provided for @report_vocabulary.
  ///
  /// In en, this message translates to:
  /// **'Vocabulary'**
  String get report_vocabulary;

  /// No description provided for @report_grammar.
  ///
  /// In en, this message translates to:
  /// **'Grammar'**
  String get report_grammar;

  /// No description provided for @report_confidence.
  ///
  /// In en, this message translates to:
  /// **'Confidence'**
  String get report_confidence;

  /// No description provided for @report_best_moments.
  ///
  /// In en, this message translates to:
  /// **'Highlight Quotes & Best Moments'**
  String get report_best_moments;

  /// No description provided for @report_improvements.
  ///
  /// In en, this message translates to:
  /// **'Priority Focus Areas'**
  String get report_improvements;

  /// No description provided for @report_recommendation.
  ///
  /// In en, this message translates to:
  /// **'Coach Recommendation'**
  String get report_recommendation;

  /// No description provided for @category_current_affairs.
  ///
  /// In en, this message translates to:
  /// **'Current Affairs'**
  String get category_current_affairs;

  /// No description provided for @category_abstract.
  ///
  /// In en, this message translates to:
  /// **'Abstract Topics'**
  String get category_abstract;

  /// No description provided for @category_case_based.
  ///
  /// In en, this message translates to:
  /// **'Case Based'**
  String get category_case_based;

  /// No description provided for @category_mba_specific.
  ///
  /// In en, this message translates to:
  /// **'MBA & Business'**
  String get category_mba_specific;

  /// No description provided for @category_ielts_aligned.
  ///
  /// In en, this message translates to:
  /// **'IELTS Aligned'**
  String get category_ielts_aligned;
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
      <String>['en', 'hi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'hi':
      {
        switch (locale.countryCode) {
          case 'IN':
            return AppLocalizationsHiIn();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
