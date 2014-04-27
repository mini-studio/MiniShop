//
//  ClientAgent+LS.m
//  xcmg
//
//  Created by Wuquancheng on 12-11-11.
//  Copyright (c) 2012年 mini. All rights reserved.
//

#import "ClientAgent+Mini.h"
#import "AFHTTPClient.h"
#import "MSObject.h"
#import "MSVersion.h"
#import "MSSystem.h"
#import "MSUIAuthWebViewController.h"
#import "MSFShopInfo.h"
#import "NSString+URLEncoding.h"
#import "NSString+Mini.h"
#import "NSData+Base64.h"
#import "UIDevice+Ext.h"

#define TB_HTTP_REQ_PATH_NEWNOTIFY                      @"api/notify"
#define TB_HTTP_REQ_PATH_LOOK                           @"api/look"
#define TB_HTTP_REQ_PATH_FEEDBACK                       @"api/msg"
#define TB_HTTP_REQ_PATH_GOODSPROMPTION                 @"api/goods"
#define TB_HTTP_REQ_PATH_GOODSIDS                       @"api/newsgoods"
#define TB_HTTP_REQ_PATH_DEVICETOKEN                    @"api/iostoken"
#define TB_HTTP_REQ_PATH_VERSIONCHECK                   @"api/version"

#define TB_HTTP_REQ_PATH_NEWNOTIFY_BGIMAGE              @"api/image"

#define SCREEN_SCALE ([[UIScreen mainScreen] scale])
#define SCREEN_SIZE ([UIScreen mainScreen].bounds.size)

@implementation ClientAgent (LS)

+ (NSString *)host
{
    return @"http://www.youjiaxiaodian.com";
}


+ (NSString *)imageUrl:(NSString *)path
{
    return [NSString stringWithFormat:@"http://%@%@",[ClientAgent host],path];
}

+ (NSString *)jumpToTaoBaoUrl:(NSString *)type
{
    return [NSString stringWithFormat:@"http://youjiaxiaodian.com/api/jumptaobao?type=%@&device=iphone",type];
}

-(NSMutableDictionary*)perfectParameters:(NSDictionary*)param headers:(NSMutableDictionary*)headers
{
    return [self perfectParameters:param security:NO headers:headers];
}

- (void)perfectHttpRequest:(NSMutableURLRequest *)requst
{
    NSString *imei = @"";
    if ( [MSSystem sharedInstance].udid.length > 0 ) {
        imei = [MSSystem sharedInstance].udid;
    }
    else {
        if ( [MSSystem sharedInstance].mainVersion >= 7 ) {
            ;
        }
        else {
            imei = UDID;
        }
    }
    if (imei.length > 0)
    [requst setValue:imei forHTTPHeaderField:@"imei"];
    
    if ( WHO !=nil && WHO.uniqid.length>0) {
        [requst setValue:WHO.uniqid forHTTPHeaderField:@"uniqid"];
    }
    
    [requst setValue:@"iphone" forHTTPHeaderField:@"sys_device"];
    [requst setValue:[NSString stringWithFormat:@"%d",MAIN_VERSION] forHTTPHeaderField:@"sys_version"];
    [requst setValue:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"] forHTTPHeaderField:@"app_version"];
}

-(NSMutableDictionary*)perfectParameters:(NSDictionary*)param security:(BOOL)security headers:(NSMutableDictionary*)headers
{
    NSMutableDictionary * p = param==nil?[NSMutableDictionary dictionary]:[NSMutableDictionary dictionaryWithDictionary:param];
    {
        NSString *imei = @"";
        if ( [MSSystem sharedInstance].udid.length > 0 ) {
            imei = [MSSystem sharedInstance].udid;
        }
        else {
            if ( [MSSystem sharedInstance].mainVersion >= 7 ) {
                ;
            }
            else {
                imei = UDID;
            }
        }
        [p setObject:imei forKey:@"imei"];
        headers[@"imei"] = imei;
    }
    {
        if ( WHO !=nil && WHO.uniqid.length>0) {
            [p setValue:WHO.uniqid forKey:@"uniqid"];
            headers[@"uniqid"] = WHO.uniqid;
        }
    }
    {
        headers[@"sys_device"] = @"iphone";
        headers[@"sys_version"] = [NSString stringWithFormat:@"%d",MAIN_VERSION];
        headers[@"app_version"] = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    }
    {
        if ( security ) {
            [p setValue:@"1" forKey:@"security"];
        }
    }
    [p setObject:@"" forKey:@"usernick"];
    [p setObject:@"json" forKey:@"tn"];
    NSString *w = [NSString stringWithFormat:@"%d",(int)(SCREEN_SIZE.width*SCREEN_SCALE)];
    NSString * h = [NSString stringWithFormat:@"%d",(int)(SCREEN_SIZE.height*SCREEN_SCALE)];
    [p setValue:w forKey:@"screenW"];
    [p setValue:h forKey:@"screenY"];
    [p setValue:h forKey:@"screenH"];
    
   
    return p;
}

+ (NSString *)prefectUrl:(NSString*)url
{
    if ( WHO != nil && WHO.uniqid.length > 0 ) {
        if ( [url rangeOfString:@"?"].length > 0 ) {
            return [NSString stringWithFormat:@"%@&uniqid=%@&imei=%@",url,WHO.uniqid,UDID];
        }
        else {
            return [NSString stringWithFormat:@"%@?uniqid=%@&imei=%@",url,WHO.uniqid,UDID];
        }
    }
    else {
        return url;
    }
}

- (NSString*)requestUri:(NSString *)path
{
    return [NSString stringWithFormat:@"%@/api/%@",[ClientAgent host],path];
}

- (NSString*)requestNewUri:(NSString *)path
{
    return [NSString stringWithFormat:@"%@/new/%@",[ClientAgent host],path];
}

- (NSString *)requestUri:(NSString *)path param:(NSDictionary*)param
{
    NSString* uri = [self requestUri:path];
    if ( param != nil ) {
        NSMutableDictionary *headers = [NSMutableDictionary dictionary];
        NSMutableDictionary *params = [self perfectParameters:param headers:headers];
        NSMutableString *pm = [NSMutableString string];
        for ( NSString *rkey in params.allKeys )
        {
            [pm appendFormat:@"%@=%@&",rkey,[(NSString *)[params valueForKey:rkey] encodedURLString]];
        }
        if ( pm.length > 0 )
        {
            [pm deleteCharactersInRange:NSMakeRange(pm.length-1,1)];
        }
        uri = [NSString stringWithFormat:@"%@?%@",uri,pm];
    }
    return uri;
}

- (void)registe:(NSString*)uname passwd:(NSString*)passwd mobile:(NSString*)mobile block:(void (^)(NSError *error, id data, id userInfo , BOOL cache ))block
{
    if (mobile==nil) {
        mobile = @"";
    }
    NSString *addr = [self requestUri:@"newreg" param:@{}];
    NSMutableDictionary *headers = [NSMutableDictionary dictionary];
    NSDictionary *dic = [self perfectParameters:@{@"name":uname,@"passwd":passwd,@"mobile":mobile} security:NO headers:headers];
    [self loadDataFromServer:addr method:@"POST" params:dic headers:headers cachekey:nil clazz:[MSUser class] isJson:YES mergeobj:nil showError:YES block:^(NSError *error, MSUser* user, BOOL cache) {
        if ( error == nil ) {
            if ( user.uniqid.length==0 ) {
                error = [NSError errorWithDomain:@"registe" code:200 userInfo:@{NSLocalizedDescriptionKey:@"注册异常"}];
            }
            else {
                if ( user.usernick.length == 0 ) {
                    user.usernick = uname;
                }
                WHO = user;
            }
        }
        block(error,user,nil,NO);
    }];
}

- (void)login:(NSString*)uname passwd:(NSString*)passwd  block:(void (^)(NSError *error, id data, id userInfo , BOOL cache ))block
{
    NSString *addr = [self requestUri:@"newlogin" param:@{}];
    NSMutableDictionary *headers = [NSMutableDictionary dictionary];
    NSDictionary *dic = [self perfectParameters:@{@"name":uname,@"passwd":passwd} security:NO headers:headers];
    [self loadDataFromServer:addr method:@"POST" params:dic headers:headers cachekey:nil clazz:[MSUser class] isJson:YES mergeobj:nil showError:YES block:^(NSError *error, MSUser* user, BOOL cache) {
        if ( error == nil ) {
            if ( user.uniqid.length==0 ) {
                error = [NSError errorWithDomain:@"login" code:200 userInfo:@{NSLocalizedDescriptionKey:@"登录异常"}];
            }
            else {
                if ( user.usernick.length == 0 ) {
                    user.usernick = uname;
                }
                WHO = user;
            }
        }
        block(error,user,nil,NO);
    }];
}

- (void)resetpasswd:(NSString*)uname mobile:(NSString*)mobile  block:(void (^)(NSError *error, id data, id userInfo , BOOL cache ))block
{
    NSString *addr = [self requestUri:@"resetpasswd"];
    NSMutableDictionary *headers = [NSMutableDictionary dictionary];
    NSMutableDictionary *dic = [self perfectParameters:@{@"name":uname,@"mobile":mobile} headers:headers];
    [self getDataFromServer:addr params:dic headers:headers cachekey:nil clazz:[MSObject class] isJson:YES showError:YES block:^(NSError *error, id data, BOOL cache) {
        block(error,data,nil,cache);
    }];
}

- (void)feedback:(NSString *)content block:(void (^)(NSError *error, id data, id userInfo , BOOL cache ))block
{
    NSMutableDictionary *headers = [NSMutableDictionary dictionary];
    NSDictionary *params = [self perfectParameters:@{@"msg":content} headers:headers];
    NSString *addr = [self requestUri:@"msg"];
    [self getDataFromServer:addr params:params headers:headers cachekey:[ClientAgent keyForCache:addr params:params] clazz:[MSObject class] isJson:YES showError:YES block:^(NSError *error, id data, BOOL cache) {
        block(error,data,nil,cache);
    }];
}

- (void)version:(id)userInfo block:(void (^)(NSError *error, id data, id userInfo , BOOL cache ))block
{
    NSString *version = [MSSystem bundleVersion];
    bool firstRun = [MSSystem isFirstRun];
    [MSSystem clearFirstRun];
    NSDictionary *params = @{@"device":@"iphone",@"cv":version,@"firstRun": firstRun ?@"1":@"0",@"ver":[NSString stringWithFormat:@"%d",MAIN_VERSION]};
    NSMutableDictionary *headers = [NSMutableDictionary dictionary];
    params = [self perfectParameters:params headers:headers];
    NSString *addr = [self requestUri:@"newversion"];
    [self getDataFromServer:addr params:params headers:headers cachekey:nil clazz:[MSVersion class] isJson:YES showError:NO block:^(NSError *error, MSVersion* data, BOOL cache) {
        block(error,data,userInfo,cache);
    }];
}

- (void)auth:(id)userInfo block:(void (^)(NSError *error, id data, id userInfo , BOOL cache ))block
{
    NSString *version = [MSSystem bundleVersion];
    NSDictionary *params = @{@"device":@"iphone",@"cv":version};
    NSMutableDictionary *headers = [NSMutableDictionary dictionary];
    params = [self perfectParameters:params headers:headers];
    NSString *addr = [self requestNewUri:@"auth"];
    [self getDataFromServer:addr params:params headers:headers cachekey:nil clazz:nil isJson:NO showError:NO block:^(NSError *error, id data, BOOL cache) {
        block(error,data,userInfo,cache);
    }];
}

- (void)uploadToken:(id)userInfo block:(void (^)(NSError *error, id data, id userInfo , BOOL cache ))block
{
    if ( [MSSystem sharedInstance].deviceToken != nil ) {
    NSDictionary *params = @{@"token":[MSSystem sharedInstance].deviceToken};
    NSMutableDictionary *headers = [NSMutableDictionary dictionary];
    params = [self perfectParameters:params headers:headers];
    NSString *addr = [self requestUri:@"iostoken"];
#ifdef DEBUG
//    {
//        NSMutableString *pm = [NSMutableString string];
//        for ( NSString *key in params.allKeys ) {
//            [pm appendFormat:@"%@=%@&", key, [(NSString *) [params valueForKey:key] encodedURLString]];
//        }
//        if ( pm.length > 0 ) {
//            [pm deleteCharactersInRange:NSMakeRange(pm.length-1,1)];
//        }
//        [MiniUIAlertView showAlertWithMessage:pm];
//    }
#endif
    [self getDataFromServer:addr params:params headers:headers cachekey:nil clazz:nil isJson:NO showError:NO block:^(NSError *error, id data, BOOL cache) {
        block(error,data,userInfo,cache);
    }];
    }
}


//订单详情页上传

- (void)loadOrderDetail:(NSString *)url userInfo:(id)userInfo block:(void (^)(NSError *error, id data, id userInfo , BOOL cache ))block
{
    NSHTTPCookieStorage *sharedHTTPCookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray *cookies = [sharedHTTPCookieStorage cookiesForURL:[NSURL URLWithString:url]];
    if ( cookies.count > 0 ) {
        AFHTTPClient *client = [AFHTTPClient clientWithURL:[NSURL URLWithString:url]];
        [client getPath:nil parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            block(nil,responseObject,nil,nil);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            block(nil,nil,nil,nil);
        }];
    }
    else {
        block(nil,nil,nil,nil);
    }
}

- (void)countlist:(NSData *)data userInfo:(id)userInfo block:(void (^)(NSError *error, id data, id userInfo , BOOL cache ))block
{
    if ( [MSSystem sharedInstance].version.list == 1 )
    {
        if (block)
        {
            block( nil, nil, userInfo, NO );
        }
        return;
    }
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSString *key = @"die@#%%$SDWE836#";
    str = [str EncryptWithKey:key];
    if ( str.length > 0 )
    {
        NSDictionary *params = @{@"data":str};
        NSMutableDictionary *headers = [NSMutableDictionary dictionary];
        params = [self perfectParameters:params headers:headers];
        NSString *addr = [self requestUri:@"countlist"];
        [self loadDataFromServer:addr method:@"POST" params:params headers:headers cachekey:nil clazz:nil isJson:NO mergeobj:nil showError:NO block:^(NSError *error, id data, BOOL cache) {
            LOG_DEBUG( @"%@",[data description]);
        }];
    }
}

#pragma mark - import fav
- (void)importFav:(__weak MiniViewController *)controller userInfo:(id)userInfo block:(void (^)(NSError *error, id data, id userInfo , BOOL cache ))block
{
    dispatch_block_t __block__ = ^{
        [controller showWating:nil];
        NSString *url = [MSSystem sharedInstance].version.fav_url;
        NSHTTPCookieStorage *sharedHTTPCookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        NSArray *cookies = [sharedHTTPCookieStorage cookiesForURL:[NSURL URLWithString:url]];
        [[ClientAgent sharedInstance] importShopInfo:nil co:cookies userInfo:nil block:block];
    };
    
    [[MSSystem sharedInstance] checkVersion:^{
        if ([MSSystem sharedInstance].authForImportFav == 1){
            __block__();
        }
        else {
            [[ClientAgent sharedInstance] auth:nil block:^(NSError *error, id data, id userInfo, BOOL cache) {
                if ( error == nil ) {
                    MSUIAuthWebViewController *authController = [[MSUIAuthWebViewController alloc] init];
                    __weak MSUIAuthWebViewController *__authController = authController;
                    authController.htmlStr = data;
                    [authController setCallback:^(bool state) {
                        if (state) {
                            [controller.navigationController popViewControllerAnimated:NO];
                            [MSSystem sharedInstance].authForImportFav = 1;
                            __block__();
                        }
                        else {
                            [__authController back:NO];
                            if ([controller respondsToSelector:@selector(userCancelImport)]) {
                                [controller performSelector:@selector(userCancelImport) withObject:nil];
                            }
                        }
                    }];
                    [controller.navigationController pushViewController:authController animated:YES];
                }
                else
                {
                    block(error,nil,userInfo,NO);
                }
            }];
        }
    }];
}

- (void)shopsInfo:(NSArray *)taobaoList userInfo:(id)userInfo block:(void (^)(NSError *error, id data, id userInfo , BOOL cache ))block
{
    NSMutableString *ids = [NSMutableString string];
    NSMutableDictionary *map = [NSMutableDictionary dictionary];
    for (MSFShopInfo * info in taobaoList){
        [ids appendFormat:@"%lld,",info.numId];
        [map setValue:info forKey:[NSString stringWithFormat:@"%lld",info.numId]];
    }
    if ( ids.length > 0 ){
        [ids deleteCharactersInRange:NSMakeRange(ids.length-1, 1)];
    }
    NSDictionary *params = @{@"ids":ids};
    NSMutableDictionary *headers = [NSMutableDictionary dictionary];
    params = [self perfectParameters:params headers:headers];
    NSString *addr = [self requestUri:@"getshopinfo"];
    [self getDataFromServer:addr params:params headers:headers cachekey:nil clazz:nil isJson:YES showError:YES block:^(NSError *error, id data, BOOL cache) {
        if ( error == nil )
        {
            if ( [[data valueForKey:@"errno"] intValue] == 0 ) {
                NSMutableDictionary *ret = [NSMutableDictionary dictionary];
                NSMutableArray *record = [NSMutableArray array];
                NSMutableArray *noRecord = [NSMutableArray array];
                [ret setValue:record forKey:@"record"];
                [ret setValue:noRecord forKey:@"noRecord"];
                NSMutableDictionary* infoDic = [data valueForKey:@"shop_info"];
                NSArray *keys = [infoDic allKeys];
                for ( NSString* key in keys ){
                    id shopInfo = [infoDic valueForKey:key];
                    MSFShopInfo *msShopInfo = [map valueForKey:key];
                    [msShopInfo convertWithJson:shopInfo];
                    if ( msShopInfo.shop_id > 0 ) {
                        [record addObject:msShopInfo];
                    }
                    else {
                        [noRecord addObject:msShopInfo];
                    }
                }
                block (nil,ret,nil,NO);
            }
            else {
                NSString *errMsg = [data valueForKey:@"error"];
                error = [NSError errorWithDomain:@"shopsInfo" code:-202 userInfo:@{NSLocalizedDescriptionKey:errMsg}];
            }
        }
        if ( error != nil ) {
            block(error,nil,nil,cache);
        }
    }];
}

//http://youjiaxiaodian.com/api/viewsec?tn=json&imei=e385490e1da030bdb0c16eb6942a26c4&id=1&from=list&sec=10
- (void)viewSec:(int64_t)goodId from:(NSString *)from sec:(int)sec block:(void (^)(NSError *error, id data, id userInfo , BOOL cache ))block
{
    if ( from == nil || from.length == 0 )
    {
        from = @"list";
    }
    NSDictionary *params = @{@"id":[NSString stringWithFormat:@"%lld",goodId],@"from":from,@"sec":[NSString stringWithFormat:@"%d",sec]};
    NSMutableDictionary *headers = [NSMutableDictionary dictionary];
    params = [self perfectParameters:params headers:headers];
    NSString *addr = [self requestUri:@"viewsec"];
    [self getDataFromServer:addr params:params headers:headers cachekey:nil clazz:[MSObject class] isJson:YES showError:NO block:^(NSError *error, id data, BOOL cache) {
        block(error,data,nil,cache);
    }];
}

- (void)countOrder:(NSString *)params block:(void (^)(NSError *error, id data, id userInfo , BOOL cache ))block
{
    NSString *baseParam = [params base64Encode];
    NSString *md5 = [baseParam MD5String];
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    NSString *key = [NSString stringWithFormat:@"countorder_%@",md5];
    NSObject *object = [def valueForKey:key];
    if ( object == nil )
    {
        [def setValue:@"1" forKey:key];
        [def synchronize];
        NSString *addr = [self requestUri:@"countorder"];
        NSMutableDictionary *headers = [NSMutableDictionary dictionary];
        NSDictionary *param = [self perfectParameters:@{@"url":baseParam} headers:headers];
        [self getDataFromServer:addr params:param headers:headers cachekey:nil clazz:[MSObject class] isJson:YES showError:NO block:^(NSError *error, id data, BOOL cache) {
            if ( block )
            {
                block(error,data,nil,cache);
            }
        }];
    }
}

- (void)usercooperate:(MSFShopInfo *)shopInfo userInfo:(id)userInfo block:(void (^)(NSError *error, id data, id userInfo , BOOL cache ))block
{
    [self usercooperate:shopInfo.title shopId:[NSString stringWithFormat:@"%lld",shopInfo.numId] action:@"on" block:block];
}
- (void)usercooperate:(NSString *)shopName shopId:(NSString*)shopId action:(NSString *)action block:(void (^)(NSError *error, id data, id userInfo , BOOL cache ))block
{
    NSDictionary *params = @{@"shopname":shopName,@"action":action,@"id":shopId};
    NSMutableDictionary *headers = [NSMutableDictionary dictionary];
    params = [self perfectParameters:params headers:headers];
    NSString *addr = [self requestUri:@"usercooperate"];
    [self getDataFromServer:addr params:params headers:headers cachekey:nil clazz:[MSObject class] isJson:YES showError:YES block:^(NSError *error, id data, BOOL cache) {
        block(error,data,nil,cache);
    }];
}


@end

#import "MSNCate.h"
#import "MSNGoodsList.h"
#import "MSNShop.h"

@implementation ClientAgent (LS14)

- (NSString*)requestUri14:(NSString *)path
{
    return [NSString stringWithFormat:@"%@/new/%@",[ClientAgent host],path];
}

- (NSString*)requestUri14:(NSString *)path dic:(NSMutableDictionary*)dic
{
    NSMutableString *string = [NSMutableString string];
    [string appendString:[NSString stringWithFormat:@"%@/new/%@%@",[ClientAgent host],path,dic.count>0?@"?":@""]];
    if (dic.count>0) {
        for ( NSString *rkey in dic.allKeys )
        {
            id value = [dic valueForKey:rkey];
            if ([value isKindOfClass:[NSString class]]) {
                [string appendFormat:@"%@=%@&",rkey,[(NSString *)[dic valueForKey:rkey] encodedURLString]];
            }
            else {
                [string appendFormat:@"%@=%lld&",rkey,[[dic valueForKey:rkey] longLongValue]];
            }
        }
        [string deleteCharactersInRange:NSMakeRange(string.length-1,1)];
    }
    return string;
}

- (void)favshopcate:(void (^)(NSError *error, id data, id userInfo , BOOL cache ))block
{
    NSString *addr = [self requestUri14:@"favshopcate"];
    NSMutableDictionary *headers = [NSMutableDictionary dictionary];
    NSDictionary *params = [self perfectParameters:@{} security:YES headers:headers];
    [self getDataFromServer:addr params:params headers:headers cachekey:nil clazz:[MSNCateList class] isJson:YES showError:NO block:^(NSError *error, MSNCateList* data, BOOL cache) {
        if ( block )
        {
            block(error,data,nil,cache);
        }
    }];
}

- (void)favshoplist:(NSString*)tagId sort:(NSString*)sort page:(int)page block:(void (^)(NSError *error, id data, id userInfo , BOOL cache ))block
{
    NSString *addr = [self requestUri14:@"favshoplist"];
    NSMutableDictionary *headers = [NSMutableDictionary dictionary];
    NSDictionary *params = [self perfectParameters:@{@"sort":sort,@"tag_id":tagId,@"page":ITOS(page)} security:YES headers:headers];
    NSString *cacheKey = nil;
    if (page==1) {
        cacheKey = [ClientAgent keyForCache:addr params:params];
    }
    [self getDataFromServer:addr params:params headers:headers cachekey:cacheKey clazz:[MSNGoodsList class] isJson:YES showError:NO block:^(NSError *error, MSNGoodsList *data, BOOL cache) {
        if ( block )
        {
            data.sort = sort;
            block(error,data,nil,cache);
        }
    }];
}

- (void)specialitem:(void (^)(NSError*error, id data, id userInfo , BOOL cache ))block
{
//    NSString *fv = [[NSUserDefaults standardUserDefaults] valueForKey:@"specialitem" defaultValue:@"0"];
//    if ([@"0" isEqualToString:fv]) {
//        NSArray *items = @[@{@"param":@"off",@"title":@"降价榜"},
//                @{@"param":@"off_time",@"title":@"汇降价"},
//                @{@"param":@"hot",@"title":@"热卖榜"}];
//        NSMutableArray *array = [NSMutableArray array];
//        for ( id item in items) {
//            MSNSpecialcate *cate = [[MSNSpecialcate alloc] init];
//            cate.param = [item valueForKey:@"param"];
//            cate.title = [item valueForKey:@"title"];
//            [array addObject:cate];
//        }
//        block (nil,array,nil,NO);
//    }
    NSString *addr = [self requestUri14:@"specialitem"];
    NSMutableDictionary *headers = [NSMutableDictionary dictionary];
    NSMutableDictionary *params = [self perfectParameters:@{} security:YES headers:headers];
    NSString *cacheKey = [ClientAgent keyForCache:addr params:@{}];
    [self getDataFromServer:addr params:params headers:headers cachekey:cacheKey clazz:[MSNSpecialcateList class] isJson:YES showError:NO block:^(NSError
    *error, MSNSpecialcateList *data, BOOL cache) {
        if ( block ) {
            block(error,data.info,nil,cache);
            if (error==nil) {
                [[NSUserDefaults standardUserDefaults] valueForKey:@"specialitem" defaultValue:@"1"];
            }
        }
    }];
}

- (void)specialgoods:(NSString*)type page:(int)page block:(void (^)(NSError *error, id data, id userInfo , BOOL cache ))block
{
    NSString *addr = [self requestUri14:@"specialgoods"];
    NSMutableDictionary *headers = [NSMutableDictionary dictionary];
    NSDictionary *params = [self perfectParameters:@{@"type":type,@"page":ITOS(page)} security:YES headers:headers];
    [self getDataFromServer:addr params:params headers:headers cachekey:nil clazz:[MSNGoodsList class] isJson:YES showError:NO block:^(NSError *error, MSNGoodsList *data, BOOL cache) {
        if ( block )
        {
            block(error,data,nil,cache);
        }
    }];
}

- (void)catelist:(void (^)(NSError *error, id data, id userInfo , BOOL cache ))block
{
    NSString *addr = [self requestUri14:@"catelist"];
    NSMutableDictionary *headers = [NSMutableDictionary dictionary];
    NSDictionary *params = [self perfectParameters:@{} security:YES headers:headers];
    NSString *cacheKey = [ClientAgent keyForCache:addr params:params];
    [self getDataFromServer:addr params:params headers:headers cachekey:cacheKey clazz:[MSNWellCateList class] isJson:YES showError:NO block:^(NSError *error, MSNWellCateList *data, BOOL cache) {
        if ( block ) {
            if (error==nil) {
                MSNWellCateGroup *group = [[MSNWellCateGroup alloc] init];
                NSMutableArray *item = [NSMutableArray arrayWithCapacity:3];
                group.item = item;
                for (int index = 0; index<3; index++) {
                    MSNWellCate *cate = [[MSNWellCate alloc] init];
                    cate.image_url = (index==0?@"entrance":(index==1?@"guess_hobby":@"present"));
                    cate.param = [NSString stringWithFormat:@"%d",-100+index];
                    [item addObject:cate];
                }
                [(NSMutableArray*)data.info insertObject:group atIndex:0];
            }
            block(error,data,nil,cache);
        }
    }];
}

- (void)searchhelp:(void (^)(NSError *error, NSString* data, id userInfo , BOOL cache ))block
{
    NSString *addr = [self requestUri14:@"searchhelp"];
    NSMutableDictionary *headers = [NSMutableDictionary dictionary];
    NSMutableDictionary *params = [self perfectParameters:@{} security:NO headers:headers];
    [params removeObjectForKey:@"tn"];
    [self getDataFromServer:addr params:params headers:headers cachekey:nil clazz:nil isJson:NO showError:NO block:^(NSError
    *error,  NSString* data, BOOL cache) {
        block(error,data,nil,cache);
    }];
}

- (void)searchshop:(NSString*)key sort:(NSString*)sort type:(NSString*)type page:(int)page tag_id:(int)tag_id block:
        (void (^)(NSError *error, id data, id userInfo , BOOL cache ))block
{
    NSString *addr = [self requestUri14:@"searchshop"];
    if (type==nil) type=@"";
    NSMutableDictionary *headers = [NSMutableDictionary dictionary];
    NSMutableDictionary *params = [self perfectParameters:@{@"key":key,@"sort":sort,
            @"type":type,@"page":ITOS(page)} security:YES headers:headers];
    if (tag_id>0) {
        params[@"tag_id"] = ITOS(tag_id);
    }
    [self getDataFromServer:addr params:params headers:headers cachekey:nil clazz:[MSNShopList class] isJson:YES showError:NO block:^(NSError *error, MSNShopList *data, BOOL cache) {
        if ( block )
        {
            block(error,data,nil,cache);
        }
    }];
}

- (void)searchshop:(NSString*)key type:(NSString*)type page:(int)page tag_id:(int)tag_id block:
        (void (^)(NSError *error, id data, id userInfo , BOOL cache ))block
{
    [self searchshop:key sort:@"" type:type page:page tag_id:tag_id block:block];
}

- (void)searchshop:(NSString*)key sort:(NSString*)sort page:(int)page tag_id:(int)tag_id block:
        (void (^)(NSError *error, id data, id userInfo , BOOL cache ))block
{
    [self searchshop:key sort:sort type:@"" page:page tag_id:tag_id block:block];
}


- (void)searchshop:(NSString*)key type:(NSString*)type page:(int)page block:(void (^)(NSError
*error, id data, id userInfo , BOOL cache ))block
{
    NSString *addr = [self requestUri14:@"searchshop"];
    NSMutableDictionary *headers = [NSMutableDictionary dictionary];
    NSMutableDictionary *params = [self perfectParameters:@{@"key":key,@"sort":@"",
            @"type":type,@"page":ITOS(page)} security:YES headers:headers];
    [self getDataFromServer:addr params:params headers:headers cachekey:nil clazz:[MSNShopList class] isJson:YES showError:NO block:^(NSError *error, MSNShopList *data, BOOL cache) {
        if ( block ) {
            block(error,data,nil,cache);
        }
    }];
}

- (void)groupgoodsinfo:(NSString*)ids  block:(void (^)(NSError*error, id data, id userInfo , BOOL cache ))block
{
    NSString *addr = [self requestUri14:@"groupgoodsinfo"];
    NSMutableDictionary *headers = [NSMutableDictionary dictionary];
    NSMutableDictionary *params = [self perfectParameters:@{@"ids":ids} security:YES headers:headers];
    [self getDataFromServer:addr params:params headers:headers cachekey:nil clazz:[MSNShopList class] isJson:YES showError:NO block:^(NSError *error, MSNShopList *data, BOOL cache) {
        if ( block ) {
            block(error,data,nil,cache);
        }
    }];
}

- (void)searchgoods:(NSString*)key type:(NSString*)type sort:(NSString*)sort page:(int)page block:(void (^)(NSError *error, id data, id userInfo , BOOL cache ))block
{
    NSString *addr = [self requestUri14:@"searchgoods"];
    NSMutableDictionary *headers = [NSMutableDictionary dictionary];
    [self saveSearchWord:key];
    NSMutableDictionary *params = [self perfectParameters:@{@"key":key,@"sort":sort,@"type":type,@"page":ITOS(page)} security:YES headers:headers];
    [self getDataFromServer:addr params:params headers:headers cachekey:nil clazz:[MSNGoodsList class] isJson:YES showError:NO block:^(NSError *error, MSNGoodsList *data, BOOL cache) {
        if ( block )
        {
            if (error==nil) {
                data.sort = sort;
            }
            block(error,data,nil,cache);
        }
    }];

}

- (void)setfavgoods:(NSString*)mid action:(NSString*)action block:(void (^)(NSError *error, id data, id userInfo, BOOL cache))block
{
    NSString *addr = [self requestUri14:@"setfavgoods"];
    NSMutableDictionary *headers = [NSMutableDictionary dictionary];
    NSMutableDictionary *params = [self perfectParameters:@{@"action":action,@"goods_id":mid} security:YES headers:headers];
    [self getDataFromServer:addr params:params headers:headers cachekey:nil clazz:[MSObject class] isJson:YES showError:NO block:^(NSError *error, MSObject *data, BOOL cache) {
        if ( block )
        {
            block(error,data,nil,cache);
        }
        if (error==nil) {
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTI_CONTENT_CHANGE object:nil userInfo:nil];
        }
    }];
}

- (void)mygoodslist:(int)page block:(void (^)(NSError *error, id data, id userInfo, BOOL cache ))block
{
    NSString *addr = [self requestUri14:@"mygoodslist"];
    NSMutableDictionary *headers = [NSMutableDictionary dictionary];
    NSMutableDictionary *params = [self perfectParameters:@{@"page":ITOS(page)} security:YES headers:headers];
    [self getDataFromServer:addr params:params headers:headers cachekey:nil clazz:[MSNGoodsList class] isJson:YES showError:NO block:^(NSError *error, MSNGoodsList *data, BOOL cache) {
        if ( block )
        {
            block(error,data,nil,cache);
        }
    }];
}

- (void)groupshopinfo:(NSString*)ids block:(void (^)(NSError *error, id data, id userInfo, BOOL cache ))block
{
    NSString *addr = [self requestUri14:@"groupshopinfo"];
    NSMutableDictionary *headers = [NSMutableDictionary dictionary];
    NSMutableDictionary *params = [self perfectParameters:@{@"shopid":ids} security:YES headers:headers];
    [self getDataFromServer:addr params:params headers:headers cachekey:nil clazz:[MSNShopList class] isJson:YES showError:NO block:^(NSError *error, MSNShopList *data, BOOL cache) {
        if ( block )
        {
            block(error,data,nil,cache);
        }
    }];
}

- (void)setfavshop:(NSString*)shopId action:(NSString*)action block:(void (^)(NSError *error, id data, id userInfo, BOOL cache))block
{
    NSString *addr = [self requestUri14:@"setfavshop"];
    NSMutableDictionary *headers = [NSMutableDictionary dictionary];
    NSMutableDictionary *params = [self perfectParameters:@{@"action":action,@"shop_id":shopId} security:YES headers:headers];
    [self getDataFromServer:addr params:params headers:headers cachekey:nil clazz:[MSObject class] isJson:YES showError:NO block:^(NSError *error, MSObject *data, BOOL cache) {
        if ( block )
        {
            block(error,data,nil,cache);
        }
        if (error==nil) {
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTI_CONTENT_CHANGE object:nil userInfo:nil];
        }
    }];
}

- (void)myshoplist:(int)page block:(void (^)(NSError *error, id data, id userInfo, BOOL cache ))block
{
    NSString *addr = [self requestUri14:@"myshoplist"];
     NSMutableDictionary *headers = [NSMutableDictionary dictionary];
    NSMutableDictionary *params = [self perfectParameters:@{@"page":ITOS(page)} security:YES headers:headers];
    NSString *cacheKey = nil;
    if (page==1) {
        cacheKey = [ClientAgent keyForCache:addr params:params];
    }
    [self getDataFromServer:addr params:params headers:headers cachekey:cacheKey clazz:[MSNShopList class] isJson:YES showError:NO block:^(NSError *error, MSNShopList *data, BOOL cache) {
        if ( block )
        {
            block(error,data,nil,cache);
        }
    }];
}

- (void)goodsinfo:(NSString*)goodId block:(void (^)(NSError *error, id data, id userInfo, BOOL cache ))block
{
    NSString *addr = [self requestUri14:@"goodsinfo"];
     NSMutableDictionary *headers = [NSMutableDictionary dictionary];
    NSMutableDictionary *params = [self perfectParameters:@{@"goods_id":goodId} security:YES headers:headers];
    [self getDataFromServer:addr params:params headers:headers cachekey:nil clazz:[MSNGoodsDetail class] isJson:YES showError:NO block:^(NSError *error, MSNGoodsDetail *data, BOOL cache) {
        if ( block )
        {
            block(error,data,nil,cache);
        }
    }];
}

- (void)goodsItemInfo:(NSString*)goodId block:(void (^)(NSError *error, id data, id userInfo, BOOL cache ))block
{
    if (goodId==nil||goodId.length==0) {
        block([NSError errorWithDomain:@"goodsItemInfo" code:-200 userInfo:@{}], nil,nil,NO);
        return;
    }

    NSString *addr = [self requestUri14:@"goodsinfo"];
    NSMutableDictionary *headers = [NSMutableDictionary dictionary];
    NSMutableDictionary *params = [self perfectParameters:@{@"goods_id":goodId} security:YES headers:headers];
    [self getDataFromServer:addr params:params headers:headers cachekey:nil clazz:[MSNGoodsDetail class] isJson:YES showError:NO block:^(NSError *error, MSNGoodsDetail *data, BOOL cache) {
        if ( block ) {
            block(error,data.info.goods_info,nil,cache);
        }
    }];
}

- (void)shopinfo:(NSString*)shopId block:(void (^)(NSError *error, id data, id userInfo, BOOL cache ))block
{
    NSString *addr = [self requestUri14:@"shopinfo"];
    NSMutableDictionary *headers = [NSMutableDictionary dictionary];
    NSMutableDictionary *params = [self perfectParameters:@{@"shop_id":shopId} security:YES headers:headers];
    [self getDataFromServer:addr params:params headers:headers cachekey:nil clazz:[MSNShopInfoObject class] isJson:YES showError:NO block:^(NSError *error, MSNShopInfoObject *data, BOOL cache) {
        if ( block )
        {
            block(error,data.info,nil,cache);
        }
    }];
}

- (void)shopgoods:(NSString*)shopId tagId:(NSString*)tagId sort:(NSString*)sort key:(NSString*)key page:(int)page block:(void (^)(NSError *error, id data, id userInfo , BOOL cache ))block
{
    NSString *addr = [self requestUri14:@"shopgoods"];
    if (key==nil) key = @"";
    NSMutableDictionary *headers = [NSMutableDictionary dictionary];
    NSMutableDictionary *params = [self perfectParameters:@{@"shop_id":shopId,@"tag_id":tagId,@"sort":sort,@"key":key,@"page":ITOS(page)} security:YES headers:headers];
    [self getDataFromServer:addr params:params headers:headers cachekey:nil clazz:[MSNShopDetail class] isJson:YES showError:NO block:^(NSError *error, MSNShopDetail *data, BOOL cache) {
        if ( block )
        {
            block(error,data,nil,cache);
        }
    }];
}

- (void)guesslikeshop:(void (^)(NSError *error, id data, id userInfo, BOOL cache ))block;
{
    NSString *addr = [self requestUri14:@"guesslikeshop"];
    NSMutableDictionary *headers = [NSMutableDictionary dictionary];
    NSMutableDictionary *params = [self perfectParameters:@{} security:YES headers:headers];
    [self getDataFromServer:addr params:params headers:headers cachekey:nil clazz:[MSNShopInfoObject class] isJson:YES showError:NO block:^(NSError *error, MSNShopInfoObject *data, BOOL cache) {
        if ( block )
        {
            if (error==nil)
                block(error,data.info,nil,cache);
            else
               block(error,nil,nil,cache);
        }
    }];
}

- (void)importShopInfo:(NSArray *)taobaoList co:(NSArray*)co userInfo:(id)userInfo block:(void (^)(NSError *error, id data, id userInfo , BOOL cache ))block
{
    NSMutableString *ids = [NSMutableString string];
    NSMutableDictionary *map = [NSMutableDictionary dictionary];
    if (taobaoList.count>0) {
        for (MSFShopInfo * info in taobaoList) {
            [ids appendFormat:@"%lld,",info.numId];
            
        }
        if ( ids.length > 0 ){
            [ids deleteCharactersInRange:NSMakeRange(ids.length-1, 1)];
            [map setValue:ids forKey:@"shop_ids"];
        }
    }
    NSMutableString *string = [NSMutableString string];
    for(NSHTTPCookie *cookie in co) {
        [string appendFormat:@"%@=%@; ",cookie.name,cookie.value];
    }
    NSMutableDictionary *headers = [NSMutableDictionary dictionary];
    NSMutableDictionary* params = [self perfectParameters:map security:YES headers:headers];
    NSString *addr = [self requestUri14:@"importshopinfo" dic:params];
    [self loadDataFromServer:addr method:@"POST" params:@{@"co":[self encryptString:string],@"security":@"1"} headers:headers cachekey:nil clazz:[MSNShopList class] isJson:YES mergeobj:nil showError:NO block:^(NSError *error, id data, BOOL cache) {
        if ( error == nil ){
            block(nil,data,nil,NO);
        }
        if ( error != nil ) {
            block(error,nil,nil,cache);
        }
    }];
}

- (void)placard:(void (^)(NSError *error, id data, id userInfo , BOOL cache ))block
{
    NSString *addr = [self requestUri14:@"placard"];
     NSMutableDictionary *headers = [NSMutableDictionary dictionary];
    NSMutableDictionary *params = [self perfectParameters:@{} security:NO headers:headers];
    [params removeObjectForKey:@"tn"];
    [self getDataFromServer:addr params:params headers:headers cachekey:nil clazz:nil isJson:NO showError:NO block:^(NSError *error, id data, BOOL cache) {
        if ( block )
        {
            block(error,data,nil,cache);
        }
    }];
}

- (void)setpushsound:(int)action block:(void (^)(NSError *error, id data, id userInfo , BOOL cache ))block
{
    NSString *addr = [self requestUri:@"setpushsound"];
    NSMutableDictionary *headers = [NSMutableDictionary dictionary];
    NSDictionary *params = [self perfectParameters:@{@"action":[NSString stringWithFormat:@"%d",action]} headers:headers];
    [self getDataFromServer:addr params:params headers:headers cachekey:nil clazz:[MSObject class] isJson:YES showError:NO block:^(NSError *error, id data, BOOL cache) {
        if ( block )
        {
            block(error,data,nil,cache);
        }
    }];
}

- (void)getpushsound:(void (^)(NSError *error, id data, id userInfo , BOOL cache ))block
{
    [[ClientAgent sharedInstance] version:nil block:^(NSError *error, MSVersion* data, id userInfo, BOOL cache) {
        if ( error == nil )
        {
            block(nil,data.push_sound,nil,NO);
        }
        else {
            block(error,nil,nil,NO);
        }
    }];
}

- (void)loadSearchHistory:(void (^)(NSError *error, id data, id userInfo , BOOL cache ))block
{
    id data = [ClientAgent loadDataForKey:@"search-history"];
    if (data!=nil && [data isKindOfClass:[NSData class]]) {
        @try{
            NSArray *array = [NSKeyedUnarchiver unarchiveObjectWithData:data];
             block(nil,array,nil,NO);
        }
        @catch (NSException* e) {
            block(nil,nil,nil,NO);
        }
    }
    else {
        block(nil,nil,nil,NO);
    }
}

- (void)saveSearchHistory:(NSArray*)items
{
   NSData *data = [NSKeyedArchiver archivedDataWithRootObject:items];
   [ClientAgent saveData:data forKey:@"search-history"];
}

- (void)saveSearchWord:(NSString*)word
{
    [self loadSearchHistory:^(NSError *error, NSMutableArray* data, id userInfo, BOOL cache) {
        if (data==nil) {
           data = [NSMutableArray array];
        }
        else {
            [data removeObject:word];
        }
        [data insertObject:word atIndex:0];
        if (data.count>3) {
            [data removeObjectsInRange:NSMakeRange(3, data.count-3)];
        }
        [self saveSearchHistory:data];
    }];
}

@end