//
//  MSNShop.m
//  MiniShop
//
//  Created by Wuquancheng on 13-12-28.
//  Copyright (c) 2013年 mini. All rights reserved.
//

#import "MSNShop.h"
#import "MSNGoodsList.h"

@implementation MSNShopInfo
- (NSInteger)gradeValue
{
    int grade = [self.shop_grade intValue];
    if (grade>10000000) {
        return 45;
    }
    else if (grade>5000000) {
        return 44;
    }
    else if (grade>2000000) {
        return 43;
    }
    else if (grade>1000000) {
        return 42;
    }
    else if (grade>500000) {
        return 41;
    }
    else if (grade>200000) {
        return 35;
    }
    else if (grade>100000) {
        return 34;
    }
    else if (grade>20000) {
        return 33;
    }
    else if (grade>10000) {
        return 32;
    }
    else if (grade>5000) {
        return 25;
    }
    else if (grade>2000) {
        return 24;
    }
    else if (grade>1000) {
        return 23;
    }
    else if (grade>500) {
        return 22;
    }
    else if (grade>250) {
        return 21;
    }
    else if (grade>150) {
        return 15;
    }
    else if (grade>90) {
        return 14;
    }
    else if (grade>40) {
        return 13;
    }
    else if (grade>10) {
        return 12;
    }
    else if (grade>4) {
        return 11;
    }
    else {
        return 10;
    }
}
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

@implementation MSNShopDetailInfo:MSObject
- (id)init
{
    self = [super init];
    if (self) {
        [self setAttri:@"shop_info" clazz:[MSNShopInfo class]];
        [self setAttri:@"goods_info" clazz:[MSNGoodsItem class]];
    }
    return self;
}
@end

@implementation MSNShopDetail:MSObject
- (id)init
{
    self = [super init];
    if (self) {
        [self setAttri:@"info" clazz:[MSNShopDetailInfo class]];
    }
    return self;
}
@end