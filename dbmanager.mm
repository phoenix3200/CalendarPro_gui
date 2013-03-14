
//#define TESTING

#import "common.h"
#import "defines.h"

#import "dbmanager.h"

sqlite3* db = NULL;

void NotifyChange()
{
	CFNotificationCenterRef darwin = CFNotificationCenterGetDarwinNotifyCenter();
//	NSLog(@"callback!1111 %x", pthread_self());
	CFNotificationCenterPostNotification(darwin, (CFStringRef) @"_CPSettingsChanged", NULL, NULL, NULL);	
}

bool derivativeStyleCheck(int style, int potparent)
{
	if(style==potparent)
		return YES;
	if(style==0)
		return NO;
	const char *deriv = "select style from CPStyles where rowid = ?";
	sqlite3_stmt *deriv_stmt;
	sqlite3_prepare_v2(db, deriv, -1, &deriv_stmt, NULL);
	sqlite3_bind_int(deriv_stmt, 1, style);
	
	bool ret = NO;
	
	if(sqlite3_step(deriv_stmt)==SQLITE_ROW)
	{
		int parentStyle = sqlite3_column_int(deriv_stmt, 0);
		ret = derivativeStyleCheck(parentStyle, potparent);
	}
	sqlite3_finalize(deriv_stmt);
	return ret;
}


// need a finalize stmt in here
uint32_t modeForStyleID(int styleId, NSString *type, const char *mode)
{
	if(styleId==0)
		return 4;
	if(mode==nil)
		mode = [[NSString stringWithFormat: @"select %@, style from CPStyles where rowid = ?", type] UTF8String];
	sqlite3_stmt *mode_stmt;
	sqlite3_prepare_v2(db, mode, -1, &mode_stmt, NULL);
	sqlite3_bind_int(mode_stmt, 1, styleId);
	
	int ret = 4;
	
	if(sqlite3_step(mode_stmt)==SQLITE_ROW)
	{
		int style = sqlite3_column_int(mode_stmt, 0);
		if(style==4)
		{
			ret = modeForStyleID(sqlite3_column_int(mode_stmt, 1), nil, mode);
		}
		else
		{
			ret = style;
		}
	}
	sqlite3_finalize(mode_stmt);
	
	return ret;
}


uint32_t styleForEventId(int eventId)
{
	if(eventId<=0)
		return 0;
	
	if(!db)
		loadDB();
	
	if(eventId<=0)
	{
		return 0;
	}
	
	if(!db)
		return nil;
	
	uint32_t ret = 0;
	{
		const char *find = "select style from CPEvents where event = ?";
		sqlite3_stmt *find_stmt;
		if(sqlite3_prepare_v2(db, find, -1, &find_stmt, NULL)==SQLITE_OK)
		{
			sqlite3_bind_int(find_stmt, 1, eventId);
			if(sqlite3_step(find_stmt)==SQLITE_ROW)
			{
				ret = sqlite3_column_int(find_stmt, 0);
				NSLog(@"returning %d for %d", ret, eventId);
			}
			sqlite3_finalize(find_stmt);
		}
	}
	if(!ret)
	{
		const char *parent = "select orig_event_id from Event where rowid = ?";
		sqlite3_stmt *parent_stmt;
		if(sqlite3_prepare_v2(db, parent, -1, &parent_stmt, NULL)==SQLITE_OK)
		{
			sqlite3_bind_int(parent_stmt, 1, eventId);
			uint32_t res = sqlite3_step(parent_stmt);
			if(res==SQLITE_ROW)
			{
				int parentId = sqlite3_column_int(parent_stmt, 0);
				sqlite3_finalize(parent_stmt);
				NSLog(@"returning parent for %d", eventId);
				ret = styleForEventId(parentId);
			}
			sqlite3_finalize(parent_stmt);
		}
	}
	return ret;
}

void setStyleForEventId(uint32_t eventId, uint32_t style)
{
	NSLine();
	uint32_t res;
	{
		const char *find = "select style from CPEvents where event = ?";
		sqlite3_stmt *find_stmt;
		sqlite3_prepare_v2(db, find, -1, &find_stmt, NULL);
		sqlite3_bind_int(find_stmt, 1, eventId);
		res = sqlite3_step(find_stmt);
		sqlite3_finalize(find_stmt);
	}
	if(res==SQLITE_ROW)
	{
		NSLine();
		const char *insert = "update CPEvents set style = ? where event = ?";
		sqlite3_stmt *insert_stmt;
		sqlite3_prepare_v2(db, insert, -1, &insert_stmt, NULL);
		sqlite3_bind_int(insert_stmt, 1, style);
		sqlite3_bind_int(insert_stmt, 2, eventId);
		uint32_t res = sqlite3_step(insert_stmt);
		if(res != SQLITE_DONE)
			NSLog(@"error setting style");
		//		ret = sqlite3_last_insert_rowid(db);
		sqlite3_finalize(insert_stmt);
	}
	else if(res==SQLITE_DONE)
	{
		NSLine();
		const char *insert = "insert into CPEvents(event, style, hereditary) values (?, ?, 0)";
		sqlite3_stmt *insert_stmt;
		sqlite3_prepare_v2(db, insert, -1, &insert_stmt, NULL);
		sqlite3_bind_int(insert_stmt, 1, eventId);
		sqlite3_bind_int(insert_stmt, 2, style);
		uint32_t res = sqlite3_step(insert_stmt);
		if(res != SQLITE_DONE)
			NSLog(@"error setting style");
		//		ret = sqlite3_last_insert_rowid(db);
		sqlite3_finalize(insert_stmt);
	}
	NotifyChange();
}

uint32_t eventRow(uint32_t event)
{
	if(!db)
		loadDB();
	
	const char *find = "select rowid from CPEvents where event = ?";
	sqlite3_stmt *find_stmt;
	sqlite3_prepare_v2(db, find, -1, &find_stmt, NULL);
	sqlite3_bind_int(find_stmt, 1, event);
	
	uint32_t res = sqlite3_step(find_stmt);
	
//	NSLog(@"res = %d for event %d", res, event);
//	NSLog(@"sqlite3_column_int = %d", sqlite3_column_int(find_stmt, 0));
	uint32_t ret = 1;
	if(res == SQLITE_ROW)
	{
		ret = sqlite3_column_int(find_stmt, 0);
	}
	else
	{
		const char *insert = "insert into CPEvents(event, style, hereditary) values (?, 1, 0)";
		sqlite3_stmt *insert_stmt;
		sqlite3_prepare_v2(db, insert, -1, &insert_stmt, NULL);
		sqlite3_bind_int(insert_stmt, 1, event);
		res = sqlite3_step(insert_stmt);
		if(res == SQLITE_DONE)
			ret = sqlite3_last_insert_rowid(db);
		sqlite3_finalize(insert_stmt);
	}
//	NSLog(@"ret=%d", ret);
	sqlite3_finalize(find_stmt);
	return ret;
}


//NSArray *AllStyles$cached = nil;

NSMutableArray *StyleKVs(BOOL getVals)
{
	NSLine();
	if(!db)
		loadDB();
	
	
	static NSMutableArray* keys;
	static NSMutableArray* vals;
	
	if(getVals==0)
	{
		if(keys)
			return keys;
	}
	else
	{
		if(vals)
			return vals;
	}
	
	vals = [NSMutableArray new];
	keys = [NSMutableArray new];
	
	const char *styles = "select name, rowid from CPStyles order by priority";
	
	sqlite3_stmt *styles_stmt;
	if(sqlite3_prepare_v2(db, styles, -1, &styles_stmt, NULL)==SQLITE_OK)
	{
		while(sqlite3_step(styles_stmt)==SQLITE_ROW)
		{
			int rowid = sqlite3_column_int(styles_stmt, 1);
			NSString *name = [NSString stringWithUTF8String: (const char *) sqlite3_column_text(styles_stmt, 0)];
			if(rowid<=4)
			{
				name = RPLOC(name);
			}
			[vals addObject: name];
			[keys addObject: [NSNumber numberWithInt: rowid]];
		}
		sqlite3_finalize(styles_stmt);
	}
	if(getVals==0)
	{
		if(keys)
			return keys;
	}
	else
	{
		if(vals)
			return vals;
	}
	return nil;
}


void SaveStyleOrdering()
{
	NSMutableArray *keys = StyleKVs(0);

	NSEnumerator *enumerator = [keys objectEnumerator];

	const char *update = "update CPStyles set priority = ? where rowid = ?";
	
	sqlite3_stmt *update_stmt;
	for(int i=0; NSNumber *row = [enumerator nextObject]; i++)
	{
		if(sqlite3_prepare_v2(db, update, -1, &update_stmt, NULL)==SQLITE_OK)
		{
			sqlite3_bind_int(update_stmt, 1, i);
			sqlite3_bind_int(update_stmt, 2, [row intValue]);
			if(sqlite3_step(update_stmt)==SQLITE_DONE)
			{}
			sqlite3_finalize(update_stmt);
		}
	}
	NotifyChange();
	
}

void RemoveStyle(NSNumber* key)
{
	if(key)
	{
	
		const char* del = "delete from CPStyles where rowid = ?";
	
		sqlite3_stmt* del_stmt;
		if(sqlite3_prepare_v2(db, del, -1, &del_stmt, NULL)==SQLITE_OK)
		{
			sqlite3_bind_int(del_stmt, 1, [key intValue]);
			sqlite3_step(del_stmt);
			sqlite3_finalize(del_stmt);
		}
		int row = [StyleKVs(0) indexOfObject: key];
		if(row!=NSNotFound)
		{
			[StyleKVs(0) removeObjectAtIndex: row];
			[StyleKVs(1) removeObjectAtIndex: row];
		}
	}
	SaveStyleOrdering();
	
}

void InsertStyle(NSNumber* key, NSString* name)
{
	NSLog(@"InsertStyle(%d, %@", [key intValue], name);
	
	NSMutableArray* keys = StyleKVs(0);
	NSMutableArray* vals = StyleKVs(1);
	
	int row = [keys indexOfObject: key];
	if(row==NSNotFound)
	{
		[keys insertObject: key atIndex: 0];
		[vals insertObject: name atIndex: 0];
	}
	else
	{
		[vals removeObjectAtIndex: row];
		[vals insertObject: name atIndex: row];
	}

	SaveStyleOrdering();
}

NSMutableArray *RuleKVs(BOOL getVals)
{
	NSLine();
	
	static NSMutableArray *keys;
	static NSMutableArray* vals;
	
	if(keys && getVals==NO)
	{
		return keys;
	}
	if(vals && getVals==YES)
	{
		return vals;
	}
	keys = [NSMutableArray new];
	vals = [NSMutableArray new];
	
	
	const char *styles = "select name, rowid from CPRules order by priority";
	
	sqlite3_stmt *styles_stmt;
	if(sqlite3_prepare_v2(db, styles, -1, &styles_stmt, NULL)==SQLITE_OK)
	{
		while(sqlite3_step(styles_stmt)==SQLITE_ROW)
		{
			[vals addObject: [NSString stringWithUTF8String: (const char *) sqlite3_column_text(styles_stmt, 0)]];
			[keys addObject: [NSNumber numberWithInt: sqlite3_column_int(styles_stmt, 1)]];
		}
		sqlite3_finalize(styles_stmt);
	}
	if(keys && getVals==NO)
	{
		return keys;
	}
	if(vals && getVals==YES)
	{
		return vals;
	}
	return nil;
}


void SaveRuleOrdering()
{
	NSMutableArray *keys = RuleKVs(0);

	NSEnumerator *enumerator = [keys objectEnumerator];

	const char *update = "update CPRules set priority = ? where rowid = ?";
	
	sqlite3_stmt *update_stmt;
	for(int i=0; NSNumber *row = [enumerator nextObject]; i++)
	{
		if(sqlite3_prepare_v2(db, update, -1, &update_stmt, NULL)==SQLITE_OK)
		{
			sqlite3_bind_int(update_stmt, 1, i);
			sqlite3_bind_int(update_stmt, 2, [row intValue]);
			if(sqlite3_step(update_stmt)==SQLITE_DONE)
			{}
			sqlite3_finalize(update_stmt);
		}
	}
	NotifyChange();
	
}

void RemoveRule(NSNumber* key)
{
	if(key)
	{
	
		const char* del = "delete from CPRules where rowid = ?";
	
		sqlite3_stmt* del_stmt;
		if(sqlite3_prepare_v2(db, del, -1, &del_stmt, NULL)==SQLITE_OK)
		{
			sqlite3_bind_int(del_stmt, 1, [key intValue]);
			sqlite3_step(del_stmt);
			sqlite3_finalize(del_stmt);
		}
		int row = [RuleKVs(0) indexOfObject: key];
		if(row!=NSNotFound)
		{
			[RuleKVs(0) removeObjectAtIndex: row];
			[RuleKVs(1) removeObjectAtIndex: row];
		}
	}
	SaveRuleOrdering();
	
}

void InsertRule(NSNumber* key, NSString* name)
{
	NSLog(@"InsertRule(%d, %@", [key intValue], name);
	
	NSMutableArray* keys = RuleKVs(0);
	NSMutableArray* vals = RuleKVs(1);
	
	int row = [keys indexOfObject: key];
	if(row==NSNotFound)
	{
		[keys insertObject: key atIndex: 0];
		[vals insertObject: name atIndex: 0];
	}
	else
	{
		[vals removeObjectAtIndex: row];
		[vals insertObject: name atIndex: row];
	}
	SaveRuleOrdering();
}


NSArray *AllCalendars$cached = nil;

NSArray *AllCalendars()
{
	if(AllCalendars$cached)
		return AllCalendars$cached;
	
	NSMutableArray *names = [[NSMutableArray alloc] init];
	NSMutableArray *rowids = [[NSMutableArray alloc] init];
	
	const char *styles = "select title, rowid from Calendar where hidden = 0";
	const char *styles2 = "select title, rowid from Calendar where color_r >=0";

	sqlite3_stmt *styles_stmt;
	if(sqlite3_prepare_v2(db, styles, -1, &styles_stmt, NULL)==SQLITE_OK)
	{
		while(sqlite3_step(styles_stmt)==SQLITE_ROW)
		{
			[names addObject: [NSString stringWithUTF8String: (const char *) sqlite3_column_text(styles_stmt, 0)]];
			[rowids addObject: [NSNumber numberWithInt: sqlite3_column_int(styles_stmt, 1)]];
		}
		AllCalendars$cached = [[NSArray alloc] initWithObjects: names, rowids, nil];
		[names release];
		[rowids release];
		sqlite3_finalize(styles_stmt);
	}
	else if(sqlite3_prepare_v2(db, styles2, -1, &styles_stmt, NULL)==SQLITE_OK)
	{
		while(sqlite3_step(styles_stmt)==SQLITE_ROW)
		{
			[names addObject: [NSString stringWithUTF8String: (const char *) sqlite3_column_text(styles_stmt, 0)]];
			[rowids addObject: [NSNumber numberWithInt: sqlite3_column_int(styles_stmt, 1)]];
		}
		AllCalendars$cached = [[NSArray alloc] initWithObjects: names, rowids, nil];
		[names release];
		[rowids release];
		sqlite3_finalize(styles_stmt);
	}
	
	
	return AllCalendars$cached;
}







void loadDB()
{
	uint32_t err = sqlite3_open(DATABASE, &db);
	if(err != SQLITE_OK)
	{
		NSLog(@"database load error: %s", sqlite3_errmsg(db));
		NSLog(@"database load failed with error code %d", err);
		db = NULL;
	}
	else
	{
		NSLog(@"db open");
		
		const char *init_db_cmds[] = {
			0,
			"drop table CPEvents",
			"create table if not exists CPEvents (event integer, style integer default 1, hereditary integer default 0)",
			
			"drop table CPStyles",
			"create table if not exists CPStyles (name text, priority integer, editable integer default 1, main integer, alt integer)",
			
			"drop table CPStyleRules",
			"create table if not exists CPStyleRules (sys integer, ring integer, text integer, vm integer, imail integer, omail integer, cal integer, push integer)",
			
			
			"insert into CPStyleRules(sys, ring, text, vm, imail, omail, cal, push) values (4,		4,		4,		4,		4,		4,		4,		4)",
			//																		name			prior	edit	main,	alt	
			"insert into CPStyles(name, priority, editable, main, alt) values  (\"Default\",		4,		0,		1,		1)",
			//																				sys		ring	text	vm		imail	omail	cal		push
			"insert into CPStyleRules(sys, ring, text, vm, imail, omail, cal, push) values (1,		4,		4,		4,		4,		4,		4,		4)",
			//																		name			prior	edit	main,	alt	
			"insert into CPStyles(name, priority, editable, main, alt) values  (\"Always Vibrate\",	3,		0,		2,		2)",
			//																				sys		ring	text	vm		imail	omail	cal		push
			"insert into CPStyleRules(sys, ring, text, vm, imail, omail, cal, push) values (1,		4,		4,		4,		4,		4,		4,		4)",
			"insert into CPStyleRules(sys, ring, text, vm, imail, omail, cal, push) values (0,		4,		4,		4,		4,		4,		4,		4)",
			//																		name			prior	edit	main,	alt	
			"insert into CPStyles(name, priority, editable, main, alt) values  (\"Vibrate/Silent\",	2,		0,		3,		4)",
			//																				sys		ring	text	vm		imail	omail	cal		push
			"insert into CPStyleRules(sys, ring, text, vm, imail, omail, cal, push) values (0,		4,		4,		4,		4,		4,		4,		4)",
			//																		name			prior	edit	main,	alt	
			"insert into CPStyles(name, priority, editable, main, alt) values  (\"Silent\",			1,		0,		5,		5)",
			
			
			/*
			
			//																				sys		ring	text	vm		imail	omail	cal		push
			//																				sys		ring	text	vm		imail	omail	cal		push
			"insert into CPStyleRules(sys, ring, text, vm, imail, omail, cal, push) values (1,		4,		4,		4,		4,		4,		4,		4)",
			"insert into CPStyleRules(sys, ring, text, vm, imail, omail, cal, push) values (3,		4,		4,		4,		4,		4,		4,		4)",
			//																		name			prior	edit	main,	alt	
			"insert into CPStyles(name, priority, editable, main, alt) values  (\"Invert+Vibrate\",	0,		1,		1,		2)",
			//																				sys		ring	text	vm		imail	omail	cal		push
			"insert into CPStyleRules(sys, ring, text, vm, imail, omail, cal, push) values (0,		3,		4,		4,		4,		4,		4,		4)",
			//																		name			prior	edit	main,	alt	
			"insert into CPStyles(name, priority, editable, main, alt) values  (\"Ringer Only\",	1,		0,		3,		3)",
			//																				sys		ring	text	vm		imail	omail	cal		push
			"insert into CPStyleRules(sys, ring, text, vm, imail, omail, cal, push) values (1,		4,		4,		4,		4,		4,		4,		4)",
			//																		name			prior	edit	main,	alt	
			"insert into CPStyles(name, priority, editable, main, alt) values  (\"Vibrate\",		2,		0,		4,		4)",
			//																				sys		ring	text	vm		imail	omail	cal		push
			"insert into CPStyleRules(sys, ring, text, vm, imail, omail, cal, push) values (3,		4,		4,		4,		4,		4,		4,		4)",
			//																		name			prior	edit	main,	alt	
			"insert into CPStyles(name, priority, editable, main, alt) values  (\"Full\",			5,		1,		5,		5)",
			//																				sys		ring	text	vm		imail	omail	cal		push
			"insert into CPStyleRules(sys, ring, text, vm, imail, omail, cal, push) values (0,		3,		2,		2,		2,		2,		2,		2)",
			"insert into CPStyleRules(sys, ring, text, vm, imail, omail, cal, push) values (0,		1,		1,		1,		1,		1,		1,		1)",
			//																		name			prior	edit	main,	alt	
			"insert into CPStyles(name, priority, editable, main, alt) values  (\"Std. Only\",		6,		1,		6,		7)",
			*/
			
			"drop table CPRules",
			"create table if not exists CPRules (name text, priority integer, style integer, all_day integer, start_time integer, end_time integer, weekdays integer, match integer, override integer)",
			
																												// name		prior	style	alldy	startT	endT	weekdys	match
		//	"insert into CPRules(name, priority, style, all_day, start_time, end_time, weekdays, match) values (\"Rule 1\", 1,		2,		1,		0,		0,		127,	0)",	
		//	"insert into CPRules(name, priority, style, all_day, start_time, end_time, weekdays, match) values (\"Rule 2\", 0,		3,		0,		3600,	7200,	7,		0)",	
			
			
			"drop table CPRuleFilters",
			"create table if not exists CPRuleFilters (ruleid integer, filter integer, category integer, match integer, string text)",
																					//	ruleid	filter	categ	match	str
		//	"insert into CPRuleFilters(ruleid, filter, category, match, string) values (1,		0,		0,		0,		\"Test1\")",
		//	"insert into CPRuleFilters(ruleid, filter, category, match, string) values (1,		1,		1,		1,		\"Test2\")",
		//	"insert into CPRuleFilters(ruleid, filter, category, match, string) values (2,		0,		2,		2,		\"Test3\")",
			
			
			
			"drop trigger cp_event_drop",
			"drop trigger cp_rule_drop",
			"drop trigger cp_style_drop",
			
//			"create trigger if not exists cp_event_drop" "\n"
			"create trigger cp_event_drop" "\n"
				"before delete on Event" "\n"
				"for each row begin" "\n"
					"delete from CPEvents where event = old.rowid;" "\n"
				"end",
//			"drop trigger cp_rule_drop",
//			"create trigger if not exists cp_rule_drop" "\n"
			"create trigger cp_rule_drop" "\n"
				"before delete on CPRules" "\n"
				"for each row begin" "\n"
					"delete from CPRuleFilters where ruleid = old.rowid;" "\n"
				"end",
//			"drop trigger cp_style_drop",
//			"create trigger if not exists cp_style_drop" "\n"
			"create trigger cp_style_drop" "\n"
				"before delete on CPStyles" "\n"
				"for each row begin" "\n"
					"update CPEvents set style = 1 where style = old.rowid;" "\n"
					"delete from CPRules where style = old.rowid;" "\n"
					"delete from CPStyleRules where rowid = old.main;" "\n"
					"delete from CPStyleRules where rowid = old.alt;" "\n"
					//"update CPRules set style = 1 where style = old.rowid;" "\n"
				"end",
			0};
		
		//int i=0;
		{
			
			const char *check_init = "select * from CPStyles where name = \"Default\"";
			sqlite3_stmt *check_stmt;
			if(sqlite3_prepare_v2(db, check_init, -1, &check_stmt, NULL)==SQLITE_OK)
			{
				if(sqlite3_step(check_stmt)==SQLITE_ROW)
				{
					sqlite3_finalize(check_stmt);
					return;
				}
			}
			sqlite3_finalize(check_stmt);
			
		}
		int i = 1;
		
		for(; init_db_cmds[i]; i++)
		{
			uint32_t result = sqlite3_exec(db, init_db_cmds[i], NULL, NULL, NULL);
			
			{
				NSLog(@"init_db_cmds[%d] result code %d", i, result);
				if(result!=0)
				{
					NSLog(@"%s", init_db_cmds[i]);
				}
			}
		}
		NotifyChange();
//		NSLog(@"%d", i)
	}
	
}








NSMutableDictionary* LocalPrefsDict;

NSObject* LocalPreferencesCopyValue(NSString* key)
{
	//NSMutableDictionary* LocalPrefsDict = nil;
	if(!LocalPrefsDict)
	{
		NSLine();
		LocalPrefsDict = [[NSMutableDictionary dictionaryWithContentsOfFile: @"/var/mobile/Library/Calendar/cp4.plist"] retain];
	}
	if(LocalPrefsDict)
	{
		NSLine();
		NSLog(@"LocalPrefsDict: %@", [LocalPrefsDict description]);
		return [[LocalPrefsDict objectForKey: key] retain];
	}
	
	return nil;
}

void LocalPreferencesSetValue(NSString* key, NSObject* val)
{
	NSLine();
	NSLog(@"%@, %@", key, val);
//	NSMutableDictionary* LocalPrefsDict= nil;
	
	if(!LocalPrefsDict)
	{
		NSLine();
		LocalPrefsDict = [[NSMutableDictionary dictionaryWithContentsOfFile: @"/var/mobile/Library/Calendar/cp4.plist"] retain];// mutableCopy];
	}
	NSLine();
	if(!LocalPrefsDict)
	{
		NSLine();
		LocalPrefsDict = [NSMutableDictionary new];
	}
	NSLog(@"LocalPrefsDict: %@", [LocalPrefsDict description]);
	
	NSLine();
	if(LocalPrefsDict)
	{
		[LocalPrefsDict setValue: val forKey: key];
		NSLine();
		NSType(LocalPrefsDict);
		NSLog(@"LocalPrefsDict: %@", [LocalPrefsDict description]);
		NSLine();
		[LocalPrefsDict writeToFile: @"/var/mobile/Library/Calendar/cp4.plist" atomically: YES];
		NSLine();
	}
}


uint32_t htoi(const char *str)
{
	//	NSLine();
	
	uint32_t retval=0;
	for(int i=0; i<8; i++)
	{
		char c=str[i];
		if(c==0)
			break;
		c &=0x4F;
		if(c&0x40)
			c-=0x37;
		retval = (retval << 4) + c;
	}
	return retval;
}

extern "C" id lockdown_connect();
extern "C" void lockdown_disconnect(id port);
extern "C" NSString *lockdown_copy_value(id port, int idk, CFStringRef value);
extern "C" CFStringRef kLockdownUniqueDeviceIDKey;

NSString *cachedUDID = nil;

NSString *GetUDID()
{
	//	NSLine();
	
	if(!cachedUDID)
	{
		id port = nil;
		if((port = lockdown_connect()))
		{
			cachedUDID = lockdown_copy_value(port, 0, kLockdownUniqueDeviceIDKey);
			//[cachedUDID autorelease];
			lockdown_disconnect(port);
		}
	}
	return cachedUDID;
}


uint32_t currkey[4];

void decodeKey(const char *key_str)//, bool mode)
{
	NSLine();
	
	uint32_t currTime = 15;//time(0) >> (mode ? 17 : 20);
	
	//const char *key_str = [key UTF8String];
	uint32_t cell[5];
	for(int i=0; i<5; i++)
	{
		cell[i]=htoi(&key_str[8*i]);
	}
	
	const char *udid_str = [GetUDID() UTF8String];
	uint32_t udid[5];
	for(int i=0; i<5; i++)
	{
		udid[i]=htoi(&udid_str[8*i]);
	}
	
	uint32_t seed = currTime;
	rand_r(&seed);
	seed ^= udid[0];
	rand_r(&seed);
	seed ^= cell[0];
	
//	uint32_t keys[5];
	
	for(int i=1; i<5; i++)
	{
		rand_r(&seed);
		uint32_t ukey = cell[i];
		ukey ^= udid[i];
		rand_r(&ukey);
		ukey ^= seed;
		rand_r(&ukey);
		currkey[i-1]=ukey;
	}
}

bool shownMessage = FALSE;







void closeDB()
{
	sqlite3_close(db);
}

