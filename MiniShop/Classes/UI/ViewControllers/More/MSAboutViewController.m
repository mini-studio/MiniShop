//
//  MSAboutViewController.m
//  MiniShop
//
//  Created by Wuquancheng on 13-4-6.
//  Copyright (c) 2013年 mini. All rights reserved.
//

#import "MSAboutViewController.h"
#import "MSUIWebViewController.h"
#import "UIColor+Mini.h"
#import "UILabel+Mini.h"
#import "MSSystem.h"
#import "MiniSysUtil.h"
#include "UIDevice+Ext.h"
#import <QuartzCore/QuartzCore.h>

// 间距配置
#define KCopyrightHeight            62.0f

// 字体颜色配置
#define KLabelColor          0x898989AA

// 字体高度配置
#define KLabelHeight          12.0f

@interface MSAboutViewController ()

@end

@implementation MSAboutViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    UIImage *image = [MiniUIImage imagePreciseNamed:@"about" ext:@"jpg"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.frame = self.view.bounds;
    imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:imageView];
    [self addLogo];
}

- (void)addLogo
{
    NSString *ver = [NSString stringWithFormat:@"版本:%@",[MSSystem bundleversion]];
    UILabel *lable = [UILabel LabelWithFrame:CGRectZero
                                     bgColor:[UIColor colorWithRGBA:0x00000055]
                                        text:ver
                                       color:[UIColor whiteColor]
                                        font:[UIFont boldSystemFontOfSize:KLabelHeight]
                                   alignment:NSTextAlignmentCenter
                                 shadowColor:nil
                                  shadowSize:CGSizeZero];
    [lable sizeToFit];
    lable.size = CGSizeMake(lable.size.width + 12, lable.size.height + 6);
    lable.layer.cornerRadius =  lable.size.height/2;
    lable.layer.masksToBounds = YES;
    lable.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    lable.center = CGPointMake(self.view.width/2, self.view.height - 60 );
    [self.view addSubview:lable];
    CGFloat width = self.view.width - 160;
    MiniUIButton * tel = [MiniUIButton buttonWithType:UIButtonTypeCustom];
    //tel.backgroundColor = [UIColor redColor];
    tel.frame = CGRectMake(80, self.view.height/2+(IS_IPHONE5?0:30) , width, 40);
    tel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [tel setTouchupHandler:^(MiniUIButton *button) {
        [MiniSysUtil call:@"01082858599"];
    }];
    [self.view addSubview:tel];
    MiniUIButton * address = [MiniUIButton buttonWithType:UIButtonTypeCustom];
    address.frame = CGRectMake(20, self.view.height - 30 , self.view.width - 40, 30);
    address.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    __weak typeof (self) pSelf = self;
    [address setTouchupHandler:^(MiniUIButton *button) {
        MSUIWebViewController *controller = [[MSUIWebViewController alloc] initWithUri:@"http://www.youjiaxiaodian.com" title:nil toolbar:YES];
        [pSelf.navigationController pushViewController:controller animated:YES];
    }];
    [self.view addSubview:address];

    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.navigationItem.title = @"关于";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
