

#import "CPTableItem.h"
#import "CPCustomTableController.h"

@interface CPEditableItem : NSObject <CPTableItem>
{
	NSMutableArray* keys;
	NSMutableArray* vals;
	Class detailClass;
	
//	NSString* identifier;
	CPCustomTableController* delegate;
}

- (NSString*) identifier;
- (void) dealloc;

- (void) setDelegate: (CPCustomTableController*) newDelegate;
- (void) setKeys: (NSArray*) newKeys vals: (NSArray*) newVals detailClass: (Class) newClass;

- (int) subitemCount;
- (UITableViewCell*) cellForRow: (int) row;

@end