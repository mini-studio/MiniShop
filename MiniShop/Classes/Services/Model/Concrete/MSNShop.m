//
//  MSNShop.m
//  MiniShop
//
//  Created by Wuquancheng on 13-12-28.
//  Copyright (c) 2013年 mini. All rights reserved.
//

#import "MSNShop.h"

@implementation MSNShopInfo

@end

@implementation MSNShopList
- (id)init
{
    self = [super init];
    if (self) {
        [self setAttri:@"info" clazz:[MSNShopInfo class]];
    }
    return self;
}

- (void)append:(MSNShopList*)list
{
    [(NSMutableArray*)self.info addObjectsFromArray:list.info];
}
@end