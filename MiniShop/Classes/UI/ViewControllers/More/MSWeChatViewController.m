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
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 60, self.contentView.width, 40)];
    label.numberOfLines=2;
    label.text = @"微信号:youjiaxiaodianapp\nwenjun133";
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont systemFontOfSize:14];
    [self.contentView addSubview:label];
    UIImage *image = [QRCodeGenerator qrImageForString:@"微信号:youjiaxiaodianapp" imageSize:200];
    UIImageView * imageView = [[UIImageView alloc] initWithImage:image];
    imageView.center = CGPointMake(self.contentView.width/2, imageView.height/2 + label.bottom);
    [self.contentView addSubview:imageView];
}

- (void)addLogo
{

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
