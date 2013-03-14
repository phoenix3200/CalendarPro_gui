
//#define TESTING

#import "common.h"
#import "defines.h"

#import "classes.h"

#import "EKEventProfileEditItemViewController.h"
#import "CPSelectionItem.h"
#import "CPStyleManagerItem.h"
#import "CPRuleManagerItem.h"

#import "dbmanager.h"

@implementation EKEventProfileEditItemViewController

- (id) initWithFrame: (CGRect) frame;
{
	if((self = [super initWithFrame: frame]))
	{
		[self setTitle: @"Ring Profile"];
	}
	return self;
}

- (void) dealloc
{
	[_style release];
	[super dealloc];
}

- (NSArray*) tableItems
{
	//static NSArray* tableItems;
	if(_tableItems==nil)
	{
		//CPStyleItem* item1 = [CPStyleItem new];
		
		CPSelectionItem* item1 = [[CPSelectionItem alloc] initWithIdentifier: @"style"];
		{
			[item1 setDelegate: self];
			NSMutableArray* vals = [StyleKVs(YES) retain];//[allStyles objectAtIndex: 0];
			NSMutableArray* keys = [StyleKVs(NO) retain];// [allStyles objectAtIndex: 1];
			
			[item1 setKeys: keys vals: vals selection: [self style]];
			
			//[item1 setSelection: [self style]];
			
			[item1 autorelease];
		}
		
		CPRuleManagerItem* item2 = [CPStyleManagerItem new];
		{
			[item2 setDelegate: self];
			[item2 autorelease];
		}
		
		CPRuleManagerItem* item3 = [CPRuleManagerItem new];
		{
			[item3 setDelegate: self];
			[item3 autorelease];
		}
		
		_tableItems = [[NSArray alloc] initWithObjects: 
						item1, item2, item3,
						nil];
	}
	return _tableItems;
}

- (NSNumber*) style
{
	if(!_style)
	{
		_style = [[NSNumber alloc] initWithInt: 0];
	}
	return _style;
}

- (void) setSelection: (NSObject*) selection forIdentifier: (NSString*) identifier
{
	NSLog(@"Selection changed to %@ = %@", identifier, [selection description]);
	
	if([identifier isEqualToString: @"style"])
	{
		[_style release];
		_style = [selection retain];
	}	
}

- (UIBarButtonSystemItem) leftItem
{
	return UIBarButtonSystemItemCancel;
}

- (void) leftAction
{
	SelLog();
	
	[self cancel];
	
//	extern UINavigationController* eventEditor;
//	NSDesc(eventEditor.viewControllers);
//	[eventEditor popViewControllerAnimated: YES];
//	NSDesc(eventEditor.viewControllers);
	
//	[self cancel];
}

- (UIBarButtonSystemItem) rightItem
{
	return UIBarButtonSystemItemDone;
}

- (void) rightAction
{
	[self saveAndDismiss];
}

/*
- (NSString*) deleteButtonTitle
{
	return @"BALEETED";
}

- (void) deleteButtonAction
{
	[self cancel];
	return;
}
*/


@end