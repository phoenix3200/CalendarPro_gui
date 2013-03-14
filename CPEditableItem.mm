
//#define TESTING

#import "common.h"
#import "defines.h"

#import "classes.h"

#import "CPEditableItem.h"
#import "CPCustomTableController.h"

@implementation CPEditableItem

// *************** SET THIS IN DERIVATIVE CLASSES
- (NSString*) identifier
{
	return nil;
}

- (void) dealloc
{
	[keys release];
	[vals release];
	[super dealloc];
}

- (void) setDelegate: (CPCustomTableController*) newDelegate
{
	delegate = newDelegate;	
}

- (void) setKeys: (NSArray*) newKeys vals: (NSArray*) newVals detailClass: (Class) newClass;
{
	[keys release];
	[vals release];
	
	keys = [newKeys retain];
	vals = [newVals retain];
	detailClass = newClass;
}

- (int) subitemCount
{
	int nKeys = keys ? [keys count] : 0;
	int nVals = vals ? [vals count] : 0;
	int cnt =  (nVals < nKeys) ? nVals : nKeys;
//	NSLog(@"subitemCount = %d", cnt);
	return cnt;
}

- (BOOL) canDiscloseRow: (int) row
{
	return YES;
}

- (UITableViewCell*) cellForRow: (int) row
{
	UITableViewCell* cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleValue1 reuseIdentifier: NO];
	[[cell textLabel] setText: [vals objectAtIndex: row]];
	if([self canDiscloseRow: row])
	{
		[cell setAccessoryType: UITableViewCellAccessoryDisclosureIndicator];
		[cell setEditingAccessoryType: UITableViewCellAccessoryDisclosureIndicator];
	}
	
	//[cell setEditing: YES];
	
	return [cell autorelease];
}

- (void) moveRow: (int) src toRow: (int) dest
{
	id key = [keys objectAtIndex: src];
	id val = [vals objectAtIndex: src];
	[keys removeObjectAtIndex: src];
	[vals removeObjectAtIndex: src];
	[keys insertObject: key atIndex: dest];
	[vals insertObject: val atIndex: dest];
	
	
	if(delegate && [delegate respondsToSelector: @selector(orderChanged)])
	{
		[delegate orderChanged];
	}

}

- (CPCustomTableController*) viewControllerWithFrame: (CGRect) frame forSubitemAtIndex: (int) index;
{
	CPCustomTableController* vc = [(CPCustomTableController*)[detailClass alloc] initWithFrame: frame];
	if([vc respondsToSelector: @selector(setPrimaryKey:)])
	{
		[vc setPrimaryKey:  [keys objectAtIndex: index]];
	}
	
	return [vc autorelease];
}

- (BOOL) deleteRow: (int) row
{
	SelLog();
//	if([self respondsToSelector: @selector(canDeleteRow:)] && [self canDeleteRow: row])
	{
		NSObject* removed = [[[keys objectAtIndex: row] retain] autorelease];
		
		[keys removeObjectAtIndex: row];
		[vals removeObjectAtIndex: row];
		
		
		if(delegate && [delegate respondsToSelector: @selector(itemRemoved:)])
		{
			[delegate itemRemoved: removed];
		}
		
		return YES;
	}
	return NO;
}

@end
