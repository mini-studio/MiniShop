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
#import "MSNotify.h"
#import "MSGoodsList.h"
#import "MSVersion.h"
#import "MSSystem.h"
#import "MSImageInfo.h"
#import "MSUIAuthWebViewController.h"
#import "MSShopInfo.h"
#import "NSString+URLEncoding.h"
#import "NSString+Mini.h"
#import "NSData+Base64.h"
#import "MSRecmdList.h"
#import "MSCooperateInfo.h"
#import "MSPotentialInfo.h"
#import "UIDevice+Ext.h"
#import "MSNotiItemInfo.h"

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

-(NSMutableDictionary*)perfectParameters:(NSDictionary*)param
{
    NSMutableDictionary * p = param==nil?[NSMutableDictionary dictionary]:[NSMutableDictionary dictionaryWithDictionary:param];
    if ( [MSSystem sharedInstance].mainVersion >= 7 ) {
      [p setObject:@"" forKey:@"imei"];
    }
    else {
       [p setObject:UDID forKey:@"imei"];
    }
    
    [p setObject:@"" forKey:@"usernick"];
    [p setObject:@"json" forKey:@"tn"];
    NSString *w = [NSString stringWithFormat:@"%d",(int)(SCREEN_SIZE.width*SCREEN_SCALE)];
    NSString * h = [NSString stringWithFormat:@"%d",(int)(SCREEN_SIZE.height*SCREEN_SCALE)];
    [p setValue:w forKey:@"screenW"];
    [p setValue:h forKey:@"screenY"];
    [p setValue:h forKey:@"screenH"];
    if ( WHO !=nil && WHO.uniqid.length>0) {
         [p setValue:WHO.uniqid forKey:@"uniqid"];
    }
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

- (NSString *)requestUri:(NSString *)path param:(NSDictionary*)param
{
    NSString* uri = [self requestUri:path];
    if ( param != nil ) {
        NSMutableDictionary *params = [self perfectParameters:param];
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
    NSString *addr = [self requestUri:@"reg" param:@{}];
    NSDictionary *dic = @{@"name":uname,@"passwd":passwd,@"mobile":mobile};
    [self loadDataFromServer:addr method:@"POST" params:dic cachekey:nil clazz:[MSUser class] isJson:YES mergeobj:nil showError:YES block:^(NSError *error, MSUser* user, BOOL cache) {
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
    NSString *addr = [self requestUri:@"login" param:@{}];
    NSDictionary *dic = @{@"name":uname,@"passwd":passwd};
    [self loadDataFromServer:addr method:@"POST" params:dic cachekey:nil clazz:[MSUser class] isJson:YES mergeobj:nil showError:YES block:^(NSError *error, MSUser* user, BOOL cache) {
        if ( error == nil ) {
            if ( user.uniqid.length==0 ) {
                error = [NSError errorWithDomain:@"login" code:200 userInfo:@{NSLocalizedDescriptionKey:@"登陆异常"}];
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
    NSMutableDictionary *dic = [self perfectParameters:@{@"name":uname,@"mobile":mobile}];
    [self getDataFromServer:addr params:dic cachekey:nil clazz:[MSObject class] isJson:YES showError:YES block:^(NSError *error, id data, BOOL cache) {
        block(error,data,nil,cache);
    }];
}

- (void)feedback:(NSString *)content block:(void (^)(NSError *error, id data, id userInfo , BOOL cache ))block
{
    NSDictionary *params = [self perfectParameters:@{@"msg":content}];
    NSString *addr = [self requestUri:@"msg"];
    [self getDataFromServer:addr params:params cachekey:[ClientAgent keyForCache:addr params:params] clazz:[MSObject class] isJson:YES showError:YES block:^(NSError *error, id data, BOOL cache) {
        block(error,data,nil,cache);
    }];
}

- (void)loadNews:(int)page userInfo:(id)userInfo block:(void (^)(NSError *error, id data, id userInfo , BOOL cache ))block
{
    NSDictionary * params = @{@"page":[NSString stringWithFormat:@"%d",page]};
    params = [self perfectParameters:params];
    NSString *addr = [self requestUri:@"news13"];
    [self getDataFromServer:addr params:params cachekey:[ClientAgent keyForCache:addr params:params] clazz:[MSPicNotify class] isJson:YES showError:YES block:^(NSError *error, MSPicNotify* data, BOOL cache) {
        if ( error == nil )  {
            for (MSPicNotiGroupInfo *groupInfo in data.items_info ) {
                if ( groupInfo.items_info.shop_info.more_goods == 1 ) {
                    MSGoodItem *item = [[MSGoodItem alloc] init];
                    item.mid = MSDataType_MoreData;
                    [groupInfo.items_info.goods_info addObject:item];
                }
            }
        }
        block(error,data,userInfo,cache);
    }];
}

- (void)loadTopic:(NSString *)type page:(NSInteger)page maxid:(int64_t)maxid userInfo:(id)userInfo block:(void (^)(NSError *error, id data, id userInfo , BOOL cache ))block
{
    NSDictionary * params = @{@"type":type,@"page":[NSString stringWithFormat:@"%d",page],@"maxid":[NSString stringWithFormat:@"%lld",maxid]};
    params = [self perfectParameters:params];
    NSString *addr = [self requestUri:@"topic"];
    [self getDataFromServer:addr params:params cachekey:nil clazz:[MSNotify class] isJson:YES showError:YES block:^(NSError *error, id data, BOOL cache) {
        block(error,data,userInfo,cache);
    }];
}

- (void)loadLookData:(NSString *)type page:(NSInteger)page maxid:(int64_t)maxid userInfo:(id)userInfo block:(void (^)(NSError *error, id data, id userInfo , BOOL cache ))block
{
    NSDictionary * params = @{@"look_type":type,@"page":[NSString stringWithFormat:@"%d",page],@"maxid":[NSString stringWithFormat:@"%lld",maxid]};
    params = [self perfectParameters:params];
    NSString *addr = [self requestUri:@"look"];
    [self getDataFromServer:addr params:params cachekey:nil clazz:[MSNotify class] isJson:YES showError:YES block:^(NSError *error, id data, BOOL cache) {
        block(error,data,userInfo,cache);
    }];
}

//- (void)loadNewGoods:(NSString *)type mid:(int64_t)mid userInfo:(id)userInfo block:(void (^)(NSError *error, id data, id userInfo , BOOL cache ))block
//{
//    NSDictionary *params = @{@"type":type,@"id":[NSString stringWithFormat:@"%lld",mid]};
//    params = [self perfectParameters:params];
//    NSString *addr = [self requestUri:@"newsgoods"];
//    [self getDataFromServer:addr params:params cachekey:nil clazz:[MSGoodsList class] isJson:YES block:^(NSError *error, id data, BOOL cache) {
//        block(error,data,userInfo,cache);
//    }];
//}

- (void)loadNewsBody:(NSString *)type mid:(int64_t)mid userInfo:(id)userInfo block:(void (^)(NSError *error, id data, id userInfo , BOOL cache ))block
{
    NSDictionary *params = @{@"type":type,@"id":[NSString stringWithFormat:@"%lld",mid]};
    params = [self perfectParameters:params];
    NSString *addr = [self requestUri:@"newsbody"];
    [self getDataFromServer:addr params:params cachekey:nil clazz:[MSGoodsList class] isJson:YES showError:YES block:^(NSError *error, id data, BOOL cache) {
        block(error,data,userInfo,cache);
    }];
}

- (void)loadGoodsDetail:(NSString *)type shopId:(int64_t)shopId page:(int)page userInfo:(id)userInfo block:(void (^)(NSError *error, id data, id userInfo , BOOL cache ))block
{
    if (shopId > 0)
    {
        NSDictionary *params = @{@"type":type,@"shopid":[NSString stringWithFormat:@"%lld",shopId],@"page":[NSString stringWithFormat:@"%d",page],@"from":@"list"};
        params = [self perfectParameters:params];
        NSString *addr = [self requestUri:@"goodsdetail"];
        [self getDataFromServer:addr params:params cachekey:nil clazz:[MSGoodsList class] isJson:YES showError:YES block:^(NSError *error, id data, BOOL cache) {
            block(error,data,userInfo,cache);
        }];
    }
}

- (void)loadGoods:(NSString *)type mid:(int64_t)mid userInfo:(id)userInfo block:(void (^)(NSError *error, id data, id userInfo , BOOL cache ))block
{
    NSDictionary *params = @{@"type":type,@"id":[NSString stringWithFormat:@"%lld",mid]};
    params = [self perfectParameters:params];
    NSString *addr = [self requestUri:@"goods"];
    [self getDataFromServer:addr params:params cachekey:nil clazz:[MSGoodItem class] isJson:YES showError:YES block:^(NSError *error, id data, BOOL cache) {
        block(error,data,userInfo,cache);
    }];
}

- (void)version:(id)userInfo block:(void (^)(NSError *error, id data, id userInfo , BOOL cache ))block
{
    NSString *version = [MSSystem bundleversion];
    bool firstrun = [MSSystem isFirstRun];
    [MSSystem clearFirstRun];
    NSDictionary *params = @{@"device":@"iphone",@"cv":version,@"firstrun":firstrun?@"1":@"0",@"ver":[NSString stringWithFormat:@"%d",MAIN_VERSION]};
    params = [self perfectParameters:params];
    NSString *addr = [self requestUri:@"version"];
    [self getDataFromServer:addr params:params cachekey:nil clazz:[MSVersion class] isJson:YES showError:NO block:^(NSError *error, id data, BOOL cache) {
        block(error,data,userInfo,cache);
    }];
}

- (void)auth:(id)userInfo block:(void (^)(NSError *error, id data, id userInfo , BOOL cache ))block
{
    NSString *version = [MSSystem bundleversion];
    NSDictionary *params = @{@"device":@"iphone",@"cv":version};
    params = [self perfectParameters:params];
    NSString *addr = [self requestUri:@"auth"];
    [self getDataFromServer:addr params:params cachekey:nil clazz:nil isJson:NO showError:NO block:^(NSError *error, id data, BOOL cache) {
        block(error,data,userInfo,cache);
    }];
}

- (void)uploadToken:(id)userInfo block:(void (^)(NSError *error, id data, id userInfo , BOOL cache ))block
{
    if ( [MSSystem sharedInstance].deviceToken != nil ) {
    NSDictionary *params = @{@"token":[MSSystem sharedInstance].deviceToken};
    params = [self perfectParameters:params];
    NSString *addr = [self requestUri:@"iostoken"];
#ifdef DEBUG
    {
        NSMutableString *pm = [NSMutableString string];
        for ( NSString *rkey in params.allKeys )
        {
            [pm appendFormat:@"%@=%@&",rkey,[(NSString *)[params valueForKey:rkey] encodedURLString]];
        }
        if ( pm.length > 0 )
        {
            [pm deleteCharactersInRange:NSMakeRange(pm.length-1,1)];
        }
        [MiniUIAlertView showAlertWithMessage:pm];
    }
#endif
    [self getDataFromServer:addr params:params cachekey:nil clazz:nil isJson:NO showError:NO block:^(NSError *error, id data, BOOL cache) {
        block(error,data,userInfo,cache);
    }];
    }
}

- (void)image:(NSString *)type  block:(void (^)(NSError *error, id data, id userInfo , BOOL cache ))block
{
    NSDictionary *params = @{@"type":type};
    params = [self perfectParameters:params];
    NSString *addr = [self requestUri:@"image"];
    [self getDataFromServer:addr params:params cachekey:nil clazz:[MSImageInfo class] isJson:YES showError:NO block:^(NSError *error, id data, BOOL cache) {
        block(error,data,nil,cache);
    }];
}

- (void)like:(NSString *)type action:(NSString *)action mid:(int64_t)mid block:(void (^)(NSError *error, id data, id userInfo , BOOL cache ))block
{
    NSDictionary *params = @{@"type":type,@"action":action,@"id":[NSString stringWithFormat:@"%lld",mid]};
    params = [self perfectParameters:params];
    NSString *addr = [self requestUri:@"userlike"];
    [self getDataFromServer:addr params:params cachekey:nil clazz:[MSObject class] isJson:YES showError:YES block:^(NSError *error, id data, BOOL cache) {
        block(error,data,nil,cache);
    }];
}

- (void)usercooperate:(MSShopInfo *)shopInfo userInfo:(id)userInfo block:(void (^)(NSError *error, id data, id userInfo , BOOL cache ))block
{
    [self usercooperate:shopInfo.title shopId:[NSString stringWithFormat:@"%lld",shopInfo.numId] action:@"on" block:block];
}
- (void)usercooperate:(NSString *)shopName shopId:(NSString*)shopId action:(NSString *)action block:(void (^)(NSError *error, id data, id userInfo , BOOL cache ))block
{
    NSDictionary *params = @{@"shopname":shopName,@"action":action,@"id":shopId};
    params = [self perfectParameters:params];
    NSString *addr = [self requestUri:@"usercooperate"];
    [self getDataFromServer:addr params:params cachekey:nil clazz:[MSObject class] isJson:YES showError:YES block:^(NSError *error, id data, BOOL cache) {
        block(error,data,nil,cache);
    }];
}

//订单详情页上传

- (void)loadOrderDetail:(NSString *)url userInfo:(id)userInfo block:(void (^)(NSError *error, id data, id userInfo , BOOL cache ))block
{
    NSHTTPCookieStorage *sharedHTTPCookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray *cookies = [sharedHTTPCookieStorage cookiesForURL:[NSURL URLWithString:url]];
    if ( cookies.count > 0 )
    {
        AFHTTPClient *client = [AFHTTPClient clientWithURL:[NSURL URLWithString:url]];
        [client getPath:nil parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            block(nil,responseObject,nil,nil);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            block(nil,nil,nil,nil);
        }];
//        __weak ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]];
//        [request setRequestCookies:[NSMutableArray arrayWithArray:cookies]];
//        [request setCompletionBlock:^{
//            block(nil,[request responseData],nil,nil);
//        }];
//        [request setFailedBlock:^{
//             block(nil,nil,nil,nil);
//        }];
//        [request startAsynchronous];
    }
    else
    {
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
        params = [self perfectParameters:params];
        NSString *addr = [self requestUri:@"countlist"];
        [self loadDataFromServer:addr method:@"POST" params:params cachekey:nil clazz:nil isJson:NO mergeobj:nil showError:NO block:^(NSError *error, id data, BOOL cache) {
            LOG_DEBUG( @"%@",[data description]);
        }];
    }
}

#pragma mark - import fav
- (void)importFav:(MiniViewController *)controller userInfo:(id)userInfo block:(void (^)(NSError *error, id data, id userInfo , BOOL cache ))block
{
    dispatch_block_t __block__ = ^{
        NSString *url = [MSSystem sharedInstance].version.fav_url;
        AFHTTPClient *client = [AFHTTPClient clientWithURL:[NSURL URLWithString:url]];
        [client getPath:nil parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            NSRange start = [responseStr rangeOfString:@"{"];
            NSRange end = [responseStr rangeOfString:@"}" options:NSBackwardsSearch];
            if ( start.length > 0 && end.length > 0 )
            {
                NSInteger len = end.location - start.location + 1;
                responseStr = [responseStr substringWithRange:NSMakeRange(start.location, len)];
                LOG_DEBUG(@"======\n%@\n=======",responseStr);
                NSError *e = nil;
                NSJSONSerialization *data = [NSJSONSerialization JSONObjectWithData:[responseStr dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&e];
                if ( e == nil )
                {
                    NSMutableArray *nlist = [NSMutableArray array];
                    id result = [[data valueForKey:@"data"] valueForKey:@"result"];
                    NSArray *lst = [result valueForKey:@"resultList"];
                    for ( id v in lst )
                    {
                        MSShopInfo *info = [[MSShopInfo alloc] init];
                        [info convertWithJson:v];
                        [nlist addObject:info];
                    }
                    [result setValue:nlist forKey:@"resultList"];
                    block(nil ,result,userInfo,NO);
                }
                else
                {
                    block([NSError errorWithDomain:@"fav" code:-200 userInfo:@{NSLocalizedDescriptionKey:@"导入收藏夹失败!"}] ,nil,userInfo,NO);
                    //block(e ,data,userInfo,NO);
                }
            }
            else
            {
                block([NSError errorWithDomain:@"fav" code:-200 userInfo:@{NSLocalizedDescriptionKey:@"导入收藏夹失败!"}] ,nil,userInfo,NO);
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSError *e = [NSError errorWithDomain:@"importfav" code:-201 userInfo:nil];
            block(e,nil,userInfo,NO);
            [self throwNetWorkException:@"导入收藏夹失败!!!"];
        }];
    };
    [[MSSystem sharedInstance] checkVersion:^{
        if ( [MSSystem sharedInstance].authForImportFav == 1 )
        {
            __block__();
        }
        else
        {
            [[ClientAgent sharedInstance] auth:nil block:^(NSError *error, id data, id userInfo, BOOL cache) {
                if ( error == nil )
                {
                    MSUIAuthWebViewController *authcontroller = [[MSUIAuthWebViewController alloc] init];
                    authcontroller.htmlStr = data;
                    [authcontroller setCallback:^(bool state ) {
                        [controller.navigationController popViewControllerAnimated:NO];
                        [MSSystem sharedInstance].authForImportFav = 1;
                        __block__();
                    }];
                    [controller.navigationController pushViewController:authcontroller animated:YES];
                }
                else
                {
                    block(error,nil,userInfo,NO);
                }
            }];
        }
    }];
}

- (void)shopsInfo:(NSArray *)taobaolist userInfo:(id)userInfo block:(void (^)(NSError *error, id data, id userInfo , BOOL cache ))block
{
    NSMutableString *ids = [NSMutableString string];
    NSMutableDictionary *map = [NSMutableDictionary dictionary];
    for (MSShopInfo* info in taobaolist)
    {
        [ids appendFormat:@"%lld,",info.numId];
        [map setValue:info forKey:[NSString stringWithFormat:@"%lld",info.numId]];
    }
    if ( ids.length > 0 )
    {
        [ids deleteCharactersInRange:NSMakeRange(ids.length-1, 1)];
    }
    NSDictionary *params = @{@"ids":ids};
    params = [self perfectParameters:params];
    NSString *addr = [self requestUri:@"getshopinfo"];
    [self getDataFromServer:addr params:params cachekey:nil clazz:nil isJson:YES showError:YES block:^(NSError *error, id data, BOOL cache) {
        NSString *errmsg = nil;
        if ( error == nil )
        {
            if ( [[data valueForKey:@"errno"] intValue] == 0 )
            {
                NSMutableDictionary *ret = [NSMutableDictionary dictionary];
                NSMutableArray *record = [NSMutableArray array];
                NSMutableArray *norecord = [NSMutableArray array];
                [ret setValue:record forKey:@"record"];
                [ret setValue:norecord forKey:@"norecord"];
                NSMutableDictionary* infodic = [data valueForKey:@"shop_info"];
                NSArray *keys = [infodic allKeys];
                for ( NSString* key in keys )
                {
                    id shopInfo = [infodic valueForKey:key];
                    MSShopInfo *msshopinfo = [map valueForKey:key];
                    [msshopinfo convertWithJson:shopInfo];
                    if ( msshopinfo.shop_id > 0 )
                    {
                        [record addObject:msshopinfo];
                    }
                    else
                    {
                        [norecord addObject:msshopinfo];
                    }
                }
                block (nil,ret,nil,NO);
            }
            else
            {
                errmsg = [data valueForKey:@"error"];
                error = [NSError errorWithDomain:@"shopsInfo" code:-202 userInfo:nil];
            }
        }
        if ( error != nil )
        {
            block(error,nil,nil,cache);
        }
    }];
}

- (void)recommendlist:(id)userInfo  block:(void (^)(NSError *error, id data, id userInfo , BOOL cache ))block
{
    NSDictionary *params = [self perfectParameters:nil];
    NSString *addr = [self requestUri:@"shop"];
    NSString *cacheKey = [ClientAgent keyForCache:addr params:params];
    [self getDataFromServer:addr params:params cachekey:cacheKey clazz:[MSRecmdList class] isJson:YES showError:YES block:^(NSError *error, id data, BOOL cache) {
        block(error,data,nil,cache);
    }];
}

- (void)shoplist:(id)userInfo  block:(void (^)(NSError *error, id data, id userInfo , BOOL cache ))block
{
    NSDictionary *params = [self perfectParameters:nil];
    NSString *addr = [self requestUri:@"shoplist"];
    [self getDataFromServer:addr params:params cachekey:nil clazz:[MSFollowedList class] isJson:YES showError:YES block:^(NSError *error, id data, BOOL cache) {
        block(error,data,nil,cache);
    }];
}

- (void)searchshop:(NSString *)key first:(NSString*)first userInfo:(id)userInfo  block:(void (^)(NSError *error, id data, id userInfo , BOOL cache ))block
{
    NSDictionary *params = [self perfectParameters:first==nil?@{@"key": key}:@{@"key": key,@"first":first}];
    NSString *addr = nil;
    if ( first != nil && first.length > 0 )
    {
        addr = [self requestUri:@"shopkey"];
    }
    else
    {
        addr = [self requestUri:@"shopsearch"];
    }
    [self getDataFromServer:addr params:params cachekey:nil clazz:[MSSearchList class] isJson:YES showError:YES block:^(NSError *error, MSSearchList* data, BOOL cache) {
        if ( error == nil )
        {
            //@"record":@"norecord"
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            if ( [data.search_shop_info isKindOfClass:[NSArray class]])
            [dic setValue:data.search_shop_info forKey:@"record"];
            if ( [data.taobao_search_shop_info isKindOfClass:[NSArray class]])
            {
                NSMutableArray *array = (NSMutableArray*)data.taobao_search_shop_info;
                NSMutableArray *filter = [NSMutableArray array];
                if ( data.search_shop_ids.count > 0 )
                {
                    for (MSShopInfo *info in array )
                    {
                        if ( [data.search_shop_ids indexOfObject:info.taobao_shop_id] != NSNotFound )
                        {
                            [filter addObject:info];
                        }
                    }
                    [array removeObjectsInArray:filter];
                }
                [dic setValue:array forKey:@"norecord"];
            }
            block ( nil , dic, nil ,cache );
        }
        else
        {
            block(error,data,nil,cache);
        }
    }];
}

- (void)shopkey:(NSString*)first userInfo:(id)userInfo  block:(void (^)(NSError *error, id data, id userInfo , BOOL cache ))block
{
    NSDictionary *params = [self perfectParameters:@{@"first":first}];
    NSString *addr = [self requestUri:@"shopkey"];
    [self getDataFromServer:addr params:params cachekey:nil clazz:[MSSearchList class] isJson:YES showError:YES block:^(NSError *error, MSSearchList* data, BOOL cache) {
        if ( error == nil )
        {
            //@"record":@"norecord"
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            if ( [data.search_shop_info isKindOfClass:[NSArray class]])
                [dic setValue:data.search_shop_info forKey:@"record"];
            if ( [data.taobao_search_shop_info isKindOfClass:[NSArray class]])
            {
                NSMutableArray *array = (NSMutableArray*)data.taobao_search_shop_info;
                NSMutableArray *filter = [NSMutableArray array];
                if ( data.search_shop_ids.count > 0 )
                {
                    for (MSShopInfo *info in array )
                    {
                        if ( [data.search_shop_ids indexOfObject:info.taobao_shop_id] != NSNotFound )
                        {
                            [filter addObject:info];
                        }
                    }
                    [array removeObjectsInArray:filter];
                }
                [dic setValue:array forKey:@"norecord"];
            }
            block ( nil , dic, nil ,cache );
        }
        else
        {
            block(error,data,nil,cache);
        }
    }];
}

- (void)cooperatelist:(id)userInfo  block:(void (^)(NSError *error, id data, id userInfo , BOOL cache ))block
{
    NSMutableDictionary *params = [self perfectParameters:@{}];
    NSString *addr = [self requestUri:@"cooperatelist"];
    [self getDataFromServer:addr params:params cachekey:nil clazz:[MSCooperateData class] isJson:YES showError:YES block:^(NSError *error, MSCooperateData *data, BOOL cache) {
        if ( error == nil && [data isKindOfClass:[MSCooperateData class]])
        {
            if (data.limit == 0 )
                block(error,data.info,nil,cache);
            else
                block( [NSError errorWithDomain:@"cooper" code:200 userInfo:@{NSLocalizedDescriptionKey: data.msg}],data.info,nil,cache);
        }
        else
        {
             block(error,data,nil,cache);
        }
    }];
}

- (void)kinkList:(id)userInfo page:(int)page block:(void (^)(NSError *error, id data, id userInfo , BOOL cache ))block
{
    NSMutableDictionary *params = [self perfectParameters:@{@"page":[NSString stringWithFormat:@"%d",page]}];
    NSString *addr = [self requestUri:@"getkink"];
    [self getDataFromServer:addr params:params cachekey:nil clazz:[MSPotentialInfo class] isJson:YES showError:YES block:^(NSError *error, MSCooperateData *data, BOOL cache) {
                    block(error,data,nil,cache);
    }];
}

- (void)singlegoodsdetail:(int64_t)goodId from:(NSString*)from block:(void (^)(NSError *error, id data, id userInfo , BOOL cache ))block
{
    NSMutableDictionary *params = [self perfectParameters:@{@"id":[NSString stringWithFormat:@"%lld",goodId],@"from":from}];
    NSString *addr = [self requestUri:@"singlegoodsdetail"];
    [self getDataFromServer:addr params:params cachekey:nil clazz:[MSGoodsList class] isJson:YES showError:YES block:^(NSError *error, MSGoodsList *data, BOOL cache) {
        block(error,data,nil,cache);
    }];
}

- (void)newsbody12:(int64_t)shopId  block:(void (^)(NSError *error, id data, id userInfo , BOOL cache ))block
{
    NSMutableDictionary *params = [self perfectParameters:@{@"shopid":[NSString stringWithFormat:@"%lld",shopId]}];
    NSString *addr = [self requestUri:@"newsbody12"];
    [self getDataFromServer:addr params:params cachekey:nil clazz:[MSShopGalleryList class] isJson:YES showError:YES block:^(NSError *error, MSShopGalleryList *data, BOOL cache) {
        block(error,data,nil,cache);
    }];
}

- (void)goodsdetail12:(int64_t)shopId page:(int)page  block:(void (^)(NSError *error, id data, id userInfo , BOOL cache ))block
{
    NSMutableDictionary *params = [self perfectParameters:@{@"shopid":[NSString stringWithFormat:@"%lld",shopId],@"page":[NSString stringWithFormat:@"%d",page]}];
    NSString *addr = [self requestUri:@"goodsdetail12"];
    [self getDataFromServer:addr params:params cachekey:nil clazz:[MSGoodsList class] isJson:YES showError:YES block:^(NSError *error, MSGoodsList *data, BOOL cache) {
        block(error,data,nil,cache);
    }];
}

- (void)activityDetail:(int64_t)actId  block:(void (^)(NSError *error, id data, id userInfo , BOOL cache ))block
{
    NSMutableDictionary *params = [self perfectParameters:@{@"activity_id":[NSString stringWithFormat:@"%lld",actId]}];
    NSString *addr = [self requestUri:@"activitydetail"];
    [self getDataFromServer:addr params:params cachekey:nil clazz:[MSGoodsList class] isJson:YES showError:YES block:^(NSError *error, MSGoodsList *data, BOOL cache) {
        block(error,data,nil,cache);
    }];
}

- (void)shopnews12:(NSString*)shopIds page:(int)page userInfo:(id)userInfo block:(void (^)(NSError *error, id data, id userInfo , BOOL cache ))block
{
    NSDictionary * params = @{@"id":shopIds,@"page":[NSString stringWithFormat:@"%d",page]};
    params = [self perfectParameters:params];
    NSString *addr = [self requestUri:@"shopnews12"];
    [self getDataFromServer:addr params:params cachekey:[ClientAgent keyForCache:addr params:params] clazz:[MSNotify class] isJson:YES showError:YES block:^(NSError *error, id data, BOOL cache) {
        block(error,data,userInfo,cache);
    }];
}

- (void)zoom:(int64_t)goodId  from:(NSString *)from userInfo:(id)userInfo block:(void (^)(NSError *error, id data, id userInfo , BOOL cache ))block
{
    if ( from == nil || from.length == 0 )
    {
        from = @"list";
    }
    NSDictionary * params = @{@"id":[NSString stringWithFormat:@"%lld",goodId],@"from":from};
    params = [self perfectParameters:params];
    NSString *addr = [self requestUri:@"zoom"];
    [self getDataFromServer:addr params:params cachekey:nil clazz:[MSObject class] isJson:YES showError:NO block:^(NSError *error, id data, BOOL cache) {
        block(error,data,userInfo,cache);
    }];
}

//http://youjiaxiaodian.com/api/viewsec?tn=json&imei=e385490e1da030bdb0c16eb6942a26c4&id=1&from=list&sec=10
- (void)viewsec:(int64_t)goodId  from:(NSString *)from sec:(int)sec block:(void (^)(NSError *error, id data, id userInfo , BOOL cache ))block
{
    if ( from == nil || from.length == 0 )
    {
        from = @"list";
    }
    NSDictionary *params = @{@"id":[NSString stringWithFormat:@"%lld",goodId],@"from":from,@"sec":[NSString stringWithFormat:@"%d",sec]};
    params = [self perfectParameters:params];
    NSString *addr = [self requestUri:@"viewsec"];
    [self getDataFromServer:addr params:params cachekey:nil clazz:[MSObject class] isJson:YES showError:NO block:^(NSError *error, id data, BOOL cache) {
        block(error,data,nil,cache);
    }];
}

- (void)countorder:(NSString*)params block:(void (^)(NSError *error, id data, id userInfo , BOOL cache ))block
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
        NSDictionary *param = [self perfectParameters:@{@"url":baseParam}];
        [self getDataFromServer:addr params:param cachekey:nil clazz:[MSObject class] isJson:YES showError:NO block:^(NSError *error, id data, BOOL cache) {
            if ( block )
            {
                block(error,data,nil,cache);
            }
        }];
    }
}

- (void)setpushsound:(int)action block:(void (^)(NSError *error, id data, id userInfo , BOOL cache ))block
{
    NSString *addr = [self requestUri:@"setpushsound"];
    NSDictionary *params = [self perfectParameters:@{@"action":[NSString stringWithFormat:@"%d",action]}];
    [self getDataFromServer:addr params:params cachekey:nil clazz:[MSObject class] isJson:YES showError:NO block:^(NSError *error, id data, BOOL cache) {
        if ( block )
        {
            block(error,data,nil,cache);
        }
    }];

}

@end