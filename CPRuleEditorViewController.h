
#import "CPCustomTableController.h"

@interface CPRuleEditorViewController : CPCustomTableController <CPCustomTableControllerProtocol>
{
	NSNumber* primaryKey;
	
	NSMutableDictionary* _dict;
	NSMutableArray* _filters;
	
	
}

- (void) getRuleProperties;



@end