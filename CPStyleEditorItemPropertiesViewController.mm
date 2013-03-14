
//#define TESTING

#import "common.h"
#import "defines.h"

#import "classes.h"

#import "CPStyleEditorItemProperties.h"
#import "CPStyleEditorItemPropertiesViewController.h"


#import "dbmanager.h"

@implementation CPStyleEditorItemPropertiesViewController



- (void) loadView
{
	[super loadView];
	[self setTitle: RPLOC(@"Sound Modes")];
}

- (NSArray*) tableItems
{
//	static NSArray* tableItems;
	if(_tableItems==nil)
	{
		CPStyleEditorItemProperties* item0 = [CPStyleEditorItemProperties new];
		{
			[item0 setDelegate: self];
			[item0 setMode: 2];
			[item0 autorelease];
		}
		
		_tableItems = [[NSArray alloc] initWithObjects: 
						item0,
						nil];
	}
	return _tableItems;
}

- (BOOL) isEditable
{
	return YES;
}

- (void) setDict: (NSMutableDictionary*) dict
{
	[(CPStyleEditorItemProperties*)[[self tableItems] objectAtIndex: 0] setStyleDictionary: dict];
	
}


@end