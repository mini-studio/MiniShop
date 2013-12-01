//
//  MSDetailViewController.m
//  MiniShop
// http://www.youjiaxiaodian.com/api/showgoodsdescimage?screenY=960&screenW=640&imei=e512a8b652a4ceda3c70226b21b9745e&id=455325
//  Created by Wuquancheng on 13-4-1.
//  Copyright (c) 2013年 mini. All rights reserved.
//

#import "MSDetailViewController.h"
#import "MSGoodsList.h"
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
#import "MSWebChatUtil.h"
#import "MiniSysUtil.h"

#define CURR_GROUP 0
#define NEXT_GROUP 1
#define PRE_GROUP 0

@interface MSDetailViewController ()<MWPhotoBrowserDelegate>
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

@end

@implementation MSDetailViewController

- (id)init
{
    self = [super init];
    if (self) {
        [self setDelegate:self];
        self.displayActionButton = NO;
        self.dataCache = [NSMutableDictionary dictionary];
        self.more = YES;
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
    if ( self.goods == nil )
    {
        [self loadData];
        [self.itemInfo setRead:YES];
    }
    else
    {
        [self setInitialPageIndex:self.defaultIndex];
    }
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"image_view_bg"]];
    [self createNaviView];
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


- (BOOL)isLastGroupIndex:( NSInteger )index
{
    return index == (self.goods.body_info.count - 1);
}

- (BOOL)isActivityItem
{
    return [MSStoreNewsTypeGoodsPromotion isEqualToString:self.itemInfo.type];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ( [self isLastGroupIndex:self.currentPageIndex] )
    {
        if ( ![self isActivityItem] && self.more )
        {
            CGFloat offsetx = scrollView.contentOffset.x - scrollView.contentSize.width + scrollView.width;
            if ( offsetx > 50 && self.loading == NO )
            {
                self.loading = YES;
                MSShopGalleryViewController *controller = [[MSShopGalleryViewController alloc] init];
                controller.notiInfo = self.itemInfo;
                controller.autoLayout = NO;
                [self.navigationController pushViewController:controller animated:YES];
                return;
            }
            
        }
    }
    [super scrollViewDidScroll:scrollView];
    
}

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser
{
    return self.goods.body_info.count;
}

- (id<MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index
{
    MSGoodItem *item = [self.goods.body_info objectAtIndex:index];
    [MobClick event:MOB_LOAD_IMAGE];
    return [MWPhoto photoWithURL:[NSURL URLWithString:[item big_image_url]]];
}


- (void)setNavBarAppearance:(BOOL)animated
{
}

- (void)updateViewContents:(NSInteger)index
{
    NSString *title = nil;
    MSGoodItem *item = [self.goods.body_info objectAtIndex:index];
    if ( item.rush_buy == 1 )
    {
        title = [NSString stringWithFormat:@"%@件抢购",item.sku_num];
    }
    else
    {
        title = @"去淘宝看看";
    }
    [self.button setTitle:title forState:UIControlStateNormal];
    NSString *shopName = item.shop_title;
    if ( shopName==nil || shopName.length == 0)
    {
        if ( self.itemInfo != nil ) {
            shopName = self.itemInfo.shop_title;
        }
    }
    item.shop_name = shopName;
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
    return CGSizeMake(bounds.size.width * [self numberOfPhotos]+(self.more?1:0), bounds.size.height);
}

- (NSString *)loadingTitle
{
    return @"正在努力加载...";
}

- (void)reloadWithData:(MSGoodsList*)data
{
    if ( self.goods == nil )
    {
        self.goods = data;
    }
    else
    {
        NSMutableArray *info = [NSMutableArray arrayWithArray:self.goods.body_info];
        [info addObjectsFromArray:data.body_info];
        self.goods.body_info = info;
        self.goods.next_info = data.next_info;
    }
    self.goods.user_is_like_shop = data.user_is_like_shop;
    [self setNaviTitle];
    [self reloadData];
    self.loading = NO;
}

- (void)loadData:(int)type
{
    if (self.itemInfo.shop_id > 0 )
    {
        __PSELF__;
        [self showWating:nil];
        if ( [self isActivityItem] )
        {
           [[ClientAgent sharedInstance] activityDetail:self.itemInfo.mid block:^(NSError *error, MSGoodsList* data, id userInfo, BOOL cache) {
               [pSelf dismissWating];
               if ( error == nil )
               {
                   [pSelf reloadWithData:data];
                   [self silentAccess];
               }
           }];
        }
        else
        {
        [[ClientAgent sharedInstance] newsbody12:self.itemInfo.shop_id block:^(NSError *error, MSShopGalleryList* data, id userInfo, BOOL cache) {
            [pSelf dismissWating];
            if ( error == nil )
            {
                MSGoodsList *list = [[MSGoodsList alloc] init];
                list.user_is_like_shop = data.user_is_like_shop;
                list.body_info = ((MSShopGalleryInfo*)[data.body_info objectAtIndex:0]).goods_info;
                [pSelf reloadWithData:list];
                [self silentAccess];
            }
        }];
        }
    }
}

- (void)loadData
{
    [self loadData:CURR_GROUP];
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
    NSString *title = [MSStoreNewsTypeGoodsPromotion isEqualToString:self.itemInfo.type]?@"抢购":@"去淘宝看看";
    
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
    
    //CGFloat top = self.navigationController.navigationBar.height + [UIApplication sharedApplication].statusBarFrame.size.height;
//    MSUIDTView *view = [[MSUIDTView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height+toolbar.height-64)];
//    view.bestTop = self.navigationController.navigationBar.bottom-toolbar.height;
//    view.top = self.view.height - toolbar.height;

//    self.toolView = view;
//    view.controller = self;
//    view.webView = [[MiniUIWebView alloc] initWithFrame:CGRectMake(0, toolbar.height, self.view.width, view.height-toolbar.height)];
//    view.toolbar = toolbar;
    return self.toolbar;
}

- (void)setToolbarContent:( MSGoodItem *)item
{
    ((UILabel *)[self.toolbar viewWithTag:10000]).text = [NSString stringWithFormat:@"价格:%@",item.price];
    ((UILabel *)[self.toolbar viewWithTag:10001]).text = item.shop_name;
    ((UILabel *)[self.toolbar viewWithTag:10002]).text = item.name;
    if ( item.activity.length > 0 )
    {
        ((UILabel *)[self.toolbar viewWithTag:10003]).text = [NSString stringWithFormat:@"参加活动：%@",item.activity];
    }
    else
    {
        ((UILabel *)[self.toolbar viewWithTag:10003]).text = @"";
    }
    self.toolView.mid = item.mid;
}

//查看详情
- (void)actionGoToShopping
{
    [MobClick event:MOB_GOODS_DETAIL];
    MSGoodItem *item = [self.goods.body_info objectAtIndex:self.currentPageIndex];
    NSString* requestStr = [NSString stringWithFormat:@"http://%@?type=%@&activity_id=%@&id=%lld&imei=%@&usernick=", StoreGoUrl, self.itemInfo==nil?@"online":self.itemInfo.type, self.itemInfo==nil?@"":[self.itemInfo iId] , item.mid,UDID];
    MSUIWebViewController *controller = [[MSUIWebViewController alloc] initWithUri:requestStr title:[self.itemInfo typeTitleDesc] toolbar:YES];
    controller.autoLayout = NO;
    [self.navigationController pushViewController:controller animated:YES];
}


- (void)silentAccess
{
    MSGoodItem *item = [self.goods.body_info objectAtIndex:self.currentPageIndex];
    NSString* requestStr = [NSString stringWithFormat:@"http://%@?type=%@&activity_id=%@&id=%lld&usernick=", StoreGoUrl, self.itemInfo==nil?@"online":self.itemInfo.type, self.itemInfo==nil?@"":[self.itemInfo iId] , item.mid];
    requestStr = [ClientAgent prefectUrl:requestStr];
    [[ClientAgent sharedInstance] get:requestStr params:nil block:^(NSError *error, id data, BOOL cache){}];
}

- (void)handleZoomInNotification:(NSNotification *)noti
{
    MSGoodItem *item = [self.goods.body_info objectAtIndex:self.currentPageIndex];
    [[ClientAgent sharedInstance] zoom:item.mid from:self.from userInfo:nil block:^(NSError *error, id data, id userInfo, BOOL cache) {
        
    }];
}

- (void)uploadviewsec:(int)sec index:(NSInteger)index
{
    if ( index >=0 && index < self.goods.body_info.count && sec > 2 )
    {
        MSGoodItem *item = [self.goods.body_info objectAtIndex:index];
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
    [MobClick event:MOB_DETAIL_TOP_SHARE];
    MSGoodItem *item = [self.goods.body_info objectAtIndex:self.currentPageIndex];
    if ( item == nil || item.mid == 0 ) {
        return;
    }
    [MiniUIAlertView showAlertWithTitle:@"分享我喜欢的" message:@"" block:^(MiniUIAlertView *alertView, NSInteger buttonIndex) {
        if ( buttonIndex == 1 )
        {
            [MSWebChatUtil shareGoodItem:item scene:WXSceneTimeline];
        }
        else if ( buttonIndex == 2 )
        {
            [MSWebChatUtil shareGoodItem:item scene:WXSceneSession];
        }
    } cancelButtonTitle:@"等一会儿吧" otherButtonTitles:@"微信朋友圈",@"微信好友", nil];
}
- (NSString*)itemUri:(MSGoodItem *)item
{
    NSString* uri = [NSString stringWithFormat:@"http://%@?type=%@&activity_id=%@&id=%lld&imei=%@&usernick=", StoreGoUrl, self.itemInfo==nil?@"online":self.itemInfo.type, self.itemInfo==nil?@"":[self.itemInfo iId] , item.mid,UDID];
    return uri;
}

- (void)copylink:(MiniUIButton *)button
{
    [MobClick event:MOB_DETAIL_TOP_COPY];
    MSGoodItem *item = [self.goods.body_info objectAtIndex:self.currentPageIndex];
    if ( item == nil || item.mid == 0 ) {
        return;
    }
    [[MiniSysUtil sharedInstance] copyToBoard:[self itemUri:item]];
    [self showMessageInfo:@"商品链接地址已经复制啦" delay:2];
}

- (void)gotoShop:(MiniUIButton *)button
{
    MSShopGalleryViewController *controller = [[MSShopGalleryViewController alloc] init];
    MSNotiItemInfo *info = self.itemInfo;
    if ( info == nil ) {
        info = [[MSNotiItemInfo alloc] init];
        info.shop_id = self.goods.shop_id;
        info.shop_title = self.goods.shop_name;
        info.name = self.goods.shop_name;
    }
    controller.notiInfo = info;
    controller.autoLayout = NO;
    [self.navigationController pushViewController:controller animated:YES];
}

- (BOOL)reseponseDoubleClickControls
{
    return NO;
}

- (void)toggleControls
{
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
