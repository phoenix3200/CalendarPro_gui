
#import "EKEventEditItemViewControllerDelegate.h"

@protocol CPCustomTableControllerProtocol

@optional
- (NSArray*) tableItems;

- (UIBarButtonSystemItem) leftItem;
- (NSString*) leftTitle;
- (UIBarButtonItemStyle) leftStyle;
- (void) leftAction;

- (UIBarButtonSystemItem) rightItem;
- (NSString*) rightTitle;
- (UIBarButtonItemStyle) rightStyle;
- (void) rightAction;

- (UIBarButtonSystemItem) leftToolbarItem;
- (NSString*) leftToolbarTitle;
- (UIBarButtonItemStyle) leftToolbarStyle;
- (void) leftToolbarAction;

- (UIBarButtonSystemItem) rightToolbarItem;
- (NSString*) rightToolbarTitle;
- (UIBarButtonItemStyle) rightToolbarStyle;
- (void) rightToolbarAction;

- (NSString*) deleteButtonTitle;
- (void) deleteButtonAction;

- (void) setSelection: (NSObject*) selection forIdentifier: (NSString*) identifier;


- (BOOL) returnOnMarked;

@end


@interface CPCustomTableController : UIViewController <UITableViewDataSource, UITableViewDelegate, CPCustomTableControllerProtocol, EKEventEditItemViewControllerDelegate>
{
	id<EKEventEditItemViewControllerDelegate> editDelegate;
	
	id itemDelegate;
	
	UITableView* _table;
	UIToolbar* toolbar;
	
	NSArray* _tableItems;
	
	BOOL modal;
	CGRect initialFrame;
}
@property(assign, nonatomic) BOOL modal;
@property(assign, nonatomic) id<EKEventEditItemViewControllerDelegate> editDelegate;
@property(assign, nonatomic) id itemDelegate;

- (id) initWithFrame: (CGRect) frame;
- (void) loadView;
- (void) viewDidLoad;
- (void) viewWillDisappear: (BOOL) animated;

- (void) cancel;
- (void) _saveAndDismissWithForce: (BOOL) force;
- (void) saveAndDismiss;
- (void) saveAndDismissWithExtremePrejudice;
- (BOOL) validateAllowingAlert: (BOOL) alert;
- (void) showValidationErrorWithTitle: (NSString*) title body: (NSString*) body;
- (id) prompt;
- (void) didReceiveMemoryWarning;

- (BOOL) shouldAutorotateToInterfaceOrientation: (UIInterfaceOrientation) interfaceOrientation;
- (void) willAnimateRotationToInterfaceOrientation: (UIInterfaceOrientation) interfaceOrientation duration: (double) duration;
- (void) updatePromptForOrientation: (UIInterfaceOrientation) orientation;
- (void) updateViewsForOrientation: (UIInterfaceOrientation) interfaceOrientation;

- (int) numberOfSectionsInTableView: (UITableView*) table;
- (int) tableView: (UITableView*) table numberOfRowsInSection: (int) section;
- (UITableViewCell*) tableView: (UITableView*) table cellForRowAtIndexPath: (NSIndexPath*) indexPath;
- (void) tableView: (UITableView*) table didSelectRowAtIndexPath: (NSIndexPath*) indexPath;


- (UITableViewCellEditingStyle) tableView: (UITableView*) table editingStyleForRowAtIndexPath: (NSIndexPath*) indexPath;
//- (BOOL) tableView: (UITableView*) table canEditRowAtIndexPath: (NSIndexPath*) indexPath;
- (BOOL) tableView: (UITableView*) table canMoveRowAtIndexPath: (NSIndexPath*) indexPath;



- (void) refreshNavigationBar;

- (void) refreshToolbar;
- (void) setToolbarItems: (NSArray*) items;


@end