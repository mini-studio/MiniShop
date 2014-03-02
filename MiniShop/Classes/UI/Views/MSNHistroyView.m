//
//  MSNHistroyView.m
//  MiniShop
//
//  Created by Wuquancheng on 14-3-2.
//  Copyright (c) 2014年 mini. All rights reserved.
//

#import "MSNHistroyView.h"

@interface MSNHistroyView() <UITableViewDelegate,UITableViewDataSource>
@property(nonatomic,strong)UITableView *tableView;
@end

@implementation MSNHistroyView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.tableView = [[UITableView alloc] initWithFrame:self.bounds];
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        [self addSubview:self.tableView];
    }
    return self;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.historyItems.count>0) {
        return 1+self.hotItems.count;
    }
    else {
        return self.hotItems.count;
    }
}

- (NSString*)titleFor:(NSIndexPath *)indexPath
{
    if (self.historyItems.count>0 && indexPath.section==0) {
        return [self.historyItems objectAtIndex:indexPath.row];
    }
    else {
        int section = indexPath.section;
        if (self.historyItems.count>0) {
            section = section-1;
        }
        NSDictionary *dic = (NSDictionary *)[self.hotItems objectAtIndex:section];
        return [dic.allValues objectAtIndex:indexPath.row];
    }
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (self.historyItems.count>0 && section==0) {
        return @"搜索历史";
    }
    else {
        if (self.historyItems.count>0) {
            section = section-1;
        }
        NSDictionary *dic = (NSDictionary *)[self.hotItems objectAtIndex:section];
        return [[dic allKeys] objectAtIndex:0];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 30;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.historyItems.count>0 && section==0) {
        return self.historyItems.count;
    }
    else {
        if (self.historyItems.count>0) {
            section = section-1;
        }
        NSDictionary *dic = (NSDictionary *)[self.hotItems objectAtIndex:section];
        return [dic allValues].count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell==nil) {
        cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.textLabel.font = [UIFont systemFontOfSize:16];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.textLabel.text = [self titleFor:indexPath];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.historyItems.count>0 && indexPath.section==0) {
        if (self.onSelected) {
            self.onSelected([self.historyItems objectAtIndex:indexPath.row]);
        }
    }
}

- (void)reload
{
    [self.tableView reloadData];
}

@end
