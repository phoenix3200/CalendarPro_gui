
//#define TESTING

#import "common.h"
#import "defines.h"

#import "CPStyleEditorItem.h"

#import "CPStyleEditorViewController.h"

@implementation CPStyleEditorItem

- (void) dealloc
{
	[super dealloc];
}

- (void) setDelegate: (CPCustomTableController*) newDelegate
{
	delegate = newDelegate;	
}


- (int) subitemCount
{
	if([(CPStyleEditorViewController*) delegate isEditable])
	{
		return 2;
	}
	return 0;
//	return 2;
}

- (UITableViewCell*) cellForRow: (int) row
{
	UITableViewCell* cell = nil;//
	
	if(row==0)
	{
		cell = [[UITableViewCell alloc] initWithStyle: (UITableViewCellStyle) 1000 reuseIdentifier: NO];

		id editableTextField = [cell editableTextField];
		NSType(editableTextField);
		[editableTextField setPlaceholder: @"Profile Name"];
		
		NSString* text = [(CPStyleEditorViewController*) delegate name];
		
		[editableTextField setText: text];
		[cell setTextFieldOffset: 0];
		[cell setSelectionStyle: UITableViewCellSelectionStyleNone];
		[editableTextField setAutocapitalizationType: UITextAutocapitalizationTypeSentences];
		
		[editableTextField addTarget: delegate
							action: @selector(textChanged:)
							forControlEvents: UIControlEventEditingChanged];
	}
	else
	{
		cell = [[UITableViewCell alloc] initWithStyle: (UITableViewCellStyleDefault) reuseIdentifier: NO];
		[[cell textLabel] setText: @"Ringer Switch"];
		
		UISwitch *switchObj = [[UISwitch alloc] initWithFrame: (CGRect){{0.0f,0.0f},{0.0f,0.0f}}];//CGRectMake(1.0, 1.0, 20.0, 20.0)];
		switchObj.on =  [(CPStyleEditorViewController*) delegate ringerSwitch];
        [switchObj addTarget: delegate
					action: @selector(switchChanged:)
					forControlEvents: UIControlEventValueChanged];
		cell.accessoryView = switchObj;
		[cell setSelectionStyle: UITableViewCellSelectionStyleNone];
		[switchObj release];
	//	[[UISwitch 
		
	}
	//
	return [cell autorelease];
}


@end