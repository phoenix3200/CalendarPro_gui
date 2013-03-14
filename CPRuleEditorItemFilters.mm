
//#define TESTING

#import "common.h"
#import "defines.h"

#import "classes.h"

#import "CPRuleEditorItemFilters.h"

#import "CPFilterViewController.h"

#import "dbmanager.h"

//#import "CPRuleManagerViewController.h"

NSString *rfFilter[] =
{
	@"Only when",
	@"Except when"
};

NSString *rfCategory[] =
{
	@"Title",
	@"Location",
	@"Notes",
	@"Calendar",
	@"Availability"
};

NSString *rfMatch[] =
{
	@"contains",
	@"is",
	@"begins with",
	@"ends with"
};

NSString *rfAvailability[] =
{
	@"Busy",
	@"Free",
	@"Tentative",
	@"Out of office"
};


@implementation CPRuleEditorItemFilters

- (void) setDelegate: (CPCustomTableController*) newDelegate
{
	delegate = newDelegate;	
}

- (void) dealloc
{
	[filters release];
	[super dealloc];
}

- (int) subitemCount
{
	if(filters)
	{
		return [filters count] + 1;
	}
	return 1;
}

- (void) setFilterDict: (NSMutableArray*) newFilters
{
	[filters release];
	filters = [newFilters retain];
}


- (CPCustomTableController*) viewControllerWithFrame: (CGRect) frame forSubitemAtIndex: (int) index
{
	SelLog();
	CPCustomTableController* vc = [[CPFilterViewController alloc] initWithFrame: frame];
	
	if(index < [filters count])
	{
	//	[vc startWithFilter: [filters objectAtIndex: index] forRow: index];
		[vc startWithFilter: [[filters objectAtIndex: index] retain] forRow: index];
	}
	else
	{
		[vc startWithFilter: nil forRow: -1];
	}
	
	[vc setItemDelegate: self];
	return [vc autorelease];
}

- (BOOL) canDiscloseRow: (int) row
{
	SelLog();
	return YES;
}

- (float) heightForRow: (int) row
{
	SelLog();
	if(row < [filters count])
	{
		return PreferencesTableDoubleRowHeight;
	}
	return 40.0f;
}

- (BOOL) canDeleteRow: (int) row
{
	return row < [filters count];
}


- (void) saveFilter: (NSDictionary*) filter forRow: (int) row
{
	SelLog();
	if(row < [filters count])
	{
		[filters removeObjectAtIndex: row];
		[filters insertObject: filter atIndex: row];
	}
	else
	{
		[filters addObject: filter];
	}
	
}

- (BOOL) deleteRow: (int) row
{
	if(row < [filters count])
	{
		[filters removeObjectAtIndex: row];
		return YES;
	}
	return NO;
}


- (UITableViewCell*) cellForRow: (int) row
{
	UITableViewCell* cell = nil;
	SRPINIT();
	if(row < [filters count])
	{
		cell = [[PreferencesDoubleTwoPartValueCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier: NO];
		
		NSMutableDictionary *dict = [filters objectAtIndex: row];
		
				int category = [[dict objectForKey: @"category"] intValue];
				int match = [[dict objectForKey: @"match"] intValue];
		NSString* textLabel = [NSString stringWithFormat: @"%@ %@ %@", SRPLOC(rfFilter[[[dict objectForKey: @"filter"] intValue]]),
																 		SRPLOC(rfCategory[category]),
																 		SRPLOC(rfMatch[
																				((category >= 3) ? 1 : match)
																		]) ];
		NSString* textLabel2 = nil;

		if(category<3)
		{
			textLabel2 = [dict objectForKey: @"string"];
		}
		else
		{
			if(category==3)
			{
				NSArray *calendars = AllCalendars();
				NSMutableArray *calnames = [calendars objectAtIndex: 0];
				NSMutableArray *calrows = [calendars objectAtIndex: 1];
				int idx = [calrows indexOfObject: [dict objectForKey: @"match"]];
				if(idx<[calrows count])
				{
					textLabel2 = [calnames objectAtIndex: idx];
				}
			}
			else
			{
				textLabel2 = SRPLOC(rfAvailability[match]);
			}
		}
		[[cell textLabel] setText: textLabel];
		UILabel* label2 = [cell textLabel2];
		[label2 setText: textLabel2];
		[label2 setFont: [UIFont systemFontOfSize: 17.0f]];
		[label2 setTextColor: [UIColor colorWithRed: 0.22 green: 0.33 blue: 0.53 alpha: 1]];
	}
	else
	{
		cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleValue1 reuseIdentifier: NO];
		[[cell textLabel] setText: @"Add Filter"];
	}
	[cell setAccessoryType: UITableViewCellAccessoryDisclosureIndicator];
	
	return [cell autorelease];
}


@end