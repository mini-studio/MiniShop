//
//  MSNotiItemInfo.m
//  MiniShop
//
//  Created by Wuquancheng on 13-3-31.
//  Copyright (c) 2013年 mini. All rights reserved.
//

#import "MSNotiItemInfo.h"
#import "UIColor+Mini.h"

@implementation MSNotiItemInfo

- (NSString *)name
{
    if ( [self.type isEqualToString:MSStoreNewsTypeOffical] || [self.type isEqualToString:MSStoreNewsTypeTopic] ||
        [self.type isEqualToString:MSStoreNewsTypeURL])
    {
        return _title;
    }
    else
    {
        return _name;
    }
}

- (NSString *)realName
{
    return _name;
}

- (id)realIntro
{
    return _intro;
}

- (NSString *)iId
{
    return [NSString stringWithFormat:@"%lld",self.mid];
}

- (NSString *)typeNoteDesc
{
    NSDictionary *dic = @{
    MSStoreNewsTypeOffical:          @"推荐",             // 官方推荐
    MSStoreNewsTypeStorePromotion:   @"活动" ,         // 店铺活动
    MSStoreNewsTypeGoodsPromotion:   @"活动",       // 商品活动
    MSStoreNewsTypeSaunter:          @"随便看看"  ,               // 随便看看
    MSStoreNewsTypeNewProduct:       @"上新" ,             // 新品上架
    MSStoreNewsTypePrevue:           @"剧透" ,               // 新品剧透
                          };
    return [dic valueForKey:self.type];
}

- (UIColor *)typeNoteColor
{
    NSDictionary *dic = @{
                          MSStoreNewsTypeOffical:          [UIColor whiteColor],             // 官方推荐
                          MSStoreNewsTypeStorePromotion:   [UIColor whiteColor] ,         // 店铺活动
                          MSStoreNewsTypeGoodsPromotion:   [UIColor whiteColor],       // 商品活动
                          MSStoreNewsTypeSaunter:          [UIColor whiteColor],       // 随便看看
                          MSStoreNewsTypeNewProduct:       [UIColor whiteColor] ,             // 新品上架
                          MSStoreNewsTypePrevue:           [UIColor whiteColor] ,               // 新品剧透
                          };
    return [dic valueForKey:self.type];
}

- (NSString *)typeTitleDesc
{
    NSDictionary *dic = @{
                          MSStoreNewsTypeOffical:          @"官方推荐",             // 官方推荐
                          MSStoreNewsTypeStorePromotion:   @"店铺活动" ,         // 店铺活动
                          MSStoreNewsTypeGoodsPromotion:   @"商品活动",       // 商品活动
                          MSStoreNewsTypeSaunter:          @"随便看看"  ,               // 随便看看
                          MSStoreNewsTypeNewProduct:       @"商品上新" ,             // 新品上架
                          MSStoreNewsTypePrevue:           @"新品剧透" ,               // 新品剧透
                          };
    return [dic valueForKey:self.type];
}

- (void)setRead:(BOOL)read
{
    NSString *key = [NSString stringWithFormat:@"NotiItem-%@",[self iId]];
    [[NSUserDefaults standardUserDefaults] setBool:read forKey:key];
}

- (BOOL)read
{
    NSString *key = [NSString stringWithFormat:@"NotiItem-%@",[self iId]];
    id v = [[NSUserDefaults standardUserDefaults] valueForKey:key];
    if ( v == NULL || ![v boolValue])
    {
        return NO;
    }
    else
    {
        return YES;
    }
}

@end



@implementation MSNotiItemGroupInfo
- (Class)classForAttri:(NSString *)attriName
{
    if ( [@"items_info" isEqualToString:attriName] )
    {
        return [MSNotiItemInfo class];
    }
    else if ( [@"shop_info" isEqualToString:attriName] )
    {
        return [MSShopInfo class];
    }
    return nil;
}

- (NSString *)shop_title
{
    return self.shop_info.shop_title;
}

- (NSInteger)shop_id
{
    return self.shop_info.shop_id;
}

- (int64_t)mid
{
    if(  self.items_info.count > 0 )
    {
        MSNotiItemInfo *info = [self.items_info objectAtIndex:0];
        return info.mid;
    }
    return 0;
}

- (NSString *)iId
{
    NSMutableString *string = [NSMutableString string];
    for (MSNotiItemInfo *info in self.items_info )
    {
        [string appendFormat:@"%lld-",info.mid];
    }
    return string;
}

- (NSString *)name
{
    return self.shop_info.shop_title;
}

- (id)intro
{
    NSMutableString *string = [NSMutableString string];
    if ( [MSStoreNewsTypeGoodsPromotion isEqualToString:self.type] || [MSStoreNewsTypeStorePromotion isEqualToString:self.type])
    {
        if ( self.items_info.count > 0 )
        {
            MSNotiItemInfo *info = self.items_info[0];
            [string appendString:info.realName];
            [string appendString:@"："];
            [string appendString:info.realIntro];
            [string appendString:@"\n时间："];
            [string appendString:info.start_time];
            [string appendString:@" 至 "];
            [string appendString:info.end_time];
            return string;
        }
    }
   
    for (MSNotiItemInfo *info in self.items_info )
    {
        [string appendFormat:@"%@ : %d件",info.publish_time,info.goods_num];
        if ( [self.items_info lastObject] != info )
        {
            [string appendString:@"\r\n"];
        }
    }
    return string;
}
@end
