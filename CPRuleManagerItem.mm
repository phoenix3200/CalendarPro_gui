
//#define TESTING

#import "common.h"
#import "defines.h"

#import "classes.h"

#import "CPRuleManagerItem.h"

#import "CPRuleManagerViewController.h"

@implementation CPRuleManagerItem

- (void) setDelegate: (CPCustomTableController*) newDelegate
{
	delegate = newDelegate;	
}

- (int) subitemCount
{
	return 1;
}

- (CPCustomTableController*) viewControllerWithFrame: (CGRect) frame forSubitemAtIndex: (int) index
{
	SelLog();
	CPCustomTableController* vc = [[CPRuleManagerViewController alloc] initWithFrame: frame];
	return [vc autorelease];
}

- (BOOL) canDiscloseRow: (int) row
{
	SelLog();
	return YES;
}

- (UITableViewCell*) cellForRow: (int) row
{
	UITableViewCell* cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleValue1 reuseIdentifier: NO];
	[[cell textLabel] setText: @"Manage Rules"];
	[cell setAccessoryType: UITableViewCellAccessoryDisclosureIndicator];
	return [cell autorelease];
}


@end