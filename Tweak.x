#import <Cephei/HBPreferences.h>
#import <Foundation/Foundation.h>
#import <CoreFoundation/CoreFoundation.h>
#import <UIKit/UIKit.h>
#import <notify.h>

//NSDateComponents* components = [cal components:NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute|NSWeekdayCalendarUnit fromDate:date];


#define kIdentifier @"com.wrp1002.truedate"
#define kSettingsChangedNotification (CFStringRef)@"com.wrp1002.truedate/ReloadPrefs"
#define kSettingsPath @"/var/mobile/Library/Preferences/com.wrp1002.truedate.plist"

//	Tweak enabled
bool enabled = false;

//	Enables hooking into function that calendar icon uses. May cause changes elsewhere too
bool calendarEnabled = false;

//	Enables hooking into function that returns string of formatted date. Causes changes on lock screen, notification center, status bar clock, etc
bool dateEnabled = false;

//	Time where the day will change to the "correct" day
int rolloverHour = 0;


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

//	Returns current weekday 0-6 starting with Sunday
long GetWeekday() {
	NSDate *date = [NSDate date];
	NSCalendar *cal = [NSCalendar currentCalendar];
	NSDateComponents* components = [cal components:NSWeekdayCalendarUnit fromDate:date];

	long weekday = [components weekday];

	return weekday;
}

//	Returns current day of month
long GetDay() {
	NSDate *date = [NSDate date];
	NSCalendar *cal = [NSCalendar currentCalendar];
	NSDateComponents* components = [cal components:NSDayCalendarUnit fromDate:date];

	long day = [components day];

	return day;
}

//	Used to determine if the date should stay the same after specified time
bool ShouldRollover() {
	return (GetHour() >= rolloverHour);
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


%hook SpringBoard

	//	Called when springboard is finished launching
	-(void)applicationDidFinishLaunching:(id)application {
		%orig;

		#pragma clang diagnostic push
		#pragma clang diagnostic ignored "-Wdeprecated-declarations"
	

		//bool active = GetPrefsBool(@"kActive");
		//rolloverHour = GetPrefsInt(@"kTime");
		springboardReady = true;

		NSString *msg = [NSString stringWithFormat:@"Active: %s  Time:%i", enabled ? "true" : "false", rolloverHour];

		ShowAlert(msg);
		
	}

%end

%hook NSDateComponents
	-(long long)weekday {
		long day = %orig();

		if (!enabled)
			return day;

		if (!ShouldRollover()) {
			day--;
			if (day < 0)
				day += 7;
		}

		return day;
	}
%end

%hook NSDateFormatter

	-(id)stringFromDate:(id)arg1 {
		if (!enabled) {
			return %orig(arg1);
		}

		long weekdayNum = GetWeekday() - 1;
		
		NSString *format = [self dateFormat];
		[self setDateFormat:[format stringByReplacingOccurrencesOfString:@"E" withString:@"$"]];

		NSString *formattedDate = %orig(arg1);
		[self setDateFormat:format];

		int weekdayLength  = 0;
		for (int i = 0; i < formattedDate.length; i++) {
			if ([formattedDate characterAtIndex:i] == '$')
				weekdayLength++;
		}

		NSString *weekday;

		//if (weekdayLength <= 2)
		//	weekday = [self veryShortWeekdaySymbols][weekdayNum];
		if (weekdayLength <= 3)
			weekday = [self shortWeekdaySymbols][weekdayNum];
		else
			weekday = [self weekdaySymbols][weekdayNum];

		NSString *result = [formattedDate stringByReplacingOccurrencesOfString:@"$" withString:weekday];

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
}


%ctor {
	reloadPrefs();
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)reloadPrefs, kSettingsChangedNotification, NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
}