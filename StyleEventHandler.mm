
//#define TESTING

#import "common.h"
#import "defines.h"

#import "StyleEventHandler.h"

#import "EKEvent.h"

#import "dbmanager.h"

@implementation StyleEventHandler


+ (id) sharedInstance
{
	static StyleEventHandler* shared;
	if(!shared)
	{
		shared = [[self alloc] init];
	}
	return shared;
}


- (id) init
{
	if((self = [super init]))
	{
		enqueued = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
	}
	return self;
}


- (NSNumber*) styleForEvent: (EKEvent*) event
{
	NSNumber* style = (NSNumber*) CFDictionaryGetValue(enqueued, (void*) event);
	if(!style)
	{
		int row = [[event rowId] intValue];
		
		// fetch from db
		int istyle = (row>0) ? styleForEventId(row) : 0;
		
		style = [NSNumber numberWithInt: (istyle>0) ? istyle : 1];
	}
	
	return style;
}

- (NSNumber*) _styleForEvent: (EKEvent*) event
{
	return (NSNumber*) CFDictionaryGetValue(enqueued, (void*) event);
}

- (BOOL) isEventDirty: (EKEvent*) event
{
	SelLog();
	
	NSNumber* rowid = [event rowId];
	NSLog(@"rowid = %@", rowid);
	BOOL ret = [self _styleForEvent: event] ? YES : NO;
	NSLog(@"isEventDirty? %d", ret);
	return ret;
}

- (void) enqueueStyleChange: (NSNumber*) style forEvent: (EKEvent*) event
{
	SelLog();
	
	NSNumber* rowid = [event rowId];
	NSLog(@"rowid = %@", rowid);
	if(style)
	{
		CFDictionarySetValue(enqueued, (void*) event, (void*) style);
	}
	else
	{
		CFDictionaryRemoveValue(enqueued, (void*) event);
	}
	
}


- (void) forgetEvent: (EKEvent*) event
{
	NSLine();
	CFDictionaryRemoveValue(enqueued, (void*) event);
//	CFDictionarySetValue(enqueued, (void*) event, (void*) NULL);
	NSLine();
	
}

- (void) saveEvent: (EKEvent*) event
{
	SelLog();
	
	int style = [[self _styleForEvent: event] intValue];
	
	int row = [[event rowId] intValue];
	
	NSLog(@"rowid = %d, style = %d", row, style);
	
	if(row>0 && style>0)
	{
		setStyleForEventId(row, style);
	}
	else
	{
		NSLog(@"FAIL! now rowid available");
	}
	
	NSLine();
	CFDictionaryRemoveValue(enqueued, (void*) event);
	//CFDictionarySetValue(enqueued, (void*) event, (void*) NULL);
	NSLine();
}

- (void) deleteEvent: (EKEvent*) event
{
	SelLog();
	
	NSNumber* rowid = [event rowId];
	NSLog(@"rowid = %@", rowid);
	
	if([rowid intValue]==-1)
	{
		NSLog(@"FAIL! deleting nonexistent rowid");
	}
	
	NSLine();
	CFDictionaryRemoveValue(enqueued, (void*) event);
//	CFDictionarySetValue(enqueued, (void*) event, (void*) NULL);
	NSLine();
}


@end