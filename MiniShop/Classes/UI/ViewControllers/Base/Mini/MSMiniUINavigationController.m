//
//  MSMiniUINavigationController.m
//  MiniShop
//
//  Created by Wuquancheng on 13-6-20.
//  Copyright (c) 2013年 mini. All rights reserved.
//

#import "MSMiniUINavigationController.h"
#import <QuartzCore/QuartzCore.h>

@interface MSMiniUINavigationController ()
{
    UIImageView *lastScreenShotView;
    UIView *blackMask;
}
@property (nonatomic,retain) UIView *backgroundView;
@property (nonatomic,retain) NSMutableArray *screenShotsList;
@end

@implementation MSMiniUINavigationController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.screenShotsList = [NSMutableArray array];
    }
    return self;
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

//- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
//{
////    UIImage *image = [self capture];
////    [self.screenShotsList addObject:image];
////    if (!self.backgroundView)
////    {
////        CGRect frame = self.view.frame;
////        self.backgroundView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width , frame.size.height)];
////        self.backgroundView.backgroundColor = [UIColor blackColor];
////        blackMask = [[UIView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width , frame.size.height)];
////        blackMask.backgroundColor = [UIColor blackColor];
////        [self.backgroundView addSubview:blackMask];
////    }
////    [self.view.superview insertSubview:self.backgroundView belowSubview:self.view];
////    blackMask.hidden = NO;
////    blackMask.alpha = 0.0;
////    
////    CGRect frame = self.view.frame;
////    frame.origin.x = 400;
////    self.view.frame = frame;
////    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
////    [self.backgroundView insertSubview:imageView belowSubview:blackMask];
//    
//    [super pushViewController:viewController animated:YES];
////    frame.origin.x = 0;
////    [UIView animateWithDuration:0.50 animations:^{
////        self.view.frame = frame;
////        imageView.transform = CGAffineTransformMakeScale(0.95, 0.95);
////        blackMask.alpha = 0.5;
////    } completion:^(BOOL finished) {
////        [imageView removeFromSuperview];
////        
////    }];
//}
//
//// get the current view screen shot
//- (UIImage *)capture
//{
//    UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, self.view.opaque, 0.0);
//    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
//    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    return img;
//}

@end
