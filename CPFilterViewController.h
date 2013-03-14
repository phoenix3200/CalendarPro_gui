
#import "CPCustomTableController.h"

@interface CPFilterViewController : CPCustomTableController <CPCustomTableControllerProtocol>
{
	NSMutableDictionary* dict;
	int filterRow;
	
	
}

- (void) getRuleProperties;



@end