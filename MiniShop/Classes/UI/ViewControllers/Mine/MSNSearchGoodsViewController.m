//
//  MSNSearchGoodsViewController.m
//  MiniShop
//
//  Created by Wuquancheng on 14-1-4.
//  Copyright (c) 2014年 mini. All rights reserved.
//

#import "MSNSearchGoodsViewController.h"
#import "MSNUISearchBar.h"
#import "MSTransformButton.h"
#import "UIColor+Mini.h"
#import "RTLabel.h"

@interface MSNSearchGoodsViewHeaderView : UIView
@property (nonatomic,strong)RTLabel *titleLabel;
@property (nonatomic,strong)MSTransformButton *orderbyButton;
@end

@implementation MSNSearchGoodsViewHeaderView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.titleLabel = [[RTLabel alloc] initWithFrame:CGRectMake(15, (self.height-16)/2, self.width*2/3-30, 16)];
        self.titleLabel.font = [UIFont systemFontOfSize:14];
        self.orderbyButton = [[MSTransformButton alloc] initWithFrame:CGRectMake(self.titleLabel.right + 20, 0, self.width/3-60, self.height)];
        UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(self.titleLabel.right, 0, 1, self.height)];
        separator.backgroundColor = [UIColor colorWithRGBA:0xd14c60ff];
        [self addSubview:self.titleLabel];
        [self addSubview:self.orderbyButton];
        [self addSubview:separator];
        
        MiniUIButton *button = [MiniUIButton buttonWithImage:[UIImage imageNamed:@"order"] highlightedImage:[UIImage imageNamed:@"order_hover"]];
        button.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 20);
        button.frame = CGRectMake(_orderbyButton.right, 0, 28, 28);
        [self addSubview:button];
        [button setTouchupHandler:^(MiniUIButton *button) {
            _orderbyButton.selectedIndex = _orderbyButton.selectedIndex+1;
        }];

    }
    return self;
}

- (void)setResultNumber:(int)number key:(NSString*)key
{
    [_titleLabel setText:[NSString stringWithFormat:@"<font color='#414345'>共有</font><font color='#d14c60'>%d</font>个宝贝",number]];
}

@end

@interface MSNSearchGoodsViewController ()<UITextFieldDelegate,MSTransformButtonDelegate>
@property (nonatomic,strong)UITextField *searchView;
@property (nonatomic,strong)MSTransformButton *transformButton;
@property (nonatomic,strong)MiniUIButton *cancelButton;

@property (nonatomic,strong)MSNSearchGoodsViewHeaderView *titleSectionView;
@end

@implementation MSNSearchGoodsViewController

- (id)init
{
    self = [super init];
    if (self)
    {
        self.hidesBottomBarWhenPushed = YES;
        self.showNaviView = YES;
    }
    return self;
}

- (void)loadView
{
    [super loadView];
     self.searchView = [self createSearchView:self placeHolder:@"搜商品"];
    [self.naviTitleView addSubview:self.searchView];
    
    self.cancelButton = [MiniUIButton buttonWithType:UIButtonTypeCustom];
    self.cancelButton.frame = CGRectMake(self.searchView.right, 0, self.naviTitleView.width-self.searchView.right,self.naviTitleView.height);
    [self.cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    [self.cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.cancelButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [self.naviTitleView addSubview:self.cancelButton];
    [self.cancelButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    
    self.transformButton = [[MSTransformButton alloc] initWithFrame:CGRectMake(15, 0, 50, self.naviTitleView.height)];
    self.transformButton.items = @[@"在我的\n商城搜",@"在好店\n汇搜索"];
    self.transformButton.fontSize = 12;
    self.transformButton.delegate = self;
    [self.naviTitleView addSubview:self.transformButton];
    
    UIImage *image = [UIImage imageNamed:@"arrow_white"];
    MiniUIButton *button = [MiniUIButton buttonWithImage:image highlightedImage:image];
    button.size = CGSizeMake(40, 40);
    button.center = CGPointMake(self.transformButton.right+4, self.naviTitleView.height/2);
    [self.naviTitleView addSubview:button];
    __PSELF__;
    [button setTouchupHandler:^(MiniUIButton *button) {
        pSelf.transformButton.selectedIndex = pSelf.transformButton.selectedIndex+1;
    }];
    
    self.titleSectionView = [[MSNSearchGoodsViewHeaderView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 28)];
    self.titleSectionView .backgroundColor = [UIColor colorWithRGBA:0xfaf1f2ff];
    self.titleSectionView.orderbyButton.items = @[@"新品",@"折扣",@"降价",@"销量"];
    self.titleSectionView.orderbyButton.values = @[@"time",@"off",@"off_time",@"sale"];
    self.titleSectionView.orderbyButton.fontColor = [UIColor colorWithRGBA:0xd14c60ff];
    self.titleSectionView.orderbyButton.fontSize = 14;
    self.titleSectionView.orderbyButton.delegate = self;
}

- (UITextField *)createSearchView:(id)delegate placeHolder:(NSString *)placeHolder
{
    CGRect frame = CGRectMake(80, (self.naviTitleView.height-26)/2, self.naviTitleView.width-130, 26);
    UITextField *searchView = [[UITextField  alloc] initWithFrame:frame];
    searchView.backgroundColor = [UIColor whiteColor];
    searchView.leftViewMode = UITextFieldViewModeAlways;
    searchView.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    searchView.delegate = self;
    searchView.placeholder = placeHolder;
    searchView.font = [UIFont systemFontOfSize:12];
    searchView.returnKeyType = UIReturnKeySearch;
    searchView.textColor = [UIColor colorWithRGBA:0xd14c60ff];
    MiniUIButton *rightbutton = [MiniUIButton buttonWithImage:[UIImage imageNamed:@"close_s"] highlightedImage:[UIImage imageNamed:@"close_s_hover"]];
    rightbutton.width = rightbutton.width + 14;
    searchView.rightView = rightbutton;
    searchView.rightViewMode = UITextFieldViewModeWhileEditing;
    [rightbutton setTouchupHandler:^(MiniUIButton *button) {
        searchView.text = @"";
    }];
    rightbutton.tag = 0xAB001;
    [self.naviTitleView addSubview:searchView];
    return searchView;
}

- (void)searchBarCancelButtonClicked:(MSNUISearchBar *)searchBar
{
    [self back];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}


- (CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section
{
    if (self.dataSource.info.count==0) {
        return 0;
    }
    else {
        return 28;
    }
}

- (UIView*)tableView:(UITableView*)tableView viewForHeaderInSection:(NSInteger)section
{
    return self.titleSectionView;
}

- (void)loadData:(int)page delay:(CGFloat)delay
{
    if (self.searchView.text.length>0) {
        __PSELF__;
        NSString *type = (self.transformButton.selectedIndex==0?@"1":@"0");
        double delayInSeconds = delay;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [pSelf showWating:nil];
            [[ClientAgent sharedInstance] searchgoods:pSelf.searchView.text type:type sort:[self.titleSectionView.orderbyButton selectedValue] page:page block:^(NSError *error, MSNGoodsList* data, id userInfo, BOOL cache) {
                [pSelf dismissWating];
                if (error==nil) {
                    [pSelf receiveData:data page:page];
                    [pSelf.titleSectionView setResultNumber:data.goods_num key:pSelf.searchView.text];
                }
                else {
                    [pSelf showErrorMessage:error];
                }
            }];

        });
    }
    else {
        [self.tableView refreshDone];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([string isEqualToString:@"\n"]) {
        [textField resignFirstResponder];
        if (textField.text.length>0) {
            [self loadData:1 delay:0];
        }
        return NO;
    }
    return YES;
}

- (void)transformButtonValueChanged:(MSTransformButton*)button
{
    [self loadData:1 delay:0];
}

@end
