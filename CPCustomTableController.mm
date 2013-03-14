

//#define TESTING

#import "common.h"
#import "defines.h"

#import "classes.h"

#import "CPCustomTableController.h"
#import "CPTableItem.h"

#import "UIModalView.h"
#import "PreferencesDeleteButtonView.h"

@implementation CPCustomTableController

@synthesize modal;
@synthesize editDelegate;
@synthesize itemDelegate;


#pragma mark View setup/destruction

- (id) initWithFrame: (CGRect) frame
{
	if((self = [super initWithNibName: nil bundle: nil]))
	{
		initialFrame = frame;
		modal = YES;
		
		//UIView* view = [[UIView alloc] initWithFrame: frame];
		//[view setBackgroundColor: [UIColor redColor]];
		//[view setAutoresizingMask: UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
		//self.view = view;
		//[view release];
		
	}
	return self;
}

- (void) dealloc
{
	[_tableItems release];
	[_table release];
	
	[toolbar release];
	[super dealloc];
}

- (void) loadView
{
	UIView* view = [[UIView alloc] initWithFrame: initialFrame];
	[view setBackgroundColor: [UIColor redColor]];
	[view setAutoresizingMask: UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
	self.view = view;
	[view release];
	
	if([self respondsToSelector: @selector(tableItems)])
	{
		_table = [[UITableView alloc] initWithFrame: initialFrame style: UITableViewStyleGrouped];
		[_table setDataSource: self];
		[_table setDelegate: self];
		[_table setAutoresizingMask: UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
		
		
		//[self setView: _table];
		[self.view addSubview: _table];
		
		if([self respondsToSelector: @selector(deleteButtonTitle)])
		{
			NSString* deleteButtonTitle = [self deleteButtonTitle];
			
			if(deleteButtonTitle)
			{
				UIView* view = [[$PreferencesDeleteButtonView alloc] initWithTitle: deleteButtonTitle target: self action: @selector(deleteButtonAction)];
				[view setFrame: (CGRect){{0.0f, 0.0f}, {0.0f, 10.0f + [$PreferencesDeleteButtonView defaultHeight]}}];
				//[_table beginUpdates];
				[_table setTableFooterView: view];
				//[_table endUpdates];
				[view release];
				[_table reloadData];
			}
		}
	}
	
	[self refreshToolbar];
	
	[self updateViewsForOrientation: [UIApp statusBarOrientation]];
}


- (void) viewDidLoad
{
	[super viewDidLoad];
	
	// set up 
	if(modal)
	{
		[self updatePromptForOrientation: [UIApp statusBarOrientation]];
		
		[self refreshNavigationBar];
	
	}
}

- (void) viewWillAppear: (BOOL) animated
{
	[super viewWillAppear: animated];
	
	[self refreshToolbar];
	
	[_table reloadData]; // just make sure we're up to date
}

- (void) viewDidUnload
{
	if(_table)
	{
		[_table setDelegate: nil];
		[_table setDataSource: nil];
		[_table release];
	}
	_table = nil;
}


- (void) viewWillDisappear: (BOOL) animated
{
	[super viewWillDisappear: animated];
	if(modal)
	{
	//	[self saveAndDismissWithExtremePrejudice];
	}
}



#pragma mark Closing

- (void) cancel
{
	[editDelegate editItemViewController: self didCompleteWithAction: 0];
}

- (void) _saveAndDismissWithForce: (BOOL) force
{
	int action = 0;
	
	if([self validateAllowingAlert: !force]) //??
	{
		if([editDelegate respondsToSelector: @selector(eventEditItemViewControllerCommit:)])
		{
			if([editDelegate eventEditItemViewControllerCommit: self])
			{
				action = 1;
			}
			else
			{
				action = 0;
			}
		}
		else
		{
			action = 1;
		}
	}
	if(force)
	{
		action = 2;
	}
	if(action)
	{
		[editDelegate editItemViewController: self didCompleteWithAction: action];
	}
}

- (void) saveAndDismiss
{
	[self _saveAndDismissWithForce: NO];
}

- (void) saveAndDismissWithExtremePrejudice
{
	[self _saveAndDismissWithForce: YES];
}

- (BOOL) validateAllowingAlert: (BOOL) alert
{
	return YES;
}

- (void) showValidationErrorWithTitle: (NSString*) title body: (NSString*) body
{
	NSArray* buttons = [[NSArray alloc] initWithObjects: [CalendarUIBundle() localizedStringForKey: @"OK" value: @"" table: @"EventEditing"], nil];
	
	GETCLASS(UIModalView);
	
	UIModalView* view = [[$UIModalView alloc] initWithTitle: title buttons: buttons defaultButtonIndex: 0 delegate: self context: nil];
	
	[view setBodyText: body];
	[view popupAlertAnimated: YES];
	[view release];
	[buttons release];
}

- (id) prompt
{
	return [CalendarUIBundle() localizedStringForKey: @"ADD_EVENT_PROMPT" value: @"" table: @"EventEditing"];
}

- (void) didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
}



#pragma mark Orientation

- (BOOL) shouldAutorotateToInterfaceOrientation: (UIInterfaceOrientation) interfaceOrientation
{
	return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown) ? YES : NO;
}

- (void) willAnimateRotationToInterfaceOrientation: (UIInterfaceOrientation) interfaceOrientation duration: (double) duration
{
	[self updatePromptForOrientation: interfaceOrientation];
	[self updateViewsForOrientation: interfaceOrientation];
}

- (void) updatePromptForOrientation: (UIInterfaceOrientation) orientation
{
	return;
}

- (void) updateViewsForOrientation: (UIInterfaceOrientation) interfaceOrientation
{
	if(toolbar && [toolbar isHidden]==NO)
	{
		CGFloat toolbarHeight = (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) ? 44.0f : 32.0f;
		
		CGRect mainViewBounds = self.view.bounds;
		[toolbar setFrame: (CGRect) {{mainViewBounds.origin.x, mainViewBounds.origin.y + mainViewBounds.size.height - toolbarHeight},
			{mainViewBounds.size.width, toolbarHeight}}];
			
		if(_table)
		{
			[_table setFrame: (CGRect) {mainViewBounds.origin, {mainViewBounds.size.width, mainViewBounds.size.height - toolbarHeight}}];
		}
	}
	else if(_table)
	{
		CGRect mainViewBounds = self.view.bounds;
		[_table setFrame: mainViewBounds];
	}
}


#pragma mark Table View

- (int) numberOfSectionsInTableView: (UITableView*) table
{
	NSArray* tableItems = [self tableItems];
	if(tableItems)
	{
		return [tableItems count];
	}
	return 0;
}

- (int) tableView: (UITableView*) table numberOfRowsInSection: (int) section
{
	NSArray* tableItems = [self tableItems];
	if(tableItems)
	{
		if(section < (int)[tableItems count] && section>=0)
		{
			return [(id<CPTableItem>)[tableItems objectAtIndex: section] subitemCount];
		}
	}
	return 0;
}

- (UITableViewCell*) tableView: (UITableView*) table cellForRowAtIndexPath: (NSIndexPath*) indexPath
{
	NSArray* tableItems = [self tableItems];
	if(tableItems)
	{
		int section = [indexPath section];
		if(section < (int)[tableItems count] && section>=0)
		{
			int row = [indexPath row];
			NSObject<CPTableItem>* tableItem = [tableItems objectAtIndex: section];
			UITableViewCell* cell = [tableItem cellForRow: row];
			
			if([tableItem respondsToSelector: @selector(isRowMarked:)] && [tableItem isRowMarked: row])
			{
				// mark
				[[cell textLabel] setTextColor: [UIColor colorWithRed: 0.22 green: 0.33 blue: 0.53 alpha: 1]];
				[cell setAccessoryType: UITableViewCellAccessoryCheckmark];
			}
			return cell;
		}
	}
	return nil;
}

- (float) tableView: (UITableView*) table heightForRowAtIndexPath: (NSIndexPath*) indexPath
{
	SelLog();
	NSArray* tableItems = [self tableItems];
	if(tableItems)
	{
		int section = [indexPath section];
		if(section < (int)[tableItems count] && section>=0)
		{
			int row = [indexPath row];
			NSObject<CPTableItem>* item = [tableItems objectAtIndex: section];
			
			
			if([item respondsToSelector: @selector(heightForRow:)])
			{
				return [item heightForRow: row];
			}
		}
	}
	return 40.0f;
//PreferencesTableDoubleRowHeight	
}


- (NSString*) tableView: (UITableView*) table titleForHeaderInSection: (int) section
{
	NSArray* tableItems = [self tableItems];
	if(tableItems)
	{
		if(section < (int)[tableItems count] && section>=0)
		{
			NSObject<CPTableItem>* tableItem = [tableItems objectAtIndex: section];
			if([tableItem respondsToSelector: @selector(header)])
			{
				return [tableItem header];
			}
		}
	}
	return nil;
	
}

- (void) tableView: (UITableView*) table updateMarkedRowsInSection: (int) section;
{
	NSArray* tableItems = [self tableItems];
	if(tableItems && section < (int)[tableItems count] && section>=0)
	{
		NSObject<CPTableItem>* tableItem = [tableItems objectAtIndex: section];
		if([tableItem respondsToSelector: @selector(isRowMarked:)])
		{
			for(int j=0; j<[table numberOfRowsInSection: section]; j++)
			{
				UITableViewCell* cell = [table cellForRowAtIndexPath: [NSIndexPath indexPathForRow: j inSection: section]];
			
				if([tableItem isRowMarked: j])
				{
					if([cell accessoryType] == UITableViewCellAccessoryNone)
					{
						// mark
						[[cell textLabel] setTextColor: [UIColor colorWithRed: 0.22 green: 0.33 blue: 0.53 alpha: 1]];
						[cell setAccessoryType: UITableViewCellAccessoryCheckmark];
					}
				}
				else
				{
					if([cell accessoryType] == UITableViewCellAccessoryCheckmark)
					{
						[[cell textLabel] setTextColor: [UIColor blackColor]];
						[cell setAccessoryType: UITableViewCellAccessoryNone];
					}
				}
			}
		}
	}	
}


- (void) showDisclosureForItem: (NSObject<CPTableItem>*) item row: (int) row
{
//	SelLog();
	
	CPCustomTableController* subController = [item viewControllerWithFrame: [self.view frame] forSubitemAtIndex: row];
	subController.editDelegate = self;
	[[self navigationController] pushViewController: subController animated: YES];
	
//	extern UINavigationController* eventEditor;
	
//	NSType([);
	
//	NSType(eventEditor);
	//UINavigationTransitionView* view = [[self.view superview] superview];
	//NSType([self editDelegate]);
//	NSDesc(eventEditor.viewControllers);
	
//	NSMutableArray* &_viewControllers(MSHookIvar<NSMutableArray*>(eventEditor, "_viewControllers"));
	
//	NSDesc(eventEditor.viewControllers);
//	[_viewControllers addObject: subController];
	
//	NSLine();
}

- (void) editItemViewController: (id) vc didCompleteWithAction: (int) action
{
	extern UINavigationController* eventEditor;	
//	NSDesc(eventEditor.viewControllers);
	[eventEditor popViewControllerAnimated: YES];
	
}
/*
	NSLine();
	/ *
	if(action)
	{
		
	}
	extern UINavigationController* eventEditor;
	[vc dismissModalViewControllerAnimated: YES];
	[eventEditor popViewControllerAnimated: YES];
	//[eventEditor popToViewController: self animated: YES];
	* /
}
*/


- (void) tableView: (UITableView*) table didSelectRowAtIndexPath: (NSIndexPath*) indexPath
{
	NSArray* tableItems = [self tableItems];
	if(tableItems)
	{
		int section = [indexPath section];
		if(section < (int)[tableItems count] && section>=0)
		{
			int row = [indexPath row];
			NSObject<CPTableItem>* item = [tableItems objectAtIndex: section];
			NSLine();
			NSDesc(item);
			if([item respondsToSelector: @selector(canDiscloseRow:)] && [item canDiscloseRow: row])
			{
				NSLine();
				[self showDisclosureForItem: item row: row];
				//[self tableView: (UITableView*) table discloseForIndexPath: indexPath];
			}
			else if([item respondsToSelector: @selector(markRow:)])
			{
				[item markRow: row];
				
				if([self respondsToSelector: @selector(returnOnMarked)] && [self returnOnMarked])
				{
					[self saveAndDismiss];
				}
				else
				{
					[self tableView: table updateMarkedRowsInSection: section];
				}
			}
		}
		
		[table selectRowAtIndexPath: [NSIndexPath indexPathForRow: -1 inSection: -1] animated: YES scrollPosition: UITableViewScrollPositionNone];
	}
}

- (UITableViewCellEditingStyle) tableView: (UITableView*) table editingStyleForRowAtIndexPath: (NSIndexPath*) indexPath
{
	BOOL canDelete = NO;
	NSArray* tableItems = [self tableItems];
	if(tableItems)
	{
		int section = [indexPath section];
		if(section < (int)[tableItems count] && section>=0)
		{
			int row = [indexPath row];
			NSObject<CPTableItem>* item = [tableItems objectAtIndex: section];
			canDelete = ([item respondsToSelector: @selector(canDeleteRow:)] && [item canDeleteRow: row]);
		}
	}
	
	return canDelete ? UITableViewCellEditingStyleDelete : UITableViewCellEditingStyleNone;
//	return NO;
}

/*
- (BOOL) tableView: (UITableView*) table canEditRowAtIndexPath: (NSIndexPath*) indexPath
{
	NSArray* tableItems = [self tableItems];
	if(tableItems)
	{
		int section = [indexPath section];
		if(section < (int)[tableItems count] && section>=0)
		{
			int row = [indexPath row];
			NSObject<CPTableItem>* item = [tableItems objectAtIndex: section];
			return ([item respondsToSelector: @selector(canDeleteRow:)] && [item canDeleteRow: row]);
		}
	}
	return NO;
}
*/

- (BOOL) tableView: (UITableView*) table canMoveRowAtIndexPath: (NSIndexPath*) indexPath
{
	SelLog();
	NSArray* tableItems = [self tableItems];
	if(tableItems)
	{
		int section = [indexPath section];
		if(section < (int)[tableItems count] && section>=0)
		{
//			int row = [indexPath row];
			NSObject<CPTableItem>* item = [tableItems objectAtIndex: section];
			return ([item respondsToSelector: @selector(canMoveRows)] && [item canMoveRows]);
		}
	}
	return NO;
}

- (void) tableView: (UITableView*) table moveRowAtIndexPath: (NSIndexPath*) fromIndexPath toIndexPath: (NSIndexPath*) toIndexPath
{
	int fromSection = [fromIndexPath section];
	int toSection = [toIndexPath section];
	if(fromSection != toSection)
	{
		[table reloadData];
		return;
	}
	
	NSLog(@"okay");
	NSArray* tableItems = [self tableItems];
	if(tableItems)
	{
		if(toSection < (int) [tableItems count] && toSection>=0)
		{
			NSObject<CPTableItem>* item = [tableItems objectAtIndex: toSection];
			if([item respondsToSelector: @selector(moveRow:toRow:)])
			{
				[item moveRow: [fromIndexPath row] toRow: [toIndexPath row]];
			}
		}
	}	
}

// required for "swipe to delete"
- (void) tableView: (UITableView*) table willBeginEditingRowAtIndexPath: (NSIndexPath*) indexPath
{
}

- (void) tableView: (UITableView*) table commitEditingStyle: (UITableViewCellEditingStyle) editingStyle forRowAtIndexPath: (NSIndexPath*) indexPath
{
	SelLog();
	
	
	NSArray* tableItems = [self tableItems];
	if(tableItems)
	{
		int section = [indexPath section];
		if(section < (int)[tableItems count] && section>=0)
		{
			int row = [indexPath row];
			NSObject<CPTableItem>* item = [tableItems objectAtIndex: section];
			if([item respondsToSelector: @selector(deleteRow:)] && [item deleteRow: row])
			{
				[table beginUpdates];
				[table deleteRowsAtIndexPaths: [NSArray arrayWithObject: indexPath] withRowAnimation: UITableViewRowAnimationFade];
				[table endUpdates];
			}
		}
	}
}


#pragma mark Navigation Bar

- (void) refreshNavigationBar
{
	UINavigationItem* navigationItem = [self navigationItem];
	
	if([self respondsToSelector: @selector(leftItem)])
	{
		UIBarButtonSystemItem item = [self leftItem];
		if(item!=-1)
		{
			[navigationItem setLeftBarButtonItem:
				[[[UIBarButtonItem alloc] initWithBarButtonSystemItem: item
					target: self action: @selector(leftAction)]
					autorelease]  animated: NO];
		}
		else
		{
			[navigationItem setLeftBarButtonItem: nil  animated: NO];
		}
	}
	else if([self respondsToSelector: @selector(leftTitle)])
	{
		if(NSString* title = [self leftTitle])
		{
			[navigationItem setLeftBarButtonItem:
				[[[UIBarButtonItem alloc] initWithTitle: title style: [self respondsToSelector: @selector(leftStyle)] ? [self leftStyle] : UIBarButtonItemStylePlain
					target: self action: @selector(leftAction)]				
					autorelease]  animated: NO];
		}
		else
		{
			[navigationItem setLeftBarButtonItem: nil animated: NO];
		}
	}
	
	if([self respondsToSelector: @selector(rightItem)])
	{
		UIBarButtonSystemItem item = [self rightItem];
		NSLog(@"item = %d", item);
		if(item!=-1)
		{
			[navigationItem setRightBarButtonItem:
				[[[UIBarButtonItem alloc] initWithBarButtonSystemItem: item
					target: self action: @selector(rightAction)]
					autorelease]  animated: NO];
		}
		else
		{
			[navigationItem setRightBarButtonItem: nil  animated: NO];
		}
		
	}
	else if([self respondsToSelector: @selector(rightTitle)])
	{
		if(NSString* title = [self rightTitle])
		{
			[navigationItem setRightBarButtonItem:
				[[[UIBarButtonItem alloc] initWithTitle: title style: [self respondsToSelector: @selector(rightStyle)] ? [self rightStyle] : UIBarButtonItemStylePlain
					target: self action: @selector(rightAction)]				
					autorelease]  animated: NO];
		}
		else
		{
			[navigationItem setRightBarButtonItem: nil  animated: NO];
		}
	}
}

#pragma mark Toolbar

- (void) refreshToolbar
{
	NSMutableArray* toolbarItems = [[NSMutableArray alloc] init];

	if([self respondsToSelector: @selector(leftToolbarItem)])
	{
		UIBarButtonSystemItem item = [self leftToolbarItem];
		if(item!=-1)
		{
			[toolbarItems addObject:
				[[[UIBarButtonItem alloc] initWithBarButtonSystemItem: item
					target: self action: @selector(leftToolbarAction)]
					autorelease]];
		}
	}
	else if([self respondsToSelector: @selector(leftToolbarTitle)])
	{
		NSString* leftToolbarTitle = [self leftToolbarTitle];
		if(leftToolbarTitle)
		{
			[toolbarItems addObject:
				[[[UIBarButtonItem alloc] initWithTitle: leftToolbarTitle style: [self respondsToSelector: @selector(leftToolbarStyle)] ? [self leftToolbarStyle] : UIBarButtonItemStylePlain
					target: self action: @selector(leftToolbarAction)]				
					autorelease]];
		}
	}
	[toolbarItems addObject: [[[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemFlexibleSpace
		target: self action: nil] autorelease]];
	
	if([self respondsToSelector: @selector(rightToolbarItem)])
	{
		UIBarButtonSystemItem item = [self rightToolbarItem];
		if(item!=-1)
		{
			[toolbarItems addObject:
				[[[UIBarButtonItem alloc] initWithBarButtonSystemItem: item
					target: self action: @selector(rightToolbarAction)]
					autorelease]];
		}
	}
	else if([self respondsToSelector: @selector(rightToolbarTitle)])
	{
		NSString* rightToolbarTitle = [self rightToolbarTitle];
		if(rightToolbarTitle)
		{
			[toolbarItems addObject:
				[[[UIBarButtonItem alloc] initWithTitle: rightToolbarTitle style: [self respondsToSelector: @selector(rightToolbarStyle)] ? [self rightToolbarStyle] : UIBarButtonItemStylePlain
					target: self action: @selector(rightToolbarAction)]				
					autorelease]];
		}
	}

	//[[self toolbar] setItems: toolbarItems animated: NO];
	//NSDesc(toolbarItems);
	[self setToolbarItems: toolbarItems];
	//[self setToolbarHidden: NO animated: NO];
	[toolbarItems release];
}


- (void) setToolbarItems: (NSArray*) items
{
	SelLog();
	[super setToolbarItems: items];
	
	if(!toolbar)
	{
		NSLine();
		toolbar = [UIToolbar new];
		toolbar.barStyle = UIBarStyleDefault;

		// size up the toolbar and set its frame
		[toolbar sizeToFit];
		CGFloat toolbarHeight = [toolbar frame].size.height;
		//[UIApp interfaceOrientation] < 2 ? 48.0f : 32.0f : 48.0f;
		//toolbarHeight = 32.0f;
		CGRect mainViewBounds = self.view.bounds;
		[toolbar setFrame: (CGRect) {{mainViewBounds.origin.x, mainViewBounds.origin.y + mainViewBounds.size.height - toolbarHeight},
			{mainViewBounds.size.width, toolbarHeight}}];
		[toolbar setAutoresizingMask: UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin];
		
		[self.view addSubview:toolbar];
	}
	[toolbar setItems: items animated: NO];
	
	//NSDesc(toolbar);
	if(items && [items count]>1) // because we're including a spacer no matter what
	{
		NSLine();
		[toolbar setHidden: NO];
	}
	else
	{
		NSLine();
		[toolbar setHidden: YES];
	}
}



//NSArray* items;

@end