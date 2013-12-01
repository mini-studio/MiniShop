//
//  MSJoinViewController.m
//  MiniShop
//
//  Created by Wuquancheng on 13-6-19.
//  Copyright (c) 2013年 mini. All rights reserved.
//

#import "MSJoinViewController.h"
#import "MiniSysUtil.h"

@interface MSJoinViewController ()
@property(nonatomic,strong)UIImageView *imageView;
@end

@implementation MSJoinViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	[self setNaviBackButton];
    self.naviTitleView.title = @"QQ群";
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[MiniUIImage imageNamed:@"join_us"]];
    imageView.userInteractionEnabled = YES;
    imageView.center = CGPointMake(self.view.width+self.view.width/2, imageView.height/2+20);
    [self.contentView addSubview:imageView];
    self.imageView = imageView;
    for ( int index = 0; index < 2; index++ )
    {
        MiniUIButton *button = [MiniUIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(0, imageView.height/2 + (index==0?-50:0), imageView.width, 50);
        button.backgroundColor = [UIColor clearColor];
        [imageView addSubview:button];
        button.longPressTimeInterval = 0.5;
        button.userInfo = (index==0?@"301350759":@"293129445");
        [button addTarget:self action:@selector(longPressed:) forControlEvents:UIControlEventTouchUpInsideRepeat];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [UIView animateWithDuration:0.25 animations:^{
        self.imageView.center = CGPointMake(self.view.width/2, self.imageView.height/2 + 20) ;
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)longPressed:(MiniUIButton*)button
{
    NSString *code = button.userInfo;
    [[MiniSysUtil sharedInstance] copyToBoard:code];
    [self showMessageInfo:[NSString stringWithFormat:@"QQ号码“%@”\n已经复制啦",code] delay:2];
}

@end
