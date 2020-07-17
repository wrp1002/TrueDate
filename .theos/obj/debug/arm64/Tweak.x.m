#line 1 "Tweak.x"
#import <Cephei/HBPreferences.h>
#import <Foundation/Foundation.h>
#import <CoreFoundation/CoreFoundation.h>
#import <UIKit/UIKit.h>
#import <notify.h>




#define kIdentifier @"com.wrp1002.truedate"
#define kSettingsChangedNotification (CFStringRef)@"com.wrp1002.truedate/ReloadPrefs"
#define kSettingsPath @"/var/mobile/Library/Preferences/com.wrp1002.truedate.plist"


bool enabled = true;


bool calendarEnabled = false;


bool dateEnabled = true;


int rolloverHour = 0;


bool debugMode = false;

bool springboardReady = false;















long GetHour() {
	NSDate *date = [NSDate date];
	NSCalendar *cal = [NSCalendar currentCalendar];
	NSDateComponents* components = [cal components:NSCalendarUnitHour|NSCalendarUnitMinute|NSWeekdayCalendarUnit fromDate:date];

	long hour = [components hour];

	return hour;
}


long GetMinute() {
	NSDate *date = [NSDate date];
	NSCalendar *cal = [NSCalendar currentCalendar];
	NSDateComponents* components = [cal components:NSCalendarUnitMinute fromDate:date];

	long minute = [components minute];

	return minute;
}


long GetWeekday() {
	NSDate *date = [NSDate date];
	NSCalendar *cal = [NSCalendar currentCalendar];
	NSDateComponents* components = [cal components:NSWeekdayCalendarUnit fromDate:date];

	long weekday = [components weekday];

	return weekday;
}


long GetPreviousWeekday() {
	NSDate *now = [NSDate date];
	NSDate *date = [now dateByAddingTimeInterval:-24*60*60];

	if (calendarEnabled)
		date = now;

	NSCalendar *cal = [NSCalendar currentCalendar];
	NSDateComponents* components = [cal components:NSWeekdayCalendarUnit fromDate:date];

	long weekday = [components weekday];

	return weekday;
}


long GetDay() {
	NSDate *date = [NSDate date];
	NSCalendar *cal = [NSCalendar currentCalendar];
	NSDateComponents* components = [cal components:NSDayCalendarUnit fromDate:date];

	long day = [components day];

	return day;
}


long GetPreviousDay() {
	NSDate *now = [NSDate date];
	NSDate *date = [now dateByAddingTimeInterval:-24*60*60];

	NSCalendar *cal = [NSCalendar currentCalendar];
	NSDateComponents* components = [cal components:NSDayCalendarUnit fromDate:date];

	long day = [components day];

	return day;
}


bool ShouldRollover() {
	return (GetHour() >= rolloverHour);
}


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



#include <substrate.h>
#if defined(__clang__)
#if __has_feature(objc_arc)
#define _LOGOS_SELF_TYPE_NORMAL __unsafe_unretained
#define _LOGOS_SELF_TYPE_INIT __attribute__((ns_consumed))
#define _LOGOS_SELF_CONST const
#define _LOGOS_RETURN_RETAINED __attribute__((ns_returns_retained))
#else
#define _LOGOS_SELF_TYPE_NORMAL
#define _LOGOS_SELF_TYPE_INIT
#define _LOGOS_SELF_CONST
#define _LOGOS_RETURN_RETAINED
#endif
#else
#define _LOGOS_SELF_TYPE_NORMAL
#define _LOGOS_SELF_TYPE_INIT
#define _LOGOS_SELF_CONST
#define _LOGOS_RETURN_RETAINED
#endif

@class NSDateFormatter; @class SpringBoard; @class NSDateComponents; 
static void (*_logos_orig$_ungrouped$SpringBoard$applicationDidFinishLaunching$)(_LOGOS_SELF_TYPE_NORMAL SpringBoard* _LOGOS_SELF_CONST, SEL, id); static void _logos_method$_ungrouped$SpringBoard$applicationDidFinishLaunching$(_LOGOS_SELF_TYPE_NORMAL SpringBoard* _LOGOS_SELF_CONST, SEL, id); static long long (*_logos_orig$_ungrouped$NSDateComponents$weekday)(_LOGOS_SELF_TYPE_NORMAL NSDateComponents* _LOGOS_SELF_CONST, SEL); static long long _logos_method$_ungrouped$NSDateComponents$weekday(_LOGOS_SELF_TYPE_NORMAL NSDateComponents* _LOGOS_SELF_CONST, SEL); static id (*_logos_orig$_ungrouped$NSDateFormatter$stringFromDate$)(_LOGOS_SELF_TYPE_NORMAL NSDateFormatter* _LOGOS_SELF_CONST, SEL, id); static id _logos_method$_ungrouped$NSDateFormatter$stringFromDate$(_LOGOS_SELF_TYPE_NORMAL NSDateFormatter* _LOGOS_SELF_CONST, SEL, id); 

#line 146 "Tweak.x"


	
	static void _logos_method$_ungrouped$SpringBoard$applicationDidFinishLaunching$(_LOGOS_SELF_TYPE_NORMAL SpringBoard* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd, id application) {
		_logos_orig$_ungrouped$SpringBoard$applicationDidFinishLaunching$(self, _cmd, application);

		#pragma clang diagnostic push
		#pragma clang diagnostic ignored "-Wdeprecated-declarations"
	

		
		
		springboardReady = true;

		
		
		
	}





	static long long _logos_method$_ungrouped$NSDateComponents$weekday(_LOGOS_SELF_TYPE_NORMAL NSDateComponents* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd) {
		long weekday = _logos_orig$_ungrouped$NSDateComponents$weekday(self, _cmd);

		if (!enabled || !calendarEnabled)
			return weekday;

		if (!ShouldRollover()) {
			weekday--;
			if (weekday < 1)
				weekday += 7;
		}

		return weekday;
	}

	
































	static id _logos_method$_ungrouped$NSDateFormatter$stringFromDate$(_LOGOS_SELF_TYPE_NORMAL NSDateFormatter* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd, id arg1) {
		if (!enabled || !dateEnabled) {
			return _logos_orig$_ungrouped$NSDateFormatter$stringFromDate$(self, _cmd, arg1);
		}

		long weekdayIndex = (ShouldRollover() ? GetWeekday() : GetPreviousWeekday()) - 1;
		long day = ShouldRollover() ? GetDay() : GetPreviousDay();

		NSString *dayStr = [NSString stringWithFormat:@"%li",day];
		
		NSString *format = [self dateFormat];
		if (debugMode)
			return format;


		NSString *formatTmp = [format stringByReplacingOccurrencesOfString:@"E" withString:@"$"];
		formatTmp = [formatTmp stringByReplacingOccurrencesOfString:@"d" withString:@"#"];
		[self setDateFormat:formatTmp];

		NSString *formattedDate = _logos_orig$_ungrouped$NSDateFormatter$stringFromDate$(self, _cmd, arg1);
		[self setDateFormat:format];

		int weekdayLength  = 0;
		for (int i = 0; i < formattedDate.length; i++) {
			if ([formattedDate characterAtIndex:i] == '$')
				weekdayLength++;
		}

		NSString *weekday;

		
		if (weekdayLength <= 3)
			weekday = [self shortWeekdaySymbols][weekdayIndex];
		else
			weekday = [self weekdaySymbols][weekdayIndex];


		
		

		NSString *result = ReplaceWithRegex(formattedDate, weekday, @"\\$+");
		result = ReplaceWithRegex(result, dayStr, @"#+");

		return result;
	}





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
	debugMode = [prefs objectForKey:@"kDebug"] ? [(NSNumber *)[prefs objectForKey:@"kDebug"] boolValue] : debugMode;
}


static __attribute__((constructor)) void _logosLocalCtor_a6d5bc98(int __unused argc, char __unused **argv, char __unused **envp) {
	reloadPrefs();
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)reloadPrefs, kSettingsChangedNotification, NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
}
static __attribute__((constructor)) void _logosLocalInit() {
{Class _logos_class$_ungrouped$SpringBoard = objc_getClass("SpringBoard"); { MSHookMessageEx(_logos_class$_ungrouped$SpringBoard, @selector(applicationDidFinishLaunching:), (IMP)&_logos_method$_ungrouped$SpringBoard$applicationDidFinishLaunching$, (IMP*)&_logos_orig$_ungrouped$SpringBoard$applicationDidFinishLaunching$);}Class _logos_class$_ungrouped$NSDateComponents = objc_getClass("NSDateComponents"); { MSHookMessageEx(_logos_class$_ungrouped$NSDateComponents, @selector(weekday), (IMP)&_logos_method$_ungrouped$NSDateComponents$weekday, (IMP*)&_logos_orig$_ungrouped$NSDateComponents$weekday);}Class _logos_class$_ungrouped$NSDateFormatter = objc_getClass("NSDateFormatter"); { MSHookMessageEx(_logos_class$_ungrouped$NSDateFormatter, @selector(stringFromDate:), (IMP)&_logos_method$_ungrouped$NSDateFormatter$stringFromDate$, (IMP*)&_logos_orig$_ungrouped$NSDateFormatter$stringFromDate$);}} }
#line 297 "Tweak.x"
