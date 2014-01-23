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
#import "MiniUIIndicator.h"

@protocol MSNUIDetailImageViewDelegate <NSObject>
- (void)willLoadImage;
- (void)didLoadImage;
@end

@interface MSNUIDetailImageView : UIView
@property (nonatomic,strong)UIImageView *imageView;
@property (nonatomic,assign)id<MSNUIDetailImageViewDelegate> imageViewDelegate;
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
}

- (void)startLoadImage
{
    if (self.imageViewDelegate) {
        [self.imageViewDelegate willLoadImage];
    }
}

- (void)didLoadImage
{
    if (self.imageViewDelegate) {
        [self.imageViewDelegate didLoadImage];
    }
}

- (void)setImageURL:(NSString*)url
{
    __PSELF__;
    [self startLoadImage];
    [self.imageView setImageWithURL:[NSURL URLWithString:url] placeholderImage:nil options:SDWebImageSetImageNoAnimated success:^(UIImage *image, BOOL cached) {
        [pSelf setImage:image];
        [pSelf didLoadImage];
    } failure:^(NSError *error) {
        [pSelf didLoadImage];
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

@interface MSNUIDetailContentView : UIView <MSNUIDetailImageViewDelegate>
@property(nonatomic,strong)MSNGoodsItem *goodsItem;
@property(nonatomic,strong)MSNUIDetailImageView *imageView;
@property(nonatomic,strong)MSNDetailToolBar *toolbar;
@property(nonatomic,strong)UIScrollView *contentView;
@property(nonatomic,strong)MiniUIActivityIndicatorView *indicator;
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
    self.contentView = [[UIScrollView alloc] initWithFrame:self.bounds];
    self.contentView.showsVerticalScrollIndicator = NO;
    [self addSubview:self.contentView];
    self.imageView = [[MSNUIDetailImageView alloc] initWithFrame:CGRectMake(0, 0, self.width, 350)];
    self.toolbar = [[MSNDetailToolBar alloc] initWithFrame:CGRectMake(0, self.imageView.bottom, self.width, 0)];
    [self.contentView addSubview:self.imageView];
    [self.contentView addSubview:self.toolbar];
    self.imageView.imageViewDelegate = self;
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
    self.contentView.contentSize = CGSizeMake(self.width, self.toolbar.bottom);
}

- (void)setGoodsItem:(MSNGoodsItem *)goodsItem
{
    _goodsItem = goodsItem;
    [self.toolbar setGoodsInfo:goodsItem];
    [self.imageView setImageURL:goodsItem.big_image_url];
    [self sizeToFit];
}

- (void)willLoadImage
{
    [self showWating];
}

- (void)didLoadImage
{
    [self dismissWating];
    [self sizeToFit];
}

- (void)showWating
{
    if ( self.indicator == nil )
    {
        self.indicator = [[MiniUIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    }
    if ( self.indicator.showing) {
        return;
    }
    self.indicator.labelText = @"正在努力加载...";
    self.indicator.userInteractionEnabled = NO;
    [self.indicator showInView:self userInterfaceEnable:YES];
}

- (void)dismissWating
{
    [self.indicator hide];
}

@end


@interface MSNDetailView : UIScrollView
@property (nonatomic,strong)NSArray  *items;
@property (nonatomic)NSInteger selectedIndex;
@end

@implementation MSNDetailView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self){
        self.showsVerticalScrollIndicator = NO;
        self.showsHorizontalScrollIndicator = NO;
        self.pagingEnabled = YES;
    }
    return self;
}

- (void)setSelectedIndex:(NSInteger)selectedIndex
{
    _selectedIndex = selectedIndex;
    CGPoint contentOffset = CGPointMake(selectedIndex*self.width, 0);
    if (contentOffset.x != self.contentOffset.x) {
        self.contentOffset = contentOffset;
    }
    if (self.items != nil && self.items.count>0) {
        MSNUIDetailContentView * view = [[self subviews] objectAtIndex:selectedIndex];
        [view setGoodsItem:[self.items objectAtIndex:selectedIndex]];
    }
}

- (void)setContentOffset:(CGPoint)contentOffset
{
    [super setContentOffset:contentOffset];
    if ((int)contentOffset.x%(int)self.width == 0) {
        int page = (int)contentOffset.x/(int)self.width;
        if (page!=self.selectedIndex) {
            self.selectedIndex = page;
        }
    }
}
@end


@interface MSNDetailViewController ()
@property (nonatomic,strong) MSNDetailView *detailView;

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
    
    CGRect frame = self.contentView.bounds;
    frame.size = CGSizeMake(frame.size.width, frame.size.height-44);
    
    self.detailView = [[MSNDetailView alloc] initWithFrame:frame];
    [self.contentView addSubview:self.detailView];
   
    [self createToolbar:44];
    
    int count = self.items.count;
    for (int index=0; index<count; index++) {
        CGRect frame = CGRectMake(index*self.detailView.width, 0, self.detailView.width, self.detailView.height);
        MSNUIDetailContentView * detailContentView = [[MSNUIDetailContentView alloc] initWithFrame:frame];
        [self.detailView addSubview:detailContentView];
    }
    self.detailView.contentSize = CGSizeMake(count*self.detailView.width, self.detailView.height);
    self.detailView.items = self.items;
    self.detailView.selectedIndex = self.defaultIndex;
}

- (void)createToolbar:(CGFloat)height
{
    UIView *toolbar = [[UIView alloc] initWithFrame:CGRectMake(0, self.contentView.height-height, self.contentView.width, height)];
    toolbar.backgroundColor = [UIColor colorWithRGBA:0xf7eeefff];
    [self.contentView addSubview:toolbar];
    
    CGFloat centerY = toolbar.height/2-4;
    MiniUIButton *button = [self createToolBarButton:@"购买" imageName:@"money" hImageName:@"money_hover"];
    button.center = CGPointMake(50,centerY);
    [toolbar addSubview:button];
    
    button = [self createToolBarButton:@"收藏" imageName:@"star" hImageName:@"star_hover"];
    button.center = CGPointMake(toolbar.width/2,centerY);
    [toolbar addSubview:button];
    
    button = [self createToolBarButton:@"分享" imageName:@"share" hImageName:@"share_hover"];
    button.center = CGPointMake(toolbar.width-50,centerY);
    [toolbar addSubview:button];
    

}

- (MiniUIButton*)createToolBarButton:(NSString*)title imageName:(NSString*)imageName hImageName:(NSString*)hImageName
{
    MiniUIButton *button = [MiniUIButton buttonWithImage:[UIImage imageNamed:imageName] highlightedImage:[UIImage imageNamed:hImageName]];
    button.size = CGSizeMake(44, 44);
    [button setTitleColor:[UIColor colorWithRGBA:0xe74764FF] forState:UIControlStateNormal];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, button.height-14, button.width, 20)];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor colorWithRGBA:0xe74764FF];
    label.font = [UIFont systemFontOfSize:8];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = title;
    [button addSubview:label];
    return button;
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
