

//#define TESTING

#import "common.h"
#import "defines.h"

#import "classes.h"

#import "CPSelectionItem.h"

@implementation CPSelectionItem

// *************** SET THIS IN DERIVATIVE CLASSES

- (id) initWithIdentifier: (NSString*) newIdentifier
{
	if((self = [super init]))
	{
		identifier = [newIdentifier retain];
	}
	return self;
}

- (void) setIdentifier: (NSString*) newIdentifier
{
	[identifier release];
	identifier = [newIdentifier retain];
}

- (NSString*) identifier
{
	return identifier;
}

- (void) dealloc
{
	[keys release];
	[vals release];
	[selection release];
	[identifier release];
	[super dealloc];
}

- (void) setDelegate: (CPCustomTableController*) newDelegate
{
	delegate = newDelegate;	
}

- (void) setKeys: (NSArray*) newKeys vals: (NSArray*) newVals selection: (NSObject*) newSelection
{
	[keys release];
	[vals release];
	[selection release];
	keys = [newKeys retain];
	vals = [newVals retain];
	selection = [newSelection retain];
}

- (void) setSelection: (NSObject*) newSelection
{
	[selection release];
	selection = [newSelection retain];
}

- (id) selection
{
	return selection;
}


- (void) toggleSelection: (NSObject*) key
{
	if([(NSMutableSet*)selection containsObject: key])
	{
		[(NSMutableSet*)selection removeObject: key];
	}
	else
	{
		[(NSMutableSet*)selection addObject: key];
	}
}

- (BOOL) allowsMultipleSelection
{
	return NO;
}


- (void) markRow: (int) row
{
	SelLog();
	int nKeys = keys ? [keys count] : 0;
	
	NSObject* key = nil;
	if(row < nKeys && row >=0)
	{
		key = [keys objectAtIndex: row];
	}
	if([self allowsMultipleSelection])
	{
		if(key)
		{
			[self toggleSelection: key];
		}
	}
	else
	{
		[self setSelection: key];
	}
	NSLine();
	if(delegate && [delegate respondsToSelector: @selector(setSelection:forIdentifier:)])
	{
		NSLine();
		[delegate setSelection: selection forIdentifier: [self identifier]];
		NSLine();
	}
}

- (BOOL) isRowMarked: (int) row
{
	int nKeys = keys ? [keys count] : 0;
	
	NSObject* key = nil;
	if(row < nKeys && row >=0)
	{
		key = [keys objectAtIndex: row];
	}
	if(key)
	{
		if([self allowsMultipleSelection])
		{
			return [(NSMutableSet*)selection containsObject: key];
		}
		else
		{
			return [key isEqual: selection];
		}
	}
	return NO;
}

- (int) subitemCount
{
	int nKeys = keys ? [keys count] : 0;
	int nVals = vals ? [vals count] : 0;
	int cnt =  (nVals < nKeys) ? nVals : nKeys;
//	NSLog(@"subitemCount = %d", cnt);
	return cnt;
}

- (UITableViewCell*) cellForRow: (int) row
{
	UITableViewCell* cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleValue1 reuseIdentifier: NO];
	[[cell textLabel] setText: [vals objectAtIndex: row]];
	return [cell autorelease];
}

@end