//
//  MSFavshopList.m
//  MiniShop
//
//  Created by Wuquancheng on 13-12-15.
//  Copyright (c) 2013年 mini. All rights reserved.
//

#import "MSNFavshopList.h"

@interface MSNFavshopList()
@property (nonatomic,strong)NSMutableDictionary *dataSource;
@property (nonatomic,strong)NSArray *dataKey;
@end

@implementation MSNFavshopList
- (id)init
{
    if (self=[super init]){
        [self setAttri:@"info" clazz:[MSNGoodItem class]];
        self.dataSource = [NSMutableDictionary dictionaryWithCapacity:12];
        self.dataKey = [NSMutableArray arrayWithCapacity:12];
    }
    return self;
}

- (void)append:(MSNFavshopList*)list
{
    self.next_page = list.next_page;
    [(NSMutableArray*)self.info addObjectsFromArray:list.info];
}

- (void)group
{
    [_dataSource removeAllObjects];
    if ([self.sort isEqualToString:SORT_TIME])
    {
        for (MSNGoodItem *item in self.info ) {
            NSMutableArray *array = _dataSource[item.goods_date];
            if (array == nil) {
                array = [NSMutableArray array];
                _dataSource[item.goods_date] = array;
            }
            [array addObject:item];
        }
    }
    else
    {
        int count = self.info.count;
        for ( int index = 0; index < count; index++) {
            NSString *key = ITOS(index/3);
            NSMutableArray *array = _dataSource[key];
            if (array == nil) {
                array = [NSMutableArray array];
                _dataSource[key] = array;
            }
            [array addObject:[self.info objectAtIndex:index]];
        }
    }
    NSArray *allkey = self.dataSource.allKeys;
    self.dataKey = [allkey sortedArrayWithOptions:NSSortConcurrent usingComparator:^NSComparisonResult(NSString * obj1, NSString * obj2) {
        return [obj2 compare:obj1];
    }];
}

- (NSArray *)dataAtIndex:(unsigned)index
{
    if (index >= self.dataKey.count) {
        return nil;
    }
    NSString *key = [self.dataKey objectAtIndex:index];
    return self.dataSource[key];
}

- (int)numberOfRows
{
    return self.dataKey.count;
}

@end

@implementation MSNGoodItem

- (void)setGoods_create_time:(NSString *)goods_create_time
{
    _goods_create_time = goods_create_time;
    NSArray *array = [_goods_create_time componentsSeparatedByString:@" "];
    if ( array.count > 0 ) {
        _goods_date = array[0];
    }
}
@end
