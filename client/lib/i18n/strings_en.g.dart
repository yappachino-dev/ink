///
/// Generated file. Do not edit.
///
// coverage:ignore-file
// ignore_for_file: type=lint, unused_import
// dart format off

part of 'strings.g.dart';

// Path: <root>
typedef TranslationsEn = Translations; // ignore: unused_element
class Translations with BaseTranslations<AppLocale, Translations> {
	/// Returns the current translations of the given [context].
	///
	/// Usage:
	/// final t = Translations.of(context);
	static Translations of(BuildContext context) => InheritedLocaleData.of<AppLocale, Translations>(context).translations;

	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	Translations({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = meta ?? TranslationMetadata(
		    locale: AppLocale.en,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ) {
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <en>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	/// Access flat map
	dynamic operator[](String key) => $meta.getTranslation(key);

	late final Translations _root = this; // ignore: unused_field

	Translations $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => Translations(meta: meta ?? this.$meta);

	// Translations
	late final TranslationsCommonEn common = TranslationsCommonEn.internal(_root);
	late final TranslationsWelcomeEn welcome = TranslationsWelcomeEn.internal(_root);
	late final TranslationsAuthEn auth = TranslationsAuthEn.internal(_root);
	late final TranslationsVaultEn vault = TranslationsVaultEn.internal(_root);
	late final TranslationsHomeEn home = TranslationsHomeEn.internal(_root);
	late final TranslationsCalendarEn calendar = TranslationsCalendarEn.internal(_root);
	late final TranslationsNoteEn note = TranslationsNoteEn.internal(_root);
	late final TranslationsProjectEn project = TranslationsProjectEn.internal(_root);
	late final TranslationsProfileEn profile = TranslationsProfileEn.internal(_root);
}

// Path: common
class TranslationsCommonEn {
	TranslationsCommonEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Ink'
	String get appName => 'Ink';

	/// en: 'Back'
	String get back => 'Back';

	/// en: 'Next'
	String get next => 'Next';

	/// en: 'Continue'
	String get kContinue => 'Continue';

	/// en: 'Confirm'
	String get confirm => 'Confirm';

	/// en: 'Save'
	String get save => 'Save';

	/// en: 'Cancel'
	String get cancel => 'Cancel';

	/// en: 'Delete'
	String get delete => 'Delete';

	/// en: 'Error'
	String get errorTitle => 'Error';

	/// en: 'Loading...'
	String get loading => 'Loading...';
}

// Path: welcome
class TranslationsWelcomeEn {
	TranslationsWelcomeEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Create local storage'
	String get createLocalStorage => 'Create local storage';

	/// en: 'Already have an account?'
	String get haveAccount => 'Already have an account?';
}

// Path: auth
class TranslationsAuthEn {
	TranslationsAuthEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Your plans under reliable protection'
	String get tagline => 'Your plans under reliable protection';

	/// en: 'Choose how to use'
	String get chooseMethod => 'Choose how to use';

	late final TranslationsAuthLoginEn login = TranslationsAuthLoginEn.internal(_root);
	late final TranslationsAuthRegisterEn register = TranslationsAuthRegisterEn.internal(_root);
	late final TranslationsAuthVerifyEn verify = TranslationsAuthVerifyEn.internal(_root);
	late final TranslationsAuthFormEn form = TranslationsAuthFormEn.internal(_root);
}

// Path: vault
class TranslationsVaultEn {
	TranslationsVaultEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final TranslationsVaultFatalEn fatal = TranslationsVaultFatalEn.internal(_root);
	late final TranslationsVaultMethodsEn methods = TranslationsVaultMethodsEn.internal(_root);
	late final TranslationsVaultSetupEn setup = TranslationsVaultSetupEn.internal(_root);
	late final TranslationsVaultUnlockEn unlock = TranslationsVaultUnlockEn.internal(_root);
}

// Path: home
class TranslationsHomeEn {
	TranslationsHomeEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Inbox'
	String get inbox => 'Inbox';

	/// en: 'Today'
	String get today => 'Today';

	/// en: 'Completed'
	String get completed => 'Completed';
}

// Path: calendar
class TranslationsCalendarEn {
	TranslationsCalendarEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Calendar'
	String get title => 'Calendar';

	/// en: 'Filter'
	String get filter => 'Filter';

	/// en: 'No notes for this day'
	String get noNotes => 'No notes for this day';

	/// en: 'Calendar view'
	String get view => 'Calendar view';

	late final TranslationsCalendarModesEn modes = TranslationsCalendarModesEn.internal(_root);
	List<String> get months => [
		'January',
		'February',
		'March',
		'April',
		'May',
		'June',
		'July',
		'August',
		'September',
		'October',
		'November',
		'December',
	];

	/// en: 'Choose timezone'
	String get timezone => 'Choose timezone';
}

// Path: note
class TranslationsNoteEn {
	TranslationsNoteEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Notes'
	String get title => 'Notes';

	/// en: 'New note'
	String get create => 'New note';

	/// en: 'Edit note'
	String get edit => 'Edit note';

	/// en: 'What needs to be done?'
	String get whatToDo => 'What needs to be done?';

	/// en: 'Add details...'
	String get addDetails => 'Add details...';

	/// en: 'Show note details'
	String get showDetails => 'Show note details';

	/// en: 'Hide note details'
	String get hideDetails => 'Hide note details';

	/// en: 'Note's project'
	String get project => 'Note\'s project';

	/// en: 'All projects'
	String get allProjects => 'All projects';

	late final TranslationsNoteDeleteEn delete = TranslationsNoteDeleteEn.internal(_root);
	late final TranslationsNotePriorityEn priority = TranslationsNotePriorityEn.internal(_root);
	late final TranslationsNoteReminderEn reminder = TranslationsNoteReminderEn.internal(_root);
}

// Path: project
class TranslationsProjectEn {
	TranslationsProjectEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'My projects'
	String get title => 'My projects';

	/// en: 'Select a project'
	String get select => 'Select a project';

	/// en: 'No project'
	String get none => 'No project';

	/// en: 'Add a project'
	String get create => 'Add a project';

	/// en: 'Edit project'
	String get edit => 'Edit project';

	late final TranslationsProjectDeleteEn delete = TranslationsProjectDeleteEn.internal(_root);
	late final TranslationsProjectFormEn form = TranslationsProjectFormEn.internal(_root);
}

// Path: profile
class TranslationsProfileEn {
	TranslationsProfileEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Profile'
	String get title => 'Profile';

	late final TranslationsProfilePersonalEn personal = TranslationsProfilePersonalEn.internal(_root);
	late final TranslationsProfileAccountEn account = TranslationsProfileAccountEn.internal(_root);
	late final TranslationsProfileSettingsEn settings = TranslationsProfileSettingsEn.internal(_root);
}

// Path: auth.login
class TranslationsAuthLoginEn {
	TranslationsAuthLoginEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Log In'
	String get title => 'Log In';

	/// en: 'Login'
	String get action => 'Login';

	/// en: 'Successfully logged in'
	String get success => 'Successfully logged in';

	/// en: 'Don't have an account?'
	String get noAccount => 'Don\'t have an account?';
}

// Path: auth.register
class TranslationsAuthRegisterEn {
	TranslationsAuthRegisterEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Register'
	String get title => 'Register';

	/// en: 'Register'
	String get action => 'Register';

	/// en: 'Successfully registered'
	String get success => 'Successfully registered';

	/// en: 'I already have an account'
	String get haveAccount => 'I already have an account';
}

// Path: auth.verify
class TranslationsAuthVerifyEn {
	TranslationsAuthVerifyEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Email Verification'
	String get title => 'Email Verification';

	/// en: 'Confirmation code sent to $email'
	String codeSent({required Object email}) => 'Confirmation code sent to ${email}';

	/// en: 'Enter verification code'
	String get codeHint => 'Enter verification code';

	/// en: 'Invalid code'
	String get codeError => 'Invalid code';

	/// en: 'Resend code'
	String get resend => 'Resend code';
}

// Path: auth.form
class TranslationsAuthFormEn {
	TranslationsAuthFormEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Email'
	String get email => 'Email';

	/// en: 'Email'
	String get emailHint => 'Email';

	/// en: 'Email is required'
	String get emailError => 'Email is required';

	/// en: 'Invalid email format'
	String get emailFormatError => 'Invalid email format';

	/// en: 'Password'
	String get password => 'Password';

	/// en: 'Password'
	String get passwordHint => 'Password';

	/// en: 'Password is required'
	String get passwordError => 'Password is required';

	/// en: 'Password must be between 6 and 72 characters'
	String get passwordLengthError => 'Password must be between 6 and 72 characters';

	/// en: 'Confirm password'
	String get confirmPassword => 'Confirm password';

	/// en: 'Passwords do not match'
	String get passwordsNotMatch => 'Passwords do not match';
}

// Path: vault.fatal
class TranslationsVaultFatalEn {
	TranslationsVaultFatalEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'App crashed fatally'
	String get title => 'App crashed fatally';

	/// en: 'Failed to load keys both locally and remotely'
	String get subtitle => 'Failed to load keys both locally and remotely';
}

// Path: vault.methods
class TranslationsVaultMethodsEn {
	TranslationsVaultMethodsEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Security Method'
	String get title => 'Security Method';

	/// en: 'Choose a quick login method. A secret phrase will be mandatory in the next step.'
	String get subtitle => 'Choose a quick login method. A secret phrase will be mandatory in the next step.';

	late final TranslationsVaultMethodsPinEn pin = TranslationsVaultMethodsPinEn.internal(_root);
	late final TranslationsVaultMethodsPatternEn pattern = TranslationsVaultMethodsPatternEn.internal(_root);
	late final TranslationsVaultMethodsSeedEn seed = TranslationsVaultMethodsSeedEn.internal(_root);
	late final TranslationsVaultMethodsWordEn word = TranslationsVaultMethodsWordEn.internal(_root);
	late final TranslationsVaultMethodsVerificationEn verification = TranslationsVaultMethodsVerificationEn.internal(_root);
	late final TranslationsVaultMethodsOptionsEn options = TranslationsVaultMethodsOptionsEn.internal(_root);
}

// Path: vault.setup
class TranslationsVaultSetupEn {
	TranslationsVaultSetupEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final TranslationsVaultSetupPinEn pin = TranslationsVaultSetupPinEn.internal(_root);
	late final TranslationsVaultSetupPatternEn pattern = TranslationsVaultSetupPatternEn.internal(_root);
	late final TranslationsVaultSetupWordEn word = TranslationsVaultSetupWordEn.internal(_root);
	late final TranslationsVaultSetupSeedEn seed = TranslationsVaultSetupSeedEn.internal(_root);
	late final TranslationsVaultSetupSeedVerifyEn seedVerify = TranslationsVaultSetupSeedVerifyEn.internal(_root);
}

// Path: vault.unlock
class TranslationsVaultUnlockEn {
	TranslationsVaultUnlockEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final TranslationsVaultUnlockPinEn pin = TranslationsVaultUnlockPinEn.internal(_root);
	late final TranslationsVaultUnlockPatternEn pattern = TranslationsVaultUnlockPatternEn.internal(_root);
	late final TranslationsVaultUnlockWordEn word = TranslationsVaultUnlockWordEn.internal(_root);
	late final TranslationsVaultUnlockSeedEn seed = TranslationsVaultUnlockSeedEn.internal(_root);

	/// en: 'Too many attempts. Try again in ${seconds}s.'
	String throttled({required Object seconds}) => 'Too many attempts. Try again in ${seconds}s.';
}

// Path: calendar.modes
class TranslationsCalendarModesEn {
	TranslationsCalendarModesEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Month'
	String get month => 'Month';

	/// en: '2 weeks'
	String get twoWeeks => '2 weeks';

	/// en: 'Week'
	String get week => 'Week';

	/// en: 'Day'
	String get day => 'Day';
}

// Path: note.delete
class TranslationsNoteDeleteEn {
	TranslationsNoteDeleteEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Delete note?'
	String get title => 'Delete note?';

	/// en: 'Delete note'
	String get tooltip => 'Delete note';

	/// en: 'This note will be permanently deleted.'
	String get message => 'This note will be permanently deleted.';
}

// Path: note.priority
class TranslationsNotePriorityEn {
	TranslationsNotePriorityEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Select a priority'
	String get select => 'Select a priority';

	/// en: 'None'
	String get none => 'None';

	/// en: 'Low'
	String get low => 'Low';

	/// en: 'Medium'
	String get medium => 'Medium';

	/// en: 'High'
	String get high => 'High';
}

// Path: note.reminder
class TranslationsNoteReminderEn {
	TranslationsNoteReminderEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Select a reminder'
	String get select => 'Select a reminder';

	/// en: 'No reminder'
	String get none => 'No reminder';

	/// en: 'Remind at time'
	String get atTime => 'Remind at time';

	/// en: '(one) {1 minute} (other) {{n} minutes}'
	String minutes({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n,
		one: '1 minute',
		other: '{n} minutes',
	);

	/// en: '(one) {1 hour} (other) {{n} hours}'
	String hours({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n,
		one: '1 hour',
		other: '{n} hours',
	);

	/// en: '(one) {1 day} (other) {{n} days}'
	String days({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n,
		one: '1 day',
		other: '{n} days',
	);
}

// Path: project.delete
class TranslationsProjectDeleteEn {
	TranslationsProjectDeleteEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Delete project?'
	String get title => 'Delete project?';

	/// en: 'Delete project'
	String get tooltip => 'Delete project';

	/// en: 'The project will be permanently deleted.'
	String get message => 'The project will be permanently deleted.';
}

// Path: project.form
class TranslationsProjectFormEn {
	TranslationsProjectFormEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Name'
	String get name => 'Name';

	/// en: 'Project color'
	String get color => 'Project color';

	/// en: 'Icon'
	String get icon => 'Icon';
}

// Path: profile.personal
class TranslationsProfilePersonalEn {
	TranslationsProfilePersonalEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Name'
	String get name => 'Name';

	/// en: 'Email'
	String get email => 'Email';

	/// en: 'Change name'
	String get changeName => 'Change name';

	/// en: 'Change password'
	String get changePassword => 'Change password';

	/// en: 'Change encryption method'
	String get changeEncryption => 'Change encryption method';

	/// en: 'Log Out'
	String get logout => 'Log Out';
}

// Path: profile.account
class TranslationsProfileAccountEn {
	TranslationsProfileAccountEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Create account'
	String get create => 'Create account';

	/// en: 'Create an account so you don't lose your data'
	String get createSubtitle => 'Create an account so you don\'t lose your data';

	/// en: 'Delete account'
	String get delete => 'Delete account';

	/// en: 'Data will be lost'
	String get deleteSubtitle => 'Data will be lost';

	/// en: 'Are you sure you want to delete your account?'
	String get deleteConfirm => 'Are you sure you want to delete your account?';
}

// Path: profile.settings
class TranslationsProfileSettingsEn {
	TranslationsProfileSettingsEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Personalization'
	String get personalization => 'Personalization';

	/// en: 'Language'
	String get language => 'Language';

	late final TranslationsProfileSettingsAppearanceEn appearance = TranslationsProfileSettingsAppearanceEn.internal(_root);

	/// en: 'Choose timezone'
	String get timezone => 'Choose timezone';

	/// en: 'Date and time'
	String get dateTime => 'Date and time';

	/// en: 'Widgets'
	String get widgets => 'Widgets';
}

// Path: vault.methods.pin
class TranslationsVaultMethodsPinEn {
	TranslationsVaultMethodsPinEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'PIN-code'
	String get title => 'PIN-code';

	/// en: 'Quick access via 4-digit code'
	String get subtitle => 'Quick access via 4-digit code';

	late final TranslationsVaultMethodsPinKeyPadEn keyPad = TranslationsVaultMethodsPinKeyPadEn.internal(_root);
}

// Path: vault.methods.pattern
class TranslationsVaultMethodsPatternEn {
	TranslationsVaultMethodsPatternEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Pattern Lock'
	String get title => 'Pattern Lock';

	/// en: 'Protection with a unique gesture'
	String get subtitle => 'Protection with a unique gesture';
}

// Path: vault.methods.seed
class TranslationsVaultMethodsSeedEn {
	TranslationsVaultMethodsSeedEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Recovery Phrase'
	String get title => 'Recovery Phrase';

	/// en: 'Secure 12-words password'
	String get subtitle => 'Secure 12-words password';
}

// Path: vault.methods.word
class TranslationsVaultMethodsWordEn {
	TranslationsVaultMethodsWordEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Association Word'
	String get title => 'Association Word';

	/// en: 'Password with a hint for recovery'
	String get subtitle => 'Password with a hint for recovery';
}

// Path: vault.methods.verification
class TranslationsVaultMethodsVerificationEn {
	TranslationsVaultMethodsVerificationEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Identity Verification'
	String get title => 'Identity Verification';

	/// en: 'Choose an unlock method to verify'
	String get subtitle => 'Choose an unlock method to verify';
}

// Path: vault.methods.options
class TranslationsVaultMethodsOptionsEn {
	TranslationsVaultMethodsOptionsEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Login via PIN-code'
	String get pin => 'Login via PIN-code';

	/// en: 'Pattern Lock'
	String get pattern => 'Pattern Lock';

	/// en: 'Association Word'
	String get word => 'Association Word';

	/// en: 'Seed Phrase (Master Key)'
	String get seed => 'Seed Phrase (Master Key)';
}

// Path: vault.setup.pin
class TranslationsVaultSetupPinEn {
	TranslationsVaultSetupPinEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Create PIN-code'
	String get title => 'Create PIN-code';

	/// en: 'For quick access to your plans'
	String get description => 'For quick access to your plans';
}

// Path: vault.setup.pattern
class TranslationsVaultSetupPatternEn {
	TranslationsVaultSetupPatternEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Create Pattern Lock'
	String get title => 'Create Pattern Lock';

	/// en: 'Connect at least 4 dots'
	String get description => 'Connect at least 4 dots';

	/// en: 'Pattern too short!'
	String get errorShort => 'Pattern too short!';
}

// Path: vault.setup.word
class TranslationsVaultSetupWordEn {
	TranslationsVaultSetupWordEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Think of an association'
	String get title => 'Think of\nan association';

	/// en: 'Word must be at least 6 characters (no spaces, digits or signs)'
	String get description => 'Word must be at least 6 characters (no spaces, digits or signs)';
}

// Path: vault.setup.seed
class TranslationsVaultSetupSeedEn {
	TranslationsVaultSetupSeedEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Your Secret Phrase'
	String get title => 'Your Secret Phrase';

	/// en: 'Write these 12 words on paper and keep them in a safe place. If you lose them, access to your data cannot be restored.'
	String get warning => 'Write these 12 words on paper and keep them in a safe place. If you lose them, access to your data cannot be restored.';

	/// en: 'Copy to clipboard'
	String get copy => 'Copy to clipboard';

	/// en: 'Phrase copied to clipboard'
	String get copyDone => 'Phrase copied to clipboard';

	/// en: 'I have written these words'
	String get savedButton => 'I have written these words';
}

// Path: vault.setup.seedVerify
class TranslationsVaultSetupSeedVerifyEn {
	TranslationsVaultSetupSeedVerifyEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Record Verification'
	String get title => 'Record Verification';

	/// en: 'Please enter the specified words from your secret phrase'
	String get description => 'Please enter the specified words from your secret phrase';

	/// en: 'Enter word...'
	String get inputHint => 'Enter word...';

	/// en: 'Words do not match. Try again!'
	String get error => 'Words do not match. Try again!';

	/// en: 'Verification successful'
	String get success => 'Verification successful';
}

// Path: vault.unlock.pin
class TranslationsVaultUnlockPinEn {
	TranslationsVaultUnlockPinEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Enter PIN-code'
	String get title => 'Enter PIN-code';

	/// en: 'Enter your PIN-code to login'
	String get description => 'Enter your PIN-code to login';
}

// Path: vault.unlock.pattern
class TranslationsVaultUnlockPatternEn {
	TranslationsVaultUnlockPatternEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Enter Pattern Lock'
	String get title => 'Enter Pattern Lock';

	/// en: 'Draw your pattern to login'
	String get description => 'Draw your pattern to login';

	/// en: 'Pattern too short!'
	String get errorShort => 'Pattern too short!';
}

// Path: vault.unlock.word
class TranslationsVaultUnlockWordEn {
	TranslationsVaultUnlockWordEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Enter association'
	String get title => 'Enter\nassociation';

	/// en: 'Enter your association word to login'
	String get description => 'Enter your association word to login';

	/// en: 'Enter association word'
	String get hint => 'Enter association word';
}

// Path: vault.unlock.seed
class TranslationsVaultUnlockSeedEn {
	TranslationsVaultUnlockSeedEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Enter your secret phrase'
	String get title => 'Enter your\nsecret phrase';

	/// en: 'Enter all 12 words in the correct order'
	String get description => 'Enter all 12 words in the correct order';

	/// en: 'Word...'
	String get wordHint => 'Word...';

	/// en: 'Record Verification'
	String get verifyTitle => 'Record Verification';

	/// en: 'Words do not match. Try again!'
	String get verifyError => 'Words do not match. Try again!';

	/// en: 'Verification successful'
	String get verifySuccess => 'Verification successful';
}

// Path: profile.settings.appearance
class TranslationsProfileSettingsAppearanceEn {
	TranslationsProfileSettingsAppearanceEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Appearance'
	String get title => 'Appearance';

	/// en: 'Light'
	String get light => 'Light';

	/// en: 'Dark'
	String get dark => 'Dark';

	/// en: 'System'
	String get system => 'System';
}

// Path: vault.methods.pin.keyPad
class TranslationsVaultMethodsPinKeyPadEn {
	TranslationsVaultMethodsPinKeyPadEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Digit $n'
	String digitButton({required Object n}) => 'Digit ${n}';

	/// en: 'Delete last digit'
	String get backspaceButton => 'Delete last digit';
}

/// The flat map containing all translations for locale <en>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on Translations {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'common.appName' => 'Ink',
			'common.back' => 'Back',
			'common.next' => 'Next',
			'common.kContinue' => 'Continue',
			'common.confirm' => 'Confirm',
			'common.save' => 'Save',
			'common.cancel' => 'Cancel',
			'common.delete' => 'Delete',
			'common.errorTitle' => 'Error',
			'common.loading' => 'Loading...',
			'welcome.createLocalStorage' => 'Create local storage',
			'welcome.haveAccount' => 'Already have an account?',
			'auth.tagline' => 'Your plans under reliable protection',
			'auth.chooseMethod' => 'Choose how to use',
			'auth.login.title' => 'Log In',
			'auth.login.action' => 'Login',
			'auth.login.success' => 'Successfully logged in',
			'auth.login.noAccount' => 'Don\'t have an account?',
			'auth.register.title' => 'Register',
			'auth.register.action' => 'Register',
			'auth.register.success' => 'Successfully registered',
			'auth.register.haveAccount' => 'I already have an account',
			'auth.verify.title' => 'Email Verification',
			'auth.verify.codeSent' => ({required Object email}) => 'Confirmation code sent to ${email}',
			'auth.verify.codeHint' => 'Enter verification code',
			'auth.verify.codeError' => 'Invalid code',
			'auth.verify.resend' => 'Resend code',
			'auth.form.email' => 'Email',
			'auth.form.emailHint' => 'Email',
			'auth.form.emailError' => 'Email is required',
			'auth.form.emailFormatError' => 'Invalid email format',
			'auth.form.password' => 'Password',
			'auth.form.passwordHint' => 'Password',
			'auth.form.passwordError' => 'Password is required',
			'auth.form.passwordLengthError' => 'Password must be between 6 and 72 characters',
			'auth.form.confirmPassword' => 'Confirm password',
			'auth.form.passwordsNotMatch' => 'Passwords do not match',
			'vault.fatal.title' => 'App crashed fatally',
			'vault.fatal.subtitle' => 'Failed to load keys both locally and remotely',
			'vault.methods.title' => 'Security Method',
			'vault.methods.subtitle' => 'Choose a quick login method. A secret phrase will be mandatory in the next step.',
			'vault.methods.pin.title' => 'PIN-code',
			'vault.methods.pin.subtitle' => 'Quick access via 4-digit code',
			'vault.methods.pin.keyPad.digitButton' => ({required Object n}) => 'Digit ${n}',
			'vault.methods.pin.keyPad.backspaceButton' => 'Delete last digit',
			'vault.methods.pattern.title' => 'Pattern Lock',
			'vault.methods.pattern.subtitle' => 'Protection with a unique gesture',
			'vault.methods.seed.title' => 'Recovery Phrase',
			'vault.methods.seed.subtitle' => 'Secure 12-words password',
			'vault.methods.word.title' => 'Association Word',
			'vault.methods.word.subtitle' => 'Password with a hint for recovery',
			'vault.methods.verification.title' => 'Identity Verification',
			'vault.methods.verification.subtitle' => 'Choose an unlock method to verify',
			'vault.methods.options.pin' => 'Login via PIN-code',
			'vault.methods.options.pattern' => 'Pattern Lock',
			'vault.methods.options.word' => 'Association Word',
			'vault.methods.options.seed' => 'Seed Phrase (Master Key)',
			'vault.setup.pin.title' => 'Create PIN-code',
			'vault.setup.pin.description' => 'For quick access to your plans',
			'vault.setup.pattern.title' => 'Create Pattern Lock',
			'vault.setup.pattern.description' => 'Connect at least 4 dots',
			'vault.setup.pattern.errorShort' => 'Pattern too short!',
			'vault.setup.word.title' => 'Think of\nan association',
			'vault.setup.word.description' => 'Word must be at least 6 characters (no spaces, digits or signs)',
			'vault.setup.seed.title' => 'Your Secret Phrase',
			'vault.setup.seed.warning' => 'Write these 12 words on paper and keep them in a safe place. If you lose them, access to your data cannot be restored.',
			'vault.setup.seed.copy' => 'Copy to clipboard',
			'vault.setup.seed.copyDone' => 'Phrase copied to clipboard',
			'vault.setup.seed.savedButton' => 'I have written these words',
			'vault.setup.seedVerify.title' => 'Record Verification',
			'vault.setup.seedVerify.description' => 'Please enter the specified words from your secret phrase',
			'vault.setup.seedVerify.inputHint' => 'Enter word...',
			'vault.setup.seedVerify.error' => 'Words do not match. Try again!',
			'vault.setup.seedVerify.success' => 'Verification successful',
			'vault.unlock.pin.title' => 'Enter PIN-code',
			'vault.unlock.pin.description' => 'Enter your PIN-code to login',
			'vault.unlock.pattern.title' => 'Enter Pattern Lock',
			'vault.unlock.pattern.description' => 'Draw your pattern to login',
			'vault.unlock.pattern.errorShort' => 'Pattern too short!',
			'vault.unlock.word.title' => 'Enter\nassociation',
			'vault.unlock.word.description' => 'Enter your association word to login',
			'vault.unlock.word.hint' => 'Enter association word',
			'vault.unlock.seed.title' => 'Enter your\nsecret phrase',
			'vault.unlock.seed.description' => 'Enter all 12 words in the correct order',
			'vault.unlock.seed.wordHint' => 'Word...',
			'vault.unlock.seed.verifyTitle' => 'Record Verification',
			'vault.unlock.seed.verifyError' => 'Words do not match. Try again!',
			'vault.unlock.seed.verifySuccess' => 'Verification successful',
			'vault.unlock.throttled' => ({required Object seconds}) => 'Too many attempts. Try again in ${seconds}s.',
			'home.inbox' => 'Inbox',
			'home.today' => 'Today',
			'home.completed' => 'Completed',
			'calendar.title' => 'Calendar',
			'calendar.filter' => 'Filter',
			'calendar.noNotes' => 'No notes for this day',
			'calendar.view' => 'Calendar view',
			'calendar.modes.month' => 'Month',
			'calendar.modes.twoWeeks' => '2 weeks',
			'calendar.modes.week' => 'Week',
			'calendar.modes.day' => 'Day',
			'calendar.months.0' => 'January',
			'calendar.months.1' => 'February',
			'calendar.months.2' => 'March',
			'calendar.months.3' => 'April',
			'calendar.months.4' => 'May',
			'calendar.months.5' => 'June',
			'calendar.months.6' => 'July',
			'calendar.months.7' => 'August',
			'calendar.months.8' => 'September',
			'calendar.months.9' => 'October',
			'calendar.months.10' => 'November',
			'calendar.months.11' => 'December',
			'calendar.timezone' => 'Choose timezone',
			'note.title' => 'Notes',
			'note.create' => 'New note',
			'note.edit' => 'Edit note',
			'note.whatToDo' => 'What needs to be done?',
			'note.addDetails' => 'Add details...',
			'note.showDetails' => 'Show note details',
			'note.hideDetails' => 'Hide note details',
			'note.project' => 'Note\'s project',
			'note.allProjects' => 'All projects',
			'note.delete.title' => 'Delete note?',
			'note.delete.tooltip' => 'Delete note',
			'note.delete.message' => 'This note will be permanently deleted.',
			'note.priority.select' => 'Select a priority',
			'note.priority.none' => 'None',
			'note.priority.low' => 'Low',
			'note.priority.medium' => 'Medium',
			'note.priority.high' => 'High',
			'note.reminder.select' => 'Select a reminder',
			'note.reminder.none' => 'No reminder',
			'note.reminder.atTime' => 'Remind at time',
			'note.reminder.minutes' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n, one: '1 minute', other: '{n} minutes', ), 
			'note.reminder.hours' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n, one: '1 hour', other: '{n} hours', ), 
			'note.reminder.days' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n, one: '1 day', other: '{n} days', ), 
			'project.title' => 'My projects',
			'project.select' => 'Select a project',
			'project.none' => 'No project',
			'project.create' => 'Add a project',
			'project.edit' => 'Edit project',
			'project.delete.title' => 'Delete project?',
			'project.delete.tooltip' => 'Delete project',
			'project.delete.message' => 'The project will be permanently deleted.',
			'project.form.name' => 'Name',
			'project.form.color' => 'Project color',
			'project.form.icon' => 'Icon',
			'profile.title' => 'Profile',
			'profile.personal.name' => 'Name',
			'profile.personal.email' => 'Email',
			'profile.personal.changeName' => 'Change name',
			'profile.personal.changePassword' => 'Change password',
			'profile.personal.changeEncryption' => 'Change encryption method',
			'profile.personal.logout' => 'Log Out',
			'profile.account.create' => 'Create account',
			'profile.account.createSubtitle' => 'Create an account so you don\'t lose your data',
			'profile.account.delete' => 'Delete account',
			'profile.account.deleteSubtitle' => 'Data will be lost',
			'profile.account.deleteConfirm' => 'Are you sure you want to delete your account?',
			'profile.settings.personalization' => 'Personalization',
			'profile.settings.language' => 'Language',
			'profile.settings.appearance.title' => 'Appearance',
			'profile.settings.appearance.light' => 'Light',
			'profile.settings.appearance.dark' => 'Dark',
			'profile.settings.appearance.system' => 'System',
			'profile.settings.timezone' => 'Choose timezone',
			'profile.settings.dateTime' => 'Date and time',
			'profile.settings.widgets' => 'Widgets',
			_ => null,
		};
	}
}
