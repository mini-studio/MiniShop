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
    [self.dataKey removeAllObjects];
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
            if ([self.dataKey indexOfObject:key]==NSNotFound) {
                [self.dataKey addObject:key];
            }
        }
    }
    else
    {
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

- (void)copy:(MSNGoodsItem *)other
{
    self.mid = other.mid;
    self.big_image_url = other.big_image_url;
    self.goods_create_time = other.goods_create_time;
    self.goods_id = other.goods_id;
    self.goods_marked_price = other.goods_marked_price;
    self.goods_sale_price = other.goods_sale_price;
    self.goods_title = other.goods_title;
    self.image_url = other.image_url;
    self.micro_image_url = other.micro_image_url;
    self.middle_image_url = other.middle_image_url;
    self.small_image_url = other.small_image_url;
    self.price_history_intro = other.price_history_intro;
    self.goods_sales_intro = other.goods_sales_intro;
    self.shop_id = other.shop_id;
    self.shop_title = other.shop_title;
    self.like_goods = other.like_goods;

    self.goods_date = other.goods_date;
    self.detail = other.detail;
    self.discountMessage = other.discountMessage;
    self.image = other.image;
}

- (NSString*)valueForKey:(NSString*)key def:(NSString*)def
{
    id v = [self valueForKey:key];
    if (v==nil) {
        return def;
    }
    if ([v isKindOfClass:[NSString class]]) {
        return v;
    }
    else if ([v isKindOfClass:[NSNumber class]]) {
        return [(NSNumber*)v stringValue];
    }
    else {
        return def;
    }
}

-(NSDictionary *)dictionary {
    NSArray *keys = @[@"big_image_url",@"goods_create_time",@"goods_id",@"goods_marked_price",
                      @"goods_sale_price",@"goods_title",@"image_url",@"micro_image_url",@"middle_image_url",
                      @"small_image_url",@"price_history_intro",@"goods_sales_intro",@"shop_id",
                      @"shop_title",@"like_goods",@"mid"];
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    for (NSString *key in keys) {
        [dic setValue:[self valueForKey:key def:@""] forKey:key];
    }
    return dic;
}

@end

@implementation MSNGoodsDetailInfo : MSObject
- (id)init
{
    if (self=[super init]){
        [self setAttri:@"goods_info" clazz:[MSNGoodsItem class]];
        [self setAttri:@"collocation_info" clazz:[MSNGoodsItem class]];
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