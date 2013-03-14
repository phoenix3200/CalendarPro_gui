

//#define TESTING

#import "common.h"
#import "defines.h"

#import "classes.h"

#import "CPRuleEditorViewController.h"

//#import "CPEditableItem.h"

#import "dbmanager.h"

#import "CPRuleEditorItem.h"
#import "CPRuleEditorItemDate.h"
#import "CPRuleEditorItemFilters.h"


@implementation CPRuleEditorViewController

- (id) initWithFrame: (CGRect) frame
{
	if((self = [super initWithFrame: frame]))
	{
		[self setTitle: @"Edit Rule"];
	}
	return self;
}

- (void) dealloc
{
	[_dict release];
	[_filters release];
	[primaryKey release];
	[super dealloc];
}

- (NSArray*) tableItems
{
//	static NSArray* tableItems;
	if(_tableItems==nil)
	{
		CPRuleEditorItem* item0 = [[CPRuleEditorItem alloc] init];//WithIdentifier: @"style"];
		{
			// have it fetch the properties from us
			[item0 setDelegate: self];
			[item0 autorelease];
		}
		
		CPRuleEditorItemDate* item1 = [[CPRuleEditorItemDate alloc] init];
		{
			[item1 setDelegate: self];
			[item1 autorelease];
		}
		
		CPRuleEditorItemFilters* item2 = [[CPRuleEditorItemFilters alloc] init];
		{
			[item2 setDelegate: self];
			[item2 autorelease];
		}
		
		_tableItems = [[NSArray alloc] initWithObjects: 
						item0, item1, item2,
						nil];
	}
	return _tableItems;
}

- (void) setSelection: (NSObject*) selection forIdentifier: (NSString*) identifier
{
	[_dict setValue: selection forKey: identifier];
}


- (void) refreshSubitems
{
	NSArray* tableItems = [self tableItems];
	CPRuleEditorItem* item0 = [tableItems objectAtIndex: 0];
	[item0 setRuleDict: _dict];
	CPRuleEditorItemDate* item1 = [tableItems objectAtIndex: 1];
	[item1 setRuleDict: _dict];
	CPRuleEditorItemFilters* item2 = [tableItems objectAtIndex: 2];
	[item2 setFilterDict: _filters];
	
};

- (void) setPrimaryKey: (NSNumber*) newPrimaryKey
{
	if(primaryKey)
	{
		NSLog(@"FAIL!");
	}
	else
	{
		primaryKey = [newPrimaryKey retain];
		[self getRuleProperties];
		[self refreshSubitems];
		
		[_table reloadData];
//		[self reloadItemContent];
	}
}


- (NSString*) deleteButtonTitle
{
	if(primaryKey)
	{
		return RPLOC(@"Delete Rule");
	}
	return nil;
}


- (void) deleteButtonAction
{
	RemoveRule(primaryKey);
	[self cancel];
}


- (UIBarButtonSystemItem) leftItem
{
	return UIBarButtonSystemItemCancel;
}


- (void) leftAction
{
	[self cancel];
}

- (UIBarButtonSystemItem) rightItem
{
	return UIBarButtonSystemItemDone;
}

- (void) rightAction
{
	[self saveRuleProperties];
	
	
	
	
	[self saveAndDismiss];
}


- (void) getRuleProperties
{
	SelLog();
	
	const char *req = "select * from CPRules where rowid = ?";
	
	[_dict release];
	_dict = [[NSMutableDictionary alloc] initWithCapacity: 8];
	
	[_filters release];
	_filters = [[NSMutableArray alloc] init];
	
	if(primaryKey)
	{
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
					[_dict setObject: [NSNumber numberWithInt: sqlite3_column_int(req_stmt, 1)] forKey: @"priority"];
					[_dict setObject: [NSNumber numberWithInt: sqlite3_column_int(req_stmt, 2)] forKey: @"style"];
					[_dict setObject: [NSNumber numberWithInt: sqlite3_column_int(req_stmt, 3)] forKey: @"all_day"];
					[_dict setObject: [NSNumber numberWithInt: sqlite3_column_int(req_stmt, 4)] forKey: @"start_time"];
					[_dict setObject: [NSNumber numberWithInt: sqlite3_column_int(req_stmt, 5)] forKey: @"end_time"];
					[_dict setObject: [NSNumber numberWithInt: sqlite3_column_int(req_stmt, 6)] forKey: @"weekdays"];
					[_dict setObject: [NSNumber numberWithInt: sqlite3_column_int(req_stmt, 7)] forKey: @"match"];
					[_dict setObject: [NSNumber numberWithInt: sqlite3_column_int(req_stmt, 8)] forKey: @"override"];
				}
				else
				{
					NSLog(@"err = %d", err);
					//					NSLine();
				}
				if(sqlite3_step(req_stmt)==SQLITE_DONE)
				{
					NSLog(@"style properties retrieved");
					//NSLog([_dict description]);
					
					const char *filter = "select * from CPRuleFilters where ruleid = ?";
					sqlite3_stmt *filter_stmt;
					if(sqlite3_prepare_v2(db, filter, -1, &filter_stmt, NULL)==SQLITE_OK)
					{
						if(sqlite3_bind_int(filter_stmt, 1, [primaryKey intValue])==SQLITE_OK)
						{
							while(sqlite3_step(filter_stmt)==SQLITE_ROW)
							{
								NSMutableDictionary *subdict = [[NSMutableDictionary alloc] initWithCapacity: 4];
								NSLog(@"additional clause");
								[subdict setObject: [NSNumber numberWithInt: sqlite3_column_int(filter_stmt, 1)] forKey: @"filter"];
								[subdict setObject: [NSNumber numberWithInt: sqlite3_column_int(filter_stmt, 2)] forKey: @"category"];
								[subdict setObject: [NSNumber numberWithInt: sqlite3_column_int(filter_stmt, 3)] forKey: @"match"];
								[subdict setObject: [NSString stringWithUTF8String: (const char *) sqlite3_column_text(filter_stmt, 4)] forKey: @"string"];
								[_filters addObject: subdict];
								[subdict release];
							}
							
						}
					}
					sqlite3_finalize(filter_stmt);
				}
			}
		}
		sqlite3_finalize(req_stmt);
	}
	else
	{
		NSLine();
		[_dict setObject: @"" forKey: @"name"];
		[_dict setObject: [NSNumber numberWithInt: 0x7FFFFFFF] forKey: @"priority"];
		[_dict setObject: [NSNumber numberWithInt: 1] forKey: @"style"];
		[_dict setObject: [NSNumber numberWithInt: 1] forKey: @"all_day"];
		[_dict setObject: [NSNumber numberWithInt: 28800] forKey: @"start_time"];
		[_dict setObject: [NSNumber numberWithInt: 61200] forKey: @"end_time"];
		[_dict setObject: [NSNumber numberWithInt: 127] forKey: @"weekdays"];
		[_dict setObject: [NSNumber numberWithInt: 0] forKey: @"match"];
		[_dict setObject: [NSNumber numberWithInt: 0] forKey: @"override"];
	}
}

- (void) saveRuleProperties
{
	SelLog();
		
	if(primaryKey)
	{
		const char *upd = "update CPRules set name = ?, style = ?, all_day = ?, start_time = ?, end_time = ?, weekdays = ?, match = ?, override = ? where rowid = ?";
		
//		char *ins = "insert into CPRules (name, priority, style, all_day, start_time, end_time, weekdays, eventless) values (?, ?, ?, ?, ?, ?, ?, ?)";
		sqlite3_stmt *upd_stmt;
		if(sqlite3_prepare_v2(db, upd, -1, &upd_stmt, NULL)==SQLITE_OK)
		{
			sqlite3_bind_text(upd_stmt, 1, [[_dict objectForKey: @"name"] UTF8String], -1, SQLITE_STATIC);
			//sqlite3_bind_int(upd_stmt, 2, [[_dict objectForKey: @"priority"] intValue]);
			sqlite3_bind_int(upd_stmt, 2, [[_dict objectForKey: @"style"] intValue]);
			sqlite3_bind_int(upd_stmt, 3, [[_dict objectForKey: @"all_day"] intValue]);
			sqlite3_bind_int(upd_stmt, 4, [[_dict objectForKey: @"start_time"] intValue]);
			sqlite3_bind_int(upd_stmt, 5, [[_dict objectForKey: @"end_time"] intValue]);
			sqlite3_bind_int(upd_stmt, 6, [[_dict objectForKey: @"weekdays"] intValue]);
			sqlite3_bind_int(upd_stmt, 7, [[_dict objectForKey: @"match"] intValue]);
			sqlite3_bind_int(upd_stmt, 8, [[_dict objectForKey: @"override"] intValue]);
			sqlite3_bind_int(upd_stmt, 9, [primaryKey intValue]);
			
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
		const char *ins = "insert into CPRules(name, priority, style, all_day, start_time, end_time, weekdays, match, override) values (?, -1, ?, ?, ?, ?, ?, ?, ?)";
		sqlite3_stmt *ins_stmt;
		if(sqlite3_prepare_v2(db, ins, -1, &ins_stmt, NULL)==SQLITE_OK)
		{
			
			sqlite3_bind_text(ins_stmt, 1, [[_dict objectForKey: @"name"] UTF8String], -1, SQLITE_STATIC);
			//sqlite3_bind_int(ins_stmt, 2, [[_dict objectForKey: @"priority"] intValue]);
			sqlite3_bind_int(ins_stmt, 2, [[_dict objectForKey: @"style"] intValue]);
			sqlite3_bind_int(ins_stmt, 3, [[_dict objectForKey: @"all_day"] intValue]);
			sqlite3_bind_int(ins_stmt, 4, [[_dict objectForKey: @"start_time"] intValue]);
			sqlite3_bind_int(ins_stmt, 5, [[_dict objectForKey: @"end_time"] intValue]);
			sqlite3_bind_int(ins_stmt, 6, [[_dict objectForKey: @"weekdays"] intValue]);
			sqlite3_bind_int(ins_stmt, 7, [[_dict objectForKey: @"match"] intValue]);
			sqlite3_bind_int(ins_stmt, 8, [[_dict objectForKey: @"override"] intValue]);
			//sqlite3_bind_int(ins_stmt, 8, [_rule intValue]);
			
			if(sqlite3_step(ins_stmt)==SQLITE_DONE)
			{
				NSLog(@"new rule saved successfully");
				[primaryKey release];
				primaryKey = [[NSNumber numberWithInt: sqlite3_last_insert_rowid(db)] retain];
				
//				[self setKey: ];
			}
		
			sqlite3_finalize(ins_stmt);
			//[self setKey: [NSNumber numberWithInt: sqlite3_last_insert_rowid(db)]];
		}
//		NSLog(@"Done saving rule.  Key is %x %d", primaryKey, [primaryKey intValue]);
				
			
	//	NSLog(@"no valid style specified - not saving.");
		//		NSArray *ASC = AllStyles()
	}
	
	InsertRule(primaryKey, [_dict objectForKey: @"name"]);
	
	{
		const char *del = "delete from CPRuleFilters where ruleid = ?";
		
		sqlite3_stmt *del_stmt;
		
		sqlite3_prepare_v2(db, del, -1, &del_stmt, NULL);
		sqlite3_bind_int(del_stmt, 1, [primaryKey intValue]);
		sqlite3_step(del_stmt);
		sqlite3_finalize(del_stmt);
	}
	if(_filters)
	{
		NSEnumerator *enumerator = [_filters objectEnumerator];
		NSDictionary *dict;
		while(dict = [enumerator nextObject])
		{
			const char *ins = "insert into CPRuleFilters(ruleid, filter, category, match, string) values (?,	?, ?, ?, ?)";
			sqlite3_stmt *ins_stmt;
			if(sqlite3_prepare_v2(db, ins, -1, &ins_stmt, NULL)==SQLITE_OK)
			{
				sqlite3_bind_int(ins_stmt, 1, [primaryKey intValue]);
				sqlite3_bind_int(ins_stmt, 2, [[dict objectForKey: @"filter"] intValue]);
				sqlite3_bind_int(ins_stmt, 3, [[dict objectForKey: @"category"] intValue]);
				sqlite3_bind_int(ins_stmt, 4, [[dict objectForKey: @"match"] intValue]);
				sqlite3_bind_text(ins_stmt, 5, [[dict objectForKey: @"string"] UTF8String], -1, SQLITE_STATIC);
				
				sqlite3_step(ins_stmt);
				sqlite3_finalize(ins_stmt);
			}		
		}
	}
	
	NotifyChange();
	
}


@end