
//#define TESTING

#import "common.h"
#import "defines.h"

#import "classes.h"


#import "CPSelectionItem.h"

#import "CPSelectionViewController.h"


@implementation CPSelectionViewController


- (NSArray*) tableItems
{
//	static NSArray* tableItems;
	if(_tableItems==nil)
	{
		CPSelectionItem* item0 = [CPSelectionItem new];
		{
			[item0 setDelegate: self];
			[item0 autorelease];
		}
		
		_tableItems = [[NSArray alloc] initWithObjects: 
						item0,
						nil];
	}
	return _tableItems;
}

- (void) setTitle: (NSString*) title identifier: (NSString*) identifier keys: (NSArray*) keys vals: (NSArray*) vals selection: (NSObject*) newSelection
{
	CPSelectionItem* item0 = (CPSelectionItem*)[[self tableItems] objectAtIndex: 0];
	[self setTitle: title];
	[item0 setIdentifier: identifier];
	[item0 setKeys: keys vals: vals selection: newSelection];
}

- (void) setSelection: (NSObject*) selection forIdentifier: (NSString*) identifier
{
	NSLog(@"Selection changed to %@ = %@", identifier, [selection description]);
	
	if(itemDelegate)
	{
		[itemDelegate setSelection: (NSObject*) selection forIdentifier: (NSString*) identifier];
	}
	[self saveAndDismiss];
}


@end