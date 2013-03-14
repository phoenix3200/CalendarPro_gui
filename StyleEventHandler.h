
#import "EKEvent.h"

@interface StyleEventHandler : NSObject
{
	CFMutableDictionaryRef enqueued;
}

+ (id) sharedInstance;

- (id) init;
- (NSNumber*) styleForEvent: (EKEvent*) event;
- (BOOL) isEventDirty: (EKEvent*) event;
- (void) enqueueStyleChange: (NSNumber*) style forEvent: (EKEvent*) event;
- (void) forgetEvent: (EKEvent*) event;
- (void) saveEvent: (EKEvent*) event;
- (void) deleteEvent: (EKEvent*) event;

@end