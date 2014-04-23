//
//  MSNAddShopViewController.m
//  MiniShop
//
//
//
//  Created by Wuquancheng on 14-3-22.
//  Copyright (c) 2014年 mini. All rights reserved.
//

#import "MSNAddShopViewController.h"
#import "MSNTransformButton.h"
#import "MSNShop.h"
#import "MSNShopInfoCell.h"
#import "MSNImportFavViewController.h"
#import "MSNSearchShopViewController.h"
#import "UIColor+Mini.h"

@interface MSNAddShopViewController () <UITextFieldDelegate>
@property (nonatomic, strong)UITextField *searchField;
@property (nonatomic, strong)MSNTransformButton *transformButton;
@property (nonatomic, strong)EGOUITableView   *tableView;
@property (nonatomic, strong)MSNShopList   *dataSource;
@property (nonatomic, strong)UIView        *sectionHeaderView;
@property (nonatomic) NSInteger page;
@property (nonatomic) BOOL dataChanged;
@end

@implementation MSNAddShopViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _dataChanged = NO;
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    [self setNaviBackButton];
    self.title = @"添加商铺";

    UIView *view = [self createSearchView];
    view.center = CGPointMake(self.contentView.width/2, 30);
    [self.contentView addSubview:view];

    MiniUIButton *button = [MiniUIButton buttonWithBackGroundImage:[UIImage imageNamed:@"bigbtn"]
            highlightedBackGroundImage:nil title:@"导入收藏夹"];
    [button setTitleColor:[UIColor colorWithRGBA:0x543d34FF] forState:UIControlStateNormal];
    button.frame = CGRectMake(0, view.bottom+10, self.contentView.width, 38);
    [button addTarget:self action:@selector(actionImportFav:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:button];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (UIView *)createSearchView
{
    if (_sectionHeaderView==nil){
        _sectionHeaderView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.contentView.width, 40)];
        _sectionHeaderView.backgroundColor = [self backgroundColor];

        self.searchField = [[UITextField  alloc] initWithFrame:CGRectMake(0,5,self.contentView.width,30)];
        MiniUIButton *button = [MiniUIButton buttonWithImage:[UIImage imageNamed:@"icon_search_hover"]
                                            highlightedImage:[UIImage imageNamed:@"icon_search_hover"]];
        button.frame = CGRectMake(0, 0, 50, 30);
        [button addTarget:self.searchField action:@selector(becomeFirstResponder) forControlEvents:UIControlEventTouchUpInside];
        self.searchField.rightView = button;
        self.searchField.rightViewMode = UITextFieldViewModeAlways;
        self.searchField.font = [UIFont systemFontOfSize:14];
        self.searchField.backgroundColor = [UIColor clearColor];
        self.searchField.placeholder = @"搜索店铺然后添加";
        [_sectionHeaderView addSubview:self.searchField];
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, 30)];
        self.searchField.leftView = view;
        self.searchField.leftViewMode = UITextFieldViewModeAlways;
        self.searchField.returnKeyType = UIReturnKeySearch;
        self.searchField.delegate = self;

    }
    return _sectionHeaderView;
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([string isEqualToString:@"\n"]) {
        [self search];
        return NO;
    }
    else {
        return YES;
    }
}


- (void)search
{
    [self.searchField resignFirstResponder];
    NSString *key = self.searchField.text;
    if (key.length>0) {
        MSNSearchShopViewController *controller = [[MSNSearchShopViewController alloc] init];
        controller.key = key;
        [self.navigationController pushViewController:controller animated:YES];
    }
}


- (void)actionImportFav:(MiniUIButton *)button
{
    MSNImportFavViewController *controller = [[MSNImportFavViewController alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)back
{
    if (_dataChanged) {
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTI_FAV_CHANGE object:nil];
    }
    [super back];
}

@end
