

//#define TESTING

#import "common.h"
#import "defines.h"

#import "classes.h"

#import "CPStyleEditorViewController.h"

//#import "CPEditableItem.h"

#import "dbmanager.h"

#import "CPStyleEditorItem.h"

#import "CPStyleEditorItemProperties.h"

@implementation CPStyleEditorViewController

- (id) initWithFrame: (CGRect) frame
{
	if((self = [super initWithFrame: frame]))
	{
		[self setTitle: @"Edit Profile"];
	}
	return self;
}

- (void) dealloc
{
	[primaryKey release];
	[_dict release];
	[_mainDict release];
	[_altDict release];
	
	[super dealloc];
}

- (void) refreshSubitems
{
	NSLog(@"maindict = %p", _mainDict);
	//NSDesc(_mainDict);
	
	NSArray* tableItems = [self tableItems];

//	CPStyleEditorItem* mainItem = (CPStyleEditorItem*)[tableItems objectAtIndex: 0];
//	[mainItem setStyleDictionary: _dict];
	
	int submode;
	if([self isEditable])
	{
		if(_mainDict == _altDict)
			submode = 3;
		else
			submode = 1;
	}
	else
	{
		submode = 3;
	}
	
	
	CPStyleEditorItemProperties* mainTable = (CPStyleEditorItemProperties*)[tableItems objectAtIndex: 1];
	
	[mainTable setMode: submode];
	[mainTable setStyleDictionary: _mainDict];

	NSLog(@"altdict = %p", _altDict);
	
	//NSDesc(_altDict);
	
	if(_mainDict == _altDict)
		submode = 0;
	
	CPStyleEditorItemProperties* altTable = (CPStyleEditorItemProperties*)[tableItems objectAtIndex: 2];
	[altTable setMode: submode];
	[altTable setStyleDictionary: _altDict];
	
//	[(CPStyleEditorItemProperties*)[tableItems objectAtIndex: 2] setMode: 3];
}

- (NSString*) tableView: (UITableView*) table titleForHeaderInSection: (int) section
{
	if(_mainDict != _altDict)
	{
		if(section==1)
		{
			return @"Ringer Switch On";
		}
		if(section==2)
		{
			return @"Ringer Switch Off";
		}
	}
	return nil;
}

- (BOOL) ringerSwitch
{
	return _mainDict != _altDict;
}

- (void) switchChanged: (UISwitch*) switchObj
{
	SelLog();
	NSType(switchObj);
	if(switchObj.on)
	{
		NSLog(@"switch is ON");
		[_altDict release];
		_altDict = [_mainDict mutableCopy];
		//[[NSMutableDictionary alloc] initWithDictionary: _mainDict];
	}
	else
	{
		NSLog(@"switch is OFF");
		[_altDict release];
		_altDict = [_mainDict retain];
	}
	[self refreshSubitems];
	[_table reloadData];
}

- (NSString*) name
{
	return [_dict objectForKey: @"name"];
}

- (void) textChanged: (UITextField*) field
{
	[_dict setValue: [field text] forKey: @"name"];
}

- (NSString*) deleteButtonTitle
{
	if(primaryKey && isEditable)
	{
		return RPLOC(@"Delete Profile");
	}
	return nil;
}


- (void) deleteButtonAction
{
	RemoveStyle(primaryKey);
	[self cancel];
}


- (void) setPrimaryKey: (NSNumber*) newPrimaryKey
{
	if(primaryKey)
	{
		NSLog(@"FAIL!");
	}
	else
	{
		primaryKey = [newPrimaryKey retain];
		[self getStyleProperties];
		[self refreshSubitems];
		if(!isEditable)
		{
			[self setTitle: RPLOC([self name])];
		}
		
		[_table reloadData];
//		[self reloadItemContent];
	}
}

- (NSArray*) tableItems
{
//	static NSArray* tableItems;
	if(_tableItems==nil)
	{
		CPStyleEditorItem* item0 = [[CPStyleEditorItem alloc] init];//WithIdentifier: @"style"];
		{
			// have it fetch the properties from us
			[item0 setDelegate: self];
			[item0 autorelease];
		}
		
		CPStyleEditorItemProperties* item1 = [[CPStyleEditorItemProperties alloc] init];//WithIdentifier: @"main"];
		{
			[item1 setDelegate: self];
		//	[item1 setMode: 1];
		//	[item1 setStyleDictionary: [NSMutableDictionary new]];
			[item1 autorelease];
		}
		
		CPStyleEditorItemProperties* item2 = [[CPStyleEditorItemProperties alloc] init];//WithIdentifier: @"alt"];
		{
			[item2 setDelegate: self];
		//	[item2 setMode: 2];
		//	[item2 setStyleDictionary: [NSMutableDictionary new]];
			[item2 autorelease];
		}
		
		_tableItems = [[NSArray alloc] initWithObjects: 
						item0, item1, item2,
						nil];
	}
	return _tableItems;
}

- (UIBarButtonSystemItem) leftItem
{
	return isEditable ? UIBarButtonSystemItemCancel : (UIBarButtonSystemItem) -1;
	//return UIBarButtonSystemItemCancel;
}


- (void) leftAction
{
	[self cancel];
}

- (UIBarButtonSystemItem) rightItem
{
	return isEditable ? UIBarButtonSystemItemDone : (UIBarButtonSystemItem) -1;
}

- (void) rightAction
{
	[self saveStyleProperties];
	
	[self saveAndDismiss];
}

- (BOOL) isEditable
{
	return isEditable;
}

- (void) getStyleProperties
{
	SelLog();
	
	[_dict release];
	_dict = [[NSMutableDictionary alloc] initWithCapacity: 5];
	
	
	if(primaryKey)
	{
		const char *req = "select * from CPStyles where rowid = ?";
		sqlite3_stmt *req_stmt;
		if(sqlite3_prepare_v2(db, req, -1, &req_stmt, NULL)==SQLITE_OK)
		{
			if(sqlite3_bind_int(req_stmt, 1, [primaryKey intValue])==SQLITE_OK)
			{
				int err;
				if((err=sqlite3_step(req_stmt))==SQLITE_ROW)
				{
					NSLine();
					[_dict setObject: primaryKey forKey: @"rowid"];
					[_dict setObject: [NSString stringWithUTF8String: (const char *) sqlite3_column_text(req_stmt, 0)] forKey: @"name"];
					
					isEditable = sqlite3_column_int(req_stmt, 2);
					[_dict setObject: [NSNumber numberWithBool: isEditable] forKey: @"editable"];
					
					int mainStyRule = sqlite3_column_int(req_stmt, 3);
					int altStyRule = sqlite3_column_int(req_stmt, 4);
					[_dict setObject: [NSNumber numberWithInt: mainStyRule] forKey: @"main"];
					if(altStyRule != mainStyRule)
					{
						[_dict setObject: [NSNumber numberWithInt: altStyRule] forKey: @"alt"];
					}
					
				}
			}
			sqlite3_finalize(req_stmt);
		}
	}
	else
	{
		[_dict setObject: @"" forKey: @"name"];
		isEditable = YES;
		[_dict setObject: [NSNumber numberWithBool: isEditable] forKey: @"editable"];
	}
	
	[_mainDict release];
	[_altDict release];
	_mainDict = [[NSMutableDictionary alloc] initWithCapacity: 9];
	_altDict = nil;
	
	if(NSNumber *mainSty = [_dict objectForKey: @"main"])
	{
		
		const char *req = "select * from CPStyleRules where rowid = ?";
		sqlite3_stmt *req_stmt;
		if(sqlite3_prepare_v2(db, req, -1, &req_stmt, NULL)==SQLITE_OK)
		{
			if(sqlite3_bind_int(req_stmt, 1, [mainSty intValue])==SQLITE_OK)
			{
				int err;
				if((err=sqlite3_step(req_stmt))==SQLITE_ROW)
				{
					NSLine();
					[_mainDict setObject: [NSNumber numberWithInt: sqlite3_column_int(req_stmt, 0)] forKey: @"sys"];
					[_mainDict setObject: [NSNumber numberWithInt: sqlite3_column_int(req_stmt, 1)] forKey: @"ring"];
					[_mainDict setObject: [NSNumber numberWithInt: sqlite3_column_int(req_stmt, 2)] forKey: @"text"];
					[_mainDict setObject: [NSNumber numberWithInt: sqlite3_column_int(req_stmt, 3)] forKey: @"vm"];
					[_mainDict setObject: [NSNumber numberWithInt: sqlite3_column_int(req_stmt, 4)] forKey: @"imail"];
					[_mainDict setObject: [NSNumber numberWithInt: sqlite3_column_int(req_stmt, 5)] forKey: @"omail"];
					[_mainDict setObject: [NSNumber numberWithInt: sqlite3_column_int(req_stmt, 6)] forKey: @"cal"];
					[_mainDict setObject: [NSNumber numberWithInt: sqlite3_column_int(req_stmt, 7)] forKey: @"push"];
					
					[_mainDict setObject: [NSNumber numberWithBool: isEditable] forKey: @"editable"];

				}
			}
			sqlite3_finalize(req_stmt);
		}
		if(NSNumber *altSty = [_dict objectForKey: @"alt"])
		{
			_altDict = [[NSMutableDictionary alloc] initWithCapacity: 9];
			if(sqlite3_prepare_v2(db, req, -1, &req_stmt, NULL)==SQLITE_OK)
			{
				if(sqlite3_bind_int(req_stmt, 1, [altSty intValue])==SQLITE_OK)
				{
					int err;
					if((err=sqlite3_step(req_stmt))==SQLITE_ROW)
					{
						NSLine();
						[_altDict setObject: [NSNumber numberWithInt: sqlite3_column_int(req_stmt, 0)] forKey: @"sys"];
						[_altDict setObject: [NSNumber numberWithInt: sqlite3_column_int(req_stmt, 1)] forKey: @"ring"];
						[_altDict setObject: [NSNumber numberWithInt: sqlite3_column_int(req_stmt, 2)] forKey: @"text"];
						[_altDict setObject: [NSNumber numberWithInt: sqlite3_column_int(req_stmt, 3)] forKey: @"vm"];
						[_altDict setObject: [NSNumber numberWithInt: sqlite3_column_int(req_stmt, 4)] forKey: @"imail"];
						[_altDict setObject: [NSNumber numberWithInt: sqlite3_column_int(req_stmt, 5)] forKey: @"omail"];
						[_altDict setObject: [NSNumber numberWithInt: sqlite3_column_int(req_stmt, 6)] forKey: @"cal"];
						[_altDict setObject: [NSNumber numberWithInt: sqlite3_column_int(req_stmt, 7)] forKey: @"push"];
						
						[_altDict setObject: [NSNumber numberWithBool: isEditable] forKey: @"editable"];

					}
				}
			}
			sqlite3_finalize(req_stmt);
		}
		else
		{
			_altDict = [_mainDict retain];
		}
	}
	else
	{
		[_mainDict setObject: [NSNumber numberWithInt: 4] forKey: @"sys"];
		[_mainDict setObject: [NSNumber numberWithInt: 4] forKey: @"ring"];
		[_mainDict setObject: [NSNumber numberWithInt: 4] forKey: @"text"];
		[_mainDict setObject: [NSNumber numberWithInt: 4] forKey: @"vm"];
		[_mainDict setObject: [NSNumber numberWithInt: 4] forKey: @"imail"];
		[_mainDict setObject: [NSNumber numberWithInt: 4] forKey: @"omail"];
		[_mainDict setObject: [NSNumber numberWithInt: 4] forKey: @"cal"];
		[_mainDict setObject: [NSNumber numberWithInt: 4] forKey: @"push"];
		
		
		[_mainDict setObject: [NSNumber numberWithBool: isEditable] forKey: @"editable"];

		_altDict = [_mainDict retain];
	}
}

- (void) saveStyleProperties
{
	SelLog();
	
	if(NSNumber *mainSty = [_dict objectForKey: @"main"])
	{
		const char *del = "delete from CPRuleFilters where ruleid = ?";
		sqlite3_stmt *del_stmt;
		sqlite3_prepare_v2(db, del, -1, &del_stmt, NULL);
		sqlite3_bind_int(del_stmt, 1, [mainSty intValue]);
		sqlite3_step(del_stmt);
		sqlite3_finalize(del_stmt);
	}
	if(NSNumber *altSty = [_dict objectForKey: @"alt"])
	{
		const char *del = "delete from CPRuleFilters where ruleid = ?";
		sqlite3_stmt *del_stmt;
		sqlite3_prepare_v2(db, del, -1, &del_stmt, NULL);
		sqlite3_bind_int(del_stmt, 1, [altSty intValue]);
		sqlite3_step(del_stmt);
		sqlite3_finalize(del_stmt);
	}
	{
		//(sys integer, ring integer, text integer, vm integer, imail integer, omail integer, cal integer, push integer)",
		const char *ins = "insert into CPStyleRules(sys, ring, text, vm, imail, omail, cal, push) values (?, ?, ?, ?, ?, ?, ?, ?)";
		sqlite3_stmt *ins_stmt;
		if(sqlite3_prepare_v2(db, ins, -1, &ins_stmt, NULL)==SQLITE_OK)
		{
			sqlite3_bind_int(ins_stmt, 1, [[_mainDict objectForKey: @"sys"] intValue]);
			sqlite3_bind_int(ins_stmt, 2, [[_mainDict objectForKey: @"ring"] intValue]);
			sqlite3_bind_int(ins_stmt, 3, [[_mainDict objectForKey: @"text"] intValue]);
			sqlite3_bind_int(ins_stmt, 4, [[_mainDict objectForKey: @"vm"] intValue]);
			sqlite3_bind_int(ins_stmt, 5, [[_mainDict objectForKey: @"imail"] intValue]);
			sqlite3_bind_int(ins_stmt, 6, [[_mainDict objectForKey: @"omail"] intValue]);
			sqlite3_bind_int(ins_stmt, 7, [[_mainDict objectForKey: @"cal"] intValue]);
			sqlite3_bind_int(ins_stmt, 8, [[_mainDict objectForKey: @"push"] intValue]);
			
			if(sqlite3_step(ins_stmt)==SQLITE_DONE)
			{
				NSLog(@"new style saved successfully");
				[_dict setObject: [NSNumber numberWithInt: sqlite3_last_insert_rowid(db)] forKey: @"main"];
			}
			else
			{
				NSLog(@"error will robinson");
			}
			sqlite3_finalize(ins_stmt);
		}
		else
		{
			NSLog(@"error will robinson3");
		}
	}
	if(_mainDict != _altDict)
	{
		const char *ins = "insert into CPStyleRules(sys, ring, text, vm, imail, omail, cal, push) values (?, ?, ?, ?, ?, ?, ?, ?)";
		sqlite3_stmt *ins_stmt;
		if(sqlite3_prepare_v2(db, ins, -1, &ins_stmt, NULL)==SQLITE_OK)
		{
			sqlite3_bind_int(ins_stmt, 1, [[_altDict objectForKey: @"sys"] intValue]);
			sqlite3_bind_int(ins_stmt, 2, [[_altDict objectForKey: @"ring"] intValue]);
			sqlite3_bind_int(ins_stmt, 3, [[_altDict objectForKey: @"text"] intValue]);
			sqlite3_bind_int(ins_stmt, 4, [[_altDict objectForKey: @"vm"] intValue]);
			sqlite3_bind_int(ins_stmt, 5, [[_altDict objectForKey: @"imail"] intValue]);
			sqlite3_bind_int(ins_stmt, 6, [[_altDict objectForKey: @"omail"] intValue]);
			sqlite3_bind_int(ins_stmt, 7, [[_altDict objectForKey: @"cal"] intValue]);
			sqlite3_bind_int(ins_stmt, 8, [[_altDict objectForKey: @"push"] intValue]);
			
			if(sqlite3_step(ins_stmt)==SQLITE_DONE)
			{
				NSLog(@"new style saved successfully");
				[_dict setObject: [NSNumber numberWithInt: sqlite3_last_insert_rowid(db)] forKey: @"alt"];
			}
			else
			{
				NSLog(@"error will robinson2");
			}
			sqlite3_finalize(ins_stmt);
		}
	}
	else
	{
		[_dict removeObjectForKey: @"alt"];
	}
	
	if(primaryKey)
	{
		const char *upd = "update CPStyles set name = ?, main = ?, alt = ? where rowid = ?";
		sqlite3_stmt *upd_stmt;
		if(sqlite3_prepare_v2(db, upd, -1, &upd_stmt, NULL)==SQLITE_OK)
		{
			sqlite3_bind_text(upd_stmt, 1, [[_dict objectForKey: @"name"] UTF8String], -1, SQLITE_STATIC);
			int mainStyRule = [[_dict objectForKey: @"main"] intValue];
			int altStyRule = mainStyRule;
			if(NSNumber *altSty = [_dict objectForKey: @"alt"])
			{
				altStyRule = [altSty intValue];
			}
			
			sqlite3_bind_int(upd_stmt, 2, mainStyRule);
			sqlite3_bind_int(upd_stmt, 3, altStyRule);
			sqlite3_bind_int(upd_stmt, 4, [primaryKey intValue]);
			
			int err;
			if((err = sqlite3_step(upd_stmt))==SQLITE_DONE)
			{
				NSLog(@"properties saved successfully");
			}
			else
			{
				NSLog(@"err = %d", err);
			}
			sqlite3_finalize(upd_stmt);
		}
		else
		{
			NSLog(@"could not prepare");
		}
	}
	else
	{
		const char *ins = "insert into CPStyles (name, priority, editable, main, alt) values (?, -1, 1, ?, ?)";
		sqlite3_stmt *ins_stmt;
		if(sqlite3_prepare_v2(db, ins, -1, &ins_stmt, NULL)==SQLITE_OK)
		{
			sqlite3_bind_text(ins_stmt, 1, [[_dict objectForKey: @"name"] UTF8String], -1, SQLITE_STATIC);
			int mainStyRule = [[_dict objectForKey: @"main"] intValue];
			int altStyRule = mainStyRule;
			if(NSNumber *altSty = [_dict objectForKey: @"alt"])
			{
				altStyRule = [altSty intValue];
			}
			
			sqlite3_bind_int(ins_stmt, 2, mainStyRule);
			sqlite3_bind_int(ins_stmt, 3, altStyRule);
			
			if(sqlite3_step(ins_stmt)==SQLITE_DONE)
			{
				NSLog(@"new style saved successfully");
				
				primaryKey = [[NSNumber numberWithInt: sqlite3_last_insert_rowid(db)] retain];
			}
			sqlite3_finalize(ins_stmt);
		}
		
		NSLog(@"Done saving style.");
//		NSArray *ASC = AllStyles()
	}
	
	InsertStyle(primaryKey, [_dict objectForKey: @"name"]);
	
	NotifyChange();
	
//	NotifyChange();
}






@end