
//#define TESTING

#import "common.h"
#import "defines.h"

#import "classes.h"

#import "CPTimeViewControllerItems.h"

@implementation CPTimeViewControllerItems

- (void) setDelegate: (CPCustomTableController*) newDelegate
{
	delegate = newDelegate;	
}

- (int) subitemCount
{
	return 3;
}

- (UITableViewCell*) cellForRow: (int) row
{
	UITableViewCell* cell = nil;
	switch(row)
	{
	case 0:
		{
			cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleValue1 reuseIdentifier: NO];
			[[cell textLabel] setText: @"Starts"];
			[[cell detailTextLabel] setText: @"12:00 AM"];
			[cell setEnabled: NO];
		}
		break;
	case 1:
		{
			cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleValue1 reuseIdentifier: NO];
			[[cell textLabel] setText: @"Ends"];
			[[cell detailTextLabel] setText: @"12:00 AM"];
		}
		break;
	case 2:
		{
			cell = [[UITableViewCell alloc] initWithStyle: (UITableViewCellStyleDefault) reuseIdentifier: NO];
			[[cell textLabel] setText: @"Ringer Switch"];

			UISwitch *switchObj = [[UISwitch alloc] initWithFrame: (CGRect){{0.0f,0.0f},{0.0f,0.0f}}];//CGRectMake(1.0, 1.0, 20.0, 20.0)];
			switchObj.on =  YES;//[(CPStyleEditorViewController*) delegate ringerSwitch];
	    /*    [switchObj addTarget: delegate
						action: @selector(switchChanged:)
						forControlEvents: UIControlEventValueChanged];*/
			cell.accessoryView = switchObj;
			[cell setSelectionStyle: UITableViewCellSelectionStyleNone];
			[switchObj release];
		}
		break;
	}
	
	
	return [cell autorelease];
}


@end