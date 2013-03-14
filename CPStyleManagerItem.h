
#import "CPTableItem.h"
#import "CPCustomTableController.h"

@interface CPStyleManagerItem : NSObject <CPTableItem>
{
	CPCustomTableController* delegate;
}

- (void) setDelegate: (CPCustomTableController*) newDelegate;

- (int) subitemCount;
- (UITableViewCell*) cellForRow: (int) row;

@end