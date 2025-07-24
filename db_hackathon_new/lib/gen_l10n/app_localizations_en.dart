// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get welcomeMessage => 'Welcome to SchemeFinder';

  @override
  String get login => 'Login';

  @override
  String get register => 'Register';

  @override
  String get locationPrompt =>
      'Please allow location access to get personalized schemes.';

  @override
  String get secureTrusted => 'Secure & Trusted';

  @override
  String get aiPowered => 'AI Powered';

  @override
  String get locationBased => 'Location Based';

  @override
  String get locationBasedDescription =>
      'Get personalized schemes based on your location and preferred language.';

  @override
  String get expertSupport => 'Expert Support';

  @override
  String get expertSupportDescription =>
      'Chat or call local agents for personalized assistance.';

  @override
  String get skip => 'Skip and Continue';

  @override
  String get allowLocation => 'Allow Location Access';

  @override
  String get chooseLanguage => 'Choose your preferred language';

  @override
  String get english => 'English';

  @override
  String get hindi => 'Hindi';

  @override
  String get marathi => 'Marathi';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get dontHaveAccount => 'Don’t have an account? Register';

  @override
  String get createProfile => 'Create Profile';

  @override
  String get name => 'Name';

  @override
  String get annualIncome => 'Annual Income';

  @override
  String get savings => 'Savings';

  @override
  String get gender => 'Gender';

  @override
  String get category => 'Category';

  @override
  String get male => 'Male';

  @override
  String get female => 'Female';

  @override
  String get other => 'Other';

  @override
  String get general => 'General';

  @override
  String get obc => 'OBC';

  @override
  String get sc => 'SC';

  @override
  String get st => 'ST';

  @override
  String get next => 'Next';

  @override
  String get back => 'Back';

  @override
  String get finish => 'Finish';

  @override
  String get error => 'Error';

  @override
  String get homeTitle => 'Welcome';

  @override
  String get welcome => 'Welcome';

  @override
  String get user => 'User';

  @override
  String get recommendedSchemes => 'Here are your recommended schemes:';

  @override
  String get noSchemesFound =>
      'No recommendations found or check your profile data.';

  @override
  String get goal => 'Goal';

  @override
  String get benefits => 'Benefits';

  @override
  String get returns => 'Return';

  @override
  String get duration => 'Duration';

  @override
  String get website => 'Website';

  @override
  String get score => 'Score';

  @override
  String get appTitle => 'SchemeFinder';

  @override
  String get appSubtitle => 'Find the best schemes for you';

  @override
  String get loginSuccess => 'Login successful!';

  @override
  String get loginFailed => 'Login failed';

  @override
  String get nameRequired => 'Name is required';

  @override
  String get emailRequired => 'Email is required';

  @override
  String get passwordLength => 'Password must be at least 6 characters';

  @override
  String get chatbot => 'Continue as Guest';

  @override
  String get yourFinances => 'Your Finances';

  @override
  String get aboutYou => 'About You';

  @override
  String get incomeGroup1Lakh => '<1 Lakh';

  @override
  String get incomeGroup1to2Lakh => '1-2 Lakh';

  @override
  String get incomeGroup2to5Lakh => '2-5 Lakh';

  @override
  String get incomeGroup5to10Lakh => '5-10 Lakh';

  @override
  String get incomeGroup10PlusLakh => '10+ Lakh';

  @override
  String get urban => 'Urban';

  @override
  String get defaultSituation => 'Looking for investment schemes';

  @override
  String get profileCreationTitle => 'Create Your Profile';

  @override
  String get welcomeSchemes =>
      'Welcome! Here are the schemes you are eligible for.';

  @override
  String get typeGoalOrNeed => 'Type your goal or need (optional)';

  @override
  String get find => 'Find';

  @override
  String get noRecommendations => 'No eligible recommendations found.';

  @override
  String get matchScore => 'Match Score';

  @override
  String get trackerComingSoon => 'Tracker page coming soon!';

  @override
  String get profileComingSoon => 'Profile page coming soon!';

  @override
  String get microLoansComingSoon => 'Micro Loans page coming soon!';

  @override
  String get home => 'Home';

  @override
  String get tracker => 'Tracker';

  @override
  String get profile => 'Profile';

  @override
  String get microLoans => 'Micro Loans';

  @override
  String welcomeUser(Object user) {
    return 'Welcome, $user!';
  }

  @override
  String get searchGoalOrNeed => 'Search your goal or need';

  @override
  String get risk => 'Risk';

  @override
  String get term => 'Term';

  @override
  String get supportComingSoon => 'Support page coming soon!';

  @override
  String get community => 'Community';

  @override
  String get support => 'Support';

  @override
  String get myProfile => 'My Profile';

  @override
  String get profilePageTts =>
      'My Profile page. View your personal information, financial summary, and active schemes.';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get logout => 'Logout';

  @override
  String get loggingOut => 'Logging out';

  @override
  String get contactInfo => 'Contact Information';

  @override
  String get noEmail => 'No email';

  @override
  String get noPhone => 'No phone';

  @override
  String get noLocation => 'No location';

  @override
  String get phone => 'Phone';

  @override
  String get location => 'Location';

  @override
  String get financialSummary => 'Financial Summary';

  @override
  String get totalSavings => 'Total Savings';

  @override
  String get activeSchemes => 'Active Schemes';

  @override
  String get investmentReturns => 'Investment Returns';

  @override
  String get goalsAchieved => 'Goals Achieved';

  @override
  String get rupees => 'rupees';

  @override
  String get savingsSubtitle => '+1.2% this month';

  @override
  String activeSchemesSubtitle(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '1 new',
      zero: 'none',
    );
    return 'Joined $_temp0';
  }

  @override
  String get returnsSubtitle => '+5% last quarter';

  @override
  String get goalsSubtitle => 'On track for 3 more';

  @override
  String get recentActivities => 'Recent Activities & Tips';

  @override
  String get recentActivitiesTts => 'Recent Activities and Tips section';

  @override
  String get noSchemes => 'No schemes registered yet.';

  @override
  String get noSchemesTts =>
      'No schemes registered yet. You can explore new schemes from the home page.';

  @override
  String get unnamedScheme => 'Unnamed Scheme';

  @override
  String get amount => 'Amount';

  @override
  String get registeredOn => 'Registered on';

  @override
  String get nextDueDate => 'Next Due Date';

  @override
  String get scheme => 'Scheme';

  @override
  String get financeInclude => 'FinanceInclude';

  @override
  String get pathToFinancialSuccess => 'Your Path to Financial Success';

  @override
  String get financialToolsDescription =>
      'Simple, visual tools to help you manage money and access financial services';

  @override
  String get alreadyHaveAccount => 'Already Have Account';

  @override
  String get voiceAssistant => 'Voice Assistant';

  @override
  String get voiceAssistantDescription =>
      'Get personalized recommendations to improve your financial situation';

  @override
  String get unsureWhatYouNeed => 'Unsure of what you need?';

  @override
  String get browseSchemes => 'Browse through our schemes';

  @override
  String get continueAsGuest => 'Continue as Guest';

  @override
  String get welcomeToSchemeRecommender =>
      'Welcome to Scheme Recommender! Your AI-powered financial companion for discovering government schemes.';

  @override
  String get loginToFinWise => 'Login to FinWise';

  @override
  String get welcomeBack => 'Welcome Back!';

  @override
  String get loginDescription =>
      'Discover your personalized financial recommendations and track your progress';

  @override
  String get emailOrUsername => 'Email or Username';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get logInSecurely => 'Log in Securely';

  @override
  String get continueWithChatbot => 'Continue with Chatbot';

  @override
  String get continueAsAgent => 'Continue as Agent';

  @override
  String get registerAsAgent => 'Register as Agent';

  @override
  String get dontHaveAccountRegister => 'Don\'t have an account?';

  @override
  String get registerAsNewUser => 'Register as a New User';

  @override
  String get loggingIn => 'Logging in';

  @override
  String get loginSuccessMessage =>
      'Login successful! Redirecting to home screen.';

  @override
  String get loginFailedMessage =>
      'Login failed. Please check your credentials and try again.';

  @override
  String get welcomeLoginMessage =>
      'Welcome to Scheme Recommender Login. Enter your credentials to access your account, or explore other options like chatbot or agent services.';

  @override
  String get emailFieldEmpty => 'Email field is empty';

  @override
  String get passwordFieldEmpty => 'Password field is empty';

  @override
  String get passwordEntered => 'Password entered';

  @override
  String get loginButtonDescription =>
      'Login button. Tap to sign in to your account.';

  @override
  String get openingChatbot => 'Opening chatbot';

  @override
  String get openingAgentLogin => 'Opening agent login';

  @override
  String get openingAgentRegistration => 'Opening agent registration';

  @override
  String get createNewProfile => 'Don\'t have an account? Create profile';

  @override
  String get createNewProfileDescription =>
      'Don\'t have an account? Create a new profile to get started.';

  @override
  String get or => 'OR';

  @override
  String get createFinWiseAccount => 'Create Your FinWise Account';

  @override
  String get personalInfo => 'Personal\nInfo';

  @override
  String get financialOccupational => 'Financial &\nOccupational';

  @override
  String get demographicsBank => 'Demographics\n& Bank';

  @override
  String get fullName => 'Full Name';

  @override
  String get emailAddress => 'Email Address';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get enterFullName => 'Enter your full name';

  @override
  String get enterEmail => 'Enter your email';

  @override
  String get createPassword => 'Create a password';

  @override
  String get reenterPassword => 'Re-enter your password';

  @override
  String get doBankAccount => 'Do you have a bank account?';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get bankAccountRequired =>
      'You need a bank account to access most schemes. We\'ll help you connect with support.';

  @override
  String get welcomeProfileCreation =>
      'Welcome to profile creation. Let\'s set up your account in 3 simple steps.';

  @override
  String get step1Description =>
      'Step 1 of 3: Account Setup. Please enter your name, email, and password.';

  @override
  String get step2Description =>
      'Step 2 of 3: Financial Information. Please enter your annual income and current savings.';

  @override
  String get step3Description =>
      'Step 3 of 3: Personal Details. Please select your gender and category.';

  @override
  String get goingBackStep => 'Going back to previous step';

  @override
  String get movingNextStep => 'Moving to next step';

  @override
  String get creatingAccount => 'Creating your account';

  @override
  String get selectBankAccount => 'Please select if you have a bank account.';

  @override
  String get creatingAccountWait => 'Creating your account, please wait...';

  @override
  String get accountCreatedSuccess =>
      'Account created successfully! Welcome to Scheme Recommender!';

  @override
  String get accountCreationFailed =>
      'Account creation failed. Please try again.';

  @override
  String get pleaseSpeakField => 'Please speak your';

  @override
  String get youSaid => 'You said:';

  @override
  String get voiceInputFailed => 'Voice input failed. Please type manually.';

  @override
  String get currentGenderIs => 'Current gender is';

  @override
  String get availableOptions => 'Available options are:';

  @override
  String get currentCategoryIs => 'Current category is';

  @override
  String get profileCreation => 'Profile Creation';

  @override
  String get fullNameVoice => 'full name';

  @override
  String get emailAddressVoice => 'email address';

  @override
  String get annualIncomeVoice => 'annual income';

  @override
  String get savingsVoice => 'current savings';

  @override
  String get needBankAccountSupport =>
      'You need a bank account to access most schemes. We\'ll help you connect with support.';

  @override
  String get goingBack => 'Going back to previous step';
}
