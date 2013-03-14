
//#define TESTING

#import "common.h"
#import "defines.h"

#import "classes.h"


#import "CPSelectionItem.h"
#import "CPDaysSelectionItem.h"

#import "CPWeekViewController.h"

NSString *wkSet1[] = 
{
	@"Every Day",
	@"Weekdays",
	@"Clear All"
};


NSString *wkSet2[] = 
{
	@"Monday",
	@"Tuesday",
	@"Wednesday",
	@"Thursday",
	@"Friday",
	@"Saturday",
	@"Sunday"
};

@implementation CPWeekViewController

- (void) loadView
{
	[super loadView];
	[self setTitle: RPLOC(@"Days")];
}


- (void) dealloc
{
	[selection release];
	[super dealloc];
}

- (NSArray*) tableItems
{
	SRPINIT();
	
	if(_tableItems==nil)
	{
		CPSelectionItem* item0 = [CPSelectionItem new];
		{
			[item0 setDelegate: self];
			
			NSArray* vals = [NSArray arrayWithObjects:
								SRPLOC(wkSet1[0]),
								SRPLOC(wkSet1[1]),
								SRPLOC(wkSet1[2]),
								nil];
			NSArray* keys = [NSArray arrayWithObjects:
								[NSNumber numberWithInt: 0x7f],
								[NSNumber numberWithInt: 0x1f],
								[NSNumber numberWithInt: 0x0],
								nil];
			[item0 setIdentifier: @"weekdays"];
			[item0 setKeys: keys vals: vals selection: selection];
			[item0 autorelease];
		}

		CPDaysSelectionItem* item1 = [CPDaysSelectionItem new];
		{
			[item1 setDelegate: self];
			
			uint dayoffs =  ((uint)([[NSCalendar currentCalendar] firstWeekday])+5);
			
			
			NSArray* vals = [NSArray arrayWithObjects:
								SRPLOC(wkSet2[(0+dayoffs)%7]),
								SRPLOC(wkSet2[(1+dayoffs)%7]),
								SRPLOC(wkSet2[(2+dayoffs)%7]),
								SRPLOC(wkSet2[(3+dayoffs)%7]),
								SRPLOC(wkSet2[(4+dayoffs)%7]),
								SRPLOC(wkSet2[(5+dayoffs)%7]),
								SRPLOC(wkSet2[(6+dayoffs)%7]),
								nil];
			NSArray* keys = [NSArray arrayWithObjects:
								[NSNumber numberWithInt: 1<<((0+dayoffs)%7)],
								[NSNumber numberWithInt: 1<<((1+dayoffs)%7)],
								[NSNumber numberWithInt: 1<<((2+dayoffs)%7)],
								[NSNumber numberWithInt: 1<<((3+dayoffs)%7)],
								[NSNumber numberWithInt: 1<<((4+dayoffs)%7)],
								[NSNumber numberWithInt: 1<<((5+dayoffs)%7)],
								[NSNumber numberWithInt: 1<<((6+dayoffs)%7)],
								nil];
								
			[item1 setIdentifier: @"weekdays"];
			[item1 setKeys: keys vals: vals selection: selection];
			[item1 autorelease];
		}
		
		_tableItems = [[NSArray alloc] initWithObjects: 
						item0, item1,
						nil];
	}
	return _tableItems;
}


- (void) setSelection: (NSNumber*) newSelection
{
	[selection release];
	selection = [newSelection retain];
}

- (void) updateSelection
{
	CPSelectionItem* item0 = (CPSelectionItem*)[[self tableItems] objectAtIndex: 0];
	CPSelectionItem* item1 = (CPSelectionItem*)[[self tableItems] objectAtIndex: 1];
	[item0 setSelection: selection];
	[item1 setSelection: selection];
	[_table reloadData];
}

- (void) setSelection: (NSObject*) newSelection forIdentifier: (NSString*) identifier
{
	[self setSelection: (NSNumber*) newSelection];
	
	if(itemDelegate)
	{
		[itemDelegate setSelection: (NSObject*) newSelection forIdentifier: (NSString*) identifier];
	}
	[self updateSelection];
	[_table reloadData];
	
	
}


@end

