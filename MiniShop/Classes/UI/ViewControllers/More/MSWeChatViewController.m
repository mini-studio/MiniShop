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
#import "MiniUIButton+Mini.h"


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

- (UILabel*)textLabel:(NSString*) text frame:(CGRect)frame fontSize:(CGFloat)fontSize
{
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.font = [UIFont systemFontOfSize:fontSize];
    label.textColor = [UIColor colorWithRGBA:0x303030FF];
    label.text = text;
    label.frame = frame;
    return label;
}

- (void)loadView
{
    [super loadView];
    [self setNaviBackButton];
    self.contentView.backgroundColor = [UIColor whiteColor];

    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.contentView.bounds];
    [self.contentView addSubview:scrollView];
    
    CGFloat top = 24;
    UIImage *image = [UIImage imageNamed:@"wchat_qr"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    CGFloat left = (self.contentView.width-imageView.width)/2;
    UILabel *label = [self textLabel:@"美梦A啦微信官方账号" frame:CGRectMake(left, top, 200, 10) fontSize:10];
    [scrollView addSubview:label];
    
    top = label.bottom+12;
    label = [self textLabel:@"meila2014" frame:CGRectMake(left, top, 200, 14) fontSize:14];
    [scrollView addSubview:label];
    top = label.bottom + 12;
    
    imageView.center = CGPointMake(scrollView.width/2, top+imageView.height/2);
    [scrollView addSubview:imageView];
    MiniUIButton *button = [MiniUIButton buttonWithType:UIButtonTypeCustom];
    button.frame = imageView.frame;
    [scrollView addSubview:button];
    [button setTouchupHandler:^(MiniUIButton *button) {
        [MiniUIAlertView showAlertWithTitle:@"" message:@"保存美梦A啦微信官方账号图片?" block:^(MiniUIAlertView *alertView, NSInteger buttonIndex) {
            if (buttonIndex!=0) {
                UIImageWriteToSavedPhotosAlbum(image,self,@selector(image:didFinishSavingWithError:contextInfo:),nil);
            }
        } cancelButtonTitle:@"不,谢谢" otherButtonTitles:@"保存",nil];
    }];
    
    top = imageView.bottom + 14;
    
    label = [self textLabel:@"可复制并在微信中搜索账号添加" frame:CGRectMake(left, top, 200, 10) fontSize:9];
    [scrollView addSubview:label];
    button = [MiniUIButton buttonWithType:UIButtonTypeCustom];
    button.frame = label.frame;
    [scrollView addSubview:button];
    [button setTouchupHandler:^(MiniUIButton *button) {
        [MiniUIAlertView showAlertWithTitle:@"" message:@"梦A啦微信官方账号?" block:^(MiniUIAlertView *alertView, NSInteger buttonIndex) {
            if (buttonIndex!=0) {
                [[MiniSysUtil sharedInstance] copyToBoard:@"meila2014"];
                [self showMessageInfo:@"官方账号已复制" delay:2];
            }
        } cancelButtonTitle:@"不,谢谢" otherButtonTitles:@"复制",nil];
    }];

    
    top = label.bottom + 14;
    
    image = [UIImage imageNamed:@"wchat_sp"];
    imageView = [[UIImageView alloc] initWithImage:image];
    imageView.width = self.contentView.width-40;
    imageView.center = CGPointMake(scrollView.width/2,top + imageView.height/2 );
    [scrollView addSubview:imageView];
    
    top = imageView.bottom + 24;
    label = [self textLabel:@"产品经理 首席客服matt微信账号" frame:CGRectMake(left, top, 200, 10) fontSize:10];
    [scrollView addSubview:label];
    
    top+=(label.height + 12);
    label = [self textLabel:@"moneygalaxy" frame:CGRectMake(left, top, 200, 18) fontSize:14];
    [scrollView addSubview:label];
    top+=label.height + 12;

    imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"wchat_matt"]];
    imageView.center = CGPointMake(scrollView.width/2,top + imageView.height/2 );
    [scrollView addSubview:imageView];
    
    
    scrollView.contentSize = CGSizeMake(self.contentView.width, imageView.height>scrollView.height?imageView.height:scrollView.height+1);
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (error==nil) {
        [self showMessageInfo:@"图片已保存" delay:2];
    }
    else {
        [self showErrorMessage:error];
    }

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
