#import "CPCustomTableController.h"

@interface CPSelectionViewController : CPCustomTableController <CPCustomTableControllerProtocol>
{
}

- (NSArray*) tableItems;
- (void) setTitle: (NSString*) title identifier: (NSObject*) identifier keys: (NSArray*) keys vals: (NSArray*) vals selection: (NSObject*) newSelection;
- (void) setSelection: (NSObject*) selection forIdentifier: (NSString*) identifier;


@end