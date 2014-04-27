//
//  MSNShopDetailViewController.m
//  MiniShop
//  店铺详情页
//  Created by Wuquancheng on 14-1-4.
//  Copyright (c) 2014年 mini. All rights reserved.
//

#import "MSNShopDetailViewController.h"
#import "MSNShopInfoView.h"
#import "MSNTransformButton.h"
#import "UIColor+Mini.h"
#import "MSWebChatUtil.h"

@interface MSNShopMessageView : UIView <UITextFieldDelegate,MSTransformButtonDelegate>
@property (nonatomic,strong)UIView *messageView;
@property (nonatomic,strong)UILabel *numberLabel;
@property (nonatomic,strong)MSNTransformButton *transformButton;
@property (nonatomic,strong)MiniUIButton *searchButton;
@property (nonatomic,strong)MiniUIButton *arrowButton;

@property (nonatomic,strong)UIView *searchView;
@property (nonatomic,strong)UITextField *searchField;
@property (nonatomic,strong)MiniUIButton *cancelButton;

@property (nonatomic,strong)NSString *lastKey;

@property (nonatomic,strong) void (^handleSearchBlock)(NSString *key,NSString *orderBy);
@property (nonatomic,strong) void (^handleCancelSearchBlock)();
@end

@implementation MSNShopMessageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.messageView = [[UIView alloc] initWithFrame:self.bounds];
        [self addSubview:self.messageView];
        CGFloat top = (self.height-14)/2;
        self.numberLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, top, 200, 14)];
        self.numberLabel.backgroundColor = [UIColor clearColor];
        self.numberLabel.font = [UIFont systemFontOfSize:14];
        self.numberLabel.textColor = [UIColor colorWithRGBA:0x414345FF];
        [self.messageView addSubview:self.numberLabel];
        
        self.transformButton = [[MSNTransformButton alloc] initWithFrame:CGRectMake(230, top, 36, 14)];
        self.transformButton.items = @[@"新品",@"销量",@"降价"];
        self.transformButton.values = @[@"time",@"sale",@"off_time"];
        self.transformButton.fontColor = [UIColor colorWithRGBA:0xd14c60ff];
        self.transformButton.fontSize=14;
        [self.messageView addSubview:self.transformButton];
        self.arrowButton = [MiniUIButton buttonWithImage:[UIImage imageNamed:@"arrow_b"] highlightedImage:nil];
        self.arrowButton.frame = CGRectMake(self.transformButton.right, top, 14, 14);
        __PSELF__;
        [self.arrowButton setTouchupHandler:^(MiniUIButton *button) {
            pSelf.transformButton.selectedIndex = pSelf.transformButton.selectedIndex+1;
        }];
        [self.messageView addSubview:self.arrowButton];
        self.transformButton.delegate = self;
        
        self.searchButton= [MiniUIButton buttonWithImage:[UIImage imageNamed:@"icon_search_hover"] highlightedImage:[UIImage imageNamed:@"icon_search"]];
        self.searchButton.frame = CGRectMake(self.arrowButton.right+4, 0, self.height, self.height);
        [self.messageView addSubview:self.searchButton];
        [self.searchButton addTarget:self action:@selector(showSearchView) forControlEvents:UIControlEventTouchUpInside];
        
        self.searchView = [[UIView alloc] initWithFrame:CGRectMake(self.width, 0, self.width-80, self.height)];
        [self addSubview:self.searchView];
        
        self.searchField = [[UITextField alloc] initWithFrame:CGRectMake(0, (self.height-24)/2, self.searchView.width-60, 24)];
        self.searchField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        self.searchField.font = [UIFont systemFontOfSize:14];
        self.searchField.textColor = [UIColor colorWithRGBA:0xd14c60ff];
        self.searchField.leftViewMode = UITextFieldViewModeAlways;
        UILabel *leftView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 40, 20)];
        leftView.font = [UIFont systemFontOfSize:14];
        leftView.text = @"店内";
        leftView.textAlignment = NSTextAlignmentCenter;
        leftView.textColor = [UIColor colorWithRGBA:0xb8b8b8ff];
        self.searchField.leftView = leftView;
        self.searchField.layer.borderColor = [UIColor colorWithRGBA:0xd2afb4ff].CGColor;
        self.searchField.layer.borderWidth = 1.0f;
        [self.searchView addSubview:self.searchField];
        self.searchField.returnKeyType = UIReturnKeySearch;
        self.searchField.delegate = self;
        
        self.cancelButton = [MiniUIButton buttonWithType:UIButtonTypeCustom];
        [self.cancelButton setTitle:@"取消" forState:UIControlStateNormal];
        self.cancelButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [self.cancelButton setTitleColor:[UIColor colorWithRGBA:0xd14c60ff] forState:UIControlStateNormal];
        self.cancelButton.frame = CGRectMake(self.searchField.right, self.searchField.top, 60, self.searchField.height);
        [self.searchView addSubview:self.cancelButton];
        [self.cancelButton addTarget:self action:@selector(hideSearchView) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)showSearchView
{
    [UIView animateWithDuration:0.25f animations:^{
        self.messageView.left=-215;
        self.searchButton.alpha = 0;
        self.searchView.left = 80;
    } completion:^(BOOL finished) {
        [self.searchField becomeFirstResponder];
    }];
}

- (void)hideSearchView
{
    [self.searchField resignFirstResponder];
    self.searchField.text = self.lastKey;
    [UIView animateWithDuration:0.25f animations:^{
        self.messageView.left=0;
        self.searchButton.alpha = 1.0f;
        self.searchView.left = self.width;
    } completion:^(BOOL finished) {
       if (self.handleCancelSearchBlock!=nil) {
           self.handleCancelSearchBlock();
       }
    }
    ];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([string isEqualToString:@"\n"]) {
        [textField resignFirstResponder];
        if (self.handleSearchBlock!=nil) {
            self.handleSearchBlock(textField.text, self.transformButton.selectedValue);
        }
        self.lastKey = self.searchField.text;
        //[self hideSearchView];
        return NO;
    }
    else {
        return YES;
    }
}

- (void)transformButtonValueChanged:(MSNTransformButton*)button
{
    if (self.handleSearchBlock!=nil) {
        self.handleSearchBlock(self.searchField.text, button.selectedValue);
    }
}

@end


@interface MSNShopDetailViewController ()
@property (nonatomic,strong)MSNShopInfoView *shopInfoView;
@property (nonatomic,strong)MSNShopMessageView *messageView;
@property (nonatomic,strong)MiniUIButton *favButton;

@property (nonatomic, strong)MiniUIButton *toolBarFavButton;
@property (nonatomic, strong)MiniUIButton *toolBarShareButton;

@property (nonatomic, strong)NSString *orderBy;

@property (nonatomic, strong)MSNGoodsList *tGoodsList;
@property (nonatomic)int tPage;
@property (nonatomic, strong)NSString *tMessageTitle;
@property (nonatomic)int tTransButtonSelectIndex;
@end

@implementation MSNShopDetailViewController

- (id)init
{
    self = [super init];
    if (self) {
        self.showNaviView = YES;
        self.random = NO;
        self.hidesBottomBarWhenPushed = YES;
        self.orderBy = @"time";
    }
    return self;
}

- (void)setRandom:(BOOL)random
{
    _random = random;
}

- (void)loadView
{
    [super loadView];
	[self setNaviBackButton];
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.contentView.width, 80)];
    view.backgroundColor = [UIColor colorWithRGBA:0xfaf1f2ff];
    self.shopInfoView = [[MSNShopInfoView alloc] initWithFrame:CGRectMake(0, -3, self.contentView.width-130, 85)];
    self.shopInfoView.accessoryImageView = nil;
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, view.height-1, view.width, 1)];
    line.backgroundColor = [UIColor colorWithRGBA:0xcd796fff];
    [view addSubview:line];
    if (self.shopInfo.user_like==1) {
        self.favButton = [MiniUIButton buttonWithImage:[UIImage imageNamed:@"cancel"] highlightedImage:[UIImage imageNamed:@"cancel_hover"]];
        [view addSubview:self.shopInfoView];
    }
    else {
        self.favButton = [MiniUIButton buttonWithImage:[UIImage imageNamed:@"add"] highlightedImage:[UIImage imageNamed:@"add_hover"]];
    }
    self.favButton.center = CGPointMake(view.width-15-(self.favButton.width/2), view.height/2);
    [self.favButton addTarget:self action:@selector(actionFavButtonTap:) forControlEvents:UIControlEventTouchUpInside];
    view.layer.masksToBounds = YES;
    [view addSubview:self.shopInfoView];
    [view addSubview:self.favButton];
    
    __PSELF__;
    self.messageView = [[MSNShopMessageView alloc] initWithFrame:CGRectMake(0, 0, self.contentView.width, 36)];
    self.messageView.backgroundColor = view.backgroundColor;
    [self.messageView setHandleSearchBlock:^(NSString *key, NSString *orderBy) {
        if (pSelf.tGoodsList==nil) {
            pSelf.tGoodsList = pSelf.dataSource;
            pSelf.tPage = pSelf.page;
            pSelf.tMessageTitle = pSelf.messageView.numberLabel.text;
            pSelf.tTransButtonSelectIndex =  pSelf.messageView.transformButton.selectedIndex;
        }
        [pSelf searchWithKey:key orderby:orderBy];
    }];
    [self.messageView setHandleCancelSearchBlock:^{
        if (pSelf.tGoodsList!=nil) {
            pSelf.messageView.numberLabel.text = pSelf.tMessageTitle;
            pSelf.dataSource =  pSelf.tGoodsList;
            pSelf.page = pSelf.tPage;
            pSelf.tGoodsList = nil;
            pSelf.tPage = 0;
            [pSelf.messageView.transformButton setSelectedIndex:pSelf.tTransButtonSelectIndex animated:YES withEvent:NO];
            [pSelf.tableView reloadData];
        }
    }];
    
    self.tableView.tableHeaderView = view;
    self.tableView.height = self.tableView.height-44;
    [self createToolbar:44];
}

- (void)setPullToRefreshAction
{
    __PSELF__;
    if (self.random) {
        [self.tableView setPullToRefreshAction:^{
            [pSelf randomShop];
        }];
    }
    else {
        [self.tableView setPullToRefreshAction:^{
             [pSelf searchWithKey:pSelf.key orderby:pSelf.orderBy];
        }];
    }
 
}

- (void)resetFavButton
{
    if (self.shopInfo.user_like==1) {
        [self.favButton setImage:[UIImage imageNamed:@"cancel"] forState:UIControlStateNormal];
        [self.favButton setImage:[UIImage imageNamed:@"cancel_hover"] forState:UIControlStateHighlighted];
    }
    else {
        [self.favButton setImage:[UIImage imageNamed:@"add"] forState:UIControlStateNormal];
        [self.favButton setImage:[UIImage imageNamed:@"add_hover"] forState:UIControlStateHighlighted];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (!self.random) {
        if (self.shopInfo.shop_title.length==0) {
            [self loadShopInfo];
        }
        else {
            [self.naviTitleView setTitle:self.shopInfo.shop_title];
            [self.shopInfoView setShopInfo:self.shopInfo];
        }
    }
    [self.tableView triggerRefresh];
}

- (void)createToolbar:(CGFloat)height
{
    UIView *toolbar = [[UIView alloc] initWithFrame:CGRectMake(0, self.contentView.height-height, self.contentView.width, height)];
    toolbar.backgroundColor = [UIColor colorWithRGBA:0xf7eeefff];
    [self.contentView addSubview:toolbar];

    CGFloat centerY = toolbar.height/2-4;

    if (self.random) {
        MiniUIButton *button = [MiniUIButton createToolBarButton:@"  再猜    " imageName:nil hImageName:nil];
        [button setImage:[UIImage imageNamed:@"guess"] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:@"guess-hover"] forState:UIControlStateHighlighted];

        button.center = CGPointMake(toolbar.width/2,centerY);
        [toolbar addSubview:button];
        [button addTarget:self action:@selector(actionToolTryAgain:) forControlEvents:UIControlEventTouchUpInside];
    }
    else {
        MiniUIButton *button = [MiniUIButton createToolBarButton:@"收藏" imageName:@"star" hImageName:@"star"];
        button.center = CGPointMake(50,centerY);
        [toolbar addSubview:button];
        [button addTarget:self action:@selector(actionToolBarFav:) forControlEvents:UIControlEventTouchUpInside];
        self.toolBarFavButton = button;
        
        button = [MiniUIButton createToolBarButton:@"分享" imageName:@"share" hImageName:@"share_hover"];
        button.center = CGPointMake(toolbar.width/2,centerY);
        [toolbar addSubview:button];
        [button addTarget:self action:@selector(actionToolBarShare:) forControlEvents:UIControlEventTouchUpInside];
        self.toolBarShareButton = button;
        self.toolBarFavButton.left = 60;
        self.toolBarShareButton.right = self.contentView.width-60;
    }
}

- (CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section
{
    return 36;
}

- (UIView*)tableView:(UITableView*)tableView viewForHeaderInSection:(NSInteger)section
{
    return self.messageView;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadShopInfo
{
    __PSELF__;
    [[ClientAgent sharedInstance] shopinfo:self.shopInfo.shop_id block:^(NSError *error, MSNShopInfo* data, id userInfo, BOOL cache) {
        if (error==nil){
            pSelf.shopInfo = data;
            pSelf.title = data.shop_title;
            [pSelf.shopInfoView setShopInfo:pSelf.shopInfo];
        }
    }];
}

- (void)randomShop
{
    __PSELF__;
    [[ClientAgent sharedInstance] guesslikeshop:^(NSError *error, id data, id userInfo, BOOL cache) {
        if (error==nil) {
            pSelf.shopInfo = data;
            pSelf.naviTitleView.title = pSelf.shopInfo.shop_title;
            [pSelf.naviTitleView setNeedsLayout];
            [pSelf.shopInfoView setShopInfo:pSelf.shopInfo];
            [pSelf resetFavButton];
            pSelf.contentView.hidden=NO;
            [pSelf loadData:1 orderby:@"time" delay:0];
        }
        else {
            [pSelf showErrorMessage:error];
        }
    }];
}

- (void)loadData:(int)page delay:(CGFloat)delay
{
    [self loadData:page orderby:self.orderBy delay:delay];
}

- (void)loadData:(int)page orderby:(NSString*)orderBy delay:(CGFloat)delay
{
    if (page==1) {
        [self.tableView refreshDone];
    }
    __PSELF__;
    [[ClientAgent sharedInstance] shopgoods:self.shopInfo.shop_id tagId:@"" sort:orderBy key:self.key page:page block:^
    (NSError *error, MSNShopDetail *data, id userInfo, BOOL cache) {
        if (error == nil) {
            pSelf.messageView.numberLabel.text = [NSString stringWithFormat:@"%@:%@件", self.key.length
           ==0?@"全部在售商品":[NSString stringWithFormat:@"和%@相关",self.key],data.goods_num];
            MSNGoodsList *list = [[MSNGoodsList alloc] init];
            list.info = data.info.goods_info;
            list.goods_num = [data.goods_num integerValue];
            list.next_page = data.next_page;
            [pSelf receiveData:list page:page];
            [pSelf resetToolBarFavButton:self.toolBarFavButton];
        }
        else {
            [pSelf showErrorMessage:error];
        }
    }];
}

- (void)searchWithKey:(NSString*)key orderby:(NSString*)orderBy
{
    self.key = key;
    self.orderBy = orderBy;
    [self loadData:1 orderby:orderBy delay:0];
}

- (void)actionFavButtonTap:(MiniUIButton*)button
{
    [self showWating:nil];
    __PSELF__;
    NSString *action = self.shopInfo.user_like==1?@"off":@"on";
    [[ClientAgent sharedInstance] setfavshop:self.shopInfo.shop_id action:action block:^(NSError *error, id data, id userInfo, BOOL cache) {
        [pSelf dismissWating];
        if (error==nil) {
            pSelf.shopInfo.user_like = (self.shopInfo.user_like==1?0:1);
            [pSelf resetFavButton];
        }
        else {
            [pSelf showErrorMessage:error];
        }
    }];

}

- (void)resetToolBarFavButton:(MiniUIButton*)button
{
    UIImage *image = [UIImage imageNamed:(self.shopInfo.user_like==1?@"star_hover":@"star")];
    [button setImage:image forState:UIControlStateNormal];
    [button setImage:image forState:UIControlStateHighlighted];
}

- (void)actionToolBarFav:(MiniUIButton*)button
{
    __PSELF__;
    [[ClientAgent sharedInstance] setfavshop:self.shopInfo.shop_id action:self.shopInfo.user_like?@"off":@"on" block:^(NSError *error, id data, id userInfo, BOOL cache) {
        if ( error != nil ) {
            [pSelf showMessageInfo:[error localizedDescription] delay:2];
        }
        else {
            if (self.shopInfo.user_like==0){
                [pSelf showMessageInfo:@"收藏成功" delay:2];
                self.shopInfo.user_like=1;

            }
            else {
                [pSelf showMessageInfo:@"取消成功" delay:2];
                self.shopInfo.user_like=0;
            }
            [self resetToolBarFavButton:button];
        }
    }];
}

- (void)actionToolBarShare:(MiniUIButton*)button
{
    [MobClick event:MOB_DETAIL_TOP_SHARE];
    [MSWebChatUtil shareShop:self.shopInfo controller:self];
}

- (void)actionToolTryAgain:(MiniUIButton *)button
{
    [self randomShop];
}



@end
