//
//  MSShopCate.m
//  MiniShop
//
//  Created by Wuquancheng on 13-12-11.
//  Copyright (c) 2013年 mini. All rights reserved.
//

#import "MSNCate.h"

@implementation MSNCate
@end

@implementation MSNCateList
- (id)init
{
    self = [super init];
    if ( self ) {
        [self setAttri:@"info" clazz:[MSNCate class]];
    }
    return self;
}
@end


@implementation MSNSpecialcate
@end


@implementation MSNWellCate

- (void)setParam:(id)param {
    if ([param isKindOfClass:[NSNumber class]]) {
        _param = [NSString stringWithFormat:@"%d",[param integerValue]];
    }
    else {
        _param = param;
    }
}
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

@implementation MSNSpecialcateList
- (id)init
{
    self = [super init];
    if ( self ) {
        [self setAttri:@"info" clazz:[MSNSpecialcate class]];
    }
    return self;
}
@end