//
//  MSUIAuthWebViewController.h
//  MiniShop
//
//  Created by Wuquancheng on 13-4-5.
//  Copyright (c) 2013年 mini. All rights reserved.
//

#import "MSUIWebViewController.h"

@interface MSUIAuthWebViewController : MSUIWebViewController
@property (nonatomic,strong) void (^callback)( bool );
@end
