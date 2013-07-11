//
//  UITableViewCell+GroupBackGround.h
//  MiniShop
//
//  Created by Wuquancheng on 13-3-28.
//  Copyright (c) 2013年 mini. All rights reserved.
//

#import <UIKit/UIKit.h>

enum {
    EFirstCell,
    EMiddleCell,
    ELastCell,
    ESingleCell
};

typedef int TableViewCellLocation;

@interface MiniUITableGroupCellBackgroudView : UIView
@property (nonatomic)TableViewCellLocation loc;
@property (nonatomic,strong)UIColor *borderColor;

@end


@interface UITableViewCell (GroupBackGround)
- (void)setCellTheme:(UITableView*)tableView indexPath:(NSIndexPath *)indexPath backgroundCorlor:(UIColor *)backgroundCorlor highlightedBackgroundCorlor:(UIColor *)highlightedBackgroundCorlor sectionRowNumbers:(NSInteger)sectionRowNumbers;

- (void)setCellTheme:(UITableView*)tableView indexPath:(NSIndexPath *)indexPath background:(UIImage *)background highlightedBackground:(UIImage *)highlightedBackground sectionRowNumbers:(NSInteger)sectionRowNumbers;

@end
