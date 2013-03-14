
#import "CPTableItem.h"

@interface CPStyleEditorItemProperties : NSObject <CPTableItem>
{
	CPCustomTableController* delegate;
	int mode;
	NSMutableDictionary* dict;
}


- (void) dealloc;
- (void) setDelegate: (CPCustomTableController*) newDelegate;

- (int) mode;
- (void) setMode: (int) newMode;

- (void) setStyleDictionary: (NSMutableDictionary*) newDict;


- (int) subitemCount;
- (UITableViewCell*) cellForRow: (int) row;



@end