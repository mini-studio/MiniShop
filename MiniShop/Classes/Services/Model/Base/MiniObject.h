//
//  LSObject.h
//  xcmg
//
//  Created by Wuquancheng on 12-11-22.
//  Copyright (c) 2012年 mini. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MiniObject : NSObject
- (void)convertWithJson:(id)json;

- (Class)classForAttri:(NSString *)attriName;
@end
