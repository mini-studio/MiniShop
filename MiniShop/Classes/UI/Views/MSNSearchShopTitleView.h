//
//  MSNSearchShopTitleView.h
//  MiniShop
//
//  Created by Wuquancheng on 14-2-2.
//  Copyright (c) 2014年 mini. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MSNTransformButton.h"

@interface MSNSearchShopTitleView : UIView
@property (nonatomic,strong)NSString *keyWord;
@property (nonatomic,readonly) MSNTransformButton *transformButton;
@end
