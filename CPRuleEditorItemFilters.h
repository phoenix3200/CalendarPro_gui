#import "CPTableItem.h"
#import "CPCustomTableController.h"

@interface CPRuleEditorItemFilters : NSObject <CPTableItem>
{
	CPCustomTableController* delegate;
	NSMutableArray* filters;
}

- (void) setDelegate: (CPCustomTableController*) newDelegate;

- (void) setFilterDict: (NSMutableArray*) newFilters;

- (int) subitemCount;
- (UITableViewCell*) cellForRow: (int) row;

@end