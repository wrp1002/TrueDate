#import <Cephei/HBPreferences.h>
#import <Foundation/Foundation.h>
#import <CoreFoundation/CoreFoundation.h>
#import <UIKit/UIKit.h>
#import <notify.h>
#import <PeterDev/libpddokdo.h>

#define kIdentifier @"com.wrp1002.truedate"
#define kSettingsChangedNotification (CFStringRef)@"com.wrp1002.truedate/ReloadPrefs"
#define kSettingsPath @"/var/mobile/Library/Preferences/com.wrp1002.truedate.plist"

//	Tweak enabled
bool enabled = true;

//	Hour or sunset
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


const int sunsetUpdateRate = 7*24*60*60;	//	Once a week
NSDate *nextSunsetUpdate;					//	Next date when the sunset time should be updated
long currentSunsetTime = 0;					//	Current hour when the sun sets

//	Old code used to retrieve values from preferences. Respring needed
/*
bool GetPrefsBool(NSString *key) {
	return [[[NSDictionary dictionaryWithContentsOfFile:kSettingsPath] valueForKey:key] boolValue];
}

int GetPrefsInt(NSString *key) {
	return [[[NSDictionary dictionaryWithContentsOfFile:kSettingsPath] valueForKey:key] integerValue];
}
*/


//	=========================== Debugging stuff ===========================

NSString *LogTweakName = @"TrueDate";
bool springboardReady = false;

UIWindow* GetKeyWindow() {
    UIWindow        *foundWindow = nil;
    NSArray         *windows = [[UIApplication sharedApplication]windows];
    for (UIWindow   *window in windows) {
        if (window.isKeyWindow) {
            foundWindow = window;
            break;
        }
    }
    return foundWindow;
}

//	Shows an alert box. Used for debugging 
void ShowAlert(NSString *msg, NSString *title) {
	if (!springboardReady) return;

	UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:title
                                 message:msg
                                 preferredStyle:UIAlertControllerStyleAlert];

    //Add Buttons
    UIAlertAction* dismissButton = [UIAlertAction
                                actionWithTitle:@"Cool!"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action) {
                                    //Handle dismiss button action here
									
                                }];

    //Add your buttons to alert controller
    [alert addAction:dismissButton];

    [GetKeyWindow().rootViewController presentViewController:alert animated:YES completion:nil];
}

//	Show log with tweak name as prefix for easy grep
void Log(NSString *msg) {
	NSLog(@"%@: %@", LogTweakName, msg);
}

//	Log exception info
void LogException(NSException *e) {
	NSLog(@"%@: NSException caught", LogTweakName);
	NSLog(@"%@: Name:%@", LogTweakName, e.name);
	NSLog(@"%@: Reason:%@", LogTweakName, e.reason);
	//ShowAlert(@"TVLock Crash Avoided!", @"Alert");
}


//	=========================== Functions ===========================

//	Returns current hour in 24hr time
long GetHour() {
	NSDate *date = [NSDate date];
	NSCalendar *cal = [NSCalendar currentCalendar];
	NSDateComponents* components = [cal components:NSCalendarUnitHour fromDate:date];

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

bool ShouldUpdateWeatherDate() {
	NSDate *now = [NSDate date];

	NSComparisonResult result = [now compare:nextSunsetUpdate];

	if (result == NSOrderedDescending)
		return true;
	
	return false;
}

void UpdateSunsetDate() {
	NSDate *now = [NSDate date];
	nextSunsetUpdate = [now dateByAddingTimeInterval:sunsetUpdateRate];
}

long GetSunsetHour() {
	if (!ShouldUpdateWeatherDate()) {
		return currentSunsetTime;
	}
	UpdateSunsetDate();

	[[PDDokdo sharedInstance] refreshWeatherData];
	NSDate *sunset = [[PDDokdo sharedInstance] sunset];

	NSCalendar *cal = [NSCalendar currentCalendar];
	NSDateComponents* components = [cal components:NSCalendarUnitHour|NSCalendarUnitMinute fromDate:sunset];

	currentSunsetTime = [components hour];
	long minute = [components minute];
	if (minute > 30 && currentSunsetTime < 23)
		currentSunsetTime += 1;

	return currentSunsetTime;
}

//	Used to determine if the date should stay the same after specified time
bool ShouldRollover(int targetHour) {
	return (GetHour() >= targetHour);
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
		//long sunsetHour = GetSunsetHour();
		springboardReady = true;

		//NSString *msg = [NSString stringWithFormat:@"Active: %s  Time:%i  CurrentHr:%i  Sunset:%li", enabled ? "true" : "false", rolloverHour, GetHour(), GetSunsetHour()];
		//ShowAlert(msg);
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

		Log([NSString stringWithFormat:@"enabled:%d  dateEnabled:%d", enabled, dateEnabled]);

		Log([NSString stringWithFormat:@"weekday:%ld", GetWeekday()]);
		Log([NSString stringWithFormat:@"Day:%ld", GetDay()]);
		Log([NSString stringWithFormat:@"shouldRollover:%d", ShouldRollover(rolloverHour)]);


		long weekdayIndex = GetWeekday() - 1;
		long day = GetDay();


		if (mode == 0) {
			Log(@"Mode 0");
			weekdayIndex = (ShouldRollover(rolloverHour) ? GetWeekday() : GetPreviousWeekday()) - 1;
			day = ShouldRollover(rolloverHour) ? GetDay() : GetPreviousDay();
		}
		else if (mode == 1) {
			Log(@"Mode 1");
			long sunsetHour = GetSunsetHour();
			weekdayIndex = (ShouldRollover(sunsetHour + sunsetOffset) ? GetNextWeekday() : GetWeekday()) - 1;
			day = ShouldRollover(sunsetHour + sunsetOffset) ? GetNextDay() : GetDay();
		}

		Log([NSString stringWithFormat:@"Weekday:%ld", GetWeekday()]);
		Log([NSString stringWithFormat:@"newWeekday:%ld", weekdayIndex]);

		NSString *dayStr = [NSString stringWithFormat:@"%li",day];

		Log([NSString stringWithFormat:@"dayStr:%@", dayStr]);
		
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


		Log([NSString stringWithFormat:@"weekdayStr:%@", weekday]);


		//NSString *result = [formattedDate stringByReplacingOccurrencesOfString:@"$" withString:weekday];
		//result = [result stringByReplacingOccurrencesOfString:@"#" withString:dayStr];

		NSString *result = ReplaceWithRegex(formattedDate, weekday, @"\\$+");
		result = ReplaceWithRegex(result, dayStr, @"#+");

		return result;
	}

%end


//	Called whenever any preferences are changed to update variables
static void reloadPrefs() {
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

	nextSunsetUpdate = [NSDate date];
	Log(@"Init");
}