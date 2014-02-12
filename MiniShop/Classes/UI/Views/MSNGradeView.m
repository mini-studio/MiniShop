//
//  MSNGradeView.m
//  MiniShop
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

- (void)setGrade:(NSInteger)grade
{
    int numbers = grade%10;
    int level = grade/10; /*1心 2钻 3冠 4皇冠*/
    for (int index=0; index<numbers; index++) {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"heart"]];
        imageView.frame = CGRectMake(index*(self.height+4), 0, (self.height+1), self.height);
        [self addSubview:imageView];
    }
}

@end
