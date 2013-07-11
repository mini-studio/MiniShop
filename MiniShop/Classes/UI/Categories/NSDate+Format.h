//
//  NSDate+Format.h
//  MiniShop
//
//  Created by Wuquancheng on 13-6-2.
//  Copyright (c) 2013年 mini. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (Format)
+ (NSDate *)dateFromString:(NSString *)string format:(NSString *)format;
@end
