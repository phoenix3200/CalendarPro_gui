

#import "EKEventEditItem.h"
#import "EKEventEditItemViewController.h"

@interface EKProfileEditItem : EKEventEditItem
{
	
}

- (UITableViewCell*) cellForSubitemAtIndex: (int) index;
- (EKEventEditItemViewController*) detailViewControllerWithFrame: (CGRect) frame forSubitemAtIndex: (int) index;
- (BOOL) eventEditItemViewControllerCommit: (UIView*) view;

@end

void ClassCreate_EKProfileEditItem();