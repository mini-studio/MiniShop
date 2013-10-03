//
//  MSGoodsList.m
//  MiniShop
//
//  Created by Wuquancheng on 13-4-1.
//  Copyright (c) 2013年 mini. All rights reserved.
//

#import "MSGoodsList.h"
#import "NSDate+Format.h"

@implementation MSGoodItem

@synthesize big_image_url = _big_image_url;

- (NSString*)image_url
{
    if ( _image_url == nil || _image_url.length == 0 )
    {
        _image_url = _big_image_url;
    }
    return _image_url;
}

- (NSString*)big_image_url
{
    if ( _big_image_url == nil || _big_image_url.length == 0 )
    {
        _big_image_url = _image_url;
    }
    return  _big_image_url;
}

- (void)setBig_image_url:(NSString *)big_image_url
{
    if ( [big_image_url hasSuffix:@".jpg_.jpg"] ) {
        big_image_url = [big_image_url substringToIndex:big_image_url.length-5];
    }
    _big_image_url = big_image_url;
}

- (void)setRead:(BOOL)read
{
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    [def setBool:read forKey:[NSString stringWithFormat:@"good_item_%lld",_mid]];
    [def synchronize];
}

- (void)setSku_num:(id)sku_num
{
    if ( [sku_num isKindOfClass:[NSString class] ] ) {
        _sku_num = sku_num;
    }
    else if ( [sku_num isKindOfClass:[NSNumber class]] ){
        _sku_num = [NSString stringWithFormat:@"%d",[sku_num integerValue]];
    }
    else {
        _sku_num = [sku_num string];
    }
}

+ (BOOL)isRead:(int64_t)mid
{
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    BOOL v = [def boolForKey:[NSString stringWithFormat:@"good_item_%lld",mid]];
    return v;
}

@end

@implementation MSGoodsListInfo


@end

@implementation MSGoodsList
- (Class)classForAttri:(NSString *)attriName
{
    if ( [attriName isEqualToString:@"body_info"] )
    {
        return [MSGoodItem class];
    }
    else if ( [attriName isEqualToString:@"pre_info"] || [attriName isEqualToString:@"next_info"] )
    {
        return [MSGoodsListInfo class];
    }
    return nil;
}

- (void)setBody_info:(id)body_info
{
    if ([body_info isKindOfClass:[NSArray class]])
    {
        _body_info = body_info;
    }
    else if ( [body_info isKindOfClass:[MSGoodItem class]])
    {
        _body_info = [NSMutableArray array];
        [(NSMutableArray*)_body_info addObject:body_info];
    }
}
@end


@implementation MSShopGalleryItemInfo
@end

@implementation MSShopGalleryInfo
- (Class)classForAttri:(NSString *)attriName
{
    if ( [attriName isEqualToString:@"goods_info"] )
    {
        return [MSGoodItem class];
    }
    else if ( [attriName isEqualToString:@"item_info"])
    {
        return [MSShopGalleryItemInfo class];
    }
    return nil;
}
@end

@interface  MSShopGalleryList()
@property (nonatomic,strong)NSMutableDictionary *dictionary;
@end

@implementation MSShopGalleryList
- (Class)classForAttri:(NSString *)attriName
{
    if ( [attriName isEqualToString:@"body_info"] )
    {
        return [MSShopGalleryInfo class];
    }
    return nil;
}

- (void)appendGoodItems:(NSArray *)items
{
    if ( self.dictionary == nil )
    {
        self.dictionary = [NSMutableDictionary dictionary];
    }
    for (MSGoodItem *item in items)
    {
        NSString *date = item.date;
        NSDate *da = [NSDate dateFromString:date format:@"yyyy-MM-dd"];
        NSTimeInterval interval = [da timeIntervalSinceNow];
        if ( interval < -(14*24*3600))
        {
            date = @"14天以前上架的商品";
        }
        MSShopGalleryInfo *info = [self.dictionary valueForKey:date];
        if ( info != nil )
        {
            [(NSMutableArray*)info.goods_info addObject:item];
        }
        else
        {
            info = [[MSShopGalleryInfo alloc] init];
            MSShopGalleryItemInfo *itemInfo = [[MSShopGalleryItemInfo alloc] init];
            itemInfo.publish_time = date;
            info.goods_info = [NSMutableArray array];
            info.item_info = itemInfo;
            
            [self.dictionary setValue:info forKey:date];
            [(NSMutableArray*)info.goods_info addObject:item];
            [(NSMutableArray*)self.body_info addObject:info];
        }
    }
}
@end
