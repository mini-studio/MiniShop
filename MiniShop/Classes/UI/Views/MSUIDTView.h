//
//  MSUIDTView.h
//  MiniShop
//
//  Created by Wuquancheng on 13-9-14.
//  Copyright (c) 2013年 mini. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MiniUIWebView.h"

@interface MSUIDTView : UIView
@property(nonatomic)CGFloat bestTop;
@property(nonatomic,strong)MiniUIWebView *webView;
@property(nonatomic)int64_t mid;
@property(nonatomic,strong)UIView    *toolbar;
- (void)loadDetail;
@end
