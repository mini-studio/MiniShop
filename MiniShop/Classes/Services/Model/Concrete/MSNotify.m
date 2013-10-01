//
//  MSNotify.m
//  MiniShop
//
//  Created by Wuquancheng on 13-3-31.
//  Copyright (c) 2013年 mini. All rights reserved.
//

#import "MSNotify.h"
#import "MSNotiItemInfo.h"

@implementation MSNotify

- (Class)classForAttri:(NSString *)attriName
{
    if ( [@"items_info" isEqualToString:attriName] )
    {
        return [MSNotiItemGroupInfo class];
    }
    else if( [@"official" isEqualToString:attriName] || [@"topic" isEqualToString:attriName] ) 
    {
        return [MSNotiItemInfo class];
    }
    return nil;
}
@end

@implementation MSPicNotify
- (Class)classForAttri:(NSString *)attriName
{
    if ( [@"items_info" isEqualToString:attriName] )
    {
        return [MSPicNotiGroupInfo class];
    }
    else if( [@"official" isEqualToString:attriName] || [@"topic" isEqualToString:attriName] )
    {
        return [MSNotiItemInfo class];
    }
    return nil;
}
@end