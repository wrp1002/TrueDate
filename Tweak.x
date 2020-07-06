
//NSDateComponents* components = [cal components:NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute|NSWeekdayCalendarUnit fromDate:date];

//	Time where the day will change to the "correct" day
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


/*%hook SpringBoard

	-(void)applicationDidFinishLaunching:(id)application {
		%orig;

		#pragma clang diagnostic push
		#pragma clang diagnostic ignored "-Wdeprecated-declarations"
		
		//NSDate *date = [NSDate date];
		//NSCalendar *cal = [NSCalendar currentCalendar];
		//NSDateComponents* components = [cal components:NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute|NSWeekdayCalendarUnit fromDate:date];

		//long day = [components day];
		long weekday = GetWeekday();
		long hour = GetHour();
		//long min = [components minute];

		NSString *msg = [NSString stringWithFormat:@"Weekday:%ld  Hour:%ld", weekday, (long)hour];

		ShowAlert(msg);
	}

%end*/

%hook NSDateComponents
	-(long long)weekday {
		long day = %orig();

		if (!ShouldRollover()) {
			day -= 1;
			if (day < 0)
				day += 7;
		}

		return day;
	}
%end

%hook NSDateFormatter

	-(id)stringFromDate:(id)arg1 {
		long weekdayNum = GetWeekday();
		
		NSString *format = [self dateFormat];
		[self setDateFormat:[format stringByReplacingOccurrencesOfString:@"E" withString:@"$"]];

		NSString *formattedDate = %orig(arg1);
		[self setDateFormat:format];

		NSString *weekday = [self shortWeekdaySymbols][weekdayNum];

		NSString *result = [formattedDate stringByReplacingOccurrencesOfString:@"$" withString:weekday];

		return result;
	}

%end