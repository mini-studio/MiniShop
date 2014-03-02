

#import <Foundation/Foundation.h>
//#import "ASIHTTPRequest.h"

@class MiniObject;


#define KErr_NotLogin -4
#define KErr_No_Data  600

#define MSNetWorkErrorNitification @"MSNetWorkErrorNitification"


@interface ClientAgent : NSObject
//+ (NSString *)host;

- (void)throwNetWorkException:(NSString*)mess;

+ (NSString *)filePathForKey:(NSString *)key;

+ (ClientAgent*)sharedInstance;

- (void)setRequestHeaderWithKey:(NSString*)key value:(NSString*)value;

- (void)showServerExceptoin:(NSString *)string;

- (void)get:(NSString*)url  params:(NSDictionary *)params  block:(void (^)(NSError *error, id data, BOOL cache ))block;

- (void)getDataFromServer:(NSString *)url params:(NSDictionary *)params cachekey:(NSString *)key showError:(BOOL)showError block:(void (^)(NSError *error, id data, BOOL cache ))block;

- (void)getDataFromServer:(NSString *)url params:(NSDictionary *)params cachekey:(NSString *)key clazz:(Class)clazz isJson:(BOOL)isJson showError:(BOOL)showError block:(void (^)(NSError *error, id data, BOOL cache ))block;

- (void)loadDataFromServer:(NSString *)url  method:(NSString *)method params:(NSDictionary *)params cachekey:(NSString *)key clazz:(Class)clazz isJson:(BOOL)isJson mergeobj:(MiniObject*)mergeobj showError:(BOOL)showError block:(void (^)(NSError *error, id data, BOOL cache ))block;

+ (NSString *)keyForCache:(NSString *)addr params:(NSDictionary*)params;
+ (id)loadDataForKey:(NSString*)key;
+ (void)saveData:(id)data forKey:(NSString*)key;
+ (void)clearCache;

@end

