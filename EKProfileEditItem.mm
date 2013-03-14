

//#define TESTING

#import "common.h"
#import "defines.h"

#import "classes.h"

#import "EKProfileEditItem.h"
#import "EKEventProfileEditItemViewController.h"

#import "dbmanager.h"

#import "StyleEventHandler.h"


UITableViewCell* EKProfileEditItem$cellForSubitemAtIndex$(EKEventEditItem* self, SEL sel, int index)
{
	SelLog();
	
	UITableViewCell* ret = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleValue1 reuseIdentifier: NO];
	
	[[ret textLabel] setText: @"Ring Profile"];
	
	EKEvent* &_event(MSHookIvar<EKEvent*>(self, "_event"));
	
	StyleEventHandler* shared = [StyleEventHandler sharedInstance];
	
	NSNumber* style = [shared styleForEvent: _event];
	
	NSLog(@"style = %d", [style intValue]);
		
	
//	NSArray* allStyles = AllStyles();
	NSMutableArray* vals = StyleKVs(YES);//[allStyles objectAtIndex: 0];
	NSMutableArray* keys = StyleKVs(NO);//[allStyles objectAtIndex: 1];
	
	int styleidx = [keys indexOfObject: style];
	if(styleidx == NSNotFound)
	{
		style = [NSNumber numberWithInt: 1];
		[shared enqueueStyleChange: style forEvent: _event];
		
		styleidx = [keys indexOfObject: style];
	}
	if(styleidx != NSNotFound)
	{
		NSLog(@"resolved style!");
		[[ret detailTextLabel] setText: [vals objectAtIndex: styleidx]];
	}
	else
	{
		NSLog(@"could not resolve style??");
	}
	
	
	[ret setAccessoryType: UITableViewCellAccessoryDisclosureIndicator];
	return [ret autorelease];
}

EKEventEditItemViewController* EKProfileEditItem$detailViewControllerWithFrame$forSubitemAtIndex$(EKEventEditItem* self, SEL sel, CGRect frame, int index)
{
	
	
	
	id ret = [[EKEventProfileEditItemViewController alloc] initWithFrame: frame];
	[ret setEditDelegate: self];
	
	EKEvent* &_event(MSHookIvar<EKEvent*>(self, "_event"));
	NSNumber* style = [[StyleEventHandler sharedInstance] styleForEvent: _event];
	
	[ret setSelection: style forIdentifier: @"style"];
	
	return (EKEventEditItemViewController*) [ret autorelease];
//	return nil;
}

BOOL EKProfileEditItem$eventEditItemViewControllerCommit$(EKEventEditItem* self, SEL sel, UIView* view)
{
	SelLog();
//	EKEventStore* &_store(MSHookIvar<EKEventStore*>(self, "_store"));
	EKEvent* &_event(MSHookIvar<EKEvent*>(self, "_event"));
	 
	
//	NSLog(@"rowID = %@", [_event rowId]);
	
//	NSLog(@"event is %@", [_event eventIdentifier]);
//	NSLog(@"style is %@", [view style]);
	
	StyleEventHandler* shared = [StyleEventHandler sharedInstance];
	if([[shared styleForEvent: _event] isEqual: [(EKEventProfileEditItemViewController*)view style]]==NO)
	{
		[shared enqueueStyleChange: [(EKEventProfileEditItemViewController*)view style] forEvent: _event];
		[self notifySubitemDidCommit: nil];
	}
	
		
	NSType(view);
	return YES;
}


void ClassCreate_EKProfileEditItem()
{
	if($EKEventEditItem)
	{
		$EKProfileEditItem = objc_allocateClassPair($EKEventEditItem, "EKProfileEditItem", 0);
		
		class_addMethod($EKProfileEditItem, @selector(cellForSubitemAtIndex:), (IMP) EKProfileEditItem$cellForSubitemAtIndex$, "@@:i");
		class_addMethod($EKProfileEditItem, @selector(detailViewControllerWithFrame:forSubitemAtIndex:), (IMP) EKProfileEditItem$detailViewControllerWithFrame$forSubitemAtIndex$, "@@:{{ff}{ff}}i");
		class_addMethod($EKProfileEditItem, @selector(eventEditItemViewControllerCommit:), (IMP) EKProfileEditItem$eventEditItemViewControllerCommit$, "C@:@");

//		class_addMethod($EKProfileEditItem, @selector(), (IMP) EKProfileEditItem$, "");
		objc_registerClassPair($EKProfileEditItem);
	}
	
}
