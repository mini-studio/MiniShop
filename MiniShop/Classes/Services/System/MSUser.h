//
//  MSUser.h
//  MiniShop
//
//  Created by Wuquancheng on 13-4-5.
//  Copyright (c) 2013年 mini. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MSUser : MSObject
@property (nonatomic,strong)NSString *uniqid;
@property (nonatomic,strong)NSString *usernick;
@property (nonatomic,strong)NSString *imei;
@end
