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
		  _meta = meta ?? TranslationMetadata(
		    locale: AppLocale.en,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <en>.
	final TranslationMetadata<AppLocale, Translations> _meta;
	@override TranslationMetadata<AppLocale, Translations> get $meta => _meta;

	/// Access flat map
	dynamic operator[](String key) => _meta.getTranslation(key);

	late final Translations _root = this; // ignore: unused_field

	Translations $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => Translations(meta: meta ?? this.$meta);

	// Translations
	late final Translations$common$en common = Translations$common$en.internal(_root);
	late final Translations$welcome$en welcome = Translations$welcome$en.internal(_root);
	late final Translations$auth$en auth = Translations$auth$en.internal(_root);
	late final Translations$vault$en vault = Translations$vault$en.internal(_root);
	late final Translations$notes$en notes = Translations$notes$en.internal(_root);
	late final Translations$trust$en trust = Translations$trust$en.internal(_root);
	late final Translations$home$en home = Translations$home$en.internal(_root);
	late final Translations$calendar$en calendar = Translations$calendar$en.internal(_root);
	late final Translations$note$en note = Translations$note$en.internal(_root);
	late final Translations$project$en project = Translations$project$en.internal(_root);
	late final Translations$profile$en profile = Translations$profile$en.internal(_root);
}

// Path: common
class Translations$common$en {
	Translations$common$en.internal(this._root);

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

	/// en: 'That note is no longer available.'
	String get notFound => 'That note is no longer available.';

	/// en: 'Delete'
	String get delete => 'Delete';

	/// en: 'Error'
	String get errorTitle => 'Error';

	/// en: 'Loading...'
	String get loading => 'Loading...';

	/// en: 'Try again'
	String get retry => 'Try again';

	/// en: 'Ink could not read your saved session. Your data is safe — try again.'
	String get sessionLoadFailed => 'Ink could not read your saved session. Your data is safe — try again.';

	late final Translations$common$errors$en errors = Translations$common$errors$en.internal(_root);
}

// Path: welcome
class Translations$welcome$en {
	Translations$welcome$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Your notes are encrypted on this device. Ink's servers can't read them.'
	String get thesis => 'Your notes are encrypted on this device. Ink\'s servers can\'t read them.';

	/// en: 'Create local storage'
	String get createLocalStorage => 'Create local storage';

	/// en: 'Already have an account?'
	String get haveAccount => 'Already have an account?';
}

// Path: auth
class Translations$auth$en {
	Translations$auth$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Your plans under reliable protection'
	String get tagline => 'Your plans under reliable protection';

	/// en: 'Choose how to use'
	String get chooseMethod => 'Choose how to use';

	late final Translations$auth$login$en login = Translations$auth$login$en.internal(_root);
	late final Translations$auth$register$en register = Translations$auth$register$en.internal(_root);
	late final Translations$auth$verify$en verify = Translations$auth$verify$en.internal(_root);
	late final Translations$auth$errors$en errors = Translations$auth$errors$en.internal(_root);
	late final Translations$auth$form$en form = Translations$auth$form$en.internal(_root);
}

// Path: vault
class Translations$vault$en {
	Translations$vault$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$vault$fatal$en fatal = Translations$vault$fatal$en.internal(_root);
	late final Translations$vault$methods$en methods = Translations$vault$methods$en.internal(_root);
	late final Translations$vault$setup$en setup = Translations$vault$setup$en.internal(_root);
	late final Translations$vault$unlock$en unlock = Translations$vault$unlock$en.internal(_root);
}

// Path: notes
class Translations$notes$en {
	Translations$notes$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'No notes yet'
	String get emptyTitle => 'No notes yet';

	/// en: 'Everything you write is encrypted on this device first.'
	String get emptyBody => 'Everything you write is encrypted on this device first.';

	/// en: 'Nothing here'
	String get emptyByFilterTitle => 'Nothing here';

	/// en: 'No notes match this view. Try another notebook or lens.'
	String get emptyByFilterBody => 'No notes match this view. Try another notebook or lens.';

	/// en: 'Could not load your notes'
	String get errorTitle => 'Could not load your notes';

	/// en: 'Your notes are still on this device. Try again.'
	String get errorBody => 'Your notes are still on this device. Try again.';

	/// en: 'Try again'
	String get retry => 'Try again';

	/// en: 'Offline. Your notes are safe on this device and will sync when you reconnect.'
	String get offline => 'Offline. Your notes are safe on this device and will sync when you reconnect.';
}

// Path: trust
class Translations$trust$en {
	Translations$trust$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'On device'
	String get onDevice => 'On device';

	/// en: 'Encrypted on this device only. Syncing is available on Ink Pro.'
	String get onDeviceMessage => 'Encrypted on this device only. Syncing is available on Ink Pro.';

	/// en: 'Pending'
	String get queued => 'Pending';

	/// en: 'Changes are encrypted and waiting to sync.'
	String get queuedMessage => 'Changes are encrypted and waiting to sync.';

	/// en: 'Syncing'
	String get syncing => 'Syncing';

	/// en: 'Encrypting and sending your changes.'
	String get syncingMessage => 'Encrypting and sending your changes.';

	/// en: 'Synced'
	String get synced => 'Synced';

	/// en: 'Every note is encrypted and up to date on your other devices.'
	String get syncedMessage => 'Every note is encrypted and up to date on your other devices.';

	/// en: 'Sync failed'
	String get failed => 'Sync failed';

	/// en: 'Your notes are safe on this device. Syncing will retry.'
	String get failedMessage => 'Your notes are safe on this device. Syncing will retry.';

	/// en: 'Conflict'
	String get conflicted => 'Conflict';

	/// en: 'A note changed on two devices. Nothing has been overwritten.'
	String get conflictedMessage => 'A note changed on two devices. Nothing has been overwritten.';
}

// Path: home
class Translations$home$en {
	Translations$home$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'All notes'
	String get all => 'All notes';

	/// en: 'Today'
	String get today => 'Today';

	/// en: 'Completed'
	String get completed => 'Completed';
}

// Path: calendar
class Translations$calendar$en {
	Translations$calendar$en.internal(this._root);

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

	late final Translations$calendar$modes$en modes = Translations$calendar$modes$en.internal(_root);
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
class Translations$note$en {
	Translations$note$en.internal(this._root);

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

	/// en: 'Save'
	String get save => 'Save';

	/// en: 'Cancel'
	String get cancel => 'Cancel';

	/// en: 'That note is no longer available.'
	String get notFound => 'That note is no longer available.';

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

	late final Translations$note$delete$en delete = Translations$note$delete$en.internal(_root);
	late final Translations$note$priority$en priority = Translations$note$priority$en.internal(_root);
	late final Translations$note$reminder$en reminder = Translations$note$reminder$en.internal(_root);
}

// Path: project
class Translations$project$en {
	Translations$project$en.internal(this._root);

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

	late final Translations$project$delete$en delete = Translations$project$delete$en.internal(_root);
	late final Translations$project$form$en form = Translations$project$form$en.internal(_root);
}

// Path: profile
class Translations$profile$en {
	Translations$profile$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Profile'
	String get title => 'Profile';

	late final Translations$profile$personal$en personal = Translations$profile$personal$en.internal(_root);
	late final Translations$profile$account$en account = Translations$profile$account$en.internal(_root);
	late final Translations$profile$settings$en settings = Translations$profile$settings$en.internal(_root);
}

// Path: common.errors
class Translations$common$errors$en {
	Translations$common$errors$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Unable to reach the server. Check your connection.'
	String get network => 'Unable to reach the server. Check your connection.';

	/// en: 'The server took too long to respond. Try again.'
	String get timeout => 'The server took too long to respond. Try again.';

	/// en: 'Something went wrong. Please try again.'
	String get unknown => 'Something went wrong. Please try again.';
}

// Path: auth.login
class Translations$auth$login$en {
	Translations$auth$login$en.internal(this._root);

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
class Translations$auth$register$en {
	Translations$auth$register$en.internal(this._root);

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
class Translations$auth$verify$en {
	Translations$auth$verify$en.internal(this._root);

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

// Path: auth.errors
class Translations$auth$errors$en {
	Translations$auth$errors$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Invalid email or password.'
	String get invalidCredentials => 'Invalid email or password.';

	/// en: 'An account with this email already exists.'
	String get emailAlreadyInUse => 'An account with this email already exists.';

	/// en: 'Password does not meet the security requirements.'
	String get invalidPassword => 'Password does not meet the security requirements.';
}

// Path: auth.form
class Translations$auth$form$en {
	Translations$auth$form$en.internal(this._root);

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
class Translations$vault$fatal$en {
	Translations$vault$fatal$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'App crashed fatally'
	String get title => 'App crashed fatally';

	/// en: 'Failed to load keys both locally and remotely'
	String get subtitle => 'Failed to load keys both locally and remotely';

	/// en: 'Reset the app state (debug only)'
	String get devReset => 'Reset the app state (debug only)';

	/// en: 'Close and reopen Ink. Your data on this device is untouched. If the app keeps failing, reinstall it from your app store.'
	String get releaseHint => 'Close and reopen Ink. Your data on this device is untouched. If the app keeps failing, reinstall it from your app store.';
}

// Path: vault.methods
class Translations$vault$methods$en {
	Translations$vault$methods$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Security Method'
	String get title => 'Security Method';

	/// en: 'Choose a quick login method. A secret phrase will be mandatory in the next step.'
	String get subtitle => 'Choose a quick login method. A secret phrase will be mandatory in the next step.';

	late final Translations$vault$methods$pin$en pin = Translations$vault$methods$pin$en.internal(_root);
	late final Translations$vault$methods$pattern$en pattern = Translations$vault$methods$pattern$en.internal(_root);
	late final Translations$vault$methods$seed$en seed = Translations$vault$methods$seed$en.internal(_root);
	late final Translations$vault$methods$word$en word = Translations$vault$methods$word$en.internal(_root);
	late final Translations$vault$methods$verification$en verification = Translations$vault$methods$verification$en.internal(_root);
	late final Translations$vault$methods$options$en options = Translations$vault$methods$options$en.internal(_root);
}

// Path: vault.setup
class Translations$vault$setup$en {
	Translations$vault$setup$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$vault$setup$pin$en pin = Translations$vault$setup$pin$en.internal(_root);
	late final Translations$vault$setup$pattern$en pattern = Translations$vault$setup$pattern$en.internal(_root);
	late final Translations$vault$setup$word$en word = Translations$vault$setup$word$en.internal(_root);
	late final Translations$vault$setup$seed$en seed = Translations$vault$setup$seed$en.internal(_root);
	late final Translations$vault$setup$seedVerify$en seedVerify = Translations$vault$setup$seedVerify$en.internal(_root);
}

// Path: vault.unlock
class Translations$vault$unlock$en {
	Translations$vault$unlock$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$vault$unlock$pin$en pin = Translations$vault$unlock$pin$en.internal(_root);
	late final Translations$vault$unlock$pattern$en pattern = Translations$vault$unlock$pattern$en.internal(_root);
	late final Translations$vault$unlock$word$en word = Translations$vault$unlock$word$en.internal(_root);
	late final Translations$vault$unlock$seed$en seed = Translations$vault$unlock$seed$en.internal(_root);

	/// en: 'Too many attempts. Try again in ${seconds}s.'
	String throttled({required Object seconds}) => 'Too many attempts. Try again in ${seconds}s.';
}

// Path: calendar.modes
class Translations$calendar$modes$en {
	Translations$calendar$modes$en.internal(this._root);

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
class Translations$note$delete$en {
	Translations$note$delete$en.internal(this._root);

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
class Translations$note$priority$en {
	Translations$note$priority$en.internal(this._root);

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
class Translations$note$reminder$en {
	Translations$note$reminder$en.internal(this._root);

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
class Translations$project$delete$en {
	Translations$project$delete$en.internal(this._root);

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
class Translations$project$form$en {
	Translations$project$form$en.internal(this._root);

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
class Translations$profile$personal$en {
	Translations$profile$personal$en.internal(this._root);

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
class Translations$profile$account$en {
	Translations$profile$account$en.internal(this._root);

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
class Translations$profile$settings$en {
	Translations$profile$settings$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Personalization'
	String get personalization => 'Personalization';

	/// en: 'Language'
	String get language => 'Language';

	late final Translations$profile$settings$appearance$en appearance = Translations$profile$settings$appearance$en.internal(_root);

	/// en: 'Choose timezone'
	String get timezone => 'Choose timezone';

	/// en: 'Date and time'
	String get dateTime => 'Date and time';

	/// en: 'Widgets'
	String get widgets => 'Widgets';
}

// Path: vault.methods.pin
class Translations$vault$methods$pin$en {
	Translations$vault$methods$pin$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'PIN-code'
	String get title => 'PIN-code';

	/// en: 'Quick access via 4-digit code'
	String get subtitle => 'Quick access via 4-digit code';

	late final Translations$vault$methods$pin$keyPad$en keyPad = Translations$vault$methods$pin$keyPad$en.internal(_root);
}

// Path: vault.methods.pattern
class Translations$vault$methods$pattern$en {
	Translations$vault$methods$pattern$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Pattern Lock'
	String get title => 'Pattern Lock';

	/// en: 'Protection with a unique gesture'
	String get subtitle => 'Protection with a unique gesture';
}

// Path: vault.methods.seed
class Translations$vault$methods$seed$en {
	Translations$vault$methods$seed$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Recovery Phrase'
	String get title => 'Recovery Phrase';

	/// en: 'Secure 12-words password'
	String get subtitle => 'Secure 12-words password';
}

// Path: vault.methods.word
class Translations$vault$methods$word$en {
	Translations$vault$methods$word$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Association Word'
	String get title => 'Association Word';

	/// en: 'Password with a hint for recovery'
	String get subtitle => 'Password with a hint for recovery';
}

// Path: vault.methods.verification
class Translations$vault$methods$verification$en {
	Translations$vault$methods$verification$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Identity Verification'
	String get title => 'Identity Verification';

	/// en: 'Choose an unlock method to verify'
	String get subtitle => 'Choose an unlock method to verify';
}

// Path: vault.methods.options
class Translations$vault$methods$options$en {
	Translations$vault$methods$options$en.internal(this._root);

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
class Translations$vault$setup$pin$en {
	Translations$vault$setup$pin$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Create PIN-code'
	String get title => 'Create PIN-code';

	/// en: 'For quick access to your plans'
	String get description => 'For quick access to your plans';
}

// Path: vault.setup.pattern
class Translations$vault$setup$pattern$en {
	Translations$vault$setup$pattern$en.internal(this._root);

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
class Translations$vault$setup$word$en {
	Translations$vault$setup$word$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Think of an association'
	String get title => 'Think of\nan association';

	/// en: 'Word must be at least 6 characters (no spaces, digits or signs)'
	String get description => 'Word must be at least 6 characters (no spaces, digits or signs)';
}

// Path: vault.setup.seed
class Translations$vault$setup$seed$en {
	Translations$vault$setup$seed$en.internal(this._root);

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
class Translations$vault$setup$seedVerify$en {
	Translations$vault$setup$seedVerify$en.internal(this._root);

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
class Translations$vault$unlock$pin$en {
	Translations$vault$unlock$pin$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Enter PIN-code'
	String get title => 'Enter PIN-code';

	/// en: 'Enter your PIN-code to login'
	String get description => 'Enter your PIN-code to login';
}

// Path: vault.unlock.pattern
class Translations$vault$unlock$pattern$en {
	Translations$vault$unlock$pattern$en.internal(this._root);

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
class Translations$vault$unlock$word$en {
	Translations$vault$unlock$word$en.internal(this._root);

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
class Translations$vault$unlock$seed$en {
	Translations$vault$unlock$seed$en.internal(this._root);

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
class Translations$profile$settings$appearance$en {
	Translations$profile$settings$appearance$en.internal(this._root);

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
class Translations$vault$methods$pin$keyPad$en {
	Translations$vault$methods$pin$keyPad$en.internal(this._root);

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
			'common.notFound' => 'That note is no longer available.',
			'common.delete' => 'Delete',
			'common.errorTitle' => 'Error',
			'common.loading' => 'Loading...',
			'common.retry' => 'Try again',
			'common.sessionLoadFailed' => 'Ink could not read your saved session. Your data is safe — try again.',
			'common.errors.network' => 'Unable to reach the server. Check your connection.',
			'common.errors.timeout' => 'The server took too long to respond. Try again.',
			'common.errors.unknown' => 'Something went wrong. Please try again.',
			'welcome.thesis' => 'Your notes are encrypted on this device. Ink\'s servers can\'t read them.',
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
			'auth.errors.invalidCredentials' => 'Invalid email or password.',
			'auth.errors.emailAlreadyInUse' => 'An account with this email already exists.',
			'auth.errors.invalidPassword' => 'Password does not meet the security requirements.',
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
			'vault.fatal.devReset' => 'Reset the app state (debug only)',
			'vault.fatal.releaseHint' => 'Close and reopen Ink. Your data on this device is untouched. If the app keeps failing, reinstall it from your app store.',
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
			'notes.emptyTitle' => 'No notes yet',
			'notes.emptyBody' => 'Everything you write is encrypted on this device first.',
			'notes.emptyByFilterTitle' => 'Nothing here',
			'notes.emptyByFilterBody' => 'No notes match this view. Try another notebook or lens.',
			'notes.errorTitle' => 'Could not load your notes',
			'notes.errorBody' => 'Your notes are still on this device. Try again.',
			'notes.retry' => 'Try again',
			'notes.offline' => 'Offline. Your notes are safe on this device and will sync when you reconnect.',
			'trust.onDevice' => 'On device',
			'trust.onDeviceMessage' => 'Encrypted on this device only. Syncing is available on Ink Pro.',
			'trust.queued' => 'Pending',
			'trust.queuedMessage' => 'Changes are encrypted and waiting to sync.',
			'trust.syncing' => 'Syncing',
			'trust.syncingMessage' => 'Encrypting and sending your changes.',
			'trust.synced' => 'Synced',
			'trust.syncedMessage' => 'Every note is encrypted and up to date on your other devices.',
			'trust.failed' => 'Sync failed',
			'trust.failedMessage' => 'Your notes are safe on this device. Syncing will retry.',
			'trust.conflicted' => 'Conflict',
			'trust.conflictedMessage' => 'A note changed on two devices. Nothing has been overwritten.',
			'home.all' => 'All notes',
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
			'note.save' => 'Save',
			'note.cancel' => 'Cancel',
			'note.notFound' => 'That note is no longer available.',
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
