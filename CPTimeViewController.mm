
//#define TESTING

#import "common.h"
#import "defines.h"

#import "CPTimeViewController.h"

#import "CPTimeViewControllerItems.h"

@implementation CPTimeViewController

- (NSArray*) tableItems
{
	return nil;
}


- (void) dealloc
{
	[dict release];
	[super dealloc];
}

- (void) setDict: (NSMutableDictionary*) newDict
{
	[dict release];
	dict = [newDict retain];
}

- (void) loadView
{
	[self setTitle: RPLOC(@"Start & End Time")];
	
	/*
	UIView* view = [[UIView alloc] initWithFrame: initialFrame];
	[view setBackgroundColor: [UIColor redColor]];
	[view setAutoresizingMask: UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
	self.view = view;
	[view release];
	*/
//	if([self respondsToSelector: @selector(tableItems)])
	{
		GETCLASS(EKPickerTableView);
		UIView* view = [[$EKPickerTableView alloc] initWithFrame: initialFrame];
		self.view = view;
		
		//[view release];
		
		_table = [view tableView];
		[_table setDataSource: self];
		[_table setDelegate: self];
		//[_table reloadData];
		
		_datePicker = [view datePicker];
		NSType(_datePicker);
		
		//[_datePicker setTimeZone: [NSTimeZone timeZoneWithAbbreviation: @"GMT"]];
		
		[_datePicker setDatePickerMode: UIDatePickerModeTime];
		[_datePicker setMinuteInterval: 5];
		
		//NSDateComponents *comps = [[NSDateComponents alloc] init];
		//[comps setHour: 0];
		//[comps setMinute: 0];

		//[_datePicker setDate: [[NSCalendar currentCalendar] dateFromComponents: comps]];
		
		[_datePicker addTarget: self
					action: @selector(datePickerChanged:)
					forControlEvents: UIControlEventValueChanged];
					
					
		//[_datePicker setDelegate: self];
		
		//[comps release];
		
	}
	
	
	[self refreshToolbar];
	[self updateViewsForOrientation: [UIApp statusBarOrientation]];
}



- (void) refreshSwitch
{
	SelLog();
	
	UIColor* blackColor = [UIColor blackColor];
	UIColor* detailColor = [UIColor colorWithRed: 0.22 green: 0.33 blue: 0.53 alpha: 1];
	UIColor* lightGrayColor = [UIColor lightGrayColor];
	
	
	bool allDay = [[dict objectForKey: @"all_day"] boolValue];
	
	UITableViewCell* cell0 = [_table cellForRowAtIndexPath: [NSIndexPath indexPathForRow: 0 inSection: 0]];
	UITableViewCell* cell1 = [_table cellForRowAtIndexPath: [NSIndexPath indexPathForRow: 1 inSection: 0]];
	
	[[cell0 textLabel] setTextColor: allDay ? lightGrayColor : blackColor];
	[[cell1 textLabel] setTextColor: allDay ? lightGrayColor : blackColor];
	
	[[cell0 detailTextLabel] setTextColor: allDay ? lightGrayColor : detailColor];
	
	[[cell1 twoPartTextLabel] setTextColor: allDay ? lightGrayColor : detailColor];
	
	[cell0 setUserInteractionEnabled: !allDay];
	[cell1 setUserInteractionEnabled: !allDay];
	
	[_datePicker setUserInteractionEnabled: !allDay];
	
	
	[_table selectRowAtIndexPath: [NSIndexPath indexPathForRow: allDay ? -1 : lastRow inSection: allDay ? -1 : 0] animated: NO scrollPosition: UITableViewScrollPositionNone];	
	
	UITableViewCell* cell2 = [_table cellForRowAtIndexPath: [NSIndexPath indexPathForRow: 2 inSection: 0]];
	[(UISwitch*)[cell2 accessoryView] setOn: allDay animated: NO];

}

- (void) refreshDatePicker
{
	SelLog();
	
	int time;
	switch(lastRow)
	{
	case 0:
		time = [[dict objectForKey: @"start_time"] intValue];
		break;
	case 1:
		time = [[dict objectForKey: @"end_time"] intValue];
		break;
	case 2:
		return;
	}
	
	NSDateComponents *comps = [[NSDateComponents alloc] init];
	
	int hr = ((unsigned)time % 86400) / 3600;
	int min = ((unsigned)time % 3600) / 60;
	
//	[comps setEra: 2000];
	[comps setYear: 2000];
	[comps setMonth: 1];
	[comps setDay: 1];
	
	[comps setHour: hr];
	[comps setMinute: min];
	
	//
	[_datePicker setDate: [[NSCalendar currentCalendar] dateFromComponents: comps] animated: NO];
//	[MSHookIvar<id>(_datePicker, "_pickerView") _updateDateOrTime];
}


- (void) updateTimes
{
	SelLog();
	[_table reloadData];
	[self refreshSwitch];

}

- (NSIndexPath*) tableView: (UITableView*) table willSelectRowAtIndexPath: (NSIndexPath*) indexPath
{
	SelLog();
	
	if([indexPath row]>1)
	{
		return [NSIndexPath indexPathForRow: lastRow inSection: 0];
	}
	return indexPath;
}

- (void) datePickerChanged: (id) dc
{
	SelLog();
	
	NSDateComponents *comps = [[NSCalendar currentCalendar] components: NSHourCalendarUnit | NSMinuteCalendarUnit fromDate: [_datePicker date]];

	NSLog(@"date is %@", [[_datePicker date] description]);

	int time = [comps hour] * 3600 + [comps minute] * 60;
	
	[dict setObject: [NSNumber numberWithInt: time] forKey: lastRow ? @"end_time" : @"start_time"];
	[self updateTimes];
}


- (void) viewWillAppear: (BOOL) animated
{
	[super viewWillAppear: animated];

	[self refreshDatePicker];
	[self updateTimes];
	[self refreshSwitch];
	
//	[_table selectRowAtIndexPath: [NSIndexPath indexPathForRow: 0 inSection: 0] animated: NO scrollPosition: UITableViewScrollPositionNone];
}

- (void) tableView: (UITableView*) table didSelectRowAtIndexPath: (NSIndexPath*) indexPath
{
	int row = [indexPath row];
	int section = [indexPath section];
	if(section==0 && (unsigned) row < 2)
		lastRow = row;
	
	[self refreshDatePicker];
	
}



- (void) switchChanged: (UISwitch*) switchObj
{
	[dict setObject: [NSNumber numberWithBool: [switchObj isOn]] forKey: @"all_day"];
	
	[self refreshSwitch];
}

- (int) numberOfSectionsInTableView: (UITableView*) table
{
	return 1;
}

- (int) tableView: (UITableView*) table numberOfRowsInSection: (int) section
{
	return 3;
}

- (UITableViewCell*) tableView: (UITableView*) table cellForRowAtIndexPath: (NSIndexPath*) indexPath
{
	UITableViewCell* cell = nil;
	
	
	int startT = [[dict objectForKey: @"start_time"] intValue];
	int endT = [[dict objectForKey: @"end_time"] intValue];
	
	switch([indexPath row])
	{
	case 0:
		{
			cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleValue1 reuseIdentifier: NO];
			
			UILabel* textLabel = [cell textLabel];
			UILabel* detailTextLabel = [cell detailTextLabel];
			
			[textLabel setText: @"Starts"];
			{
				NSDateFormatter *dateFormatter=  [[NSDateFormatter alloc] init];
				[dateFormatter setDateStyle: NSDateFormatterNoStyle];
				[dateFormatter setTimeStyle: NSDateFormatterShortStyle];
				[dateFormatter setTimeZone: [NSTimeZone timeZoneWithAbbreviation: @"GMT"]];
				NSString *tStr = [dateFormatter stringFromDate: [NSDate dateWithTimeIntervalSinceReferenceDate: startT]];
				[dateFormatter release];

				[detailTextLabel setText: tStr];
			}

			
		}
		break;
	case 1:
		{
			//PreferencesTwoPartValueCell
			
			cell = [[PreferencesTwoPartValueCell alloc] initWithStyle: UITableViewCellStyleValue1 reuseIdentifier: NO];
			[[cell textLabel] setText: @"Ends"];
			id twoPartTextLabel = [cell twoPartTextLabel];
			
			{
				NSDateFormatter *dateFormatter=  [[NSDateFormatter alloc] init];
				[dateFormatter setDateStyle: NSDateFormatterNoStyle];
				[dateFormatter setTimeStyle: NSDateFormatterShortStyle];
				[dateFormatter setTimeZone: [NSTimeZone timeZoneWithAbbreviation: @"GMT"]];
				NSString *tStr = [dateFormatter stringFromDate: [NSDate dateWithTimeIntervalSinceReferenceDate: endT]];
				[dateFormatter release];


				PreferencesTwoPartValueCell *cell = [_table cellForRowAtIndexPath: [NSIndexPath indexPathForRow: 1 inSection: 0]];
				if(endT >= startT || !endT || !startT)
				{
					[twoPartTextLabel setTextPart1: tStr part2: nil];

				}
				else
				{
					[twoPartTextLabel setTextPart1: RPLOC(@"(Overnight)") part2: tStr];
				}
			}
		}
		break;
	case 2:
		{
			cell = [[UITableViewCell alloc] initWithStyle: (UITableViewCellStyleDefault) reuseIdentifier: NO];
			[[cell textLabel] setText: @"All day"];

			UISwitch *switchObj = [[UISwitch alloc] initWithFrame: (CGRect){{0.0f,0.0f},{0.0f,0.0f}}];//CGRectMake(1.0, 1.0, 20.0, 20.0)];
			switchObj.on =  NO;//[(CPStyleEditorViewController*) delegate ringerSwitch];
			[switchObj addTarget: self
						action: @selector(switchChanged:)
						forControlEvents: UIControlEventValueChanged];
			cell.accessoryView = switchObj;
			[cell setSelectionStyle: UITableViewCellSelectionStyleNone];
			[switchObj release];
		}
		break;
	}
	return [cell autorelease];
}

- (void) willAnimateRotationToInterfaceOrientation: (UIInterfaceOrientation) interfaceOrientation duration: (NSTimeInterval) duration
{
	[super willAnimateRotationToInterfaceOrientation: interfaceOrientation duration: duration];
	[_table setScrollEnabled: (interfaceOrientation > (UIInterfaceOrientation) 1)];
}

@end