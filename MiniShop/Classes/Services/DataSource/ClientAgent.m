//
//  AgentJsonClient.m
//  LSClient
//
//  Created by Andy on 11-10-30.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "ClientAgent.h"
//#import "ASIFormDataRequest.h"

#import "AFHTTPClient.h"

#import "NSString+Mini.h"
#import "NSString+URLEncoding.h"


#import "MiniImageCache.h"
#import "MiniFileUtil.h"

#import "MiniUIAlertView.h"

#import <QuartzCore/QuartzCore.h>

#import "AppDelegate.h"

#import "MiniObject.h"

#import "UIView+Mini.h"

#import "NSString+URLEncoding.h"

#import "FBEncryptorAES.h"

@interface ClientAgent()
@property (nonatomic,strong)NSMutableDictionary *headers;
@end

@implementation ClientAgent

#pragma mark * Properties
#pragma mark * Initialization

#define DATA_CACHE_DIR @"Documents/user/data"

+ (ClientAgent *)sharedInstance
{
    static ClientAgent *instance;
    if (instance == nil)
    {
        @synchronized(self)
        {
            instance = [[ClientAgent alloc] init];
        }
    }
    return instance;
}

- (id)init
{
    self = [super init];
    if (self) {
    }
    return self;
}


- (void)throwNetWorkException:(NSString*)message
{
    double delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [[NSNotificationCenter defaultCenter] postNotificationName:@"MSNetWorkErrorNitification" object:nil userInfo:@{@"msg":message}];
    });

}

- (void)showServerExceptoin:(NSString *)string
{
    [MiniUIAlertView showAlertWithMessage:string title:@"服务器异常"];
}

- (void)cancelLogin:(void (^)(NSError *error, id data))block
{
    block ([NSError errorWithDomain:@"ls" code:KErr_NotLogin userInfo:nil], @"取消了登录");
}

- (void)showHttpError:(NSString *)string
{
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    UIView *view = [window viewWithTag:0xABBBCCDD];
    if (view != nil && !view.hidden)
    {
        return;
    }
    if (view == nil)
    {
        view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, window.width, 0)];
        view.hidden = YES;
        view.tag = 0xABBBCCDD;
        view.layer.masksToBounds = YES;
        view.backgroundColor = [UIColor clearColor];
        view.userInteractionEnabled = NO;
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, window.width - 40, MAXFLOAT)];
        label.numberOfLines = 0;
        label.tag = 0xBBBBCCDD;
        label.font = [UIFont systemFontOfSize:14];
        label.textColor = [UIColor whiteColor];
        label.lineBreakMode = NSLineBreakByCharWrapping;
        label.textAlignment = NSTextAlignmentCenter;
        label.backgroundColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.8f];
        label.layer.cornerRadius = 8;
        label.layer.masksToBounds = YES;
        [view addSubview:label];
        [window addSubview:view];
    }
    view.hidden = YES;
    UILabel *label = (UILabel *)[view viewWithTag:0xBBBBCCDD];
    label.text = string;
    [label sizeToFit];
    if (label.height < 60)
    {
        label.height = 60;
    }
    label.width = view.width - 20;
    view.height = label.height + 20;
    label.top = view.height;
    label.centerX = view.width / 2;
    view.bottom = window.height - 44;
    view.hidden = NO;
    [UIView animateWithDuration:0.25 animations:^{
         label.top = 10;
     } completion:^(BOOL finished) {
         [UIView animateWithDuration:0.25f delay:2 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
              label.top = view.height;
          } completion:^(BOOL finished) {
              view.hidden = YES;
          }];
     }];
}

+ (NSData *)cacheDataWithFilePath:(NSString *)filePath
{
    NSFileManager *manager = [NSFileManager defaultManager];
    NSDictionary *fileAttributes = [manager attributesOfFileSystemForPath:filePath error:nil];
    NSDate *fileModDate = [fileAttributes objectForKey:NSFileModificationDate];
    if ( fileModDate && [[NSDate date] timeIntervalSinceDate:fileModDate] > 1200 )
    {
        return nil;
    }
    else
    {
        NSData *data = [NSData dataWithContentsOfFile:filePath];
        return data;
    }
}

+ (NSString *)filePathForKey:(NSString *)key
{
    NSString *path = [NSHomeDirectory () stringByAppendingPathComponent:DATA_CACHE_DIR];
    NSFileManager *manager = [NSFileManager defaultManager];
    if ( ![manager fileExistsAtPath:path])
    {
        [manager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    path = [path stringByAppendingFormat:@"/%@",key];
    return path;
}

+ (void)saveData:(id)data forKey:(NSString*)key
{
    NSString *fp = [self filePathForKey:key];
    BOOL ret = [data writeToFile:fp atomically:YES];
    if ( ret )
    {
        ;
    }
}

+ (id)loadDataForKey:(NSString*)key
{
    NSString *fp = [self filePathForKey:key];
    NSData *data = [self cacheDataWithFilePath:fp];
    return data;
}

+ (NSString *)keyForCache:(NSString *)addr params:(NSDictionary*)params
{
    NSString *key = [[NSString stringWithFormat:@"%@-%@",addr,params==nil?@"":[params description]] MD5String];
    return key;
}

- (id)parseJsonValue:(id)json clazz:(Class)clazz
{
    if ( [json isKindOfClass:[NSArray class]] )
    {
        NSMutableArray *ret = [NSMutableArray array];
        for ( id v in (NSArray*)json )
        {
            id o = [[clazz alloc] init];
            [(MiniObject *)o convertWithJson:v];
            [ret addObject:o];
        }
        return ret;
    }
    else
    {
        id o = [[clazz alloc] init];
        [(MiniObject *)o convertWithJson:json];
        return o;
    }
}


///////////////////////////////////////////////////////
- (void)get:(NSString*)url  params:(NSDictionary *)params  headers:(NSDictionary*)headers block:(void (^)(NSError *error, id data, BOOL cache ))block
{
    [self getDataFromServer:url params:params headers:headers cachekey:nil clazz:nil isJson:NO showError:NO block:block];
}

- (void)getDataFromServer:(NSString *)url params:(NSDictionary *)params headers:(NSDictionary*)headers cachekey:(NSString *)key showError:(BOOL)showError block:(void (^)(NSError *error, id data, BOOL cache ))block
{
    [self getDataFromServer:url params:params headers:headers cachekey:key clazz:nil isJson:YES showError:showError block:block];
}

- (void)getDataFromServer:(NSString *)url params:(NSDictionary *)params headers:(NSDictionary*)headers cachekey:(NSString *)key clazz:(Class)clazz isJson:(BOOL)isJson showError:(BOOL)showError block:(void (^)(NSError *error, id data, BOOL cache ))block
{
    [self loadDataFromServer:url method:@"GET" params:params headers:headers cachekey:key clazz:clazz isJson:isJson mergeobj:nil showError:showError block:block];
}

- (void)receiveRespose:(NSString *)url responseObject:(NSData*)responseObject clazz:(Class)clazz  isJson:(BOOL)isJson key:(NSString*)key mergeobj:(MiniObject*)mergeobj encoding:(NSStringEncoding)encoding block:(void (^)(NSError *error, id data, BOOL cache ))block
{
    NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:encoding];
    LOG_DEBUG(@"\n<<<<<================================================\nResponse data for request: %@\n\n%@\n<<<<<================================================",url,responseStr);
    NSError *error = nil;
    if ( isJson )
    {
        if (responseObject!=nil) {
            NSJSONSerialization *data = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:&error];
            if ( data != nil )
            {
                if ( key != nil && key.length > 0 )
                {
                    [ClientAgent saveData:responseStr forKey:key];
                }
                if ( mergeobj != nil )
                {
                    [mergeobj convertWithJson:data];
                }
                if ( clazz != nil && [clazz isSubclassOfClass:[MiniObject class]] )
                {
                    id v = [self parseJsonValue:data clazz:clazz];
                    if ( v != nil )
                    {
                        id erno = [data valueForKey:@"errno"];
                        NSString *errmg = [data valueForKey:@"error"];
                        if ( (erno != nil && [erno intValue] !=0) ) {
                            if ( errmg == nil ) errmg = @"服务器吃饭去了";
                            error = [NSError errorWithDomain:@"MSError" code:-200 userInfo:@{NSLocalizedDescriptionKey:errmg}];
                        }
                       
                    }
                    block(error,v,NO);
                }
                else
                {
                    block (nil,data,NO);
                }
            }
            else
            {
                block( [NSError errorWithDomain:@"loadData" code:KErr_No_Data userInfo:@{NSLocalizedDescriptionKey:responseStr}], nil,NO);
            }
        }
        else
        {
            block( [NSError errorWithDomain:@"loadData" code:KErr_No_Data userInfo:@{NSLocalizedDescriptionKey:responseStr}], nil,NO);
        }
    }
    else
    {
        block (nil,responseStr,NO);
    }
}

- (void)parseCachedData:(NSData*)data clazz:(Class)clazz isJson:(BOOL)isJson block:(void (^)(NSError *error, id data, BOOL cache ))block
{
    if ( isJson )
    {
        NSError *error = nil;
        NSJSONSerialization *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
        if ( clazz != nil && [clazz isSubclassOfClass:[MiniObject class]] )
        {
            id v = [self parseJsonValue:json clazz:clazz];
            if ( v != nil && [[v valueForKey:@"errno"] intValue] != 0 )
            {
                NSString *errmg = [v valueForKey:@"error"];
                if ( errmg == nil ) errmg = @"服务器吃饭去了";
                error = [NSError errorWithDomain:@"MSError" code:-200 userInfo:@{NSLocalizedDescriptionKey:errmg}];
            }
            block(error,v, YES);
        }
        else
        {
            block(nil,json,YES);
        }
    }
    else
    {
        block(nil,data,YES);
    }
}

- (NSData*)decryptedData:(NSData*)responseData security:(BOOL)security
{
    if ( !security ) {
        return responseData;
    }
    else {
        NSString *aesKEY = @"Ddiw@#dijf)JR7#$";
        NSString *aesIV = @"+(*^$bdjdDR948D('";
        NSString *responseStr = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
        responseData = [FBEncryptorAES dataForHexString:responseStr];
        NSData* decryptedData = [FBEncryptorAES decryptData:responseData
                                                        key:[aesKEY dataUsingEncoding:NSUTF8StringEncoding]
                                                         iv:[aesIV dataUsingEncoding:NSUTF8StringEncoding]];
        return decryptedData;
    }

}

- (NSString*)encryptString:(NSString*)value
{
    NSString *aesKEY = @"Ddiw@#dijf)JR7#$";
    NSString *aesIV = @"+(*^$bdjdDR948D('";
    return [FBEncryptorAES encryptString:value keyString:aesKEY iv:aesIV];
}

- (void)loadDataFromServer:(NSString *)url method:(NSString *)method params:(NSDictionary *)params headers:(NSDictionary*)headers cachekey:(NSString *)key clazz:(Class)clazz isJson:(BOOL)isJson mergeobj:(MiniObject*)mergeobj showError:(BOOL)showError block:(void (^)(NSError *error, id data, BOOL cache ))block
{
    if ( key != nil && key.length > 0 ) {
        NSData *data = [ClientAgent loadDataForKey:key];
        if (data != nil && data.length > 0){
            [self parseCachedData:data clazz:clazz isJson:isJson block:block];
        }
    }
    dispatch_block_t __block__ = ^{
        NSString *addr = url;
        if ([@"GET" isEqualToString:method]) {
            NSMutableString *pm = [NSMutableString string];
            for ( NSString *rkey in params.allKeys ) {
                id value = [params valueForKey:rkey];
                if ([value isKindOfClass:[NSString class]]) {
                    [pm appendFormat:@"%@=%@&",rkey,[(NSString *)[params valueForKey:rkey] encodedURLString]];
                }
                else {
                    [pm appendFormat:@"%@=%lld&",rkey,[[params valueForKey:rkey] longLongValue]];
                }
            }
            if (pm.length>0) {
                [pm deleteCharactersInRange:NSMakeRange(pm.length-1,1)];
            }
            addr = [NSString stringWithFormat:([url rangeOfString:@"?"].length==0)?@"%@?%@":@"%@&%@",url,pm];
        }
        LOG_DEBUG(@"Start Request >> %@",addr);
        NSURL *url = [NSURL URLWithString:addr];
        AFHTTPClient *client = [AFHTTPClient clientWithURL:url];
        client.timeoutInterval = 30;
        [client setDefaultHeader:@"platform" value:@"iphone"];
        [client setDefaultHeader:[NSString stringWithFormat:@"%d",MAIN_VERSION] value:@"mainversion"];
        [client setDefaultHeader:@"version" value:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];
        NSEnumerator *enumerator = headers.keyEnumerator;
        NSString *hkey = enumerator.nextObject;
        while (hkey != nil) {
            [client setDefaultHeader:hkey value:[headers valueForKey:hkey]];
            hkey = enumerator.nextObject;
        }
        BOOL security = [@"1" isEqualToString:[params valueForKey:@"security"]];
        if ([@"POST" isEqualToString:method]) {
           [client postPath:@"" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
               [self receiveRespose:addr responseObject:[self decryptedData:responseObject security:security] clazz:clazz isJson:isJson key:key mergeobj:mergeobj encoding:(security?NSASCIIStringEncoding:NSUTF8StringEncoding) block:block];
           } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
               LOG_DEBUG(@"Response for request >> %@ \n %@",addr,[error localizedDescription]);
               block(error,nil,NO);
               if ( showError )
               [self throwNetWorkException:@"连接失败!请检查网络连接或服务是否正常！"];
           }];
        }
        else {
           [client getPath:@"" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
               [self receiveRespose:addr responseObject:[self decryptedData:responseObject security:security] clazz:clazz isJson:isJson key:key mergeobj:mergeobj encoding:(security?NSASCIIStringEncoding:NSUTF8StringEncoding) block:block];
           } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
               LOG_DEBUG(@"Response for request >> %@ \n %@",addr,[error localizedDescription]);
               block(error,nil,NO);
               if ( showError )
               [self throwNetWorkException:@"连接失败!请检查网络连接或服务是否正常！"];
           }];
        }
    };
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        __block__ ();
    });
}

+ (void)clearCache
{
    NSString *path = [NSHomeDirectory () stringByAppendingPathComponent:DATA_CACHE_DIR];
    NSFileManager *manager = [NSFileManager defaultManager];
    [manager removeItemAtPath:path error:nil];
}

@end
