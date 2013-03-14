

#import "CPTableItem.h"

@interface CPStyleEditorItem : NSObject <CPTableItem>
{
	CPCustomTableController* delegate;
}


- (void) dealloc;
- (void) setDelegate: (CPCustomTableController*) newDelegate;

- (int) subitemCount;
- (UITableViewCell*) cellForRow: (int) row;


@end