//
//  MSNDetailViewController.m
//  MiniShop
//
//  Created by Wuquancheng on 13-12-28.
//  Copyright (c) 2013年 mini. All rights reserved.
//

#import "MSNDetailViewController.h"
#import "MSUIWebViewController.h"
#import "MWZoomingScrollView.h"
#import "UIColor+Mini.h"
#import "MSDefine.h"
#import "MiniUIIndicator.h"
#import "MiniUIIndicator.h"
#import "MSShopGalleryViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "NSString+Mini.h"
#import "MSUIDTView.h"
#import "MiniSysUtil.h"
#import "MSNDetailToolBar.h"
#import "MSNShopDetailViewController.h"
#import "MSWebChatUtil.h"
#import "MSNGoodsList.h"
#import "UIImage+Mini.h"
#import "UIImageView+WebCache.h"

@interface MSNUIDetailImageView : UIView
@property (nonatomic,strong)UIImageView *imageView;
@end

@implementation MSNUIDetailImageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self addSubview:self.imageView];
    }
    return self;
}

- (void)setImage:(UIImage*)image
{
    CGSize size = image.size;
    self.imageView.size = size;
    self.imageView.image = image;
    [self.superview sizeToFit];
    [self.superview setNeedsLayout];
}

- (void)setImageURL:(NSString*)url
{
    __PSELF__;
    [self.imageView setImageWithURL:[NSURL URLWithString:url] placeholderImage:nil options:SDWebImageSetImageNoAnimated success:^(UIImage *image, BOOL cached) {
        [pSelf setImage:image];
    } failure:^(NSError *error) {
        
    }];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.imageView.center = CGPointMake(self.width/2, self.height/2);
}

- (void)sizeToFit
{
    [super sizeToFit];
    CGFloat height = self.imageView.height;
    CGFloat width = self.imageView.width;
    if (height>350) {
        CGFloat scale = 350.0f/height;
        width = self.imageView.width * scale;
        height = 350;
    }
    if (width>320) {
        CGFloat scale = 320.0f/width;
        height = scale*height;
        width = 320;
    }
    self.imageView.size = CGSizeMake(width, height);
    self.height = height;
}
@end

@interface MSNUIDetailContentView : UIView
@property(nonatomic,strong)MSNGoodsItem *goodsItem;
@property(nonatomic,strong)MSNUIDetailImageView *imageView;
@property(nonatomic,strong)MSNDetailToolBar *toolbar;

@end

@implementation MSNUIDetailContentView
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initSubviews];
    }
    return self;
}

- (void)initSubviews
{
    self.imageView = [[MSNUIDetailImageView alloc] initWithFrame:CGRectMake(0, 0, self.width, 700)];
    self.toolbar = [[MSNDetailToolBar alloc] initWithFrame:CGRectMake(0, 0, self.width, 120)];
    [self addSubview:self.imageView];
    [self addSubview:self.toolbar];
}

- (void)sizeToFit
{
    [super sizeToFit];
    [self.imageView sizeToFit];
    [self.toolbar sizeToFit];
    self.imageView.origin = CGPointMake(0, 0);
    CGFloat top = self.imageView.bottom;
    if (self.imageView.height==0){
        top = self.height-120;
    }
    self.toolbar.origin = CGPointMake(0, top);
    self.height = self.toolbar.bottom;
    
    UIScrollView *superView = (UIScrollView *)[self superview];
    superView.contentSize = CGSizeMake(superView.width, self.height);
}

- (void)setGoodsItem:(MSNGoodsItem *)goodsItem
{
    _goodsItem = goodsItem;
    [self.toolbar setGoodsInfo:goodsItem];
    [self.imageView setImageURL:goodsItem.big_image_url];
}

@end


@interface MSNDetailViewController ()
@property (nonatomic,strong) UIScrollView *scrollView;

@property (nonatomic,strong) UIView    *toolbar;
@property (nonatomic,strong) MSUIDTView *dtView;


@property (nonatomic,strong) MSNGoodsItem *currentGoodsItem;

@property (nonatomic,strong) NSDate *viewStartTime;
@property (nonatomic)NSInteger selectedIndex;
@property (nonatomic)bool loading;
@end

@implementation MSNDetailViewController

- (id)init
{
    self = [super init];
    if (self) {
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    self.dtView = [[MSUIDTView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height)];
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.contentView.bounds];
    [self.contentView addSubview:self.scrollView];
    
    MSNUIDetailContentView * view = [[MSNUIDetailContentView alloc] initWithFrame:self.contentView.bounds];
    [self.scrollView addSubview:view];
    [view setGoodsItem:[self.items objectAtIndex:self.defaultIndex]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setNaviBackButton];
    [self.naviTitleView setTitle:@"宝贝详情"];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (self.loading)
    {
        self.viewStartTime = [NSDate date];
    }
    self.loading = NO;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}


- (void)setSelectedIndex:(NSInteger)selectedIndex
{
   // [self setInitialPageIndex:selectedIndex];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser
{
    return self.items.count;
}

- (id<MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index
{
    MSNGoodsItem *item = [self.items objectAtIndex:index];
    [MobClick event:MOB_LOAD_IMAGE];
    return [MWPhoto photoWithURL:[NSURL URLWithString:[item big_image_url]]];
}


- (void)setNavBarAppearance:(BOOL)animated
{
}

- (void)updateViewContents:(NSInteger)index
{
    MSNGoodsItem *item = [self.items objectAtIndex:index];
    [self setToolbarContent:item];
    __PSELF__;
    [[ClientAgent sharedInstance] goodsinfo:item.goods_id block:^(NSError *error, id data, id userInfo, BOOL cache) {
        if (error==nil){
            item.detail = data;
            [pSelf setToolbarContent:item];
        }
    }];
}

- (void)changePhoto:(NSInteger)index pre:(NSInteger)preIndex
{
    if ( preIndex != index && preIndex >=0 && self.viewStartTime != nil )
    {
        NSTimeInterval inter = 0-[self.viewStartTime timeIntervalSinceNow];
        [self uploadviewsec:(int)inter index:preIndex];
        self.viewStartTime = nil;
    }
    [self updateViewContents:index];
}

- (void)loadData:(int)type
{
}

- (void)loadData
{
    
}

- (CGRect)frameForToolbarAtOrientation:(UIInterfaceOrientation)orientation
{
    CGFloat height = self.toolbar.height;
    //	return CGRectMake(0, self.view.bounds.size.height - height, self.view.bounds.size.width, height);
    return CGRectMake(0, self.view.bounds.size.height - height, self.view.bounds.size.width, height);
}


//- (UIView *)createToolBar
//{
//    MSNDetailToolBar *toolbar = [[MSNDetailToolBar alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 120)];
//    self.toolbar = toolbar;
//    [toolbar.buybutton addTarget:self action:@selector(actionToolBarBuy:) forControlEvents:UIControlEventTouchUpInside];
//    [toolbar.featureView.buyButton addTarget:self action:@selector(actionToolBarBuy:) forControlEvents:UIControlEventTouchUpInside];
//    [toolbar.featureView.favButton addTarget:self action:@selector(actionToolBarFav:) forControlEvents:UIControlEventTouchUpInside];
//    [toolbar.featureView.shareButton addTarget:self action:@selector(actionToolBarShare:) forControlEvents:UIControlEventTouchUpInside];
//    return self.toolbar;
//}

- (void)actionToolBarBuy:(MiniUIButton*)button
{
    
}

- (void)actionToolBarFav:(MiniUIButton*)button
{
    __PSELF__;
    MSNGoodsItem *item = [self currentGoodsItem];
    [[ClientAgent sharedInstance] setfavgoods:item.goods_id action:@"on" block:^(NSError *error, id data, id userInfo, BOOL cache) {
        if ( error != nil ) {
            [pSelf showMessageInfo:[error localizedDescription] delay:2];
        }
    }];
}

- (void)actionToolBarShare:(MiniUIButton*)button
{
    [MobClick event:MOB_DETAIL_TOP_SHARE];
    MSNGoodsItem *item = [self currentGoodsItem];
    if ( item == nil ) {
        return;
    }
    if (item.image==nil) {
        return;
    }
    
    [MiniUIAlertView showAlertWithTitle:@"分享我喜欢的" message:@"" block:^(MiniUIAlertView *alertView, NSInteger buttonIndex) {
        if ( buttonIndex == 1 )
        {
            [MSWebChatUtil shareGoodsItem:item scene:WXSceneTimeline];
        }
        else if ( buttonIndex == 2 )
        {
            [MSWebChatUtil shareGoodsItem:item scene:WXSceneSession];
        }
    } cancelButtonTitle:@"等一会儿吧" otherButtonTitles:@"微信朋友圈",@"微信好友", nil];

}

- (void)layoutToolBar
{
    
}

- (void)setToolbarContent:( MSNGoodsItem* )item
{
    [(MSNDetailToolBar *)self.toolbar setGoodsInfo:item];
    self.currentGoodsItem = item;
    self.dtView.mid = item.goods_id;
}


//查看详情
- (void)actionGoToShopping
{
//    [MobClick event:MOB_GOODS_DETAIL];
//    MSNGoodsItem *item = [self.items objectAtIndex:self.currentPageIndex];
//    NSString* requestStr = [NSString stringWithFormat:@"http://%@?type=%@&activity_id=%@&id=%lld&imei=%@&usernick=", StoreGoUrl, @"online":self.itemInfo.type, self.itemInfo==nil?@"":[self.itemInfo iId] , item.mid,UDID];
//    MSUIWebViewController *controller = [[MSUIWebViewController alloc] initWithUri:requestStr title:[self.itemInfo typeTitleDesc] toolbar:YES];
//    controller.autoLayout = NO;
//    [self.navigationController pushViewController:controller animated:YES];
}


- (void)silentAccess
{
//    MSNGoodsItem *item = [self.items objectAtIndex:self.currentPageIndex];
//    NSString* requestStr = [NSString stringWithFormat:@"http://%@?type=%@&activity_id=%@&id=%lld&usernick=", StoreGoUrl, self.itemInfo==nil?@"online":self.itemInfo.type, self.itemInfo==nil?@"":[self.itemInfo iId] , item.mid];
//    requestStr = [ClientAgent prefectUrl:requestStr];
//    [[ClientAgent sharedInstance] get:requestStr params:nil block:^(NSError *error, id data, BOOL cache){}];
}


- (void)uploadviewsec:(int)sec index:(NSInteger)index
{
    if ( index >=0 && index < self.items.count && sec > 2 )
    {
        MSNGoodsItem *item = [self.items objectAtIndex:index];
        [[ClientAgent sharedInstance] viewsec:item.mid from:self.from sec:sec block:^(NSError *error, id data, id userInfo, BOOL cache) {}];
    }
}


- (NSString*)itemUri:(MSNGoodsItem *)item
{
//    NSString* uri = [NSString stringWithFormat:@"http://%@?type=%@&activity_id=%@&id=%lld&imei=%@&usernick=", StoreGoUrl, self.itemInfo==nil?@"online":self.itemInfo.type, self.itemInfo==nil?@"":[self.itemInfo iId] , item.mid,UDID];
//    return uri;
    return nil;
}

- (void)gotoShop:(MiniUIButton *)button
{
    if ( self.currentGoodsItem != nil && self.currentGoodsItem.detail.shop_info != nil ) {
        MSNShopDetailViewController *controller = [[MSNShopDetailViewController alloc] init];
        controller.shopInfo = self.currentGoodsItem.detail.shop_info;
        [self.navigationController pushViewController:controller animated:YES];
    }
    
//    MSShopGalleryViewController *controller = [[MSShopGalleryViewController alloc] init];
//    MSNotiItemInfo *info = self.itemInfo;
//    if ( info == nil ) {
//        info = [[MSNotiItemInfo alloc] init];
//        info.shop_id = self.goods.shop_id;
//        info.shop_title = self.goods.shop_name;
//        info.name = self.goods.shop_name;
//    }
//    controller.notiInfo = info;
//    controller.autoLayout = NO;
//    [self.navigationController pushViewController:controller animated:YES];
}

- (BOOL)reseponseDoubleClickControls
{
    return NO;
}

- (void)toggleControls
{
    if ( self.dtView.mid > 0 ) {
        self.dtView.alpha = 0;
        self.dtView.top = 200;
        self.dtView.delegate = self;
        [self.view addSubview:self.dtView];
        [self.dtView loadDetail];
        [UIView animateWithDuration:0.3 animations:^{
            [self.navigationController setNavigationBarHidden:YES animated:YES];
            self.dtView.alpha = 1.0f;
            self.dtView.top = 0;
            [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
        }];
    }
}

- (void)hideDTView
{
    [UIView animateWithDuration:0.3 animations:^{
        self.dtView.alpha = 0.0f;
        self.dtView.top = self.view.height;
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    }completion:^(BOOL finished) {
        [self.dtView removeFromSuperview];
    }];
}

@end
