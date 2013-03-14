
//#define TESTING

#import "common.h"
#import "defines.h"

#import "classes.h"

#import "CPStyleManagerItem.h"
#import "CPStyleManagerViewController.h"

@implementation CPStyleManagerItem

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
	CPCustomTableController* vc = [[CPStyleManagerViewController alloc] initWithFrame: frame];
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
	[[cell textLabel] setText: @"Manage Profiles"];
	[cell setAccessoryType: UITableViewCellAccessoryDisclosureIndicator];
	return [cell autorelease];
}


@end