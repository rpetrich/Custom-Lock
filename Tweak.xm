#import <UIKit/UIKit.h>

@interface TPLCDTextView : UIView { }
-(void)setText:(id)text;
-(void)setTextColor:(id)color;
@end

static NSString *timeLabelText;
static NSInteger timeLabelColor;
static NSString *dateLabelText;
static NSInteger dateLabelColor;
static BOOL clockActive;
static BOOL dateActive;

static UIColor *ColorForIndex(NSInteger colorNumber) {
	switch (colorNumber) {
		case 0:
			return [UIColor redColor];
		case 1:
			return [UIColor blueColor];
		case 2:
			return [UIColor greenColor];
		case 3:
			return [UIColor blackColor];
		case 4:
			return [UIColor purpleColor];
		case 5:
			return [UIColor whiteColor];
		case 6:
			return [UIColor orangeColor];
		default:
			return nil;
	}
}



%hook SBAwayDateView
-(void)updateClock {
	%orig;
	if(clockActive) {
		TPLCDTextView *timeLabel = MSHookIvar<TPLCDTextView *>(self, "_timeLabel");
		[timeLabel setText:timeLabelText];
		[timeLabel setTextColor: ColorForIndex(timeLabelColor)];
	}
}


-(void)updateLabels {
	%orig;
	if(dateActive) {
		TPLCDTextView *dateLabel = MSHookIvar<TPLCDTextView *>(self, "_titleLabel");
		[dateLabel setText:dateLabelText];
		[dateLabel setTextColor: ColorForIndex(dateLabelColor)];		
	}
}


%end

static void LoadSettings() { 
	NSDictionary *prefrences = [NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/com.legendcoders.customlock.plist"];
	clockActive = [[prefrences objectForKey:@"clockEnable"] boolValue];
	dateActive = [[prefrences objectForKey:@"dateEnabled"] boolValue];
	[timeLabelText release];
	timeLabelText = [[prefrences objectForKey:@"timeLabelKey"] copy];
	timeLabelColor	= [[prefrences valueForKey:@"timeLabelColorKey"] integerValue];
	[dateLabelText release];
	dateLabelText = [[prefrences objectForKey:@"dateLabelKey"] copy];
	dateLabelColor =  [[prefrences valueForKey:@"dateLabelColorKey"] integerValue];
}

static void SettingsChanged(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
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