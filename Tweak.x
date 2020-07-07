
//NSDateComponents* components = [cal components:NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute|NSWeekdayCalendarUnit fromDate:date];


#define PLIST_PATH @"/var/mobile/Library/Preferences/com.wrp1002.truedateprefs.plist"

bool GetPrefsBool(NSString *key) {
	return [[[NSDictionary dictionaryWithContentsOfFile:PLIST_PATH] valueForKey:key] boolValue];
}

int GetPrefsInt(NSString *key) {
	return [[[NSDictionary dictionaryWithContentsOfFile:PLIST_PATH] valueForKey:key] integerValue];
}

//	Time where the day will change to the "correct" day
int rolloverHour = 5;
int rolloverMinute = 0;



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

long GetDay() {
	NSDate *date = [NSDate date];
	NSCalendar *cal = [NSCalendar currentCalendar];
	NSDateComponents* components = [cal components:NSDayCalendarUnit fromDate:date];

	long day = [components day];

	return day;
}

bool ShouldRollover() {
	return (GetHour() >= rolloverHour && GetMinute() >= rolloverMinute);
}

void ShowAlert(NSString *msg) {
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert"
	message:msg
	delegate:nil
	cancelButtonTitle:@"Cool!"
	otherButtonTitles:nil];
	[alert show];
}


%hook SpringBoard

	-(void)applicationDidFinishLaunching:(id)application {
		%orig;

		#pragma clang diagnostic push
		#pragma clang diagnostic ignored "-Wdeprecated-declarations"
	

		bool active = GetPrefsBool(@"kActive");
		rolloverHour = GetPrefsInt(@"kTime");

		NSString *msg = [NSString stringWithFormat:@"Active: %s  Time:%i", active ? "true" : "false", rolloverHour];

		ShowAlert(msg);
	}

%end

%hook NSDateComponents
	-(long long)weekday {
		long day = %orig();

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

