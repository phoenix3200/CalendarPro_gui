
//#define TESTING

#import "common.h"
#import "defines.h"

#import "CPStyleEditorItemProperties.h"

#import "CPSelectionViewController.h"

#import "CPStyleEditorViewController.h"

#import "CPStyleEditorItemPropertiesViewController.h"

NSString *styleTypeKeys[] = 
{
	@"sys",
	@"ring",
	@"text",
	@"vm",
	@"imail",
	@"omail",
	@"cal",
	@"push",
};

NSString *styleTypeVals[] = 
{
	@"System Behavior",
	@"Incoming Calls",
	@"New Text Message",
	@"New Voicemail",
	@"New Mail",
	@"Sent Mail",
	@"Calendar Alerts",
	@"Push Alerts"
};

NSString *modeShort[] = 
{
	@"Silent",
	@"Vibrate",
	@"Ring",
	@"Ring+Vib",
	@"Default"
};

NSString *modeLong[] = 
{
	@"Silent",
	@"Vibrate",
	@"Ring",
	@"Ring+Vibrate",
	@"Default",
};


@implementation CPStyleEditorItemProperties

- (void) dealloc
{
	[dict release];
	[super dealloc];
}

- (void) setDelegate: (CPCustomTableController*) newDelegate
{
	delegate = newDelegate;	
}

- (int) subitemCount
{
	switch(mode)
	{
		case 0:
			return 0;
		case 1:
			return 2;
		case 2:
			return 7;
		case 3:
			return 8;
	}
	return 0;
}

- (int) mode
{
	return mode;
}

- (void) setMode: (int) newMode
{
	mode = newMode;
}

- (void) setStyleDictionary: (NSMutableDictionary*) newDict
{
	[dict release];
	dict = [newDict retain];
}

- (BOOL) canDiscloseRow: (int) row
{
	return !delegate || [(CPStyleEditorViewController*)delegate isEditable];	
//	YES;
}


- (UITableViewCell*) cellForRow: (int) row
{
	UITableViewCell* cell = nil;//
	
	NSString* textLabel = nil;
	NSString* detailTextLabel = nil;
	
	BOOL detailedCheck = NO;
	
	
	SRPINIT();
	
	if(mode==2)
	{
		row+=1;
	}
	else if(mode==1 && row!=0)
	{
		detailedCheck = YES;
	}
	
	
	if(!detailedCheck)
	{
		textLabel = SRPLOC(styleTypeVals[row]);
		
		NSNumber* selection = nil;
		if(dict)
		{
			selection = [dict objectForKey: styleTypeKeys[row]];
		}
		int itemMode = 4; 
		if(selection)
		{
			itemMode = [selection intValue];
		}
		detailTextLabel = SRPLOC(modeShort[itemMode]);
	}
	else
	{
		textLabel = SRPLOC(@"Sound Modes");
		
		int i;
		for(i=1; i<8; i++)
		{
			NSNumber* val = [dict objectForKey: styleTypeKeys[i]];
			if(val && [val intValue] != 4)
				break;
		}
		
		detailTextLabel = (i==8) ? SRPLOC(@"Default") : SRPLOC(@"Custom");
	}
	
	{
		cell = [[UITableViewCell alloc] initWithStyle: (UITableViewCellStyleValue1) reuseIdentifier: NO];
		[[cell textLabel] setText: textLabel];
		[[cell detailTextLabel] setText: detailTextLabel];
		
		if(!delegate || [(CPStyleEditorViewController*)delegate isEditable])
			[cell setAccessoryType: UITableViewCellAccessoryDisclosureIndicator];
	}
	
	
	return [cell autorelease];
}

- (CPCustomTableController*) viewControllerWithFrame: (CGRect) frame forSubitemAtIndex: (int) index
{
	SRPINIT();
	
	BOOL creatingNested = NO;
	
	if(mode==2)
	{
		index+=1;
	}
	else if(mode==1 && index!=0)
	{
		creatingNested = YES;
	}
	
	static NSArray* keys;
	if(!keys)
	{
		keys = [[NSArray alloc] initWithObjects:
					[NSNumber numberWithInt: 4],
					[NSNumber numberWithInt: 0],
					[NSNumber numberWithInt: 1],
					[NSNumber numberWithInt: 2],
					[NSNumber numberWithInt: 3],
					nil];
	}
	static NSArray* vals;
	if(!vals)
	{
		vals = [[NSArray alloc] initWithObjects:
					SRPLOC(modeLong[4]),
					SRPLOC(modeLong[0]),
					SRPLOC(modeLong[1]),
					SRPLOC(modeLong[2]),
					SRPLOC(modeLong[3]),
					nil];
	}
	
	if(!creatingNested)
	{
		NSObject* selection = nil;
		if(dict)
		{
			selection = [dict objectForKey: styleTypeKeys[index]];
		}
		if(!selection)
		{
			selection = [NSNumber numberWithInt: 4];
		}
		
		CPSelectionViewController* vc = [[CPSelectionViewController alloc] initWithFrame: frame];
		[vc setTitle: SRPLOC(styleTypeVals[index])
		 	identifier: styleTypeKeys[index]
			keys: keys
			vals: vals
			selection: selection];
		[vc setItemDelegate: self];
		return [vc autorelease];
	}
	else
	{
		CPStyleEditorItemPropertiesViewController* vc = [[CPStyleEditorItemPropertiesViewController alloc] initWithFrame: frame];
		[vc setDict: dict];
		
		return [vc autorelease];
	}
}

- (void) setSelection: (NSObject*) selection forIdentifier: (NSString*) identifier
{
	if(dict)
	{
		[dict setValue: selection forKey: identifier];
	}
}



@end