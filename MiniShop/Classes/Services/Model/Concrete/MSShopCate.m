//
//  MSShopCate.m
//  MiniShop
//
//  Created by Wuquancheng on 13-12-11.
//  Copyright (c) 2013年 mini. All rights reserved.
//

#import "MSShopCate.h"

@implementation MSTag
@end

@implementation MSShopCate
- (id)init
{
    self = [super init];
    if ( self ) {
        [self setAttri:@"info" clazz:[MSTag class]];
    }
    return self;
}
@end
