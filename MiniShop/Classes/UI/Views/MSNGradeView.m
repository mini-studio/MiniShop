//
//  MSNGradeView.m
//  MiniShop
//
//  信誉等级视图
//
//  Created by Wuquancheng on 14-2-1.
//  Copyright (c) 2014年 mini. All rights reserved.
//

#import "MSNGradeView.h"

@implementation MSNGradeView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setGrade:(NSInteger)grade shopType:(NSString*)shopType
{
    [self removeAllSubviews];
    if ([@"C" isEqualToString:shopType]) {
        //淘宝商家
        int numbers = grade%10;
        int level = grade/10; /*1心 2钻 3冠 4皇冠*/
        NSString *imageName = level==1?@"hear":(level==2?@"diamond":(level==3?@"crown_silver":@"crown_gold"));
        for (int index=0; index<numbers; index++) {
            UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
            imageView.frame = CGRectMake(index*(self.height+4), 0, (self.height+1), self.height);
            [self addSubview:imageView];
        }
    }
    else {
        //天猫商家
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tianm"]];
        imageView.frame = CGRectMake(0, 0, 2*self.height,self.height);
        [self addSubview:imageView];
    }
}

@end
