
//#define TESTING

#import "common.h"
#import "defines.h"

#import "classes.h"

#import "CPRuleEditorItemDate.h"

#import "CPSelectionViewController.h"

#import "CPTimeViewController.h"

#import "CPWeekViewController.h"

NSString *rtMatch[] = {
	@"During",
	@"Overlapping",
	@"Contained",
	@"When No Event",
	@"Ignore"
};

NSString *rtOverride[] = {
	@"Default Events",
	@"Any Event",
	@"No Event"
};


@implementation CPRuleEditorItemDate

- (void) setDelegate: (CPCustomTableController*) newDelegate
{
	delegate = newDelegate;	
}

- (void) dealloc
{
	[dict release];
	[super dealloc];
}

- (int) subitemCount
{
	return 4;
}

- (void) setRuleDict: (NSMutableDictionary*) newDict
{
	[dict release];
	dict = [newDict retain];
}


- (float) heightForRow: (int) row
{
	SelLog();
	if(row==0)
	{
		return PreferencesTableDoubleRowHeight;
	}
	return 40.0f;
}

- (CPCustomTableController*) viewControllerWithFrame: (CGRect) frame forSubitemAtIndex: (int) index
{
	SRPINIT();
	if(index<2)
	{
		if(index==0)
		{
			CPTimeViewController* vc = [[CPTimeViewController alloc] initWithFrame: frame];
			[vc setDict: dict];
			[vc setItemDelegate: self];
			return [vc autorelease];
		}
		else
		{
			CPTimeViewController* vc = [[CPWeekViewController alloc] initWithFrame: frame];
			[vc setSelection: [dict objectForKey: @"weekdays"]];
			[vc setItemDelegate: delegate];
			return [vc autorelease];
		}
		return nil;
		
	}
	else
	{
		NSString* title = nil;
		NSString* key = nil;
		NSArray* keys = nil;
		NSArray* vals = nil;
		if(index==2)
		{
			title = SRPLOC(@"Event Selection");
			keys = [NSArray arrayWithObjects: [NSNumber numberWithInt: 0], [NSNumber numberWithInt: 1], [NSNumber numberWithInt: 2], [NSNumber numberWithInt: 4], nil];
			vals = [NSArray arrayWithObjects: SRPLOC(rtMatch[0]), SRPLOC(rtMatch[1]), SRPLOC(rtMatch[2]), SRPLOC(rtMatch[4]), nil];
			key = @"match";
		}
		else
		{
			title = SRPLOC(@"Override Events");
			if([[dict objectForKey: @"match"] intValue]!=4)
			{
				keys = [NSArray arrayWithObjects: [NSNumber numberWithInt: 0], [NSNumber numberWithInt: 1], nil];
				vals = [NSArray arrayWithObjects: SRPLOC(rtOverride[0]), SRPLOC(rtOverride[1]), nil];
			}
			else
			{
				keys = [NSArray arrayWithObjects: [NSNumber numberWithInt: 2], [NSNumber numberWithInt: 0], [NSNumber numberWithInt: 1], nil];
				vals = [NSArray arrayWithObjects: SRPLOC(rtOverride[2]), SRPLOC(rtOverride[0]), SRPLOC(rtOverride[1]), nil];
			}
			key = @"override";
		}
		CPSelectionViewController* vc = [[CPSelectionViewController alloc] initWithFrame: frame];
		[vc setTitle: title
			identifier: key
			keys: keys
			vals: vals
			selection: [dict objectForKey:key]];
		[vc setItemDelegate: delegate];
		return [vc autorelease];
	}
}


- (BOOL) canDiscloseRow: (int) row
{
	SelLog();
	return YES;
}


- (UITableViewCell*) cellForRow: (int) row
{
	SRPINIT();
	
	UITableViewCell* cell = nil;
	switch(row)
	{
	case 0:
		{
			cell = [[PreferencesDoubleTwoPartValueCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier: NO];
			[[cell textLabel] setText: SRPLOC(@"Starts")];
			[[cell textLabel2] setText: SRPLOC(@"Ends")];
			
			if(![[dict objectForKey: @"all_day"] boolValue])
			{
				int _startT = [[dict objectForKey: @"start_time"] intValue];
				int _endT = [[dict objectForKey: @"end_time"] intValue];
				{
					int time = _startT;
					
					NSDateFormatter *dateFormatter=  [[NSDateFormatter alloc] init];
					[dateFormatter setDateStyle: NSDateFormatterNoStyle];
					[dateFormatter setTimeStyle: NSDateFormatterShortStyle];
					[dateFormatter setTimeZone: [NSTimeZone timeZoneWithAbbreviation: @"GMT"]];
					NSString *tStr = [dateFormatter stringFromDate: [NSDate dateWithTimeIntervalSinceReferenceDate: time]];
					[dateFormatter release];
					
					[[cell twoPartTextLabel] setTextPart1: tStr part2: nil];
				}

				{
					int time = _endT;

					NSDateFormatter *dateFormatter=  [[NSDateFormatter alloc] init];
					[dateFormatter setDateStyle: NSDateFormatterNoStyle];
					[dateFormatter setTimeStyle: NSDateFormatterShortStyle];
					[dateFormatter setTimeZone: [NSTimeZone timeZoneWithAbbreviation: @"GMT"]];
					NSString *tStr = [dateFormatter stringFromDate: [NSDate dateWithTimeIntervalSinceReferenceDate: time]];
					[dateFormatter release];

					if(_endT >= _startT)
					{
						[[cell twoPartTextLabel2] setTextPart1: tStr part2: nil];
					}
					else
					{
						[[cell twoPartTextLabel2] setTextPart1: SRPLOC(@"(Overnight)") part2: tStr];						
					}
				}
			}
			else
			{
				//[mainBundle localizedStringForKey: @"ALL_DAY_SWITCH_TITLE" value:@"" table:@"EventEditing"]
				[[cell twoPartTextLabel] setTextPart1: @"All day" part2: nil];
				[[cell twoPartTextLabel2] setTextPart1: nil part2: nil];
			}
		}
		break;
	case 1:
		{
			cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleValue1 reuseIdentifier: NO];
			[[cell textLabel] setText: SRPLOC(@"Days")];
			int days = [[dict objectForKey: @"weekdays"] intValue];

			NSString *desc = nil;
			if(days==0x7F)
			{
				desc = SRPLOC(@"Every Day");
			}
			else if(days==0x1F)
			{
				desc = SRPLOC(@"Weekdays");
			}
			else
			{
				NSString *rwSet2[] = 
				{
					@"Mon",
					@"Tue",
					@"Wed",
					@"Thu",
					@"Fri",
					@"Sat",
					@"Sun"
				};

				int offset = 7 - [[NSCalendar currentCalendar] firstWeekday];
				for(int i=0; i<7; i++, offset++)
				{
					if(offset>=7)
						offset=0;
					if(days & (1 << offset))
					{
						if(desc==nil)
							desc = SRPLOC(rwSet2[offset]);
						else {
							desc = [NSString stringWithFormat: @"%@ %@", desc, SRPLOC(rwSet2[offset])];
						}
					}
				}
			}
			[[cell detailTextLabel] setText: desc];
		}
		break;
	case 2:
		{
			cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleValue1 reuseIdentifier: NO];
			[[cell textLabel] setText: SRPLOC(@"Events")];
			[[cell detailTextLabel] setText: SRPLOC(rtMatch[[[dict objectForKey: @"match"] intValue]])];
		}
		break;
	case 3:
		{
			cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleValue1 reuseIdentifier: NO];
			[[cell textLabel] setText: SRPLOC(@"Override")];
			[[cell detailTextLabel] setText: SRPLOC(rtOverride[[[dict objectForKey: @"override"] intValue]])];
		}
		break;
	
	}
	if(cell)
		[cell setAccessoryType: UITableViewCellAccessoryDisclosureIndicator];
	
	return [cell autorelease];
}


@end