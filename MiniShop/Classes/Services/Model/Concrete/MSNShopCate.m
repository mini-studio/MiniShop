//
//  MSShopCate.m
//  MiniShop
//
//  Created by Wuquancheng on 13-12-11.
//  Copyright (c) 2013年 mini. All rights reserved.
//

#import "MSNShopCate.h"

@implementation MSNShopCate
@end

@implementation MSNShopCateList
- (id)init
{
    self = [super init];
    if ( self ) {
        [self setAttri:@"info" clazz:[MSNShopCate class]];
    }
    return self;
}
@end


@implementation MSNSpecialcate
@end


@implementation MSNWellCate
@end

@implementation MSNWellCateGroup
- (id)init
{
    self = [super init];
    if ( self ) {
        [self setAttri:@"item" clazz:[MSNWellCate class]];
    }
    return self;
}
@end

@implementation MSNWellCateList
- (id)init
{
    self = [super init];
    if ( self ) {
        [self setAttri:@"info" clazz:[MSNWellCateGroup class]];
    }
    return self;
}
@end