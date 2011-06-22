@interface TPLCDTextView : UIView { }
-(void)setText:(id)text;
-(void)setTextColor:(id)color;
-(id)grabPrefColor:(NSInteger)colorNumber;
@end

NSDictionary *prefrences;
NSString *timeLabelText;
NSInteger timeLabelColor;
NSString *dateLabelText;
NSInteger dateLabelColor;
BOOL clockActive;
BOOL dateActive;

%hook SBAwayDateView
-(void)updateClock {
	%orig;
	if(clockActive) {
		TPLCDTextView *timeLabel = MSHookIvar<TPLCDTextView *>(self, "_timeLabel");
		[timeLabel setText:timeLabelText];
		[timeLabel setTextColor: [self grabPrefColor:timeLabelColor]];
	}
}


-(void)updateLabels {
	%orig;
	if(dateActive) {
		TPLCDTextView *dateLabel = MSHookIvar<TPLCDTextView *>(self, "_titleLabel");
		[dateLabel setText:dateLabelText];
		[dateLabel setTextColor: [self grabPrefColor:dateLabelColor]];		
	}
}


%new(v@:i)
-(id)grabPrefColor:(NSInteger)colorNumber {
	NSLog(@"Hello");
	UIColor *returnColor = [UIColor alloc];
	switch (colorNumber) {
		case 0:
		returnColor = [UIColor redColor];
		break;
		case 1:
		returnColor = [UIColor blueColor];
		break;
		case 2:
		returnColor = [UIColor greenColor];
		break;
		case 3:
		returnColor = [UIColor blackColor];
		break;
		case 4:
	returnColor = [UIColor purpleColor];
		break;
		case 5:
		returnColor = [UIColor whiteColor];
		break;
		case 6:
		returnColor = [UIColor orangeColor];
		break;
		default:
		break;
	}
	return (returnColor);
	[returnColor release];
}

%end

static void LoadSettings() { 
	prefrences = [[NSDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.legendcoders.customlock.plist"]; 
	clockActive = (BOOL)[[prefrences objectForKey:@"clockEnable"] boolValue];
	dateActive = (BOOL)[[prefrences objectForKey:@"dateEnabled"] boolValue];
	timeLabelText = [[NSString alloc] initWithString:[prefrences objectForKey:@"timeLabelKey" ]];
	timeLabelColor	= [((NSNumber*)[prefrences valueForKey:@"timeLabelColorKey"]) integerValue];
	dateLabelText = [[NSString alloc] initWithString:[prefrences objectForKey:@"dateLabelKey"]];
	dateLabelColor =  [((NSNumber*)[prefrences valueForKey:@"dateLabelColorKey"]) integerValue];
	[prefrences release];
}

static void SettingsChanged(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
	[timeLabelText release];
	[dateLabelText release];
	LoadSettings();
	}

%ctor
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	%init;
	LoadSettings();
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, SettingsChanged, CFSTR("com.legendcoders.customlock/updated"), NULL, CFNotificationSuspensionBehaviorCoalesce);
	[pool drain];
}