//
//  MSGalleryView.h
//  MiniShop
//
//  Created by Wuquancheng on 13-6-2.
//  Copyright (c) 2013年 mini. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MSGalleryView : UIView
@property (nonatomic,strong) NSString *title;
@property (nonatomic,strong) void (^handleTap)(id userInfo);
- (void)clear;

- (void)setData:(NSArray *)info addr:(NSString *(^)(int index, bool isBig))addr price:(NSString*(^)(int index))price userInfo:(id (^)(int index))userinfo;
+ (CGFloat)heightWithImageCount:(NSInteger)count hasTitle:(BOOL)hasTitle;
@end
