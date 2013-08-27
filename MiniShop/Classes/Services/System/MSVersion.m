//
//  MSVersion.m
//  MiniShop
//
//  Created by Wuquancheng on 13-4-5.
//  Copyright (c) 2013年 mini. All rights reserved.
//

#import "MSVersion.h"

@implementation MSVersion

@synthesize auth = _auth;
@synthesize fav_url = _fav_url;
@synthesize push_sound = _push_sound;
- (void)setAuth:(NSInteger)auth
{
    _auth = auth;
    if ( auth == 1 )
    {
        [[NSUserDefaults standardUserDefaults] setValue:[NSDate date] forKey:@"MSVersion_AUTH"];
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"MSVersion_AUTH"];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSInteger)auth
{
    if ( _auth == 1 ) return _auth;
    NSDate* date = [[NSUserDefaults standardUserDefaults] valueForKey:@"MSVersion_AUTH"];
    if ( date != nil && [date timeIntervalSinceNow] > -24*3600 )
    {
        return 1;
    }
    return _auth;
}

- (void)setFav_url:(NSString *)fav_url
{
    _fav_url = fav_url;
    if ( fav_url != nil && fav_url.length > 0 )
    {
        [[NSUserDefaults standardUserDefaults] setValue:fav_url forKey:@"MS_FAV_URL"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (NSString *)fav_url
{
    if ( _fav_url == nil || _fav_url.length == 0 )
    {
        NSString *f = [[NSUserDefaults standardUserDefaults] valueForKey:@"MS_FAV_URL"];
        if ( f != nil && f.length > 0 )
        {
            _fav_url = f;
        }
    }
    if ( _fav_url == nil || _fav_url.length == 0 )
    {
        return  @"http://api.m.taobao.com/rest/h5Api.do?callback=jsonp5&type=jsonp&data=%7B%22method%22%3A%22queryColShop%22%2C%22pageSize%22%3A%22100%22%2C%22startRow%22%3A%220%22%2C%22currentPage%22%3A%221%22%2C%22goodCount%22%3A%226%22%7D&api=com.taobao.wap.rest2.fav";
    }
    return _fav_url;
}

- (void)setList:(NSInteger)list
{
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInt:list] forKey:@"MS_COUNT_LIST"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSInteger)list
{
    NSNumber *l = [[NSUserDefaults standardUserDefaults] valueForKey:@"MS_COUNT_LIST"];
    if ( l != nil ) return [l integerValue];
    return 0;
}

- (void)setPush_sound:(NSString *)push_sound
{
    _push_sound = push_sound;
    [[NSUserDefaults standardUserDefaults] setValue:_push_sound forKey:@"MS_PUSH_SOUND"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString*)push_sound
{
    NSString *p = [[NSUserDefaults standardUserDefaults] valueForKey:@"MS_PUSH_SOUND"];
    if ( p == nil ) {
        return @"0";
    }
    return p;
}

@end
