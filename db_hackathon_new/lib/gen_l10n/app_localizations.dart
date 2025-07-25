import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_mr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen_l10n/app_localizations.dart';
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
    Locale('mr')
  ];

  /// No description provided for @welcomeMessage.
  ///
  /// In en, this message translates to:
  /// **'Welcome to SchemeFinder'**
  String get welcomeMessage;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @locationPrompt.
  ///
  /// In en, this message translates to:
  /// **'Please allow location access to get personalized schemes.'**
  String get locationPrompt;

  /// No description provided for @secureTrusted.
  ///
  /// In en, this message translates to:
  /// **'Secure & Trusted'**
  String get secureTrusted;

  /// No description provided for @aiPowered.
  ///
  /// In en, this message translates to:
  /// **'AI Powered'**
  String get aiPowered;

  /// No description provided for @locationBased.
  ///
  /// In en, this message translates to:
  /// **'Location Based'**
  String get locationBased;

  /// No description provided for @locationBasedDescription.
  ///
  /// In en, this message translates to:
  /// **'Get personalized schemes based on your location and preferred language.'**
  String get locationBasedDescription;

  /// No description provided for @expertSupport.
  ///
  /// In en, this message translates to:
  /// **'Expert Support'**
  String get expertSupport;

  /// No description provided for @expertSupportDescription.
  ///
  /// In en, this message translates to:
  /// **'Chat or call local agents for personalized assistance.'**
  String get expertSupportDescription;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip and Continue'**
  String get skip;

  /// No description provided for @allowLocation.
  ///
  /// In en, this message translates to:
  /// **'Allow Location Access'**
  String get allowLocation;

  /// No description provided for @chooseLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose your preferred language'**
  String get chooseLanguage;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @hindi.
  ///
  /// In en, this message translates to:
  /// **'Hindi'**
  String get hindi;

  /// No description provided for @marathi.
  ///
  /// In en, this message translates to:
  /// **'Marathi'**
  String get marathi;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don’t have an account? Register'**
  String get dontHaveAccount;

  /// No description provided for @createProfile.
  ///
  /// In en, this message translates to:
  /// **'Create Profile'**
  String get createProfile;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @annualIncome.
  ///
  /// In en, this message translates to:
  /// **'Annual Income'**
  String get annualIncome;

  /// No description provided for @savings.
  ///
  /// In en, this message translates to:
  /// **'Savings'**
  String get savings;

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @male.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get male;

  /// No description provided for @female.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get female;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @general.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get general;

  /// No description provided for @obc.
  ///
  /// In en, this message translates to:
  /// **'OBC'**
  String get obc;

  /// No description provided for @sc.
  ///
  /// In en, this message translates to:
  /// **'SC'**
  String get sc;

  /// No description provided for @st.
  ///
  /// In en, this message translates to:
  /// **'ST'**
  String get st;

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

  /// No description provided for @finish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get finish;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @homeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get homeTitle;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// No description provided for @user.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get user;

  /// No description provided for @recommendedSchemes.
  ///
  /// In en, this message translates to:
  /// **'Here are your recommended schemes:'**
  String get recommendedSchemes;

  /// No description provided for @noSchemesFound.
  ///
  /// In en, this message translates to:
  /// **'No recommendations found or check your profile data.'**
  String get noSchemesFound;

  /// No description provided for @goal.
  ///
  /// In en, this message translates to:
  /// **'Goal'**
  String get goal;

  /// No description provided for @benefits.
  ///
  /// In en, this message translates to:
  /// **'Benefits'**
  String get benefits;

  /// No description provided for @returns.
  ///
  /// In en, this message translates to:
  /// **'Return'**
  String get returns;

  /// No description provided for @duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// No description provided for @website.
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get website;

  /// No description provided for @score.
  ///
  /// In en, this message translates to:
  /// **'Score'**
  String get score;

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'SchemeFinder'**
  String get appTitle;

  /// No description provided for @appSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Find the best schemes for you'**
  String get appSubtitle;

  /// No description provided for @loginSuccess.
  ///
  /// In en, this message translates to:
  /// **'Login successful!'**
  String get loginSuccess;

  /// No description provided for @loginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login failed'**
  String get loginFailed;

  /// No description provided for @nameRequired.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get nameRequired;

  /// No description provided for @emailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get emailRequired;

  /// No description provided for @passwordLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordLength;

  /// No description provided for @chatbot.
  ///
  /// In en, this message translates to:
  /// **'Continue as Guest'**
  String get chatbot;

  /// No description provided for @yourFinances.
  ///
  /// In en, this message translates to:
  /// **'Your Finances'**
  String get yourFinances;

  /// No description provided for @aboutYou.
  ///
  /// In en, this message translates to:
  /// **'About You'**
  String get aboutYou;

  /// No description provided for @incomeGroup1Lakh.
  ///
  /// In en, this message translates to:
  /// **'<1 Lakh'**
  String get incomeGroup1Lakh;

  /// No description provided for @incomeGroup1to2Lakh.
  ///
  /// In en, this message translates to:
  /// **'1-2 Lakh'**
  String get incomeGroup1to2Lakh;

  /// No description provided for @incomeGroup2to5Lakh.
  ///
  /// In en, this message translates to:
  /// **'2-5 Lakh'**
  String get incomeGroup2to5Lakh;

  /// No description provided for @incomeGroup5to10Lakh.
  ///
  /// In en, this message translates to:
  /// **'5-10 Lakh'**
  String get incomeGroup5to10Lakh;

  /// No description provided for @incomeGroup10PlusLakh.
  ///
  /// In en, this message translates to:
  /// **'10+ Lakh'**
  String get incomeGroup10PlusLakh;

  /// No description provided for @urban.
  ///
  /// In en, this message translates to:
  /// **'Urban'**
  String get urban;

  /// No description provided for @defaultSituation.
  ///
  /// In en, this message translates to:
  /// **'Looking for investment schemes'**
  String get defaultSituation;

  /// No description provided for @profileCreationTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Your Profile'**
  String get profileCreationTitle;

  /// No description provided for @welcomeSchemes.
  ///
  /// In en, this message translates to:
  /// **'Welcome! Here are the schemes you are eligible for.'**
  String get welcomeSchemes;

  /// No description provided for @typeGoalOrNeed.
  ///
  /// In en, this message translates to:
  /// **'Type your goal or need (optional)'**
  String get typeGoalOrNeed;

  /// No description provided for @find.
  ///
  /// In en, this message translates to:
  /// **'Find'**
  String get find;

  /// No description provided for @noRecommendations.
  ///
  /// In en, this message translates to:
  /// **'No eligible recommendations found.'**
  String get noRecommendations;

  /// No description provided for @matchScore.
  ///
  /// In en, this message translates to:
  /// **'Match Score'**
  String get matchScore;

  /// No description provided for @trackerComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Tracker page coming soon!'**
  String get trackerComingSoon;

  /// No description provided for @profileComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Profile page coming soon!'**
  String get profileComingSoon;

  /// No description provided for @microLoansComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Micro Loans page coming soon!'**
  String get microLoansComingSoon;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @tracker.
  ///
  /// In en, this message translates to:
  /// **'Tracker'**
  String get tracker;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @microLoans.
  ///
  /// In en, this message translates to:
  /// **'Micro Loans'**
  String get microLoans;

  /// No description provided for @welcomeUser.
  ///
  /// In en, this message translates to:
  /// **'Welcome, {user}!'**
  String welcomeUser(Object user);

  /// No description provided for @searchGoalOrNeed.
  ///
  /// In en, this message translates to:
  /// **'Search your goal or need'**
  String get searchGoalOrNeed;

  /// No description provided for @risk.
  ///
  /// In en, this message translates to:
  /// **'Risk'**
  String get risk;

  /// No description provided for @term.
  ///
  /// In en, this message translates to:
  /// **'Term'**
  String get term;

  /// No description provided for @supportComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Support page coming soon!'**
  String get supportComingSoon;

  /// No description provided for @community.
  ///
  /// In en, this message translates to:
  /// **'Community'**
  String get community;

  /// No description provided for @support.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get support;

  /// No description provided for @supportHub.
  ///
  /// In en, this message translates to:
  /// **'Support Hub'**
  String get supportHub;

  /// No description provided for @supportHubWelcome.
  ///
  /// In en, this message translates to:
  /// **'Support Hub. Connect with local agents and get help with your financial schemes.'**
  String get supportHubWelcome;

  /// No description provided for @howCanWeHelp.
  ///
  /// In en, this message translates to:
  /// **'How can we help you today?'**
  String get howCanWeHelp;

  /// No description provided for @searchKnowledgeBase.
  ///
  /// In en, this message translates to:
  /// **'Search our knowledge base or connect with an expert'**
  String get searchKnowledgeBase;

  /// No description provided for @searchHelpTopics.
  ///
  /// In en, this message translates to:
  /// **'Search articles, FAQs, and help topics...'**
  String get searchHelpTopics;

  /// No description provided for @searchCleared.
  ///
  /// In en, this message translates to:
  /// **'Search cleared'**
  String get searchCleared;

  /// No description provided for @connectWithLocalAgents.
  ///
  /// In en, this message translates to:
  /// **'Connect with Local Agents'**
  String get connectWithLocalAgents;

  /// No description provided for @findExpertHelp.
  ///
  /// In en, this message translates to:
  /// **'Find expert help in your area'**
  String get findExpertHelp;

  /// No description provided for @agentInfo.
  ///
  /// In en, this message translates to:
  /// **'Agent: {name}, Region: {region}'**
  String agentInfo(String name, String region);

  /// No description provided for @regionNotSpecified.
  ///
  /// In en, this message translates to:
  /// **'Not specified'**
  String get regionNotSpecified;

  /// No description provided for @calling.
  ///
  /// In en, this message translates to:
  /// **'Calling {phone}'**
  String calling(String phone);

  /// No description provided for @openingEmail.
  ///
  /// In en, this message translates to:
  /// **'Opening email to {email}'**
  String openingEmail(String email);

  /// No description provided for @call.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get call;

  /// No description provided for @message.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get message;

  /// No description provided for @bankCustomerCare.
  ///
  /// In en, this message translates to:
  /// **'Bank Customer Care'**
  String get bankCustomerCare;

  /// No description provided for @bankCustomerCareDescription.
  ///
  /// In en, this message translates to:
  /// **'24/7 support for all your banking needs'**
  String get bankCustomerCareDescription;

  /// No description provided for @primaryCustomerCare.
  ///
  /// In en, this message translates to:
  /// **'Primary Customer Care'**
  String get primaryCustomerCare;

  /// No description provided for @primaryCustomerCareSubtitle.
  ///
  /// In en, this message translates to:
  /// **'24/7 Available • General Support'**
  String get primaryCustomerCareSubtitle;

  /// No description provided for @technicalSupport.
  ///
  /// In en, this message translates to:
  /// **'Technical Support'**
  String get technicalSupport;

  /// No description provided for @technicalSupportSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Mon-Fri, 8AM - 6PM • Technical Issues'**
  String get technicalSupportSubtitle;

  /// No description provided for @callNow.
  ///
  /// In en, this message translates to:
  /// **'Call Now'**
  String get callNow;

  /// No description provided for @helpTooltip.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get helpTooltip;

  /// No description provided for @getHelpSupport.
  ///
  /// In en, this message translates to:
  /// **'Get help and support for your financial schemes and questions'**
  String get getHelpSupport;

  /// No description provided for @myProfile.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get myProfile;

  /// No description provided for @profilePageTts.
  ///
  /// In en, this message translates to:
  /// **'My Profile page. View your personal information, financial summary, and active schemes.'**
  String get profilePageTts;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @loggingOut.
  ///
  /// In en, this message translates to:
  /// **'Logging out'**
  String get loggingOut;

  /// No description provided for @contactInfo.
  ///
  /// In en, this message translates to:
  /// **'Contact Information'**
  String get contactInfo;

  /// No description provided for @noEmail.
  ///
  /// In en, this message translates to:
  /// **'No email'**
  String get noEmail;

  /// No description provided for @noPhone.
  ///
  /// In en, this message translates to:
  /// **'No phone'**
  String get noPhone;

  /// No description provided for @noLocation.
  ///
  /// In en, this message translates to:
  /// **'No location'**
  String get noLocation;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @financialSummary.
  ///
  /// In en, this message translates to:
  /// **'Financial Summary'**
  String get financialSummary;

  /// No description provided for @totalSavings.
  ///
  /// In en, this message translates to:
  /// **'Total Savings'**
  String get totalSavings;

  /// No description provided for @activeSchemes.
  ///
  /// In en, this message translates to:
  /// **'Active Schemes'**
  String get activeSchemes;

  /// No description provided for @investmentReturns.
  ///
  /// In en, this message translates to:
  /// **'Investment Returns'**
  String get investmentReturns;

  /// No description provided for @goalsAchieved.
  ///
  /// In en, this message translates to:
  /// **'Goals Achieved'**
  String get goalsAchieved;

  /// No description provided for @rupees.
  ///
  /// In en, this message translates to:
  /// **'rupees'**
  String get rupees;

  /// No description provided for @savingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'+1.2% this month'**
  String get savingsSubtitle;

  /// No description provided for @activeSchemesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Joined {count, plural, =0{none} other{1 new}}'**
  String activeSchemesSubtitle(num count);

  /// No description provided for @returnsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'+5% last quarter'**
  String get returnsSubtitle;

  /// No description provided for @goalsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'On track for 3 more'**
  String get goalsSubtitle;

  /// No description provided for @recentActivities.
  ///
  /// In en, this message translates to:
  /// **'Recent Activities & Tips'**
  String get recentActivities;

  /// No description provided for @recentActivitiesTts.
  ///
  /// In en, this message translates to:
  /// **'Recent Activities and Tips section'**
  String get recentActivitiesTts;

  /// No description provided for @noSchemes.
  ///
  /// In en, this message translates to:
  /// **'No schemes registered yet.'**
  String get noSchemes;

  /// No description provided for @noSchemesTts.
  ///
  /// In en, this message translates to:
  /// **'No schemes registered yet. You can explore new schemes from the home page.'**
  String get noSchemesTts;

  /// No description provided for @unnamedScheme.
  ///
  /// In en, this message translates to:
  /// **'Unnamed Scheme'**
  String get unnamedScheme;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @registeredOn.
  ///
  /// In en, this message translates to:
  /// **'Registered on'**
  String get registeredOn;

  /// No description provided for @nextDueDate.
  ///
  /// In en, this message translates to:
  /// **'Next Due Date'**
  String get nextDueDate;

  /// No description provided for @scheme.
  ///
  /// In en, this message translates to:
  /// **'Scheme'**
  String get scheme;

  /// No description provided for @arthSamarth.
  ///
  /// In en, this message translates to:
  /// **'ArthSamarth'**
  String get arthSamarth;

  /// No description provided for @financeInclude.
  ///
  /// In en, this message translates to:
  /// **'ArthSamarth'**
  String get financeInclude;

  /// No description provided for @pathToFinancialSuccess.
  ///
  /// In en, this message translates to:
  /// **'Your Path to Financial Success'**
  String get pathToFinancialSuccess;

  /// No description provided for @financialToolsDescription.
  ///
  /// In en, this message translates to:
  /// **'Simple, visual tools to help you manage money and access financial services'**
  String get financialToolsDescription;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already Have Account'**
  String get alreadyHaveAccount;

  /// No description provided for @voiceAssistant.
  ///
  /// In en, this message translates to:
  /// **'Voice Assistant'**
  String get voiceAssistant;

  /// No description provided for @voiceAssistantDescription.
  ///
  /// In en, this message translates to:
  /// **'Get personalized recommendations to improve your financial situation'**
  String get voiceAssistantDescription;

  /// No description provided for @unsureWhatYouNeed.
  ///
  /// In en, this message translates to:
  /// **'Unsure of what you need?'**
  String get unsureWhatYouNeed;

  /// No description provided for @browseSchemes.
  ///
  /// In en, this message translates to:
  /// **'Browse through our schemes'**
  String get browseSchemes;

  /// No description provided for @continueAsGuest.
  ///
  /// In en, this message translates to:
  /// **'Continue as Guest'**
  String get continueAsGuest;

  /// No description provided for @welcomeToSchemeRecommender.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Scheme Recommender! Your AI-powered financial companion for discovering government schemes.'**
  String get welcomeToSchemeRecommender;

  /// No description provided for @loginToArthSamarth.
  ///
  /// In en, this message translates to:
  /// **'Login to ArthSamarth'**
  String get loginToArthSamarth;

  /// No description provided for @loginToFinWise.
  ///
  /// In en, this message translates to:
  /// **'Login to ArthSamarth'**
  String get loginToFinWise;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back!'**
  String get welcomeBack;

  /// No description provided for @loginDescription.
  ///
  /// In en, this message translates to:
  /// **'Discover your personalized financial recommendations and track your progress'**
  String get loginDescription;

  /// No description provided for @emailOrUsername.
  ///
  /// In en, this message translates to:
  /// **'Email or Username'**
  String get emailOrUsername;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @logInSecurely.
  ///
  /// In en, this message translates to:
  /// **'Log in Securely'**
  String get logInSecurely;

  /// No description provided for @continueWithChatbot.
  ///
  /// In en, this message translates to:
  /// **'Continue with Chatbot'**
  String get continueWithChatbot;

  /// No description provided for @continueAsAgent.
  ///
  /// In en, this message translates to:
  /// **'Continue as Agent'**
  String get continueAsAgent;

  /// No description provided for @registerAsAgent.
  ///
  /// In en, this message translates to:
  /// **'Register as Agent'**
  String get registerAsAgent;

  /// No description provided for @dontHaveAccountRegister.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAccountRegister;

  /// No description provided for @registerAsNewUser.
  ///
  /// In en, this message translates to:
  /// **'Register as a New User'**
  String get registerAsNewUser;

  /// No description provided for @loggingIn.
  ///
  /// In en, this message translates to:
  /// **'Logging in'**
  String get loggingIn;

  /// No description provided for @loginSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Login successful! Redirecting to home screen.'**
  String get loginSuccessMessage;

  /// No description provided for @loginFailedMessage.
  ///
  /// In en, this message translates to:
  /// **'Login failed. Please check your credentials and try again.'**
  String get loginFailedMessage;

  /// No description provided for @welcomeLoginMessage.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Scheme Recommender Login. Enter your credentials to access your account, or explore other options like chatbot or agent services.'**
  String get welcomeLoginMessage;

  /// No description provided for @emailFieldEmpty.
  ///
  /// In en, this message translates to:
  /// **'Email field is empty'**
  String get emailFieldEmpty;

  /// No description provided for @passwordFieldEmpty.
  ///
  /// In en, this message translates to:
  /// **'Password field is empty'**
  String get passwordFieldEmpty;

  /// No description provided for @passwordEntered.
  ///
  /// In en, this message translates to:
  /// **'Password entered'**
  String get passwordEntered;

  /// No description provided for @loginButtonDescription.
  ///
  /// In en, this message translates to:
  /// **'Login button. Tap to sign in to your account.'**
  String get loginButtonDescription;

  /// No description provided for @openingChatbot.
  ///
  /// In en, this message translates to:
  /// **'Opening chatbot'**
  String get openingChatbot;

  /// No description provided for @openingAgentLogin.
  ///
  /// In en, this message translates to:
  /// **'Opening agent login'**
  String get openingAgentLogin;

  /// No description provided for @openingAgentRegistration.
  ///
  /// In en, this message translates to:
  /// **'Opening agent registration'**
  String get openingAgentRegistration;

  /// No description provided for @createNewProfile.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? Create profile'**
  String get createNewProfile;

  /// No description provided for @createNewProfileDescription.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? Create a new profile to get started.'**
  String get createNewProfileDescription;

  /// No description provided for @or.
  ///
  /// In en, this message translates to:
  /// **'OR'**
  String get or;

  /// No description provided for @createArthSamarthAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Your ArthSamarth Account'**
  String get createArthSamarthAccount;

  /// No description provided for @createFinWiseAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Your ArthSamarth Account'**
  String get createFinWiseAccount;

  /// No description provided for @personalInfo.
  ///
  /// In en, this message translates to:
  /// **'Personal\nInfo'**
  String get personalInfo;

  /// No description provided for @financialOccupational.
  ///
  /// In en, this message translates to:
  /// **'Financial &\nOccupational'**
  String get financialOccupational;

  /// No description provided for @demographicsBank.
  ///
  /// In en, this message translates to:
  /// **'Demographics\n& Bank'**
  String get demographicsBank;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailAddress;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @enterFullName.
  ///
  /// In en, this message translates to:
  /// **'Enter your full name'**
  String get enterFullName;

  /// No description provided for @enterEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get enterEmail;

  /// No description provided for @createPassword.
  ///
  /// In en, this message translates to:
  /// **'Create a password'**
  String get createPassword;

  /// No description provided for @reenterPassword.
  ///
  /// In en, this message translates to:
  /// **'Re-enter your password'**
  String get reenterPassword;

  /// No description provided for @doBankAccount.
  ///
  /// In en, this message translates to:
  /// **'Do you have a bank account?'**
  String get doBankAccount;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @bankAccountRequired.
  ///
  /// In en, this message translates to:
  /// **'You need a bank account to access most schemes. We\'ll help you connect with support.'**
  String get bankAccountRequired;

  /// No description provided for @welcomeProfileCreation.
  ///
  /// In en, this message translates to:
  /// **'Welcome to profile creation. Let\'s set up your account in 3 simple steps.'**
  String get welcomeProfileCreation;

  /// No description provided for @step1Description.
  ///
  /// In en, this message translates to:
  /// **'Step 1 of 3: Account Setup. Please enter your name, email, and password.'**
  String get step1Description;

  /// No description provided for @step2Description.
  ///
  /// In en, this message translates to:
  /// **'Step 2 of 3: Financial Information. Please enter your annual income and current savings.'**
  String get step2Description;

  /// No description provided for @step3Description.
  ///
  /// In en, this message translates to:
  /// **'Step 3 of 3: Personal Details. Please select your gender and category.'**
  String get step3Description;

  /// No description provided for @goingBackStep.
  ///
  /// In en, this message translates to:
  /// **'Going back to previous step'**
  String get goingBackStep;

  /// No description provided for @movingNextStep.
  ///
  /// In en, this message translates to:
  /// **'Moving to next step'**
  String get movingNextStep;

  /// No description provided for @creatingAccount.
  ///
  /// In en, this message translates to:
  /// **'Creating your account'**
  String get creatingAccount;

  /// No description provided for @selectBankAccount.
  ///
  /// In en, this message translates to:
  /// **'Please select if you have a bank account.'**
  String get selectBankAccount;

  /// No description provided for @creatingAccountWait.
  ///
  /// In en, this message translates to:
  /// **'Creating your account, please wait...'**
  String get creatingAccountWait;

  /// No description provided for @accountCreatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Account created successfully! Welcome to Scheme Recommender!'**
  String get accountCreatedSuccess;

  /// No description provided for @accountCreationFailed.
  ///
  /// In en, this message translates to:
  /// **'Account creation failed. Please try again.'**
  String get accountCreationFailed;

  /// No description provided for @pleaseSpeakField.
  ///
  /// In en, this message translates to:
  /// **'Please speak your'**
  String get pleaseSpeakField;

  /// No description provided for @youSaid.
  ///
  /// In en, this message translates to:
  /// **'You said:'**
  String get youSaid;

  /// No description provided for @voiceInputFailed.
  ///
  /// In en, this message translates to:
  /// **'Voice input failed. Please type manually.'**
  String get voiceInputFailed;

  /// No description provided for @currentGenderIs.
  ///
  /// In en, this message translates to:
  /// **'Current gender is'**
  String get currentGenderIs;

  /// No description provided for @availableOptions.
  ///
  /// In en, this message translates to:
  /// **'Available options are:'**
  String get availableOptions;

  /// No description provided for @currentCategoryIs.
  ///
  /// In en, this message translates to:
  /// **'Current category is'**
  String get currentCategoryIs;

  /// No description provided for @profileCreation.
  ///
  /// In en, this message translates to:
  /// **'Profile Creation'**
  String get profileCreation;

  /// No description provided for @fullNameVoice.
  ///
  /// In en, this message translates to:
  /// **'full name'**
  String get fullNameVoice;

  /// No description provided for @emailAddressVoice.
  ///
  /// In en, this message translates to:
  /// **'email address'**
  String get emailAddressVoice;

  /// No description provided for @annualIncomeVoice.
  ///
  /// In en, this message translates to:
  /// **'annual income'**
  String get annualIncomeVoice;

  /// No description provided for @savingsVoice.
  ///
  /// In en, this message translates to:
  /// **'current savings'**
  String get savingsVoice;

  /// No description provided for @needBankAccountSupport.
  ///
  /// In en, this message translates to:
  /// **'You need a bank account to access most schemes. We\'ll help you connect with support.'**
  String get needBankAccountSupport;

  /// No description provided for @goingBack.
  ///
  /// In en, this message translates to:
  /// **'Going back to previous step'**
  String get goingBack;

  /// No description provided for @searchingForSchemes.
  ///
  /// In en, this message translates to:
  /// **'Searching for schemes related to: {goal}'**
  String searchingForSchemes(Object goal);

  /// No description provided for @loadingEligibleSchemes.
  ///
  /// In en, this message translates to:
  /// **'Loading your eligible schemes'**
  String get loadingEligibleSchemes;

  /// No description provided for @foundSchemesForSearch.
  ///
  /// In en, this message translates to:
  /// **'Found {count} schemes matching your search for {goal}'**
  String foundSchemesForSearch(Object count, Object goal);

  /// No description provided for @loadedEligibleSchemes.
  ///
  /// In en, this message translates to:
  /// **'Loaded {count} schemes you\'re eligible for'**
  String loadedEligibleSchemes(Object count);

  /// No description provided for @failedToLoadSchemes.
  ///
  /// In en, this message translates to:
  /// **'Failed to load schemes. Please try again.'**
  String get failedToLoadSchemes;

  /// No description provided for @pageNumber.
  ///
  /// In en, this message translates to:
  /// **'Page {page}'**
  String pageNumber(Object page);

  /// No description provided for @welcomeToFinancialHub.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Financial Scheme Hub! Loading your personalized recommendations.'**
  String get welcomeToFinancialHub;

  /// No description provided for @welcomeToFinancialHubDescription.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Financial Scheme Hub! Find personalized recommendations for your financial goals.'**
  String get welcomeToFinancialHubDescription;

  /// No description provided for @discoverFinancialOpportunities.
  ///
  /// In en, this message translates to:
  /// **'Discover Financial Opportunities'**
  String get discoverFinancialOpportunities;

  /// No description provided for @findYourPerfectScheme.
  ///
  /// In en, this message translates to:
  /// **'Find Your Perfect Scheme'**
  String get findYourPerfectScheme;

  /// No description provided for @whatAreYouLookingFor.
  ///
  /// In en, this message translates to:
  /// **'What are you looking for?'**
  String get whatAreYouLookingFor;

  /// No description provided for @usingAiToFind.
  ///
  /// In en, this message translates to:
  /// **'Using AI to find the best schemes for: {searchText}'**
  String usingAiToFind(Object searchText);

  /// No description provided for @refreshingEligibleSchemes.
  ///
  /// In en, this message translates to:
  /// **'Refreshing your eligible schemes'**
  String get refreshingEligibleSchemes;

  /// No description provided for @userProfileNotFound.
  ///
  /// In en, this message translates to:
  /// **'User profile not found.'**
  String get userProfileNotFound;

  /// No description provided for @noDataReceived.
  ///
  /// In en, this message translates to:
  /// **'No data received from backend.'**
  String get noDataReceived;

  /// No description provided for @aiRecommendations.
  ///
  /// In en, this message translates to:
  /// **'AI Recommendations'**
  String get aiRecommendations;

  /// No description provided for @eligibleSchemes.
  ///
  /// In en, this message translates to:
  /// **'Eligible Schemes'**
  String get eligibleSchemes;

  /// No description provided for @schemesFound.
  ///
  /// In en, this message translates to:
  /// **'{count} schemes found'**
  String schemesFound(Object count);

  /// No description provided for @showingAiRecommendations.
  ///
  /// In en, this message translates to:
  /// **'Showing AI-powered recommendations based on your search'**
  String get showingAiRecommendations;

  /// No description provided for @showingEligibleSchemes.
  ///
  /// In en, this message translates to:
  /// **'Showing schemes you\'re eligible for based on your profile'**
  String get showingEligibleSchemes;

  /// No description provided for @foundSchemesTotal.
  ///
  /// In en, this message translates to:
  /// **'{modeText}. Found {count} schemes.'**
  String foundSchemesTotal(Object count, Object modeText);

  /// No description provided for @pageOf.
  ///
  /// In en, this message translates to:
  /// **'Page {current} of {total}'**
  String pageOf(Object current, Object total);

  /// No description provided for @schemes.
  ///
  /// In en, this message translates to:
  /// **'schemes'**
  String get schemes;

  /// No description provided for @totalSchemesFound.
  ///
  /// In en, this message translates to:
  /// **'Page {current} of {total}. Total {count} schemes found.'**
  String totalSchemesFound(Object count, Object current, Object total);

  /// No description provided for @returnLabel.
  ///
  /// In en, this message translates to:
  /// **'Return'**
  String get returnLabel;

  /// No description provided for @riskLabel.
  ///
  /// In en, this message translates to:
  /// **'Risk'**
  String get riskLabel;

  /// No description provided for @termLabel.
  ///
  /// In en, this message translates to:
  /// **'Term'**
  String get termLabel;

  /// No description provided for @changeLanguage.
  ///
  /// In en, this message translates to:
  /// **'Change Language'**
  String get changeLanguage;

  /// No description provided for @activeMember.
  ///
  /// In en, this message translates to:
  /// **'Active Member'**
  String get activeMember;

  /// No description provided for @profileUserInfo.
  ///
  /// In en, this message translates to:
  /// **'Profile: {userName}, Active Member'**
  String profileUserInfo(String userName);

  /// No description provided for @contactInformation.
  ///
  /// In en, this message translates to:
  /// **'Contact Information'**
  String get contactInformation;

  /// No description provided for @contactInfoVoice.
  ///
  /// In en, this message translates to:
  /// **'Contact Information. Email: {email}. Phone: {phone}. Location: {location}.'**
  String contactInfoVoice(String email, String phone, String location);

  /// No description provided for @financialSummaryVoice.
  ///
  /// In en, this message translates to:
  /// **'Financial Summary. Total Savings: {savings} rupees. Active Schemes: {schemes}. Investment Returns: {returns} rupees. Goals Achieved: {goals}'**
  String financialSummaryVoice(
      String savings, String schemes, String returns, String goals);

  /// No description provided for @thisMonthGrowth.
  ///
  /// In en, this message translates to:
  /// **'+1.2% this month'**
  String get thisMonthGrowth;

  /// No description provided for @joinedNewScheme.
  ///
  /// In en, this message translates to:
  /// **'Joined {count} new'**
  String joinedNewScheme(String count);

  /// No description provided for @joinedNone.
  ///
  /// In en, this message translates to:
  /// **'Joined none'**
  String get joinedNone;

  /// No description provided for @lastQuarterGrowth.
  ///
  /// In en, this message translates to:
  /// **'+5% last quarter'**
  String get lastQuarterGrowth;

  /// No description provided for @onTrackForMore.
  ///
  /// In en, this message translates to:
  /// **'On track for 3 more'**
  String get onTrackForMore;

  /// No description provided for @recentActivitiesAndTips.
  ///
  /// In en, this message translates to:
  /// **'Recent Activities & Tips'**
  String get recentActivitiesAndTips;

  /// No description provided for @recentActivitiesVoice.
  ///
  /// In en, this message translates to:
  /// **'Recent Activities and Tips section'**
  String get recentActivitiesVoice;

  /// No description provided for @noSchemesRegistered.
  ///
  /// In en, this message translates to:
  /// **'No schemes registered yet.'**
  String get noSchemesRegistered;

  /// No description provided for @exploreNewSchemes.
  ///
  /// In en, this message translates to:
  /// **'Explore new schemes from the home page to get started!'**
  String get exploreNewSchemes;

  /// No description provided for @noSchemesVoice.
  ///
  /// In en, this message translates to:
  /// **'No schemes registered yet. You can explore new schemes from the home page.'**
  String get noSchemesVoice;

  /// No description provided for @registered.
  ///
  /// In en, this message translates to:
  /// **'Registered'**
  String get registered;

  /// No description provided for @schemeVoiceInfo.
  ///
  /// In en, this message translates to:
  /// **'Scheme: {name}. Amount: {amount} rupees. Registered on: {regDate}. Next due date: {dueDate}'**
  String schemeVoiceInfo(
      String name, String amount, String regDate, String dueDate);

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @languageSelected.
  ///
  /// In en, this message translates to:
  /// **'{language} selected'**
  String languageSelected(String language);

  /// No description provided for @myProfilePageDescription.
  ///
  /// In en, this message translates to:
  /// **'My Profile page. View your personal information, financial summary, and active schemes.'**
  String get myProfilePageDescription;

  /// No description provided for @profilePageVoice.
  ///
  /// In en, this message translates to:
  /// **'Profile: {name}, Active Member'**
  String profilePageVoice(String name);

  /// No description provided for @snapshotCardVoice.
  ///
  /// In en, this message translates to:
  /// **'{title}: {value}. {subtitle}'**
  String snapshotCardVoice(String title, String value, String subtitle);

  /// No description provided for @contactItemVoice.
  ///
  /// In en, this message translates to:
  /// **'{label}: {value}'**
  String contactItemVoice(String label, String value);
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
      <String>['en', 'hi', 'mr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
    case 'mr':
      return AppLocalizationsMr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
