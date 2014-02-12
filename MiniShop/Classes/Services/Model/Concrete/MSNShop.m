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
    if (grade>=16) {
        return 40+(grade-15);
    }
    else if (grade>=11) {
        return 30+(grade-10);
    }
    else if (grade>=6) {
        return 20+(grade-5);
    }
    else if (grade>=1) {
        return 10+grade;
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


@implementation MSNGuessObject
- (id)init
{
    self = [super init];
    if (self) {
        [self setAttri:@"info" clazz:[MSNShopInfo class]];
    }
    return self;
}
@end