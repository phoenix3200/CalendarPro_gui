

//#import "FakeEKEventEditItemViewController.h"

#import "CPCustomTableController.h"

@interface EKEventProfileEditItemViewController : CPCustomTableController <CPCustomTableControllerProtocol>
{
	NSNumber* _style;
//	UITableView* _table;
//	unsigned int _selectedRow;
}

- (id) initWithFrame: (CGRect) frame;
//- (void) dealloc;
- (NSNumber*) style;
- (void) setSelection: (NSObject*) selection forIdentifier: (NSString*) identifier;
- (UIBarButtonSystemItem) leftItem;
- (void) leftAction;
- (UIBarButtonSystemItem) rightItem;
- (void) rightAction;



@end