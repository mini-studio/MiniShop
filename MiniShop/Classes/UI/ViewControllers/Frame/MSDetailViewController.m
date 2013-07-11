//
//  MSDetailViewController.m
//  MiniShop
//
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
@property (nonatomic,strong) UIToolbar    *toolbar;
@property (nonatomic,strong) NSMutableDictionary *dataCache;

@property (nonatomic,strong) MiniUIActivityIndicatorView *indicator;

@property (nonatomic,strong) NSDate *viewStartTime;
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
    self.navigationItem.leftBarButtonItem = [MSViewController navLeftButtonWithTitle:@"返回" target:self action:@selector(back)];
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
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self changePhoto:self.currentPageIndex+1 pre:self.currentPageIndex];
}

- (void)setNaviTitle
{
    MSGoodItem *item = [self.goods.body_info objectAtIndex:self.currentPageIndex];
    if ( [@"kink" isEqualToString:self.from] || [@"push" isEqualToString:self.from] )
    {
        self.title = item.shop_title;
    }
    else
    {
        NSString *disImg = self.mtitle;
        if ( disImg.length == 0 )
            disImg = item.shop_title;
        if ( disImg == nil )
            disImg = @"";
        if ([self numberOfPhotos] > 0)            
            self.title = [NSString stringWithFormat:@"%@(%i/%i)", disImg,self.currentPageIndex+1,self.goods.body_info.count];
        else
        self.title = disImg;
    }
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
                controller.shopInfo = self.itemInfo;
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
    self.navigationController.navigationBar.tintColor = nil;
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    if ([[UINavigationBar class] respondsToSelector:@selector(appearance)])
    {
        [self.navigationController.navigationBar setBackgroundImage:[MiniUIImage imageNamed:@"navi_background"] forBarMetrics:UIBarMetricsDefault];
        [self.navigationController.navigationBar setBackgroundImage:[MiniUIImage imageNamed:@"navi_background"] forBarMetrics:UIBarMetricsLandscapePhone];
    }
}

- (void)updateViewContents:(NSInteger)index
{
    NSString *title = nil;
    MSGoodItem *item = [self.goods.body_info objectAtIndex:index];
    if ( item.rush_buy == 1 )
    {
        title = [NSString stringWithFormat:@"%d件抢购",item.sku_num];
    }
    else
    {
        title = @"查看";
    }
    [self.button setTitle:title forState:UIControlStateNormal];
    NSString *shopName = @"";
    if ( self.itemInfo == nil )
    {
        shopName = item.shop_title.length==0?item.shop_name:item.shop_title;
    }
    else
    {
        shopName = self.itemInfo.shop_title;
    }
    [self setToolbarShopName:shopName goodname:item.name activity:item.activity];
    [self setNaviTitle];
}

- (void)configurePage:(MWZoomingScrollView *)page forIndex:(NSUInteger)index
{
	[super configurePage:page forIndex:index];
    [self updateViewContents:index];
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
    CGFloat height = 54;
	return CGRectMake(0, self.view.bounds.size.height - height, self.view.bounds.size.width, height);
}


- (UIToolbar *)createToolBar
{
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.height-54, self.view.width, 54)];
    UIImage *image = [MiniUIImage imageNamed:@"tab_background"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.frame = toolbar.bounds;
    [toolbar addSubview:imageView];
    toolbar.barStyle = UIBarStyleBlackTranslucent;
    toolbar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    
    NSString *title = [MSStoreNewsTypeGoodsPromotion isEqualToString:self.itemInfo.type]?@"抢购":@"查看";
    
    MiniUIButton *button = [MiniUIButton buttonWithBackGroundImage:[MiniUIImage imageNamed:@"button_normal"] highlightedBackGroundImage:[MiniUIImage imageNamed:@"button_selected"] title:title];
    [button prefect];
    button.frame = CGRectMake(toolbar.width - 80, (toolbar.height-30)/2, 70, 30);
    [toolbar addSubview:button];
    __PSELF__;
    [button setTouchupHandler:^(MiniUIButton *button) {
        [pSelf actionGoToShopping];
    }];
    self.button = button;
    
    CGFloat width = toolbar.width - button.width - 20;
    for ( NSInteger index = 0; index < 3; index++)
    {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(5, index==0?5:5+index*16, width, 14)];
        label.tag = 10000 + index;
        label.textColor = [UIColor colorWithRGBA:0xEEEEEEEE];
        label.backgroundColor = [UIColor clearColor];
        label.font = index == 0 ? [UIFont boldSystemFontOfSize:14]:[UIFont systemFontOfSize:12];
        [toolbar addSubview:label];
    }
    self.toolbar = toolbar;
    return toolbar;
}

- (void)setToolbarShopName:(NSString *)shopname goodname:(NSString *)goodname activity:(NSString*)activity
{
    ((UILabel *)[self.toolbar viewWithTag:10000]).text = shopname;
    ((UILabel *)[self.toolbar viewWithTag:10001]).text = goodname;
    if ( activity.length > 0 )
    {
        ((UILabel *)[self.toolbar viewWithTag:10002]).text = [NSString stringWithFormat:@"参加活动：%@",activity];
    }
    else
    {
        ((UILabel *)[self.toolbar viewWithTag:10002]).text = @"";
    }
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
        [[ClientAgent sharedInstance] viewsec:item.mid from:self.from sec:sec block:^(NSError *error, id data, id userInfo, BOOL cache) {

        }];
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

@end
