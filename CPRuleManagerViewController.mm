


//#define TESTING

#import "common.h"
#import "defines.h"

#import "classes.h"


#import "CPRuleManagerViewController.h"

#import "CPEditableItem.h"

#import "dbmanager.h"

#import "CPRuleEditorViewController.h"


@implementation CPRuleManagerViewController

- (id) initWithFrame: (CGRect) frame;
{
	if((self = [super initWithFrame: frame]))
	{
		[self setTitle: @"Custom Rules"];
	}
	return self;
}

- (NSArray*) tableItems
{
//	static NSArray* tableItems;
	if(_tableItems==nil)
	{
		CPEditableItem* item1 = [CPEditableItem new];
		{
			[item1 setDelegate: self];
			[item1 setKeys: RuleKVs(NO) vals: RuleKVs(YES) detailClass: [CPRuleEditorViewController class]];
			[item1 autorelease];
		}
		
		_tableItems = [[NSArray alloc] initWithObjects: 
						item1,
						nil];
	}
	return _tableItems;
}

- (UITableViewCellEditingStyle) tableView: (UITableView*) table editingStyleForRowAtIndexPath: (NSIndexPath*) indexPath
{
	return UITableViewCellEditingStyleDelete;
}

- (BOOL) tableView: (UITableView*) table canMoveRowAtIndexPath: (NSIndexPath*) indexPath
{
	return YES;
}

- (void) itemRemoved: (NSNumber*) key
{
	RemoveRule(key);
}

- (void) orderChanged
{
	SaveRuleOrdering();
}


- (UIBarButtonSystemItem) leftToolbarItem
{
	return fakeEditing ? UIBarButtonSystemItemDone : UIBarButtonSystemItemEdit;
}

- (void) leftToolbarAction
{
	NSLog(@"isEditing? %d", [_table isEditing]);
	fakeEditing = !fakeEditing;
	[_table setEditing: fakeEditing animated: YES];
	NSLog(@"isEditing? %d", [_table isEditing]);
	
	[self refreshNavigationBar];
	[self refreshToolbar];
}

- (UIBarButtonSystemItem) rightItem
{
	return UIBarButtonSystemItemAdd;
}

- (void) rightAction
{
	CPRuleEditorViewController* subController = [[CPRuleEditorViewController alloc] initWithFrame: [self.view frame]];
	subController.editDelegate = self;
	[subController setPrimaryKey: nil];
	[[self navigationController] pushViewController: subController animated: YES];
}





@end