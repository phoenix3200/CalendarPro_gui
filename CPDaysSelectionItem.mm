



//#define TESTING

#import "common.h"
#import "defines.h"

#import "classes.h"

#import "CPDaysSelectionItem.h"

@implementation CPDaysSelectionItem


- (void) markRow: (int) row
{
	SelLog();
	int nKeys = keys ? [keys count] : 0;
	
	NSNumber* key = nil;
	if(row < nKeys && row >=0)
	{
		key = [keys objectAtIndex: row];
	}
	
	NSNumber* oldSelection = (NSNumber*) selection;
	selection = [[NSNumber numberWithInt: [oldSelection intValue] ^ [key intValue]] retain];
	[oldSelection release];	
	
	if(delegate && [delegate respondsToSelector: @selector(setSelection:forIdentifier:)])
	{
		NSLine();
		[delegate setSelection: selection forIdentifier: @"weekdays"];
		NSLine();
	}
}

- (BOOL) isRowMarked: (int) row
{
	int nKeys = keys ? [keys count] : 0;
	
	NSNumber* key = nil;
	if(row < nKeys && row >=0)
	{
		key = [keys objectAtIndex: row];
	}
	if(key)
	{
		return ([key intValue] & [(NSNumber*)selection intValue]) ? YES : NO;
	}
	return NO;
}

@end