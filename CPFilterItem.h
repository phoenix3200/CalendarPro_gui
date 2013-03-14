#import "CPTableItem.h"
#import "CPCustomTableController.h"

@interface CPFilterItem : NSObject <CPTableItem>
{
	CPCustomTableController* delegate;
	NSMutableDictionary* dict;
}

- (void) setDelegate: (CPCustomTableController*) newDelegate;


- (void) setDict: (NSMutableDictionary*) newDict;


- (int) subitemCount;
- (UITableViewCell*) cellForRow: (int) row;

@end