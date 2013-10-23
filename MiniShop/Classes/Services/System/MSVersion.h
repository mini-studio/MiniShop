//
//  MSVersion.h
//  MiniShop
//
//  Created by Wuquancheng on 13-4-5.
//  Copyright (c) 2013年 mini. All rights reserved.
//

#import "MSObject.h"

@interface MSVersion : MSObject
@property (nonatomic,strong) NSString *v;
@property (nonatomic,strong) NSString *cv;
@property (nonatomic,strong) NSString *url;
@property (nonatomic,strong) NSString *intro;
@property (nonatomic,strong) NSString *imei;
@property (nonatomic) NSInteger type;
@property (nonatomic) NSInteger auth;
@property (nonatomic,strong) NSString  *fav_url;
@property (nonatomic) NSInteger list;
@property (nonatomic,strong) NSString *push_sound;
@end
