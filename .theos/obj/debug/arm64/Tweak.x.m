#line 1 "Tweak.x"




NSInteger rolloverHour = 6;

long GetHour() {
	NSDate *date = [NSDate date];
	NSCalendar *cal = [NSCalendar currentCalendar];
	NSDateComponents* components = [cal components:NSCalendarUnitHour|NSCalendarUnitMinute|NSWeekdayCalendarUnit fromDate:date];

	long hour = [components hour];

	return hour;
}

long GetWeekday() {
	NSDate *date = [NSDate date];
	NSCalendar *cal = [NSCalendar currentCalendar];
	NSDateComponents* components = [cal components:NSWeekdayCalendarUnit fromDate:date];

	long weekday = [components weekday];

	weekday--;

	return weekday;
}

long GetDay() {
	NSDate *date = [NSDate date];
	NSCalendar *cal = [NSCalendar currentCalendar];
	NSDateComponents* components = [cal components:NSDayCalendarUnit fromDate:date];

	long day = [components day];

	return day;
}

bool ShouldRollover() {
	return (GetHour() > rolloverHour);
}

void ShowAlert(NSString *msg) {
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert"
	message:msg
	delegate:nil
	cancelButtonTitle:@"Cool!"
	otherButtonTitles:nil];
	[alert show];
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

@class NSDateFormatter; @class NSDateComponents; 
static long long (*_logos_orig$_ungrouped$NSDateComponents$weekday)(_LOGOS_SELF_TYPE_NORMAL NSDateComponents* _LOGOS_SELF_CONST, SEL); static long long _logos_method$_ungrouped$NSDateComponents$weekday(_LOGOS_SELF_TYPE_NORMAL NSDateComponents* _LOGOS_SELF_CONST, SEL); static id (*_logos_orig$_ungrouped$NSDateFormatter$stringFromDate$)(_LOGOS_SELF_TYPE_NORMAL NSDateFormatter* _LOGOS_SELF_CONST, SEL, id); static id _logos_method$_ungrouped$NSDateFormatter$stringFromDate$(_LOGOS_SELF_TYPE_NORMAL NSDateFormatter* _LOGOS_SELF_CONST, SEL, id); 

#line 77 "Tweak.x"

	static long long _logos_method$_ungrouped$NSDateComponents$weekday(_LOGOS_SELF_TYPE_NORMAL NSDateComponents* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd) {
		long day = _logos_orig$_ungrouped$NSDateComponents$weekday(self, _cmd);

		if (!ShouldRollover()) {
			day -= 1;
			if (day < 0)
				day += 7;
		}

		return day;
	}




	static id _logos_method$_ungrouped$NSDateFormatter$stringFromDate$(_LOGOS_SELF_TYPE_NORMAL NSDateFormatter* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd, id arg1) {
		long weekdayNum = GetWeekday();
		
		NSString *format = [self dateFormat];
		[self setDateFormat:[format stringByReplacingOccurrencesOfString:@"E" withString:@"$"]];

		NSString *formattedDate = _logos_orig$_ungrouped$NSDateFormatter$stringFromDate$(self, _cmd, arg1);
		[self setDateFormat:format];

		NSString *weekday = [self shortWeekdaySymbols][weekdayNum];

		NSString *result = [formattedDate stringByReplacingOccurrencesOfString:@"$" withString:weekday];

		return result;
	}


static __attribute__((constructor)) void _logosLocalInit() {
{Class _logos_class$_ungrouped$NSDateComponents = objc_getClass("NSDateComponents"); { MSHookMessageEx(_logos_class$_ungrouped$NSDateComponents, @selector(weekday), (IMP)&_logos_method$_ungrouped$NSDateComponents$weekday, (IMP*)&_logos_orig$_ungrouped$NSDateComponents$weekday);}Class _logos_class$_ungrouped$NSDateFormatter = objc_getClass("NSDateFormatter"); { MSHookMessageEx(_logos_class$_ungrouped$NSDateFormatter, @selector(stringFromDate:), (IMP)&_logos_method$_ungrouped$NSDateFormatter$stringFromDate$, (IMP*)&_logos_orig$_ungrouped$NSDateFormatter$stringFromDate$);}} }
#line 110 "Tweak.x"
