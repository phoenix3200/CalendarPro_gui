
#import "CPTableItem.h"
#import "CPCustomTableController.h"

@interface CPTimeViewControllerItems : NSObject <CPTableItem>
{
	CPCustomTableController* delegate;
}

- (void) setDelegate: (CPCustomTableController*) newDelegate;

- (int) subitemCount;
- (UITableViewCell*) cellForRow: (int) row;

@end