//
//  MSVerifyViewController.m
//  MiniShop
//
//  Created by Wuquancheng on 13-5-25.
//  Copyright (c) 2013年 mini. All rights reserved.
//

#import "MSVerifyViewController.h"
#import "UILabel+Mini.h"
#import "UIColor+Mini.h"
#import "UIImage+Mini.h"
#import "MSCooperateInfo.h"
#import "UIImageView+WebCache.h"
#import "MSUIWebViewController.h"

#define KIMAGEVIEW_TAG 0xA898930

@interface MSVerifyViewController ()
@property (nonatomic,strong)UILabel *label;
@property (nonatomic,strong)UILabel *shopNameLabel;
@property (nonatomic,strong)NSMutableArray *goodImageViews;
@property (nonatomic,strong)UIView  *buttonsView;
@property (nonatomic,strong)UIView  *verifyButtonsView;
@property (nonatomic,strong)MSCooperateInfo *cooperateInfo;
@end

@implementation MSVerifyViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.goodImageViews = [NSMutableArray array];
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"verify_top"]];
    imageView.frame = CGRectMake(0, 0, self.view.width, imageView.height);
    [self.view addSubview:imageView];
    UIScrollView *sv = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    sv.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view insertSubview:sv belowSubview:imageView];
    
    UIImage *image = [UIImage imageNamed:@"verify_text_title"];
    image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(image.size.height/2, image.size.width/2, image.size.height/2, image.size.width/2)];
    imageView = [[UIImageView alloc] initWithImage:image];        
    imageView.frame = CGRectMake(0, 0, sv.width, 100);
    [sv addSubview:imageView];
    
    image = [UIImage imageNamed:@"verify_text_title"];
    image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(image.size.height/2, image.size.width/2, image.size.height/2, image.size.width/2)];
    UIImageView *above = imageView;
    for ( int index = 0; index < 2; index++ )
    {
        imageView = [[UIImageView alloc] initWithImage:image];
        if ( index == 1 )
        {
             imageView.frame = CGRectMake(0, above.bottom-6, sv.width, 120);
        }
        else
        {
            imageView.frame = CGRectMake(0, above.bottom-6, sv.width, 120);
        }
        [sv insertSubview:imageView belowSubview:above];
        above = imageView;

    }
    self.label = [UILabel LabelWithFrame:CGRectMake(0, 30, self.view.width, 20)
                                     bgColor:[UIColor clearColor]
                                        text:@""
                                       color:[UIColor whiteColor]
                                        font:[UIFont boldSystemFontOfSize:18]
                                   alignment:NSTextAlignmentLeft
                                 shadowColor:nil
                                  shadowSize:CGSizeZero];
    [sv addSubview:self.label];
    
    self.shopNameLabel = [UILabel LabelWithFrame:CGRectMake(0, self.label.bottom+10, self.view.width, 30)
                                 bgColor:[UIColor clearColor]
                                    text:@""
                                   color:[UIColor whiteColor]
                                    font:[UIFont systemFontOfSize:16]
                               alignment:NSTextAlignmentCenter
                             shadowColor:nil
                              shadowSize:CGSizeZero];
    self.shopNameLabel.numberOfLines = 0;
    [sv addSubview:self.shopNameLabel];
    
    self.buttonsView = [self createImagesView];
    self.buttonsView.top =  self.shopNameLabel.bottom + 20;
    [sv addSubview:self.buttonsView];
    
    imageView = [[UIImageView alloc] initWithImage:[MiniUIImage imageNamed:@"verify_btn_bg"]];
    imageView.center = CGPointMake(self.view.width/2, self.buttonsView.bottom + 26 + imageView.height/2);
    [sv addSubview:imageView];
    imageView.userInteractionEnabled = YES;
    self.verifyButtonsView = imageView;
    
    __weak typeof (self) pSelf = self;
    MiniUIButton *button = [MiniUIButton buttonWithBackGroundImage:[MiniUIImage imageNamed:@"button_h_normal"] highlightedBackGroundImage:[MiniUIImage imageNamed:@"button_h_selected"] title:@"同求"];
    [button prefect];
    button.frame = CGRectMake((imageView.width-230)/2, 30, 230, 40);
    [button setTouchupHandler:^(MiniUIButton *button) {
        [pSelf actionCooperate:YES];
    }];
    [imageView addSubview:button];
    MiniUIButton *button2 = [MiniUIButton buttonWithBackGroundImage:[MiniUIImage imageNamed:@"button_h_normal"] highlightedBackGroundImage:[MiniUIImage imageNamed:@"button_h_selected"] title:@"不同求"];
    [button2 prefect];
    button2.frame = CGRectMake(button.left, button.bottom + 10, button.width , button.height);
    [button2 setTouchupHandler:^(MiniUIButton *button) {
         [pSelf actionCooperate:NO];
    }];
    [imageView addSubview:button2];
    sv.contentSize = CGSizeMake(self.view.width, imageView.bottom+20);
    sv.alwaysBounceVertical = YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.naviTitleView.title = @"审核求收录";
    [self setNaviBackButton];
    [self loadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIView*)createImagesView
{
    CGFloat imageSize = (self.view.width - 40)/3;
    CGFloat gap = 10;
    CGFloat height = 2*imageSize + gap;
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, height)];
    [self.goodImageViews removeAllObjects];
    for ( int index = 0; index < 6; index++ )
    {
        int c = index%3;
        int r = index/3;
        MiniUIButton *button = [MiniUIButton buttonWithBackGroundImage:[MiniUIImage imageNamed:@"image_bg"] highlightedBackGroundImage:nil title:nil];
        button.tag = KIMAGEVIEW_TAG +index;
        CGRect frame = CGRectMake((imageSize+gap)*c + gap, r*(imageSize+2*gap), imageSize, imageSize);
        button.frame = frame;
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:button.bounds];
        [button addSubview:imageView];
        imageView.tag = KIMAGEVIEW_TAG;
        button.showsTouchWhenHighlighted = YES;
        [view addSubview:button];
        [self.goodImageViews addObject:imageView];
        [button addTarget:self action:@selector(actionForButtonTap:) forControlEvents:UIControlEventTouchUpInside];
    }
    return view;
}

- (void)loadGoodsImage
{
    CGFloat imageSize = (self.view.width - 80)/3;
    for (int index = 0; index < self.cooperateInfo.goods_info.count ; index++)
    {
        if ( index > 6 )
        {
            break;
        }
        MSCooperateGoodInfo *goodInfo = [self.cooperateInfo.goods_info objectAtIndex:index];
        __weak UIImageView *imageView = [self.goodImageViews objectAtIndex:index];
        [imageView setImageWithURL:[NSURL URLWithString:goodInfo.tsrtcg_goods_image_url] placeholderImage:nil success:^(UIImage *image, BOOL cached) {
            imageView.size = [image sizeForScaleToFixSize:CGSizeMake(imageSize, imageSize)];
            imageView.image = image;
            imageView.center = CGPointMake(imageView.superview.width/2, floorf(imageView.superview.height/2));
        } failure:^(NSError *error) {
            
        }];
    }
}

- (void)actionCooperate:(BOOL)cooperate
{
    __PSELF__;
    //[self userAuth:^{
        [pSelf showWating:nil];
        [[ClientAgent sharedInstance] usercooperate:self.cooperateInfo.taobao_shop_title shopId:self.cooperateInfo.taobao_shop_id action:cooperate?@"on":@"off" block:^(NSError *error, id data, id userInfo, BOOL cache) {
            if ( error == nil )
            {
                [pSelf loadData];
            }
            else
            {
                [pSelf dismissWating];
                [pSelf showErrorMessage:error];
            }
        }];

    //}];
}

- (void)actionForButtonTap:(MiniUIButton *)button
{
    MSCooperateGoodInfo *goodInfo = [self.cooperateInfo.goods_info objectAtIndex:0];
    NSString* requestStr = [NSString stringWithFormat:@"http://%@?type=taobaoshop&id=%@&imei=%@&usernick=", StoreGoUrl,goodInfo.taobao_shop_id,UDID];
    MSUIWebViewController *controller = [[MSUIWebViewController alloc] initWithUri:requestStr title:nil toolbar:YES];
    controller.ctitle = self.cooperateInfo.taobao_shop_title;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)loadData
{
    self.buttonsView.hidden = YES;
    self.verifyButtonsView.hidden = YES;
    __PSELF__;
    [self showWating:nil];
    [[ClientAgent sharedInstance] cooperatelist:nil block:^(NSError *error, MSCooperateInfo* data, id userInfo, BOOL cache) {
        [pSelf dismissWating];
        if ( error == nil)
        {
           if ( data._errno != 0 )
           {
               [pSelf showMessageInfo:data.error delay:2];
           }
           else if ( data != nil )
           {
               if ( data.limit == 1 )
               {
                   pSelf.shopNameLabel.text = nil;
                   pSelf.label.text = nil;
                   [pSelf showMessageInfo:data.msg delay:2];
                   double delayInSeconds = 2.0;
                   dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                   dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                       [pSelf back];
                   });
               }
               else
               {
                   pSelf.cooperateInfo = data;
                   pSelf.shopNameLabel.text = [NSString stringWithFormat:@"   %@",data.taobao_shop_title];
                   pSelf.label.text = [NSString stringWithFormat:@"   %@",data.user];
                   pSelf.buttonsView.hidden = NO;
                   pSelf.verifyButtonsView.hidden = NO;
                   [pSelf loadGoodsImage];
               }
           }
       }
    }];
}

@end
