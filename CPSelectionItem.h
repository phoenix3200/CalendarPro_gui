

#import "CPTableItem.h"
#import "CPCustomTableController.h"

@interface CPSelectionItem : NSObject <CPTableItem>
{
	NSArray* keys;
	NSArray* vals;
	NSObject* selection;
	
	NSString* identifier;
	CPCustomTableController* delegate;
}

- (id) initWithIdentifier: (NSString*) identifier;

- (void) setIdentifier: (NSString*) newIdentifier;
- (NSString*) identifier;


- (void) dealloc;

- (void) setDelegate: (CPCustomTableController*) newDelegate;
- (void) setKeys: (NSArray*) newKeys vals: (NSArray*) newVals selection: (NSObject*) selection;
- (void) setSelection: (NSObject*) newSelection;
- (id) selection;
- (void) toggleSelection: (NSObject*) key;

- (BOOL) allowsMultipleSelection;

- (void) markRow: (int) row;
- (BOOL) isRowMarked: (int) row;

- (int) subitemCount;
- (UITableViewCell*) cellForRow: (int) row;

@end