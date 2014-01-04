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
#import "MSNShopDetailViewController.h"

#import "MSNGoodsList.h"

@interface MSNDetailViewController ()<MWPhotoBrowserDelegate>
@property (nonatomic,retain)NSArray *urls;
@property (nonatomic)NSInteger selectedIndex;
@property (nonatomic,retain)UIImage *placeholderImage;

@property (nonatomic)bool loading;
@property (nonatomic,strong) UIView *coverView;
@property (nonatomic,strong) MiniUIButton *button;
@property (nonatomic,strong) UIView    *toolbar;
@property (nonatomic,strong) NSMutableDictionary *dataCache;

@property (nonatomic,strong) MiniUIActivityIndicatorView *indicator;

@property (nonatomic,strong) NSDate *viewStartTime;

@property (nonatomic,strong) MSUIDTView *toolView;

@property (nonatomic,strong) UIView *naviView;

@property (nonatomic,strong) UIView *titleView;

@property (nonatomic) CGRect titleViewFrame;

@property (nonatomic,strong) MSNGoodsItem *currentGoodsItem;

@end

@implementation MSNDetailViewController

- (id)init
{
    self = [super init];
    if (self) {
        [self setDelegate:self];
        self.displayActionButton = NO;
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)loadView
{
    [super loadView];
    if ( MAIN_VERSION >= 7 ) {
        if ( [self respondsToSelector:@selector(setAutomaticallyAdjustsScrollViewInsets:)] ) {
            self.automaticallyAdjustsScrollViewInsets = NO;
        }
    }
    self.toolView = [[MSUIDTView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height)];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setNaviBackButton];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"image_view_bg"]];
    [self createNaviView];
    [self setInitialPageIndex:self.defaultIndex];
}

- (void)createNaviView
{
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, MAIN_VERSION>=7?64:44)];
    titleView.backgroundColor = [UIColor colorWithRGBA:0x000000CC];
    CGFloat gap = (titleView.width-160)/3;
    CGFloat top = (44-30)/2 + (MAIN_VERSION>=7?20:0);
    CGFloat right = 20;
    MiniUIButton *button = [MiniUIButton buttonWithImage:[UIImage imageNamed:@"navi_back"] highlightedImage:[UIImage imageNamed:@"navi_back_h"]];
    button.frame = CGRectMake(right, top, 30, 30);
    [titleView addSubview:button];
    [button addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    
    right = button.right + gap;
    button = [MiniUIButton buttonWithImage:[UIImage imageNamed:@"navi_share"] highlightedImage:[UIImage imageNamed:@"navi_share_h"]];
    button.frame = CGRectMake(right, top, 30, 30);
    [titleView addSubview:button];
    [button addTarget:self action:@selector(shareGood:) forControlEvents:UIControlEventTouchUpInside];
    
    right = button.right + gap;
    button = [MiniUIButton buttonWithImage:[UIImage imageNamed:@"navi_shop"] highlightedImage:[UIImage imageNamed:@"navi_shop_h"]];
    button.frame = CGRectMake(right, top, 30, 30);
    [titleView addSubview:button];
    [button addTarget:self action:@selector(gotoShop:) forControlEvents:UIControlEventTouchUpInside];
    
    
    right = button.right + gap;
    button = [MiniUIButton buttonWithImage:[UIImage imageNamed:@"navi_link"] highlightedImage:[UIImage imageNamed:@"navi_link_h"]];
    button.frame = CGRectMake(right, top, 30, 30);
    [button addTarget:self action:@selector(copylink:) forControlEvents:UIControlEventTouchUpInside];
    [titleView addSubview:button];
    
    [self.view addSubview:titleView];
    self.titleView = titleView;
    self.titleViewFrame = titleView.frame;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar addSubview:self.naviView];
    self.naviView.left = 0;
    self.naviView.alpha = 1;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    // UIImage *image = [MiniUIImage imageNamed:( MAIN_VERSION >= 7?@"navi_background":@"navi_background")];
    // [self.navigationController.navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (self.loading)
    {
        self.viewStartTime = [NSDate date];
    }
    self.loading = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleZoomInNotification:) name:MWPHOTO_ZOOM_IN_NOTIFICATION object:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (UIColor *)backgroundColor
{
    return [UIColor clearColor];
}

- (void)setNaviBackButton
{
    self.navigationItem.hidesBackButton = YES;
}

- (void)setSelectedIndex:(NSInteger)selectedIndex
{
    [self setInitialPageIndex:selectedIndex];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setNaviTitle
{
}

- (UIBarButtonItem *)navLeftButtonWithTitle:(NSString *)title target:(id)target action:(SEL)action
{
    UIImage* bgImage = [UIImage imageNamed:@"navi_bar_back"];
    
    MiniUIButton *button = [MiniUIButton buttonWithImage:bgImage highlightedImage:bgImage];
    button.width += 4;
    button.imageEdgeInsets = UIEdgeInsetsMake(0, 4, 0, 0);
    button.showsTouchWhenHighlighted = YES;
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem* tmpBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    tmpBarButtonItem.style = UIBarButtonItemStyleBordered;
    
    return  tmpBarButtonItem;
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
    NSString *title = @"去淘宝看看";
    MSNGoodsItem *item = [self.items objectAtIndex:index];
    [self.button setTitle:title forState:UIControlStateNormal];
    [self setToolbarContent:item];
    [self setNaviTitle];
}

- (void)configurePage:(MWZoomingScrollView *)page forIndex:(NSUInteger)index
{
	[super configurePage:page forIndex:index];
    if ( index == self.currentPageIndex ) {
        [self updateViewContents:index];
    }
    
}

- (void)handleMWPhotoLoadingDidEndNotification:(NSNotification *)notification
{
    [super handleMWPhotoLoadingDidEndNotification:notification];
    id <MWPhoto> currentPhoto = [self photoAtIndex:self.currentPageIndex];
    id <MWPhoto> photo = [notification object];
    if (currentPhoto == photo)
    {
        self.viewStartTime = [NSDate date];
    }
}

- (void)loadAdjacentPhotosIfNecessary:(id<MWPhoto>)photo
{
    [super loadAdjacentPhotosIfNecessary:photo];
    self.viewStartTime = [NSDate date];
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

- (CGSize)contentSizeForPagingScrollView {
    // We have to use the paging scroll view's bounds to calculate the contentSize, for the same reason outlined above.
    CGRect bounds = self.pagingScrollView.bounds;
    return CGSizeMake(bounds.size.width * [self numberOfPhotos], bounds.size.height);
}

- (NSString *)loadingTitle
{
    return @"正在努力加载...";
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


- (UIView *)createToolBar
{
    UIView *toolbar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 100)];
    [toolbar removeAllSubviews];
    UIImage *image = [MiniUIImage imageNamed:@"tool_bar"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.frame = toolbar.bounds;
    [toolbar addSubview:imageView];
    NSString *title = @"去淘宝看看";
    
    MiniUIButton *button = [MiniUIButton buttonWithBackGroundImage:[MiniUIImage imageNamed:@"button_normal"] highlightedBackGroundImage:[MiniUIImage imageNamed:@"button_selected"] title:title];
    [button prefect];
    button.frame = CGRectMake(toolbar.width - 100, 12, 90, 30);
    [toolbar addSubview:button];
    __PSELF__;
    [button setTouchupHandler:^(MiniUIButton *button) {
        [pSelf actionGoToShopping];
    }];
    self.button = button;
    
    CGFloat width = toolbar.width - button.width - 20;
    for ( NSInteger index = 0; index < 4; index++)
    {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, index==0?10:10+index*20, width, 20)];
        label.tag = 10000 + index;
        label.textColor = [UIColor colorWithRGBA:0xEEEEEEEE];
        label.backgroundColor = [UIColor clearColor];
        label.font = index == 0 ? [UIFont boldSystemFontOfSize:16]:[UIFont systemFontOfSize:14];
        [toolbar addSubview:label];
    }
    self.toolbar = toolbar;
    return self.toolbar;
}

- (void)setToolbarContent:( MSNGoodsItem* )item
{
    ((UILabel *)[self.toolbar viewWithTag:10000]).text = [NSString stringWithFormat:@"价格:%@",item.goods_marked_price];
    ((UILabel *)[self.toolbar viewWithTag:10001]).text = @"店铺名";
    ((UILabel *)[self.toolbar viewWithTag:10002]).text = item.goods_title;
    self.currentGoodsItem = item;
    self.toolView.mid = item.goods_id;
    [self loadGoodsInfo:item];
}

- (void)loadGoodsInfo:(MSNGoodsItem*)item
{
    if (item.detail == nil) {
        [[ClientAgent sharedInstance] goodsinfo:item.goods_id block:^(NSError *error, MSNGoodsDetail *data, id userInfo, BOOL cache) {
            if ( error==nil )
                item.detail = data;
        }];
    }
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

- (void)handleZoomInNotification:(NSNotification *)noti
{
    MSNGoodsItem *item = [self.items objectAtIndex:self.currentPageIndex];
    [[ClientAgent sharedInstance] zoom:item.mid from:self.from userInfo:nil block:^(NSError *error, id data, id userInfo, BOOL cache) {
        
    }];
}

- (void)uploadviewsec:(int)sec index:(NSInteger)index
{
    if ( index >=0 && index < self.items.count && sec > 2 )
    {
        MSNGoodsItem *item = [self.items objectAtIndex:index];
        [[ClientAgent sharedInstance] viewsec:item.mid from:self.from sec:sec block:^(NSError *error, id data, id userInfo, BOOL cache) {}];
    }
}

- (Class)scrollViewIndicatorViewClass
{
    return [Indicator class];
}

- (void)showWating:(NSString *)message
{
    if ( self.indicator == nil )
    {
        self.indicator = [[MiniUIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        
    }
    if ( message == nil )
        self.indicator.labelText = @"正在努力加载...";
    else
        self.indicator.labelText = @"";
    self.indicator.userInteractionEnabled = NO;
    [self.indicator showInView:self.view userInterfaceEnable:YES];
}

- (void)dismissWating:(BOOL)animated
{
    [self.indicator hide];
}


- (void)shareGood:(MiniUIButton *)button
{
//    [MobClick event:MOB_DETAIL_TOP_SHARE];
//    MSNGoodsItem *item = [self.items objectAtIndex:self.currentPageIndex];
//    if ( item == nil || item.mid == 0 ) {
//        return;
//    }
//    [MiniUIAlertView showAlertWithTitle:@"分享我喜欢的" message:@"" block:^(MiniUIAlertView *alertView, NSInteger buttonIndex) {
//        if ( buttonIndex == 1 )
//        {
//            [MSWebChatUtil shareGoodsItem:item scene:WXSceneTimeline];
//        }
//        else if ( buttonIndex == 2 )
//        {
//            [MSWebChatUtil shareGoodsItem:item scene:WXSceneSession];
//        }
//    } cancelButtonTitle:@"等一会儿吧" otherButtonTitles:@"微信朋友圈",@"微信好友", nil];
}
- (NSString*)itemUri:(MSNGoodsItem *)item
{
//    NSString* uri = [NSString stringWithFormat:@"http://%@?type=%@&activity_id=%@&id=%lld&imei=%@&usernick=", StoreGoUrl, self.itemInfo==nil?@"online":self.itemInfo.type, self.itemInfo==nil?@"":[self.itemInfo iId] , item.mid,UDID];
//    return uri;
    return nil;
}

- (void)copylink:(MiniUIButton *)button
{
    [MobClick event:MOB_DETAIL_TOP_COPY];
    MSNGoodsItem *item = [self.items objectAtIndex:self.currentPageIndex];
    if ( item == nil || [item.goods_id isEqualToString:0] ) {
        return;
    }
    [[MiniSysUtil sharedInstance] copyToBoard:[self itemUri:item]];
    [self showMessageInfo:@"商品链接地址已经复制啦" delay:2];
    __PSELF__;
    [[ClientAgent sharedInstance] setfavgoods:item.goods_id action:@"on" block:^(NSError *error, id data, id userInfo, BOOL cache) {
        if ( error != nil ) {
            [pSelf showMessageInfo:[error localizedDescription] delay:2];
        }
    }];
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
    if ( self.toolView.mid > 0 ) {
        self.toolView.alpha = 0;
        self.toolView.top = 200;
        self.toolView.delegate = self;
        [self.view addSubview:self.toolView];
        [self.toolView loadDetail];
        [UIView animateWithDuration:0.3 animations:^{
            [self.navigationController setNavigationBarHidden:YES animated:YES];
            self.toolView.alpha = 1.0f;
            self.toolView.top = 0;
            self.titleView.bottom = 0.0f;
            [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
        }];
    }
}

- (void)hideDTView
{
    [UIView animateWithDuration:0.3 animations:^{
        self.titleView.frame = self.titleViewFrame;
        self.toolView.alpha = 0.0f;
        self.toolView.top = self.view.height;
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    }completion:^(BOOL finished) {
        [self.toolView removeFromSuperview];
    }];
}

@end
