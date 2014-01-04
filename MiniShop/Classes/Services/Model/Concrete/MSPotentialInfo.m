//
//  MSPotential.m
//  MiniShop
//
//  Created by Wuquancheng on 13-5-26.
//  Copyright (c) 2013年 mini. All rights reserved.
//

#import "MSPotentialInfo.h"


@implementation MSPotentialInfo
- (Class)classForAttri:(NSString *)attriName
{
    if ( [@"kink_goods_info" isEqualToString:attriName] )
    {
        return [MSGoodsItem class];
    }
    return nil;
}

@end


@implementation MSPotentialShop
- (Class)classForAttri:(NSString *)attriName
{
    if ( [@"goods_info" isEqualToString:attriName] )
    {
        return [MSGoodsItem class];
    }
    return nil;
}
@end