#import <Cephei/HBPreferences.h>
#import <Foundation/Foundation.h>
#import <CoreFoundation/CoreFoundation.h>
#import <UIKit/UIKit.h>
#import <notify.h>
#import <PeterDev/libpddokdo.h>

//NSDateComponents* components = [cal components:NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute|NSWeekdayCalendarUnit fromDate:date];


#define kIdentifier @"com.wrp1002.truedate"
#define kSettingsChangedNotification (CFStringRef)@"com.wrp1002.truedate/ReloadPrefs"
#define kSettingsPath @"/var/mobile/Library/Preferences/com.wrp1002.truedate.plist"

//	Tweak enabled
bool enabled = true;

int mode = 0;

//	Enables hooking into function that calendar icon uses. May cause changes elsewhere too
bool calendarEnabled = false;

//	Enables hooking into function that returns string of formatted date. Causes changes on lock screen, notification center, status bar clock, etc
bool dateEnabled = true;

//	Time where the day will change to the "correct" day
int rolloverHour = 0;

//	Time after sunset when date will rollover
int sunsetOffset = 0;

//	Display string format of date before formatting takes place
bool debugMode = false;

bool springboardReady = false;

//	Old code used to retrieve values from preferences. Respring needed
/*
bool GetPrefsBool(NSString *key) {
	return [[[NSDictionary dictionaryWithContentsOfFile:kSettingsPath] valueForKey:key] boolValue];
}

int GetPrefsInt(NSString *key) {
	return [[[NSDictionary dictionaryWithContentsOfFile:kSettingsPath] valueForKey:key] integerValue];
}
*/



//	Returns current hour in 24hr time
long GetHour() {
	NSDate *date = [NSDate date];
	NSCalendar *cal = [NSCalendar currentCalendar];
	NSDateComponents* components = [cal components:NSCalendarUnitHour|NSCalendarUnitMinute|NSWeekdayCalendarUnit fromDate:date];

	long hour = [components hour];

	return hour;
}

//	Returns current minute
long GetMinute() {
	NSDate *date = [NSDate date];
	NSCalendar *cal = [NSCalendar currentCalendar];
	NSDateComponents* components = [cal components:NSCalendarUnitMinute fromDate:date];

	long minute = [components minute];

	return minute;
}

//	Returns current weekday 1-7 starting with Sunday
long GetWeekday() {
	NSDate *date = [NSDate date];
	NSCalendar *cal = [NSCalendar currentCalendar];
	NSDateComponents* components = [cal components:NSCalendarUnitWeekday fromDate:date];

	long weekday = [components weekday];

	return weekday;
}

//	Returns previous weekday 1-7 starting with Sunday
long GetPreviousWeekday() {
	NSDate *now = [NSDate date];
	NSDate *date = [now dateByAddingTimeInterval:-24*60*60];

	if (calendarEnabled)
		date = now;

	NSCalendar *cal = [NSCalendar currentCalendar];
	NSDateComponents* components = [cal components:NSCalendarUnitWeekday fromDate:date];

	long weekday = [components weekday];

	return weekday;
}

//	Returns previous weekday 1-7 starting with Sunday
long GetNextWeekday() {
	NSDate *now = [NSDate date];
	NSDate *date = [now dateByAddingTimeInterval:24*60*60];

	if (calendarEnabled)
		date = now;

	NSCalendar *cal = [NSCalendar currentCalendar];
	NSDateComponents* components = [cal components:NSCalendarUnitWeekday fromDate:date];

	long weekday = [components weekday];

	return weekday;
}

//	Returns current day of month
long GetDay() {
	NSDate *date = [NSDate date];
	NSCalendar *cal = [NSCalendar currentCalendar];
	NSDateComponents* components = [cal components:NSCalendarUnitDay fromDate:date];

	long day = [components day];

	return day;
}

//	Calculate and return the date from yesterday
long GetPreviousDay() {
	NSDate *now = [NSDate date];
	NSDate *date = [now dateByAddingTimeInterval:-24*60*60];

	NSCalendar *cal = [NSCalendar currentCalendar];
	NSDateComponents* components = [cal components:NSCalendarUnitDay fromDate:date];

	long day = [components day];

	return day;
}

//	Calculate and return the date from tomorrow
long GetNextDay() {
	NSDate *now = [NSDate date];
	NSDate *date = [now dateByAddingTimeInterval:24*60*60];

	NSCalendar *cal = [NSCalendar currentCalendar];
	NSDateComponents* components = [cal components:NSCalendarUnitDay fromDate:date];

	long day = [components day];

	return day;
}

long GetSunsetHour() {
	[[PDDokdo sharedInstance] refreshWeatherData];
	NSDate *sunset = [[PDDokdo sharedInstance] sunset];

	NSCalendar *cal = [NSCalendar currentCalendar];
	NSDateComponents* components = [cal components:NSCalendarUnitHour|NSCalendarUnitMinute fromDate:sunset];

	long hour = [components hour];
	long minute = [components minute];
	if (minute > 30 && hour < 23)
		hour += 1;

	return hour;
}

//	Used to determine if the date should stay the same after specified time
bool ShouldRollover(int targetHour) {
	return (GetHour() >= targetHour);
}

//	Shows an alert box. Used for debugging
void ShowAlert(NSString *msg) {
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert"
	message:msg
	delegate:nil
	cancelButtonTitle:@"Cool!"
	otherButtonTitles:nil];
	[alert show];
}

NSString *ReplaceWithRegex(NSString *str, NSString *newStr, NSString *pattern) {
	@try {
		NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:nil];
		NSString *modifiedString = [regex stringByReplacingMatchesInString:str options:0 range:NSMakeRange(0, [str length]) withTemplate:newStr];

		return modifiedString;
	}

	@catch ( NSException *e ) {
		return str;
	}
}


%hook SpringBoard

	//	Called when springboard is finished launching
	-(void)applicationDidFinishLaunching:(id)application {
		%orig;

		#pragma clang diagnostic push
		#pragma clang diagnostic ignored "-Wdeprecated-declarations"
	

		//bool active = GetPrefsBool(@"kActive");
		//rolloverHour = GetPrefsInt(@"kTime");
		long sunsetHour = GetSunsetHour();
		springboardReady = true;

		NSString *msg = [NSString stringWithFormat:@"Active: %s  Time:%i  Sunset:%li", enabled ? "true" : "false", rolloverHour, sunsetHour];
		ShowAlert(msg);
		
	}

%end

/*
%hook NSDateComponents
	-(long long)weekday {
		long weekday = %orig();

		if (!enabled || !calendarEnabled)
			return weekday;

		if (!ShouldRollover()) {
			weekday--;
			if (weekday < 1)
				weekday += 7;
		}

		return weekday;
	}

	/*-(long long)day {
		long day = %orig();

		if (!enabled || !calendarEnabled)
			return day;

		if (!ShouldRollover()) {
			day--;
			if (day < 1)
				day += 7;
		}

		return day;
	}
%end*/


/*
%hook NSDate
	+(id)date {
		if (!enabled || !calendarEnabled)
			return %orig();

		NSDate *date = %orig();
		NSDate *yesterday = [date dateByAddingTimeInterval:-24*60*60];

		return yesterday;
	}
%end
*/

%hook NSDateFormatter

	-(id)stringFromDate:(id)arg1 {
		if (!enabled || !dateEnabled) {
			return %orig(arg1);
		}

		long weekdayIndex = GetWeekday() - 1;
		long day = GetDay(); 

		if (mode == 0) {
			weekdayIndex = (ShouldRollover(rolloverHour) ? GetWeekday() : GetPreviousWeekday()) - 1;
			day = ShouldRollover(rolloverHour) ? GetDay() : GetPreviousDay();
		}
		else if (mode == 1) {
			long sunsetHour = GetSunsetHour();
			weekdayIndex = (ShouldRollover(sunsetHour + sunsetOffset) ? GetNextWeekday() : GetWeekday()) - 1;
			day = ShouldRollover(sunsetHour + sunsetOffset) ? GetNextDay() : GetDay();
		}

		NSString *dayStr = [NSString stringWithFormat:@"%li",day];
		
		NSString *format = [self dateFormat];
		if (debugMode)
			return format;


		NSString *formatTmp = [format stringByReplacingOccurrencesOfString:@"E" withString:@"$"];
		formatTmp = [formatTmp stringByReplacingOccurrencesOfString:@"d" withString:@"#"];
		[self setDateFormat:formatTmp];

		NSString *formattedDate = %orig(arg1);
		[self setDateFormat:format];

		int weekdayLength  = 0;
		for (int i = 0; i < formattedDate.length; i++) {
			if ([formattedDate characterAtIndex:i] == '$')
				weekdayLength++;
		}

		NSString *weekday;

		//if (weekdayLength <= 2) weekday = [self veryShortWeekdaySymbols][weekdayNum];
		if (weekdayLength <= 3)
			weekday = [self shortWeekdaySymbols][weekdayIndex];
		else
			weekday = [self weekdaySymbols][weekdayIndex];


		//NSString *result = [formattedDate stringByReplacingOccurrencesOfString:@"$" withString:weekday];
		//result = [result stringByReplacingOccurrencesOfString:@"#" withString:dayStr];

		NSString *result = ReplaceWithRegex(formattedDate, weekday, @"\\$+");
		result = ReplaceWithRegex(result, dayStr, @"#+");

		return result;
	}

%end


//	Called whenever any preferences are changed to update variables
static void reloadPrefs() {
	//if (springboardReady) ShowAlert(@"Prefs changed!");

	CFPreferencesAppSynchronize((CFStringRef)kIdentifier);

	NSDictionary *prefs = nil;
	if ([NSHomeDirectory() isEqualToString:@"/var/mobile"]) {
		CFArrayRef keyList = CFPreferencesCopyKeyList((CFStringRef)kIdentifier, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
		if (keyList != nil) {
			prefs = (NSDictionary *)CFBridgingRelease(CFPreferencesCopyMultiple(keyList, (CFStringRef)kIdentifier, kCFPreferencesCurrentUser, kCFPreferencesAnyHost));
			if (prefs == nil)
				prefs = [NSDictionary dictionary];
			CFRelease(keyList);
		}
	} else {
		prefs = [NSDictionary dictionaryWithContentsOfFile:kSettingsPath];
	}

	enabled = [prefs objectForKey:@"kEnabled"] ? [(NSNumber *)[prefs objectForKey:@"kEnabled"] boolValue] : enabled;
	calendarEnabled = [prefs objectForKey:@"kCalendar"] ? [(NSNumber *)[prefs objectForKey:@"kCalendar"] boolValue] : calendarEnabled;
	dateEnabled = [prefs objectForKey:@"kLockScreen"] ? [(NSNumber *)[prefs objectForKey:@"kLockScreen"] boolValue] : dateEnabled;
	rolloverHour = [prefs objectForKey:@"kTime"] ? [(NSNumber *)[prefs objectForKey:@"kTime"] intValue] : rolloverHour;
	sunsetOffset = [prefs objectForKey:@"kSunsetTime"] ? [(NSNumber *)[prefs objectForKey:@"kSunsetTime"] intValue] : sunsetOffset;
	mode = [prefs objectForKey:@"kMode"] ? [(NSNumber *)[prefs objectForKey:@"kMode"] intValue] : mode;
	debugMode = [prefs objectForKey:@"kDebug"] ? [(NSNumber *)[prefs objectForKey:@"kDebug"] boolValue] : debugMode;
}


%ctor {
	reloadPrefs();
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)reloadPrefs, kSettingsChangedNotification, NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
}