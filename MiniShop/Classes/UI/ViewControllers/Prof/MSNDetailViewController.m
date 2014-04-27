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
#import <QuartzCore/QuartzCore.h>
#import "NSString+Mini.h"
#import "MSNUIDTView.h"
#import "MiniSysUtil.h"
#import "MSNDetailToolBar.h"
#import "MSNShopDetailViewController.h"
#import "MSWebChatUtil.h"
#import "MSNGoodsList.h"
#import "UIImage+Mini.h"
#import "UIImageView+WebCache.h"
#import "MiniUIIndicator.h"
#import "MiniUIButton+Mini.h"


@protocol MSNUIDetailImageViewDelegate <NSObject>
- (void)willLoadImage;
- (void)didLoadImage;
- (void)touchUpImage;
@end

@interface MSNUIDetailImageView : UIView
@property (nonatomic,strong)UIImageView *imageView;
@property (nonatomic,strong)MiniUIButton *button;
@property (nonatomic,assign)id<MSNUIDetailImageViewDelegate> imageViewDelegate;
@property (nonatomic,strong)UIImageView *moreImageView;
@end

@implementation MSNUIDetailImageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self addSubview:self.imageView];
        self.button = [MiniUIButton buttonWithType:UIButtonTypeCustom];
        self.button.backgroundColor = [UIColor clearColor];
        [self addSubview:self.button];
        [self.button addTarget:self action:@selector(touchUpImage) forControlEvents:UIControlEventTouchUpInside];
        self.moreImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"more_pic"]];
        
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
    self.moreImageView.origin = CGPointMake(self.width-2*self.moreImageView.width, self.height-2*self.moreImageView.height);
    [self addSubview:self.moreImageView];
}

- (void)touchUpImage
{
    if (self.imageViewDelegate) {
        [self.imageViewDelegate touchUpImage];
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
    self.button.frame = self.imageView.frame;
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
    self.button.frame = self.imageView.frame;
    self.height = height;
}
@end

@protocol MSNUIDetailContentViewDelegate <NSObject>
@required
- (void)willLoadImage:(MSNGoodsItem *)goodsItem;
- (void)didLoadImage:(MSNGoodsItem *)goodsItem;
- (void)didLoadDetail:(MSNGoodsItem *)goodsItem;
- (void)touchUpImage:(MSNGoodsItem *)goodsItem;
- (void)jumpShopDetail:(MSNGoodsItem *)goodsItem;
- (void)jumpToBuy:(MSNGoodsItem *)goodsItem;
@end

/** 单个商品详情*/
@interface MSNUIDetailContentView : UIView <MSNUIDetailImageViewDelegate>
@property(nonatomic,strong)MSNGoodsItem *goodsItem;
@property(nonatomic,strong)MSNUIDetailImageView *imageView;
@property(nonatomic,strong)MSNDetailToolBar *toolbar;
@property(nonatomic,strong)UIScrollView *contentView;
@property(nonatomic,strong)MiniUIActivityIndicatorView *indicator;
@property(nonatomic,assign)id<MSNUIDetailContentViewDelegate>  detailContentViewDelegate;
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
    UIColor *backgroundColor = nil;
    self.contentView = [[UIScrollView alloc] initWithFrame:self.bounds];
    self.contentView.showsVerticalScrollIndicator = NO;
    [self addSubview:self.contentView];
    self.imageView = [[MSNUIDetailImageView alloc] initWithFrame:CGRectMake(0, 0, self.width, 350)];
    self.toolbar = [[MSNDetailToolBar alloc] initWithFrame:CGRectMake(0, self.imageView.bottom, self.width, self.contentView.height)];
    [self.contentView addSubview:self.imageView];
    [self.contentView addSubview:self.toolbar];
    self.imageView.imageViewDelegate = self;
    self.imageView.backgroundColor = backgroundColor;
    [self.toolbar.shopInfoView.eventButton addTarget:self action:@selector(jumpShopDetail) forControlEvents:UIControlEventTouchUpInside];
    [self.toolbar.buyButton addTarget:self action:@selector(jumpToBuy) forControlEvents:UIControlEventTouchUpInside];
    self.toolbar.backgroundColor = backgroundColor;
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
    [self setGoodsItem:goodsItem delay:0];
}

- (void)setGoodsItem:(MSNGoodsItem *)goodsItem delay:(int)delay
{
    dispatch_block_t __block__ = ^ {
    _goodsItem = goodsItem;
    __PSELF__;
    [self.toolbar setGoodsInfo:goodsItem action:^(bool loaded) {
        if (pSelf.detailContentViewDelegate != nil) {
            [pSelf.detailContentViewDelegate didLoadDetail:pSelf.goodsItem];
        }
    }];
    double delayInSeconds = delay;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self.imageView setImageURL:goodsItem.big_image_url];
        [self sizeToFit];
    });
    };
    __block MSNGoodsItem* item = goodsItem;
    if (goodsItem.big_image_url.length==0) {
        [[ClientAgent sharedInstance] goodsItemInfo:goodsItem.goods_id  block:^(NSError *error, MSNGoodsItem* data,
                id userInfo,BOOL cache) {
            [item copy:data];
            __block__();
        }];
    }
    else {
        __block__();
    }

}

- (void)willLoadImage
{
    [self showWating];
    if (self.detailContentViewDelegate != nil) {
        [self.detailContentViewDelegate willLoadImage:self.goodsItem];
    }
}

- (void)didLoadImage
{
    UIColor *backgroundColor = [UIColor colorWithRGBA:0xfdf4f2AA];
    self.imageView.backgroundColor = backgroundColor;
    [self.toolbar display];
    [self dismissWating];
    [self sizeToFit];
    if (self.detailContentViewDelegate != nil) {
        self.goodsItem.image=self.imageView.imageView.image;
        [self.detailContentViewDelegate didLoadImage:self.goodsItem];
    }
}

- (void)touchUpImage
{
    if (self.detailContentViewDelegate != nil) {
        [self.detailContentViewDelegate touchUpImage:self.goodsItem];
    }
}

- (void)jumpShopDetail
{
    if (self.detailContentViewDelegate != nil) {
        [self.detailContentViewDelegate jumpShopDetail:self.goodsItem];
    }
}

- (void)jumpToBuy
{
    if (self.detailContentViewDelegate != nil) {
        [self.detailContentViewDelegate jumpToBuy:self.goodsItem];
    }
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
    //self.indicator.labelText = @"正在努力加载...";
    self.indicator.userInteractionEnabled = NO;
    [self.indicator showInView:self userInterfaceEnable:YES];
}

- (void)dismissWating
{
    [self.indicator hide];
}

@end


@protocol MSNDetailViewDelegate <NSObject>
@required
- (void)willLoadAtIndex:(NSInteger)index;
- (void)didLoadAtIndex:(NSInteger)index current:(BOOL)isCurrent;
- (void)touchUpImage:(NSInteger)index;
- (void)jumpShopDetail:(NSInteger)index;
- (void)jumpToBuy:(NSInteger)index;
@end

@interface MSNDetailView : UIScrollView <MSNUIDetailContentViewDelegate>
@property (nonatomic,strong)NSArray  *items;
@property (nonatomic)NSInteger selectedIndex;
@property (nonatomic,assign)id<MSNDetailViewDelegate> detailViewDelegate;
- (void)setSelectedIndex:(NSInteger)selectedIndex delay:(int)delay;
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
        if (self.detailViewDelegate!=nil){
            [self.detailViewDelegate willLoadAtIndex:selectedIndex];
        }
        MSNUIDetailContentView * view = [[self subviews] objectAtIndex:selectedIndex];
        [view setGoodsItem:[self.items objectAtIndex:selectedIndex]];
    }
}

- (void)setSelectedIndex:(NSInteger)selectedIndex delay:(int)delay
{
    _selectedIndex = selectedIndex;
    CGPoint contentOffset = CGPointMake(selectedIndex*self.width, 0);
    if (contentOffset.x != self.contentOffset.x) {
        self.contentOffset = contentOffset;
    }
    if (self.items != nil && self.items.count>0) {
        if (self.detailViewDelegate!=nil){
            [self.detailViewDelegate willLoadAtIndex:selectedIndex];
        }
        MSNUIDetailContentView * view = [[self subviews] objectAtIndex:selectedIndex];
        [view setGoodsItem:[self.items objectAtIndex:selectedIndex] delay:delay];
    }
}

- (void)willLoadImage:(MSNGoodsItem *)goodsItem
{
    int index = [self.items indexOfObject:goodsItem];
    if (self.detailViewDelegate!=nil){
        [self.detailViewDelegate willLoadAtIndex:index];
    }
}
- (void)didLoadImage:(MSNGoodsItem *)goodsItem
{
    int index = [self.items indexOfObject:goodsItem];
    if (self.detailViewDelegate!=nil){
        [self.detailViewDelegate didLoadAtIndex:index current:(index==self.selectedIndex)];
    }
}

- (void)didLoadDetail:(MSNGoodsItem *)goodsItem
{
    int index = [self.items indexOfObject:goodsItem];
    MSNUIDetailContentView * view = [[self subviews] objectAtIndex:self.selectedIndex];
    [view sizeToFit];
    if (self.detailViewDelegate!=nil){
        [self.detailViewDelegate didLoadAtIndex:index current:(index==self.selectedIndex)];
    }
}

- (void)touchUpImage:(MSNGoodsItem *)goodsItem
{
    int index = [self.items indexOfObject:goodsItem];
    if (index==self.selectedIndex){
        [self.detailViewDelegate touchUpImage:index];
    }
}

- (void)jumpShopDetail:(MSNGoodsItem *)goodsItem;
{
    int index = [self.items indexOfObject:goodsItem];
    if (self.detailViewDelegate!=nil){
        [self.detailViewDelegate jumpShopDetail:index];
    }
}

- (void)jumpToBuy:(MSNGoodsItem *)goodsItem;
{
    int index = [self.items indexOfObject:goodsItem];
    if (self.detailViewDelegate!=nil){
        [self.detailViewDelegate jumpToBuy:index];
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

- (void)setItems:(NSArray *)items
{
    _items = items;
    int count = self.items.count;
    for (int index=0; index<count; index++) {
        CGRect frame = CGRectMake(index*self.width, 0, self.width, self.height);
        MSNUIDetailContentView * detailContentView = [[MSNUIDetailContentView alloc] initWithFrame:frame];
        detailContentView.detailContentViewDelegate = self;
        [self addSubview:detailContentView];
    }
    self.contentSize = CGSizeMake(count*self.width, self.height);
}
@end


@interface MSNDetailViewController () <MSNDetailViewDelegate>
@property (nonatomic,strong) MSNDetailView *detailView;
@property (nonatomic,strong) MiniUIButton *favButton;
@property (nonatomic,strong) MSNUIDTView *dtView;


@property (nonatomic,strong) MSNGoodsItem *currentGoodsItem;

@property (nonatomic,strong) NSDate *viewStartTime;
@property (nonatomic)NSInteger selectedIndex;
@property (nonatomic)bool loading;

@property (nonatomic)NSInteger preSelectedIndex;
@end

@implementation MSNDetailViewController

- (id)init
{
    self = [super init];
    if (self) {
        self.hidesBottomBarWhenPushed = YES;
        self.preSelectedIndex = -1;
    }
    return self;
}

- (void)loadView
{
    [super loadView]; 
    self.dtView = [[MSNUIDTView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height)];
    
    CGRect frame = self.contentView.bounds;
    frame.size = CGSizeMake(frame.size.width, frame.size.height-44);
    
    self.detailView = [[MSNDetailView alloc] initWithFrame:frame];
    self.detailView.detailViewDelegate = self;
    [self.contentView addSubview:self.detailView];
   
    [self createToolbar:44];
    if (self.items.count>0) {
        [self resetItems:self.items];
    }
    else {
        if (self.goodsId.length>0) {
            [self loadGoodsItemInfo];
        }
    }
}

- (void)loadGoodsItemInfo
{
    __PSELF__;
    [[ClientAgent sharedInstance] goodsItemInfo:self.goodsId block:^(NSError *error, MSNGoodsItem* data, id userInfo, BOOL cache) {
        if (error==nil && data!=nil) {
            pSelf.items = @[data];
            [pSelf resetItems:pSelf.items];
        }
    }];
}

- (void)resetItems:(NSArray *)items
{
    self.detailView.items = self.items;
    double delayInSeconds = 0.05;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        self.detailView.selectedIndex = self.defaultIndex;
    });
}

- (void)createToolbar:(CGFloat)height
{
    UIView *toolbar = [[UIView alloc] initWithFrame:CGRectMake(0, self.contentView.height-height, self.contentView.width, height)];
    toolbar.backgroundColor = [UIColor colorWithRGBA:0xf7eeefff];
    [self.contentView addSubview:toolbar];
    
    CGFloat centerY = toolbar.height/2-4;
    MiniUIButton *button = [MiniUIButton createToolBarButton:@"购买" imageName:@"money" hImageName:@"money_hover"];
    button.center = CGPointMake(50,centerY);
    [toolbar addSubview:button];
    [button addTarget:self action:@selector(actionToolBarBuy:) forControlEvents:UIControlEventTouchUpInside];
    
    button = [MiniUIButton createToolBarButton:@"收藏" imageName:@"star" hImageName:@"star"];
    button.center = CGPointMake(toolbar.width/2,centerY);
    [toolbar addSubview:button];
    [button addTarget:self action:@selector(actionToolBarFav:) forControlEvents:UIControlEventTouchUpInside];
    self.favButton = button;
    
    button = [MiniUIButton createToolBarButton:@"分享" imageName:@"share" hImageName:@"share_hover"];
    button.center = CGPointMake(toolbar.width-50,centerY);
    [toolbar addSubview:button];
    [button addTarget:self action:@selector(actionToolBarShare:) forControlEvents:UIControlEventTouchUpInside];
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
    if (self.loading) {
        self.viewStartTime = [NSDate date];
    }
    self.loading = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (MSNGoodsItem*)currentGoodsItem
{
    return [self.items objectAtIndex:self.detailView.selectedIndex];
}

- (void)willLoadAtIndex:(NSInteger)index
{
    [MobClick event:MOB_LOAD_IMAGE];
    if (self.preSelectedIndex!=-1) {
        NSTimeInterval inter = 0-[self.viewStartTime timeIntervalSinceNow];
        [self uploadviewsec:(int)inter index:self.preSelectedIndex];
        self.viewStartTime = nil;
    }
}

- (void)didLoadAtIndex:(NSInteger)index current:(BOOL)isCurrent
{
    self.viewStartTime = [NSDate date];
    [self resetFavButton:self.favButton];
}

- (void)touchUpImage:(NSInteger)index
{
    MSNGoodsItem *item = [self.items objectAtIndex:index];
    self.dtView.mid = item.goods_id;
    [self showDTView];
}

- (void)jumpShopDetail:(NSInteger)index
{
    if ( self.currentGoodsItem != nil && self.currentGoodsItem.detail.shop_info != nil ) {
        MSNShopDetailViewController *controller = [[MSNShopDetailViewController alloc] init];
        controller.shopInfo = self.currentGoodsItem.detail.shop_info;
        [self.navigationController pushViewController:controller animated:YES];
    }
}

// 跳转淘宝
- (void)jumpToBuy:(NSInteger)index
{
    [MobClick event:MOB_GOODS_DETAIL];
    MSNGoodsItem *item = [self.items objectAtIndex:index];
    NSString* requestStr = [NSString stringWithFormat:@"http://%@/new/jump?type=%@&id=%@&sche=youjiaxiaodian", [ClientAgent host], @"goods", item.goods_id];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:requestStr]];
    [[ClientAgent sharedInstance] perfectHttpRequest:request];
    MSUIWebViewController *controller = [[MSUIWebViewController alloc] initWithRequest:request title:item.goods_title toolbar:YES];
    controller.naviType = WebviewNaviTypeClose;
    controller.autoLayout = NO;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)actionToolBarBuy:(MiniUIButton*)button
{
    [self jumpToBuy:self.detailView.selectedIndex];
}

- (void)resetFavButton:(MiniUIButton*)button
{
    MSNGoodsItem *item = [self currentGoodsItem];
    UIImage *image = [UIImage imageNamed:(item.like_goods==1?@"star_hover":@"star")];
    UILabel *titleLabel = (UILabel*)[button viewWithTag:10000];
    if (titleLabel!=nil) {
        titleLabel.text = item.like_goods==1?@"取消收藏":@"收藏";
    }
    [button setImage:image forState:UIControlStateNormal];
    [button setImage:image forState:UIControlStateHighlighted];
}

- (void)actionToolBarFav:(MiniUIButton*)button
{
    __PSELF__;
    MSNGoodsItem *item = [self currentGoodsItem];
    item.like_goods = (item.like_goods+1)%2;
    [self resetFavButton:button];
    [[ClientAgent sharedInstance] setfavgoods:item.goods_id action:(item.like_goods==1?@"off":@"on") block:^(NSError *error, id data, id userInfo, BOOL cache) {
        if ( error != nil ) {
            [pSelf showMessageInfo:[error localizedDescription] delay:2];
        }
        else {
            if (item.like_goods==1){
               [pSelf showMessageInfo:@"收藏成功" delay:2];
               // item.like_goods=1;
            }
            else {
                [pSelf showMessageInfo:@"取消成功" delay:2];
              //  item.like_goods=0;
            }
           // [self resetFavButton:button];
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
    [MSWebChatUtil shareGoodsItem:item controller:self];

}


//- (void)silentAccess
//{
//    MSNGoodsItem *item = [self.items objectAtIndex:self.currentPageIndex];
//    NSString* requestStr = [NSString stringWithFormat:@"http://%@?type=%@&activity_id=%@&id=%lld&usernick=", StoreGoUrl, self.itemInfo==nil?@"online":self.itemInfo.type, self.itemInfo==nil?@"":[self.itemInfo iId] , item.mid];
//    requestStr = [ClientAgent prefectUrl:requestStr];
//    [[ClientAgent sharedInstance] get:requestStr params:nil block:^(NSError *error, id data, BOOL cache){}];
//}


- (void)uploadviewsec:(int)sec index:(NSInteger)index
{
    if ( index >=0 && index < self.items.count && sec > 2 )
    {
        MSNGoodsItem *item = [self.items objectAtIndex:index];
        [[ClientAgent sharedInstance] viewSec:item.mid from:self.from sec:sec block:^(NSError *error, id data, id userInfo, BOOL cache) {
        }];
    }
}


- (void)showDTView
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
