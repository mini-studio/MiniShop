//
//  MSAboutViewController.m
//  MiniShop
//
//  Created by Wuquancheng on 13-4-6.
//  Copyright (c) 2013年 mini. All rights reserved.
//

#import <sys/ucred.h>
#import "MSWeChatViewController.h"
#import "UIColor+Mini.h"
#import "UILabel+Mini.h"
#import "MSSystem.h"
#import "MiniSysUtil.h"
#import "QRCodeGenerator.h"


// 字体高度配置
#define KLabelHeight          12.0f

@interface MSWeChatViewController ()

@end

@implementation MSWeChatViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    [self setNaviBackButton];
    self.contentView.backgroundColor = [UIColor whiteColor];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"qrcode"]];
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.contentView.bounds];
    imageView.centerX = scrollView.width/2;
    [scrollView addSubview:imageView];
    scrollView.height = self.contentView.height;
    [self.contentView addSubview:scrollView];
    scrollView.contentSize = CGSizeMake(self.contentView.width, imageView.height>scrollView.height?imageView.height:scrollView.height+1);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.naviTitleView.title = @"微信";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
