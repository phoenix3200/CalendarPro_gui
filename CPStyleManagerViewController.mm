

//#define TESTING

#import "common.h"
#import "defines.h"

#import "classes.h"


#import "CPStyleManagerViewController.h"

#import "CPEditableItem.h"

#import "dbmanager.h"

#import "CPStyleEditorViewController.h"


@implementation CPStyleManagerViewController

- (id) initWithFrame: (CGRect) frame;
{
	if((self = [super initWithFrame: frame]))
	{
		[self setTitle: @"Ring Profiles"];
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
			[item1 setKeys: StyleKVs(NO) vals: StyleKVs(YES) detailClass: [CPStyleEditorViewController class]];
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
	int row = [indexPath row];
	
	bool canDelete = NO;
	
	NSArray* keys = StyleKVs(NO);
	if([keys count] > (unsigned) row && row >= 0)
	{
		NSNumber* key = [keys objectAtIndex: row];

		const char *candel = "select editable from CPStyles where rowid = ?";
		sqlite3_stmt *candel_stmt;

		sqlite3_prepare_v2(db, candel, -1, &candel_stmt, NULL);
		sqlite3_bind_int(candel_stmt, 1, [key intValue]);
		sqlite3_step(candel_stmt);
		canDelete = sqlite3_column_int(candel_stmt, 0);

		sqlite3_finalize(candel_stmt);
	}
	
//	return UITableViewCellEditingStyleDelete;
	return canDelete ? UITableViewCellEditingStyleDelete : UITableViewCellEditingStyleNone;
}

- (BOOL) tableView: (UITableView*) table canMoveRowAtIndexPath: (NSIndexPath*) indexPath
{
	return YES;
}


- (void) itemRemoved: (NSNumber*) key
{
	RemoveStyle(key);
}

- (void) orderChanged
{
	SaveStyleOrdering();
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
	CPStyleEditorViewController* subController = [[CPStyleEditorViewController alloc] initWithFrame: [self.view frame]];
	subController.editDelegate = self;
	[subController setPrimaryKey: nil];
	[[self navigationController] pushViewController: subController animated: YES];
	
}





@end