
#import "CPCustomTableController.h"

@interface CPStyleEditorViewController : CPCustomTableController <CPCustomTableControllerProtocol>
{
	NSNumber* primaryKey;
	
	bool isEditable;
	NSMutableDictionary *_dict;
	NSMutableDictionary *_mainDict;
	NSMutableDictionary *_altDict;
	
}

- (id) initWithFrame: (CGRect) frame;

- (void) refreshSubitems;

- (BOOL) ringerSwitch;
- (void) switchChanged: (UISwitch*) switchObj;

- (NSString*) name;
- (void) textChanged: (UITextField*) field;

- (NSString*) deleteButtonTitle;
- (void) deleteButtonAction;

- (void) setPrimaryKey: (NSNumber*) newPrimaryKey;
- (NSArray*) tableItems;
- (UIBarButtonSystemItem) leftItem;
- (void) leftAction;
- (UIBarButtonSystemItem) rightItem;
- (void) rightAction;
- (BOOL) isEditable;
- (void) getStyleProperties;



@end