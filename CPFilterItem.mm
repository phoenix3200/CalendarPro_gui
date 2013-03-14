
//#define TESTING

#import "common.h"
#import "defines.h"

#import "classes.h"

#import "CPFilterItem.h"

#import "CPSelectionViewController.h"

#import "dbmanager.h"

NSString *rfiFilter[] =
{
	@"Only when",
	@"Except when"
};

NSString *rfiCategory[] =
{
	@"Title",
	@"Location",
	@"Notes",
	@"Calendar",
	@"Availability"
};

NSString *rfiMatch[] =
{
	@"contains",
	@"is",
	@"begins with",
	@"ends with"
};

NSString *rfiAvailability[] =
{
	@"Busy",
	@"Free",
	@"Tentative",
	@"Out of office"
};



@implementation CPFilterItem

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
	int category = [[dict objectForKey: @"category"] intValue];
	if(category<3)
	{
		return 4;
	}
	else
	{
		return 3;
	}
	
}

- (void) setDict: (NSMutableDictionary*) newDict
{
	[dict release];
	dict = [newDict retain];
}

- (CPCustomTableController*) viewControllerWithFrame: (CGRect) frame forSubitemAtIndex: (int) index
{
	SRPINIT();
	
	NSString* title = nil;
	NSString* key = nil;
	NSArray* keys = nil;
	NSArray* vals = nil;
	
	switch(index)
	{
	case 0:
		key = @"filter";
		vals = [NSArray arrayWithObjects: SRPLOC(rfiFilter[0]), SRPLOC(rfiFilter[1]), nil];
		keys = [NSArray arrayWithObjects: [NSNumber numberWithInt: 0], [NSNumber numberWithInt: 1], nil];
		title = SRPLOC(@"Filter");
		break;
	case 1:
		key = @"category";
		vals = [NSArray arrayWithObjects: SRPLOC(rfiCategory[0]), SRPLOC(rfiCategory[1]), SRPLOC(rfiCategory[2]), SRPLOC(rfiCategory[3]), SRPLOC(rfiCategory[4]), nil];
		keys = [NSArray arrayWithObjects: [NSNumber numberWithInt: 0], [NSNumber numberWithInt: 1], [NSNumber numberWithInt: 2], [NSNumber numberWithInt: 3], [NSNumber numberWithInt: 4], nil];
		title = SRPLOC(@"Criteria");
		break;
	case 2:
		int category = [[dict objectForKey: @"category"] intValue];
		key = @"match";
		if(category<3)
		{
			vals = [NSArray arrayWithObjects: SRPLOC(rfiMatch[0]), SRPLOC(rfiMatch[1]), SRPLOC(rfiMatch[2]), SRPLOC(rfiMatch[3]), nil];
			keys = [NSArray arrayWithObjects: [NSNumber numberWithInt: 0], [NSNumber numberWithInt: 1], [NSNumber numberWithInt: 2], [NSNumber numberWithInt: 3], nil];
			title = SRPLOC(@"Match");
		}
		else if(category==3)
		{
			NSArray *calendars = AllCalendars();
			vals = [AllCalendars() objectAtIndex: 0];
			keys = [AllCalendars() objectAtIndex: 1];
			title = SRPLOC(rfiCategory[3]);
		}
		else
		{
			vals = [NSArray arrayWithObjects: SRPLOC(rfiAvailability[0]), SRPLOC(rfiAvailability[1]), SRPLOC(rfiAvailability[2]), SRPLOC(rfiAvailability[3]), nil];
			keys = [NSArray arrayWithObjects: [NSNumber numberWithInt: 0], [NSNumber numberWithInt: 1], [NSNumber numberWithInt: 2], [NSNumber numberWithInt: 3], nil];
			title = SRPLOC(rfiCategory[4]);
		}
		break;
	}
	
	
	{
		
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
	return (row < 3) ? YES : NO;
}

- (void) textChanged: (UITextField*) textField
{
	[dict setValue: [textField text] forKey: @"string"];

}


- (UITableViewCell*) cellForRow: (int) row
{
	SRPINIT();
	
	UITableViewCell* cell = nil;
	switch(row)
	{
	case 0:
		{
			cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleValue1 reuseIdentifier: NO];
			[[cell textLabel] setText: SRPLOC(@"Filter")];
			[[cell detailTextLabel] setText: SRPLOC(rfiFilter[[[dict objectForKey: @"filter"] intValue]])];
		}
		break;
	case 1:
		{
			cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleValue1 reuseIdentifier: NO];
			[[cell textLabel] setText: SRPLOC(@"Criteria")];
			[[cell detailTextLabel] setText: SRPLOC(rfiCategory[[[dict objectForKey: @"category"] intValue]])];
		}
		break;
	case 2:
		{
			cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleValue1 reuseIdentifier: NO];
			
			int category = [[dict objectForKey: @"category"] intValue];
			if(category<3)
			{
				[[cell textLabel] setText: SRPLOC(@"Match")];
				[[cell detailTextLabel] setText: SRPLOC(rfiMatch[[[dict objectForKey: @"match"] intValue]])];
			}
			else
			{
				[[cell textLabel] setText: SRPLOC(@"is")];
				if(category==3)
				{
					NSArray *calendars = AllCalendars();
					NSMutableArray *calnames = [calendars objectAtIndex: 0];
					NSMutableArray *calrows = [calendars objectAtIndex: 1];
					int idx=[calrows indexOfObject: [dict objectForKey: @"match"]];
					if(idx>[calrows count])
					{
						[dict setObject:[calrows objectAtIndex: 0] forKey: @"match"];
						idx = 0;
					}

					[[cell detailTextLabel] setText: [calnames objectAtIndex: idx]];
				}
				else
				{
					[[cell detailTextLabel] setText: SRPLOC(rfiAvailability[[[dict objectForKey: @"match"] intValue]])];
				}
			}

		}
		break;
	case 3:
		{
			cell = [[UITableViewCell alloc] initWithStyle: (UITableViewCellStyle) 1000 reuseIdentifier: NO];

			id editableTextField = [cell editableTextField];
			NSType(editableTextField);
			[editableTextField setPlaceholder: SRPLOC(@"Search String")];

			[editableTextField setText: [dict objectForKey: @"string"]];
			[cell setTextFieldOffset: 0];
			[cell setSelectionStyle: UITableViewCellSelectionStyleNone];
			[editableTextField setAutocapitalizationType: UITextAutocapitalizationTypeSentences];
			
			[editableTextField addTarget: self
								action: @selector(textChanged:)
								forControlEvents: UIControlEventEditingChanged];
			
		}
		break;
	
	}
	
	if(cell && row<3)
		[cell setAccessoryType: UITableViewCellAccessoryDisclosureIndicator];
	
	return [cell autorelease];
}


@end