//
//  CreditableIndexViewController.m
//  MiniShop
//
//  Created by Wuquancheng on 13-12-1.
//  Copyright (c) 2013年 mini. All rights reserved.
//

#import "CreditableIndexViewController.h"
#import "MSUISearchBar.h"
#import "ClientAgent+Mini.h"

@interface CreditableIndexViewController ()<MSUISearchBarDelegate>
@property (nonatomic,strong)MSUISearchBar *searchBar;
@property (nonatomic,strong)NSString *key;
@end

@implementation CreditableIndexViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    self.searchBar = [self createSearchBar:self placeHolder:@"搜店"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (MSUISearchBar *)createSearchBar:(id)delegate placeHolder:(NSString *)placeHolder
{
    MSUISearchBar *searchBar = [[MSUISearchBar  alloc] initWithFrame:self.naviTitleView.bounds];
    searchBar.delegate = self;
    searchBar.placeholder = placeHolder;
    [self.naviTitleView addSubview:searchBar];
    return searchBar;
}

- (void)searchBarSearchButtonClicked:(MSUISearchBar *)searchBar
{
    NSString  *key = searchBar.text;
    if ( key.length > 0 )
    {
        [self search:key];
    }
}

- (void)search:(NSString *)key
{
//    [self showWating:nil];
//    __weak typeof (self)pSelf = self;
//    [[ClientAgent sharedInstance] searchshop:key first:self.key userInfo:nil block:^(NSError *error, id data, id userInfo, BOOL cache) {
//        [pSelf dismissWating];
//        if ( error == nil )
//        {
//            pSelf.dataSource = data;
//            [pSelf.tableView reloadData];
//        }
//        else
//        {
//            [pSelf showErrorMessage:error];
//        }
//    }];
}


@end
