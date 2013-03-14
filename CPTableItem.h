

#import "CPCustomTableController.h"

@protocol CPTableItem
- (int) subitemCount;
- (UITableViewCell*) cellForRow: (int) row;
@optional
- (BOOL) canDiscloseRow: (int) row;
- (BOOL) isRowMarked: (int) row;
- (void) markRow: (int) row;
- (CPCustomTableController*) viewControllerWithFrame: (CGRect) frame forSubitemAtIndex: (int) index;
- (NSString*) header;

- (BOOL) canDeleteRow: (int) row;
- (BOOL) deleteRow: (int) row;

- (BOOL) canMoveRows;
- (void) moveRow: (int) row toRow: (int) row;

- (float) heightForRow: (int) row;

@end

