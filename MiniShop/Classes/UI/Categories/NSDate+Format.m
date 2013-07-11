//
//  NSDate+Format.m
//  MiniShop
//
//  Created by Wuquancheng on 13-6-2.
//  Copyright (c) 2013年 mini. All rights reserved.
//

#import "NSDate+Format.h"

@implementation NSDate (Format)
+ (NSDate *)dateFromString:(NSString *)string format:(NSString *)format
{
    NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
	[inputFormatter setDateFormat:format];
	NSDate *date = [inputFormatter dateFromString:string];
	return date;
}
@end
