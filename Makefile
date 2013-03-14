TWEAK_NAME = cpgui
cpgui_OBJCC_FILES = main.mm Classes.mm \
					EKProfileEditItem.mm CPCustomTableController.mm \
					EKEventProfileEditItemViewController.mm \
					CPEditableItem.mm \
					CPSelectionItem.mm CPSelectionViewController.mm \
					CPStyleManagerViewController.mm \
					dbmanager.mm StyleEventHandler.mm \
					CPStyleManagerItem.mm CPStyleEditorViewController.mm \
					CPStyleEditorItem.mm CPStyleEditorItemProperties.mm \
					CPStyleEditorItemPropertiesViewController.mm \
					CPRuleManagerItem.mm CPRuleManagerViewController.mm \
					CPRuleEditorViewController.mm \
					CPRuleEditorItem.mm CPRuleEditorItemDate.mm CPRuleEditorItemFilters.mm \
					CPTimeViewController.mm CPTimeViewControllerItems.mm \
					CPWeekViewController.mm CPDaysSelectionItem.mm \
					CPFilterViewController.mm CPFilterItem.mm

cpgui_FRAMEWORKS = UIKit EventKitUI
cpgui_PRIVATE_FRAMEWORKS = Preferences
cpgui_LDFLAGS = -lsqlite3 -llockdown

ADDITIONAL_OBJCCFLAGS = -fvisibility=hidden

ADDITIONAL_OBJCCFLAGS += -I/Users/public/decompile/iPhoneOS4.0.sdk/System/Library/Frameworks/EventKitUI.framework/Headers/
ADDITIONAL_OBJCCFLAGS += -I/Users/public/decompile/iPhoneOS4.0.sdk/System/Library/Frameworks/EventKit.framework/Headers/
ADDITIONAL_OBJCCFLAGS += -I/Users/public/decompile/iPhoneOS4.0.sdk/System/Library/Frameworks/UIKit.framework/Headers/
ADDITIONAL_OBJCCFLAGS += -I/Users/public/decompile/iPhoneOS4.0.sdk/System/Library/PrivateFrameworks/Preferences.framework/Headers/

GO_EASY_ON_ME =1
SDKVERSION = 4.0

include framework/makefiles/common.mk
include framework/makefiles/tweak.mk

