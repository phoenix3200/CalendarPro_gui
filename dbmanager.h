
//#import <sqlite3.h>

extern sqlite3* db;

void NotifyChange();

void loadDB();
void closeDB();

#define setEventStyle(row, val)			sqlite3_set_int	("CPEvents", row, "style", val)
#define setEventHereditary(row, val)	sqlite3_set_int	("CPEvents", row, "hereditary", val)

#define eventStyle(row)			sqlite3_get_int	("CPEvents", row, "style")
#define eventHereditary(row)	sqlite3_get_int	("CPEvents", row, "hereditary")

//NSArray *AllStyles();
NSMutableArray *StyleKVs(BOOL getVals);
void SaveStyleOrdering();
void RemoveStyle(NSNumber* key);
void InsertStyle(NSNumber* key, NSString* name);

NSMutableArray *RuleKVs(BOOL getVals);
void SaveRuleOrdering();
void RemoveRule(NSNumber* key);
void InsertRule(NSNumber* key, NSString* name);

NSArray *AllCalendars();


uint32_t eventRow(uint32_t event);

uint32_t styleForEventId(int eventId);

uint32_t modeForStyleID(int styleId, NSString *type, const char *mode = nil);

bool derivativeStyleCheck(int style, int potparent);

void setStyleForEventId(uint32_t eventId, uint32_t style);

uint32_t *matchingStylesForEvent(uint32_t event);

bool CheckLicense();
