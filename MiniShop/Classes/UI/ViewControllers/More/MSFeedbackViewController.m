//
//  MSFeedbackViewController.m
//  MiniShop
//
//  Created by Wuquancheng on 13-3-28.
//  Copyright (c) 2013年 mini. All rights reserved.
//

#import "MSFeedbackViewController.h"
#import "MiniUITextView.h"
#import "UITableViewCell+GroupBackGround.h"
#import "MiniUIAlertView.h"
#define KCONTENT_TEXTCTL_TAG 3000

@interface MSFeedbackViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic,strong)UITableView *tableView;
@property (nonatomic,strong)MiniUITextView *textView;
@property (nonatomic,strong)UITextField *textField;
@end

@implementation MSFeedbackViewController

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    [self.view addSubview:self.tableView];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = self.view.backgroundColor;
    self.tableView.backgroundView = nil;
    self.tableView.separatorColor = [UIColor lightGrayColor];
    self.navigationItem.title = @"留言吐槽";

    self.textView = [[MiniUITextView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 100)];
    self.textView.backgroundColor = [UIColor clearColor];
    self.textView.placeholder = @"请输入您想说的话";
    self.textView.tag = KCONTENT_TEXTCTL_TAG;
    self.textView.font = [UIFont systemFontOfSize:14];
    self.textView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    self.textField = [[UITextField alloc] initWithFrame:CGRectMake(4,0, self.view.width-36, 40)];
    self.textField.placeholder = @" 您的QQ号或微博账号";
    self.textField.font = [UIFont systemFontOfSize:14];
    self.textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter ;
    self.textField.tag = KCONTENT_TEXTCTL_TAG;
    self.textView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
	[self setNaviBackButton];
    [self setNaviRightButtonTitle:@"发送" target:self action:@selector(actionForSend)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ( indexPath.section == 0 )
    {
        return 100;
    }
    else
    {
        return 40;
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (  cell == nil )
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    [[cell viewWithTag:KCONTENT_TEXTCTL_TAG] removeFromSuperview];
    if ( indexPath.section == 0 )
    {
        [cell.contentView addSubview:self.textView];
    }
    else
    {
        [cell.contentView addSubview:self.textField];
    }
    [cell setCellTheme:tableView indexPath:indexPath backgroundCorlor:[UIColor whiteColor] highlightedBackgroundCorlor:[UIColor whiteColor] sectionRowNumbers:1];
    return cell;
}

- (void)actionForSend
{
    NSString *text = [self.textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ( text.length > 0 )
    {
        [self showWating:nil];
        [self.view endEditing:YES];
        [[ClientAgent sharedInstance] feedback:self.textView.text block:^(NSError *error, MSObject* data, id userInfo, BOOL cache) {
            [self dismissWating];
            if ( error == nil )
            {
                [self showMessageInfo:@"提交成功，感谢您的反馈！" delay:2];
            }
            else
            {
                [self showErrorMessage:error];
            }
        }];
    }
    else
    {
        [MiniUIAlertView showAlertTipWithTitle:@"提示" message:@"说点什么吧，您的反馈对我们很重要" block:^(MiniUIAlertView *alertView, NSInteger buttonIndex) {
            
        }];
    }
}

@end
