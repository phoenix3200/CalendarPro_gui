

//#define TESTING

#import "common.h"
#import "defines.h"
#import "EKEventEditor.h"
#import "EKEventEditViewController.h"

#import "classes.h"

#import "EKProfileEditItem.h"

#import "StyleEventHandler.h"

HOOKDEF(NSArray*, EKEventEditor, _editItems)
{
	// check if we need to add our item
	NSArray* &_editItems(MSHookIvar<NSArray*>(self, "_editItems"));
	bool hasItems = _editItems ? YES : NO;
	
	NSArray* editItems = CALL_ORIG(EKEventEditor, _editItems);
	if(hasItems==NO && editItems) // "rising edge"
	{
		// the default is immutable
		editItems = [editItems mutableCopy];
		
		// add our item to the list
		EKProfileEditItem* newElem = [[$EKProfileEditItem alloc] init];
		[(NSMutableArray*) editItems insertObject: newElem atIndex: 0x3];
		[newElem release];
		
		// set the new list
		[_editItems release];
		_editItems = editItems;
	}
	return editItems;

	/*
	EKEventTitleEditItem : EKEventEditItem
	EKEventDateEditItem
	EKEventRecurrenceEditItem
	**** WE GO HERE ****
	EKEventAttendeesEditItem
	EKEventAlarmEditItem
	EKEventCalendarEditItem
	EKEventAvailabilityEditItem
	EKEventNotesEditItem
	*/
}

HOOKDEF(void, EKEventEditor, completeWithAction$animated$, int action, BOOL animated)
{
	EKEvent* event = [self event];
	StyleEventHandler* shared = [StyleEventHandler sharedInstance];
	switch(action)
	{
	case 0:
		[shared forgetEvent: event];
		break;
	case 1:
		[shared saveEvent: event];
		break;
	case 2:
		[shared deleteEvent: event];
		break;
	}
	CALL_ORIG(EKEventEditor, completeWithAction$animated$, action, animated);
}


EKEventEditViewController* eventEditor;

HOOKDEF(id, EKEventEditViewController, initWithNibName$bundle$, id nibname, id bundle)
{
	self = CALL_ORIG(EKEventEditViewController, initWithNibName$bundle$, nibname, bundle);
	eventEditor = self;
	return self;
}


@class EKEvent;

HOOKDEF(BOOL, EKEvent, isDirty)
{
	BOOL ret = CALL_ORIG(EKEvent, isDirty);
	if(ret==NO)
	{
		ret = [[StyleEventHandler sharedInstance] isEventDirty: self];
	}
	return ret;
}

HOOKDEF(BOOL, EKEvent, isDirtyIgnoringCalendar)
{
	BOOL ret = CALL_ORIG(EKEvent, isDirtyIgnoringCalendar);
	if(ret==NO)
	{
		ret = [[StyleEventHandler sharedInstance] isEventDirty: self];
	}
	return ret;
}


/*
HOOKDEF(BOOL, EKEvent, commit$error$, int val, id block)
{
	HookLog();
	NSLog(@"val is %d", val);
	return CALL_ORIG(EKEvent, commit$error$, val, block);
}

HOOKDEF(BOOL, EKEvent, remove$error$, int val, id block)
{
	HookLog();
	NSLog(@"val is %d", val);
	return CALL_ORIG(EKEvent, remove$error$, val, block);
}
*/




__attribute__((constructor)) void load()
{
	SelLog();
	
	Classes_Fetch();
	
	if($CalendarApplication)
	{
		ClassCreate_EKProfileEditItem();
		
		HOOKMESSAGE(EKEventEditor, _editItems, _editItems);
		HOOKMESSAGE(EKEventEditor, completeWithAction:animated:, completeWithAction$animated$);
		
		HOOKMESSAGE(EKEventEditViewController, initWithNibName:bundle:, initWithNibName$bundle$);
		
		GETCLASS(EKEvent);
		HOOKMESSAGE(EKEvent, isDirty, isDirty);
		HOOKMESSAGE(EKEvent, isDirtyIgnoringCalendar, isDirtyIgnoringCalendar);
		

	}
}

