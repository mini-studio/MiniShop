//
//  MSFavshopList.m
//  MiniShop
//
//  Created by Wuquancheng on 13-12-15.
//  Copyright (c) 2013年 mini. All rights reserved.
//

#import "MSNGoodsList.h"

@interface MSNGoodsList()
@property (nonatomic,strong)NSMutableDictionary *dataSource;
@property (nonatomic,strong)NSMutableArray *dataKey;
@end

@implementation MSNGoodsList
- (id)init
{
    if (self=[super init]){
        [self setAttri:@"info" clazz:[MSNGoodsItem class]];
        self.dataSource = [NSMutableDictionary dictionaryWithCapacity:12];
        self.dataKey = [NSMutableArray arrayWithCapacity:12];
    }
    return self;
}

- (void)append:(MSNGoodsList*)list
{
    self.next_page = list.next_page;
    [(NSMutableArray*)self.info addObjectsFromArray:list.info];
}

- (void)group
{
    [_dataSource removeAllObjects];
    if ([SORT_TIME isEqualToString:self.sort])
    {
        for (MSNGoodsItem *item in self.info ) {
            NSString *key = [NSString stringWithFormat:@"%@ %@",item.goods_date,item.shop_title];
            NSMutableArray *array = _dataSource[key];
            if (array == nil) {
                array = [NSMutableArray array];
                _dataSource[key] = array;
            }
            [array addObject:item];
        }
        NSArray *allkey = self.dataSource.allKeys;
        [self.dataKey removeAllObjects];
        [self.dataKey addObjectsFromArray:[allkey sortedArrayWithOptions:NSSortConcurrent usingComparator:^NSComparisonResult(NSString * obj1, NSString * obj2) {
            return [obj2 compare:obj1];
        }]];
    }
    else
    {
        [self.dataKey removeAllObjects];
        int count = self.info.count;
        for ( int index = 0; index < count; ) {
            NSString *key = ITOS(index/3);
            NSMutableArray *array = _dataSource[key];
            if (array == nil) {
                array = [NSMutableArray array];
                _dataSource[key] = array;
            }
            int length = 3;
            if (length+index>=count){
                length = count-index;
            }
            NSRange rang = NSMakeRange(index, length);
            
            [array addObjectsFromArray:[self.info subarrayWithRange:rang]];
            [self.dataKey addObject:key];
            index += 3;
        }
    }
   
}

- (NSArray *)dataAtIndex:(unsigned)index
{
    if (index >= self.dataKey.count) {
        return nil;
    }
    NSString *key = [self.dataKey objectAtIndex:index];
    return self.dataSource[key];
}

- (NSString *)keyAtIndex:(unsigned)index
{
    if (index >= self.dataKey.count) {
        return nil;
    }
    else {
        return [self.dataKey objectAtIndex:index];
    }
}

- (int)numberOfRows
{
    return self.dataKey.count;
}

- (NSArray *)allSortedItems
{
    NSMutableArray *array = [NSMutableArray array];
    for (NSString *key in self.dataKey) {
        [array addObjectsFromArray:self.dataSource[key]];
    }
    return array;
}

@end

@implementation MSNGoodsItem

- (void)setGoods_create_time:(NSString *)goods_create_time
{
    _goods_create_time = goods_create_time;
    NSArray *array = [_goods_create_time componentsSeparatedByString:@" "];
    if ( array.count > 0 ) {
        _goods_date = array[0];
    }
}

- (NSString*)discountMessage
{
    if (_discountMessage==nil) {
        CGFloat sale = self.goods_sale_price.floatValue;
        CGFloat marke = self.goods_marked_price.floatValue;
        if (sale==marke) {
            _discountMessage = @"";
        }
        else {
            _discountMessage = [NSString stringWithFormat:@"%0.1f折",10*(sale/marke)];
        }
    }
    return _discountMessage;
}
@end

@implementation MSNGoodsDetailInfo : MSObject
- (id)init
{
    if (self=[super init]){
        [self setAttri:@"goods_info" clazz:[MSNGoodsItem class]];
    }
    return self;
}
@end

@implementation MSNGoodsDetail : MSObject
- (id)init
{
    if (self=[super init]){
        [self setAttri:@"shop_info" clazz:[MSNShopInfo class]];
        [self setAttri:@"info" clazz:[MSNGoodsDetailInfo class]];
    }
    return self;
}
@end