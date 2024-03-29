//
//  MSViewController.m
//  MiniShop
//
//  Created by Wuquancheng on 13-3-27.
//  Copyright (c) 2013年 mini. All rights reserved.
//

#import "MSViewController.h"
#import "MSUIWebViewController.h"
#import "SVPullToRefresh.h"
#import "UIColor+Mini.h"
#import "MSFShopInfo.h"
#import "EGOUITableView.h"
#import "MiniUIIndicator.h"
#import "MRLoginViewController.h"
#import "MSUIMoreDataCell.h"
#import "SDImageCache.h"

#define KBACKGROUDIMAGEVIEWTAG 0x20000

@interface MSViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic,strong)MiniUIActivityIndicatorView *indicator;
@end

@implementation MSViewController

- (id)init
{
    self = [super init];
    if (self) {
        _showNaviView = YES;
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
        if ( [self respondsToSelector:@selector(setEdgesForExtendedLayout:)] ) {
            self.edgesForExtendedLayout = UIRectEdgeNone;
        }
        if ( [self respondsToSelector:@selector(setAutomaticallyAdjustsScrollViewInsets:)] ) {
            self.automaticallyAdjustsScrollViewInsets = NO;
        }
    }
    self.navigationController.navigationBar.hidden = YES;
    [self setBackGroundImage:@"background_image"];
    [self setNaviTitleViewShow:_showNaviView];
    [self setStatusBar];
    if ( _showNaviView) {
        self.naviTitleView.backgroundColor = NAVI_BG_COLOR;
    }
}

- (void)setStatusBar
{
    if ( MAIN_VERSION >= 7 ) {
        UIView *view = [self.view viewWithTag:0x0C00C];
        if ( view == nil ) {
            view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 20)];
            view.backgroundColor =  NAVI_BG_COLOR;
            [self.view addSubview:view];
        }
    }
}


- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self dismissWating];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [MSSystem sharedInstance].controller = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    [[SDImageCache sharedImageCache] clearMemory];
}

- (void)setBackGroundImage:(NSString *)imageName
{
    UIImageView *imageView = (UIImageView*)[self.view viewWithTag:KBACKGROUDIMAGEVIEWTAG];
    if ( imageView == nil )
    {
        imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
        imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self.view addSubview:imageView];
    }
    imageView.image = [UIImage imageNamed:imageName];
}

- (void)setPullToRefreshViewStyle:(SVPullToRefresh*)view
{
    view.textColor = [UIColor whiteColor];
    view.arrowColor = [UIColor whiteColor];
}


- (UIColor*)backgroundColor
{
    return [UIColor colorWithRGBA:0xfaf1f2ff];
}

- (void)setViewBackGroundWithColor:(UIColor *)color
{
    self.contentView.backgroundColor = color;
}

- (void)setNaviBackButton
{
    self.navigationItem.hidesBackButton = YES;
    UIButton *button = (UIButton*)((UIBarButtonItem *)[self navLeftButtonWithTitle:@"返回" target:self action:@selector(back)]).customView;
    CGFloat top = (self.naviTitleView.height - 30)/2;
    button.frame = CGRectMake(20, top, 30, 30);
    self.naviTitleView.leftButton = (MiniUIButton*)button;
}

- (void)setNaviLeftButtonTitle:(NSString *)title target:(id)target action:(SEL)action
{
    UIBarButtonItem *item = [self navButtonWithTitle:title target:target action:action];
    self.navigationItem.leftBarButtonItem = item;
}

- (UIBarButtonItem *)navLeftButtonWithTitle:(NSString *)title target:(id)target action:(SEL)action
{
    MiniUIButton *button = [MiniUIButton buttonWithImage:[UIImage imageNamed:@"navi_back"] highlightedImage:[UIImage imageNamed:@"navi_back_h"]];
    button.width += 4;
    button.imageEdgeInsets = UIEdgeInsetsMake(0, 4, 0, 0);
    //button.showsTouchWhenHighlighted = YES;
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem* tmpBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    tmpBarButtonItem.style = UIBarButtonItemStyleBordered;
    
    return  tmpBarButtonItem;
}


- (UIBarButtonItem *)navLeftButtonWithTitle:(NSString *)title image:(NSString *)imageName target:(id)target action:(SEL)action{
    UIBarButtonItem* tmpBarButtonItem = [self navLeftButtonWithTitle:title target:target action:action];
    UIButton* btn = (UIButton*)tmpBarButtonItem.customView;
    [btn setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    
    return tmpBarButtonItem;
}

- (void)setNaviRightButtonImage:(NSString *)imageName target:(id)target action:(SEL)action
{
    UIImage* bgImage = [UIImage imageNamed:imageName];
    MiniUIButton *button = [MiniUIButton buttonWithImage:bgImage highlightedImage:bgImage];
    button.width += 10;
    button.showsTouchWhenHighlighted = YES;
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    self.naviTitleView.rightButton = button;
}

- (void)setNaviRightButtonImage:(NSString *)imageName highlighted:(NSString*)highlightedImage target:(id)target action:(SEL)action
{
    MiniUIButton *button = [MiniUIButton buttonWithImage:[UIImage imageNamed:imageName] highlightedImage:[UIImage imageNamed:highlightedImage]];
    button.width += 10;
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    self.naviTitleView.rightButton = button;
}


- (void)setNaviRightButtonTitle:(NSString *)title target:(id)target action:(SEL)action
{
    UIBarButtonItem *item = [self navButtonWithTitle:title target:target action:action];
    self.naviTitleView.rightButton = (MiniUIButton*)item.customView;
}

- (UIBarButtonItem *)navButtonWithTitle:(NSString *)title target:(id)target action:(SEL)action {
    UIFont* btnFont = [UIFont systemFontOfSize:15.];
    
    CGSize size = [title sizeWithFont:btnFont];
    
    //UIImage* bgImage = [[UIImage imageNamed:@"follow_s_button_normal"] stretchableImageWithLeftCapWidth:10 topCapHeight:10];
    //UIImage* bgImage2 = [[UIImage imageNamed:@"follow_s_button_selected"] stretchableImageWithLeftCapWidth:10 topCapHeight:10];
    
    MiniUIButton* button = [UIButton buttonWithType:UIButtonTypeCustom]; //自定义
    
    button.frame = CGRectMake(0.0, 0.0, size.width + 20, 30);
    button.titleLabel.font = btnFont;
    
//    [button setBackgroundImage:bgImage forState:UIControlStateNormal];
//    [button setBackgroundImage:bgImage2 forState:UIControlStateHighlighted];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitle:title forState:UIControlStateHighlighted];
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem* tmpBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    tmpBarButtonItem.style = UIBarButtonItemStyleBordered;
    
    return  tmpBarButtonItem;
}

- (UIBarButtonItem *)navRightButtonWithTitle:(NSString *)title image: (NSString *)imageName target:(id)target action:(SEL)action{
    UIBarButtonItem* tmpBarButtonItem = [self navButtonWithTitle:title target:target action:action];
    UIButton* btn = (UIButton*)tmpBarButtonItem.customView;
    [btn setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    btn.adjustsImageWhenHighlighted = NO;
    return tmpBarButtonItem;
}
//在右边添加多个button

- (UIBarButtonItem*)navRightButtons : (NSArray*)btns{
    CGFloat barBtnWidth = 0;
    for (UIBarButtonItem* item in btns) {
        barBtnWidth += 40;
    }
    barBtnWidth += (btns.count - 1) * 5;    //5是各个btn之间的间距
    
    UIView* view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, barBtnWidth, 30)];
    CGFloat orginX = 0;
    for (int i = 0; i < btns.count; ++i) {
        UIBarButtonItem* item = [btns objectAtIndex:i];
        item.customView.frame = CGRectMake(orginX, 0,40, 30);
        orginX += item.customView.frame.size.width + 5;
        [view addSubview:item.customView];
    }
    UIBarButtonItem* ret = [[UIBarButtonItem alloc]initWithCustomView:view];
    return ret;
}

- (void)addRightRefreshButtonToTarget:(id)target action:(SEL)action
{
    UIImage* normalImage = [UIImage imageNamed:@"web_toolbar_btn_refresh"];
    UIImage* selectedImage = [UIImage imageNamed:@"web_toolbar_btn_refresh"];
    
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom]; //自定义
    button.showsTouchWhenHighlighted = YES;
    [button setImage:normalImage forState:UIControlStateNormal];
    [button setImage:selectedImage forState:UIControlStateHighlighted];
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem* rightButtonItem = [[UIBarButtonItem alloc] init];
    rightButtonItem.style = UIBarButtonItemStyleBordered;
    
    button.frame = CGRectMake(0.0f, 0.0f, 45.0f, 45.0f);
    rightButtonItem.customView = button;
    
    self.navigationItem.rightBarButtonItem = rightButtonItem;
}

- (UITableView *)createPlainTableView
{
    UITableView *tableView = [[EGOUITableView alloc] initWithFrame:self.contentView.bounds style:UITableViewStylePlain];
    tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.backgroundView = nil;
    tableView.backgroundColor = self.contentView.backgroundColor;
    tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    return tableView;
}

- (UITableView*)createGroupedTableView
{
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.contentView.bounds style:UITableViewStyleGrouped];
    tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.separatorColor = [UIColor lightGrayColor];
    tableView.backgroundColor = self.contentView.backgroundColor;
    tableView.backgroundView = nil;
    return tableView;
}

- (EGOUITableView*)createEGOTableView
{
    CGRect frame = self.contentView.bounds;
    EGOUITableView *tableView = [[EGOUITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
    tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.backgroundView = nil;
    tableView.backgroundColor = [UIColor clearColor];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.showsVerticalScrollIndicator = NO;
    [self setPullToRefreshViewStyle:tableView.pullToRefreshView];
    return tableView;
}

- (void)showWating:(NSString *)message inView:(UIView *)inView
{
    if ( self.indicator == nil )
    {
        self.indicator = [[MiniUIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    }
    //    if ( message == nil )
    //         self.indicator.labelText = @"正在努力加载...";
    //    else
    self.indicator.labelText = @"";
    [self.indicator showInView:inView];
}


- (void)showWating:(NSString *)message
{
    [self showWating:message inView:self.contentView];
}

- (void)dismissWating:(BOOL)animated
{
    [self.indicator hide];
}

- (void)showErrorMessage:(NSError *)error
{
    if ( error.code != NSURLErrorTimedOut )
    {
        [self showMessageInfo:[error localizedDescription] delay:3];
    }
}

//查看详情
- (void)actionGoToShopping:(MSFShopInfo *)info
{
    NSString* requestStr = nil;
    if ( info.shop_id > 0 )
    {
        requestStr = [NSString stringWithFormat:@"http://%@?type=shop&id=%lld&is_mobile=1&pagepos=1&imei=%@&usernick=", StoreGoUrl, info.shop_id ,UDID];
    }
    else
    {
        requestStr = [NSString stringWithFormat:@"http://shop%lld.m.taobao.com",info.numId];
        
    }
    MSUIWebViewController *controller = [[MSUIWebViewController alloc] initWithUri:requestStr title:[info realTitle] toolbar:YES];
    [self.navigationController pushViewController:controller animated:YES];
}

- (BOOL)isLoading
{
    return [self.indicator showing];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

- (void)setDefaultNaviBackground
{
    UIImage *image = [MiniUIImage imageNamed:( MAIN_VERSION >= 7?@"navi_background_7":@"navi_background")];
    [self.navigationController.navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
}

- (void)loadMore
{
    
}

- (void)setMoreDataAction:(BOOL)more tableView:(EGOUITableView*)tableView
{
    if ( more )
    {
        if ( tableView.moreDataAction == nil)
        {
            if ( tableView.moreDataCell == nil )
            {
                tableView.moreDataCell = [[MSUIMoreDataCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"__More_Data_Cell"];
            }
            __PSELF__;
            [tableView setMoreDataAction:^{
                [pSelf loadMore];
            } keepCellWhenNoData:NO loadSection:NO];
            
        }
    }
    else
    {
        [tableView setMoreDataAction:nil keepCellWhenNoData:NO loadSection:NO];
    }
}

- (void)setTitle:(NSString *)title
{
    self.naviTitleView.title = title;
    [self.naviTitleView setNeedsLayout];
}

@end
