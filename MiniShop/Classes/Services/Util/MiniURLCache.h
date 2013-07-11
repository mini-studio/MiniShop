//
//  MiniURLCache.h
//  Buke
//
//  Created by Wuquancheng on 13-1-19.
//  Copyright (c) 2013年 mini. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MiniURLCache : NSURLCache
+ (MiniURLCache *)sharedCache;
@end
