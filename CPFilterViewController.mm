

//#define TESTING

#import "common.h"
#import "defines.h"

#import "classes.h"

#import "CPFilterViewController.h"

//#import "CPEditableItem.h"

//#import "dbmanager.h"

#import "CPFilterItem.h"


@implementation CPFilterViewController

- (id) initWithFrame: (CGRect) frame
{
	if((self = [super initWithFrame: frame]))
	{
		[self setTitle: @"Edit Filter"];
	}
	return self;
}

- (void) dealloc
{
	[dict release];
	[super dealloc];
}


- (NSArray*) tableItems
{
//	static NSArray* tableItems;
	if(_tableItems==nil)
	{
		CPFilterItem* item0 = [[CPFilterItem alloc] init];//WithIdentifier: @"style"];
		{
			// have it fetch the properties from us
			[item0 setDelegate: self];
			[item0 setDict: dict];
			[item0 autorelease];
		}
		
		_tableItems = [[NSArray alloc] initWithObjects: 
						item0,
						nil];
	}
	return _tableItems;
}

- (void) setSelection: (NSObject*) selection forIdentifier: (NSString*) identifier
{
	[dict setValue: selection forKey: identifier];
	if([identifier isEqualToString: @"category"])
	{
		[dict setValue: [NSNumber numberWithInt: 0] forKey: @"match"];
		
		
	}
	
	[_table reloadData];
}

- (void) startWithFilter: (NSDictionary*) filter forRow: (int) row
{
	SelLog();
	[filter release];
	if(filter)
	{
		dict = [[NSMutableDictionary alloc] initWithDictionary: filter];// mutableCopy];
	}
	else
	{
		dict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
					[NSNumber numberWithInt: 0], @"filter",
					[NSNumber numberWithInt: 0], @"category",
					[NSNumber numberWithInt: 0], @"match",
					@"", @"string",
					nil];
	}
	
	filterRow = row;
}


- (NSString*) deleteButtonTitle
{
	if(filterRow>=0)
	{
		return RPLOC(@"Delete Filter");
	}
	return nil;
}


- (void) deleteButtonAction
{
	SelLog();
	[itemDelegate deleteRow: filterRow];
	[self cancel];
}


- (UIBarButtonSystemItem) leftItem
{
	return UIBarButtonSystemItemCancel;
}


- (void) leftAction
{
	SelLog();
	[self cancel];
}

- (UIBarButtonSystemItem) rightItem
{
	return UIBarButtonSystemItemDone;
}

- (void) rightAction
{
	SelLog();
	
	[itemDelegate saveFilter: dict forRow: filterRow];
	
	[self saveAndDismiss];
}




@end