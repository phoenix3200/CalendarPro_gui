
//#define TESTING

#import "common.h"
#import "defines.h"

#import "classes.h"

#import "CPRuleEditorItem.h"

#import "CPSelectionViewController.h"

#import "dbmanager.h"

@implementation CPRuleEditorItem

- (void) setDelegate: (CPCustomTableController*) newDelegate
{
	delegate = newDelegate;	
}

- (void) dealloc
{
	[dict release];
	[super dealloc];
}

- (int) subitemCount
{
	return 2;
}

- (void) setRuleDict: (NSMutableDictionary*) newDict
{
	[dict release];
	dict = [newDict retain];
}

- (CPCustomTableController*) viewControllerWithFrame: (CGRect) frame forSubitemAtIndex: (int) index
{
	SelLog();
	CPSelectionViewController* vc = [[CPSelectionViewController alloc] initWithFrame: frame];
	[vc setTitle: RPLOC(@"Ring Profile")
		identifier: @"style"
		keys: StyleKVs(NO)
		vals: StyleKVs(YES)
		selection: [dict objectForKey: @"style"]];
	[vc setItemDelegate: delegate];
	return [vc autorelease];
}

- (BOOL) canDiscloseRow: (int) row
{
	return row==1;
}

- (void) textChanged: (UITextField*) view
{
	[dict setValue: [view text] forKey: @"name"];
}


- (UITableViewCell*) cellForRow: (int) row
{
	UITableViewCell* cell = nil;//
	
	
	if(row==0)
	{
		cell = [[UITableViewCell alloc] initWithStyle: (UITableViewCellStyle) 1000 reuseIdentifier: NO];

		id editableTextField = [cell editableTextField];
		NSType(editableTextField);
		[editableTextField setPlaceholder: @"Rule Name"];
		
		NSString* text = dict ? [dict objectForKey: @"name"] : nil;
		
		[editableTextField setText: text];
		[cell setTextFieldOffset: 0];
		[cell setSelectionStyle: UITableViewCellSelectionStyleNone];
		[editableTextField setAutocapitalizationType: UITextAutocapitalizationTypeSentences];
		
		[editableTextField addTarget: self
							action: @selector(textChanged:)
							forControlEvents: UIControlEventEditingChanged];
	}
	else
	{
		cell = [[UITableViewCell alloc] initWithStyle: (UITableViewCellStyleValue1) reuseIdentifier: NO];
		[[cell textLabel] setText: @"Ring Profile"];
		
		NSMutableArray* keys = StyleKVs(NO);
		NSMutableArray* vals = StyleKVs(YES);
		
		NSNumber* style = [dict objectForKey: @"style"];
		
		int styleidx = (style!=nil) ? [keys indexOfObject: style] : NSNotFound;
		if(styleidx == NSNotFound)
		{
			style = [NSNumber numberWithInt: 1];
			[dict setValue: style forKey: @"style"];
			styleidx = [keys indexOfObject: style];
		}
		
		if(styleidx != NSNotFound)
		{
			[[cell detailTextLabel] setText: [vals objectAtIndex: styleidx]];
		}
		
		
		[cell setAccessoryType: UITableViewCellAccessoryDisclosureIndicator];
	}
	//
	return [cell autorelease];
}

@end