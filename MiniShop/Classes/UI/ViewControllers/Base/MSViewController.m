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
#import "MSShopInfo.h"
#import "EGOUITableView.h"
#import "MiniUIIndicator.h"
#import "MRLoginViewController.h"
#import "MSTopicViewController.h"

#define KBACKGROUDIMAGEVIEWTAG 0x20000

@interface MSViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic,strong)MiniUIActivityIndicatorView *indicator;
@end

@implementation MSViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
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
    self.navigationItem.hidesBackButton = YES;
    [self setBackGroudImage:@"view_bg"];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    if ( MAIN_VERSION >= 7 ) {
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.automaticallyAdjustsScrollViewInsets = NO;
    }
    //[self setViewBackgroundColor];
	// Do any additional setup after loading the view.
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self dismissWating];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setBackGroudImage:(NSString *)imageName
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

- (void)setViewBackgroundColor
{
    [self setViewBackGroundWithColor:[UIColor colorWithRGBA:0xdbdbdbff]];
}

- (void)setViewBackGroundWithColor:(UIColor *)color
{
    self.view.backgroundColor = color;
}

- (void)setNaviBackButton
{
    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.leftBarButtonItem = [self navLeftButtonWithTitle:@"返回" target:self action:@selector(back)];
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
    button.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 10);
    button.width += 10;
    button.showsTouchWhenHighlighted = YES;
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.rightBarButtonItem = item;
}



- (void)setNaviRightButtonTitle:(NSString *)title target:(id)target action:(SEL)action
{
    UIBarButtonItem *item = [self navButtonWithTitle:title target:target action:action];
    self.navigationItem.rightBarButtonItem = item;
}

- (UIBarButtonItem *)navButtonWithTitle:(NSString *)title target:(id)target action:(SEL)action {
    UIFont* btnFont = [UIFont systemFontOfSize:15.];
    
    CGSize size = [title sizeWithFont:btnFont];
    
    UIImage* bgImage = [[UIImage imageNamed:@"follow_s_button_normal"] stretchableImageWithLeftCapWidth:10 topCapHeight:10];
    UIImage* bgImage2 = [[UIImage imageNamed:@"follow_s_button_selected"] stretchableImageWithLeftCapWidth:10 topCapHeight:10];
    
    MiniUIButton* button = [UIButton buttonWithType:UIButtonTypeCustom]; //自定义
    
    button.frame = CGRectMake(0.0, 0.0, size.width + 20, 30);
    button.titleLabel.font = btnFont;
    
    [button setBackgroundImage:bgImage forState:UIControlStateNormal];
    [button setBackgroundImage:bgImage2 forState:UIControlStateHighlighted];
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
    UITableView *tableView = [[EGOUITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.backgroundView = nil;
    tableView.backgroundColor = self.view.backgroundColor;
    tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    return tableView;
}

- (UITableView*)createGroupedTableView
{
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.separatorColor = [UIColor lightGrayColor];
    tableView.backgroundColor = self.view.backgroundColor;
    tableView.backgroundView = nil;
    return tableView;
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
    [self.indicator showInView:self.view];
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
- (void)actionGoToShopping:(MSShopInfo *)info
{
    [MobClick event:MOB_GOODS_DETAIL];
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

- (void)userAuth:(void (^)())block
{
    if ( WHO == nil ) {
        __PSELF__;
        [MiniUIAlertView showAlertWithTitle:@"亲，友好滴提示一下，为了更好的为您服务，您先登录一下吧" message:@"" block:^(MiniUIAlertView *alertView, NSInteger buttonIndex) {
            if ( buttonIndex != alertView.cancelButtonIndex ) {
                MRLoginViewController *controller = [[MRLoginViewController alloc] init];
                controller.loginblock = ^(BOOL login) {
                    if ( login ) {
                        [pSelf.navigationController popViewControllerAnimated:NO];
                        block();
                    }
                };
                [pSelf.navigationController pushViewController:controller animated:YES];
            }
        } cancelButtonTitle:@"等会儿吧" otherButtonTitles:@"好", nil];
    }
    else {
        block();
    }
}

- (void)remindLogin
{
    [MiniUIAlertView showAlertWithTitle:@"友好滴提示一下, 您可以" message:@"" block:^(MiniUIAlertView *alertView, NSInteger buttonIndex) {
        if ( buttonIndex == 0 ) {
            MRLoginViewController *controller = [[MRLoginViewController alloc] init];
            [self.navigationController pushViewController:controller animated:YES];
        }
        else if ( buttonIndex == 1 ) {
            MSTopicViewController *controller = [[MSTopicViewController alloc] init];
            [self.navigationController pushViewController:controller animated:YES];
            
        }
    } cancelButtonTitle:nil otherButtonTitles:@"登录/注册",@"随便逛逛",nil];
}

@end
