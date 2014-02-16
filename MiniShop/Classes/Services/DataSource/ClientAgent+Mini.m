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
#import "MSShopInfo.h"
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

-(NSMutableDictionary*)perfectParameters:(NSDictionary*)param
{
    return [self perfectParameters:param security:NO];
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

-(NSMutableDictionary*)perfectParameters:(NSDictionary*)param security:(BOOL)security
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
        [self setRequestHeaderWithKey:@"imei" value:imei];
    }
    {
        if ( WHO !=nil && WHO.uniqid.length>0) {
            [p setValue:WHO.uniqid forKey:@"uniqid"];
            [self setRequestHeaderWithKey:@"uniqid" value:WHO.uniqid];
        }
    }
    {
        [self setRequestHeaderWithKey:@"sys_device" value:@"iphone"];
        [self setRequestHeaderWithKey:@"sys_version" value:[NSString stringWithFormat:@"%d",MAIN_VERSION]];
        [self setRequestHeaderWithKey:@"app_version" value:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];
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
    NSString *addr = [self requestUri:@"newreg" param:@{}];
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
    NSString *addr = [self requestUri:@"newlogin" param:@{}];
    NSDictionary *dic = @{@"name":uname,@"passwd":passwd};
    [self loadDataFromServer:addr method:@"POST" params:dic cachekey:nil clazz:[MSUser class] isJson:YES mergeobj:nil showError:YES block:^(NSError *error, MSUser* user, BOOL cache) {
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

- (void)version:(id)userInfo block:(void (^)(NSError *error, id data, id userInfo , BOOL cache ))block
{
    NSString *version = [MSSystem bundleversion];
    bool firstrun = [MSSystem isFirstRun];
    [MSSystem clearFirstRun];
    NSDictionary *params = @{@"device":@"iphone",@"cv":version,@"firstrun":firstrun?@"1":@"0",@"ver":[NSString stringWithFormat:@"%d",MAIN_VERSION]};
    params = [self perfectParameters:params];
    NSString *addr = [self requestUri:@"newversion"];
    [self getDataFromServer:addr params:params cachekey:nil clazz:[MSVersion class] isJson:YES showError:NO block:^(NSError *error, MSVersion* data, BOOL cache) {
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


@end

#import "MSNCate.h"
#import "MSNGoodsList.h"
#import "MSNShop.h"

@implementation ClientAgent (LS14)

- (NSString*)requestUri14:(NSString *)path
{
    return [NSString stringWithFormat:@"%@/new/%@",[ClientAgent host],path];
}

- (void)favshopcate:(void (^)(NSError *error, id data, id userInfo , BOOL cache ))block
{
    NSString *addr = [self requestUri14:@"favshopcate"];
    NSDictionary *params = [self perfectParameters:@{} security:YES];
    [self getDataFromServer:addr params:params cachekey:nil clazz:[MSNCateList class] isJson:YES showError:NO block:^(NSError *error, MSNCateList* data, BOOL cache) {
        if ( block )
        {
            block(error,data,nil,cache);
        }
    }];
}

- (void)favshoplist:(NSString*)tagId sort:(NSString*)sort page:(int)page block:(void (^)(NSError *error, id data, id userInfo , BOOL cache ))block
{
    NSString *addr = [self requestUri14:@"favshoplist"];
    NSDictionary *params = [self perfectParameters:@{@"sort":sort,@"tag_id":tagId,@"page":ITOS(page)} security:YES];
    [self getDataFromServer:addr params:params cachekey:nil clazz:[MSNGoodsList class] isJson:YES showError:NO block:^(NSError *error, MSNGoodsList *data, BOOL cache) {
        if ( block )
        {
            data.sort = sort;
            block(error,data,nil,cache);
        }
    }];
}

- (void)specialcate:(void (^)(NSError *error, id data, id userInfo , BOOL cache ))block
{
    NSArray *items = @[@{@"_id":@"off",@"name":@"汇打折"},
                   @{@"_id":@"off_time",@"name":@"汇降价"},
                   @{@"_id":@"hot",@"name":@"热卖榜"},
                   @{@"_id":@"activity",@"name":@"购刺激"}];
    NSMutableArray *array = [NSMutableArray array];
    for ( id item in items) {
        MSNSpecialcate *cate = [[MSNSpecialcate alloc] init];
        cate.mid = [item valueForKey:@"_id"];
        cate.name = [item valueForKey:@"name"];
        [array addObject:cate];
    }
    block (nil,array,nil,NO);
}

- (void)specialgoods:(NSString*)type page:(int)page block:(void (^)(NSError *error, id data, id userInfo , BOOL cache ))block
{
    NSString *addr = [self requestUri14:@"specialgoods"];
    NSDictionary *params = [self perfectParameters:@{@"type":type,@"page":ITOS(page)} security:YES];
    [self getDataFromServer:addr params:params cachekey:nil clazz:[MSNGoodsList class] isJson:YES showError:NO block:^(NSError *error, MSNGoodsList *data, BOOL cache) {
        if ( block )
        {
            block(error,data,nil,cache);
        }
    }];
}

- (void)catelist:(void (^)(NSError *error, id data, id userInfo , BOOL cache ))block
{
    NSString *addr = [self requestUri14:@"catelist"];
    NSDictionary *params = [self perfectParameters:@{} security:YES];
    [self getDataFromServer:addr params:params cachekey:nil clazz:[MSNWellCateList class] isJson:YES showError:NO block:^(NSError *error, MSNWellCateList *data, BOOL cache) {
        if ( block )
        {
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

- (void)searchshop:(NSString*)key sort:(NSString*)sort page:(int)page tag_id:(int)tag_id block:(void (^)(NSError *error, id data, id userInfo , BOOL cache ))block
{
    NSString *addr = [self requestUri14:@"searchshop"];
    NSMutableDictionary *params = [self perfectParameters:@{@"key":key,@"sort":sort,@"page":ITOS(page)} security:YES];
    if (tag_id>0) {
        params[@"tag_id"] = ITOS(tag_id);
    }
    [self getDataFromServer:addr params:params cachekey:nil clazz:[MSNShopList class] isJson:YES showError:NO block:^(NSError *error, MSNShopList *data, BOOL cache) {
        if ( block )
        {
            block(error,data,nil,cache);
        }
    }];
}

- (void)searchgoods:(NSString*)key type:(NSString*)type sort:(NSString*)sort page:(int)page block:(void (^)(NSError *error, id data, id userInfo , BOOL cache ))block
{
    NSString *addr = [self requestUri14:@"searchgoods"];
    NSMutableDictionary *params = [self perfectParameters:@{@"key":key,@"sort":sort,@"type":type,@"page":ITOS(page)} security:YES];
    [self getDataFromServer:addr params:params cachekey:nil clazz:[MSNGoodsList class] isJson:YES showError:NO block:^(NSError *error, MSNGoodsList *data, BOOL cache) {
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
    NSMutableDictionary *params = [self perfectParameters:@{@"action":action,@"goods_id":mid} security:YES];
    [self getDataFromServer:addr params:params cachekey:nil clazz:[MSObject class] isJson:YES showError:NO block:^(NSError *error, MSObject *data, BOOL cache) {
        if ( block )
        {
            block(error,data,nil,cache);
        }
    }];
}

- (void)mygoodslist:(int)page block:(void (^)(NSError *error, id data, id userInfo, BOOL cache ))block
{
    NSString *addr = [self requestUri14:@"mygoodslist"];
    NSMutableDictionary *params = [self perfectParameters:@{@"page":ITOS(page)} security:YES];
    [self getDataFromServer:addr params:params cachekey:nil clazz:[MSNGoodsList class] isJson:YES showError:NO block:^(NSError *error, MSNGoodsList *data, BOOL cache) {
        if ( block )
        {
            block(error,data,nil,cache);
        }
    }];
}

- (void)setfavshop:(NSString*)shopId action:(NSString*)action block:(void (^)(NSError *error, id data, id userInfo, BOOL cache))block
{
    NSString *addr = [self requestUri14:@"setfavshop"];
    NSMutableDictionary *params = [self perfectParameters:@{@"action":action,@"shop_id":shopId} security:YES];
    [self getDataFromServer:addr params:params cachekey:nil clazz:[MSObject class] isJson:YES showError:NO block:^(NSError *error, MSObject *data, BOOL cache) {
        if ( block )
        {
            block(error,data,nil,cache);
        }
    }];
}

- (void)myshoplist:(int)page block:(void (^)(NSError *error, id data, id userInfo, BOOL cache ))block
{
    NSString *addr = [self requestUri14:@"myshoplist"];
    NSMutableDictionary *params = [self perfectParameters:@{@"page":ITOS(page)} security:YES];
    [self getDataFromServer:addr params:params cachekey:nil clazz:[MSNShopList class] isJson:YES showError:NO block:^(NSError *error, MSNShopList *data, BOOL cache) {
        if ( block )
        {
            block(error,data,nil,cache);
        }
    }];
}

- (void)goodsinfo:(NSString*)goodId block:(void (^)(NSError *error, id data, id userInfo, BOOL cache ))block
{
    NSString *addr = [self requestUri14:@"goodsinfo"];
    NSMutableDictionary *params = [self perfectParameters:@{@"goods_id":goodId} security:YES];
    [self getDataFromServer:addr params:params cachekey:nil clazz:[MSNGoodsDetail class] isJson:YES showError:NO block:^(NSError *error, MSNGoodsDetail *data, BOOL cache) {
        if ( block )
        {
            block(error,data,nil,cache);
        }
    }];
}

- (void)shopgoods:(NSString*)shopId tagId:(NSString*)tagId sort:(NSString*)sort key:(NSString*)key page:(int)page block:(void (^)(NSError *error, id data, id userInfo , BOOL cache ))block
{
    NSString *addr = [self requestUri14:@"shopgoods"];
    NSMutableDictionary *params = [self perfectParameters:@{@"shop_id":shopId,@"tag_id":tagId,@"sort":sort,@"key":key,@"page":ITOS(page)} security:YES];
    [self getDataFromServer:addr params:params cachekey:nil clazz:[MSNShopDetail class] isJson:YES showError:NO block:^(NSError *error, MSNShopDetail *data, BOOL cache) {
        if ( block )
        {
            block(error,data,nil,cache);
        }
    }];
}

- (void)shoptag:(NSString*)shopId block:(void (^)(NSError *error, id data, id userInfo, BOOL cache ))block
{
    
}

- (void)guesslikeshop:(void (^)(NSError *error, id data, id userInfo, BOOL cache ))block;
{
    NSString *addr = [self requestUri14:@"guesslikeshop"];
    NSMutableDictionary *params = [self perfectParameters:@{} security:YES];
    [self getDataFromServer:addr params:params cachekey:nil clazz:[MSNGuessObject class] isJson:YES showError:NO block:^(NSError *error, MSNGuessObject *data, BOOL cache) {
        if ( block )
        {
            if (error==nil)
                block(error,data.info,nil,cache);
            else
               block(error,nil,nil,cache);
        }
    }];
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
@end