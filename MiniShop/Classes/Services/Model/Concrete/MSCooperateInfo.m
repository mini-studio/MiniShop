//
//  MSCooperateInfo.m
//  MiniShop
//
//  Created by Wuquancheng on 13-5-25.
//  Copyright (c) 2013年 mini. All rights reserved.
//

#import "MSCooperateInfo.h"

@implementation MSCooperateInfo
- (Class)classForAttri:(NSString *)attriName
{
    if ( [@"goods_info" isEqualToString:attriName] )
    {
        return [MSCooperateGoodInfo class];
    }
    return nil;
}
@end

@implementation MSCooperateGoodInfo

@end

@implementation MSCooperateData
- (Class)classForAttri:(NSString *)attriName
{
    if ( [@"info" isEqualToString:attriName] )
    {
        return [MSCooperateInfo class];
    }
    return nil;
}
@end
