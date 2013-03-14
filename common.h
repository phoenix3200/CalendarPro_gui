// framework imports
#import <CoreFoundation/CoreFoundation.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import <sqlite3.h>

// hooking imports
#import <mach-o/dyld.h>
#import <objc/message.h>
#import <substrate.h>


#import "EKEvent.h"

#import "PreferencesDoubleTwoPartValueCell.h"
#import "PreferencesTableDoubleCell.h"
#import "PreferencesTwoPartValueCell.h"


extern "C" float PreferencesTableDoubleRowHeight;

extern "C" NSBundle* CalendarUIBundle();
extern "C" UIApplication* UIApp;
