

#define DYDUDebugLog(fmt, ...) { if ([DoYouDreamUpPersistance logEnable]) { NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__); } }
#define DYDUWarningLog(fmt, ...) { if ([DoYouDreamUpPersistance logEnable]) { NSLog((@"WARNING:%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__); }}

#define DYDUErrorLog(fmt, ...) {NSLog((@"Error:%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);}