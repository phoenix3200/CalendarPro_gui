#import "CPTableItem.h"
#import "CPCustomTableController.h"

@interface CPRuleEditorItemDate : NSObject <CPTableItem>
{
	CPCustomTableController* delegate;
	NSMutableDictionary* dict;
}

- (void) setDelegate: (CPCustomTableController*) newDelegate;


- (void) setRuleDict: (NSMutableDictionary*) newDict;


- (int) subitemCount;
- (UITableViewCell*) cellForRow: (int) row;

@end