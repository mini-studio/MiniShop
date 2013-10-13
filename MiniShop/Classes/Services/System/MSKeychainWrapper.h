//
//  KeychainWrapper.h
//  MiniShop
//
//  Created by Wuquancheng on 13-10-13.
//  Copyright (c) 2013年 mini. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MSKeychainWrapper : NSObject

@property (nonatomic, strong) NSMutableDictionary *keychainData;
@property (nonatomic, strong) NSMutableDictionary *genericPasswordQuery;

- (void)setObject:(id)inObject forKey:(id)key;
- (id)objectForKey:(id)key;
- (void)resetKeychainItem;

@end
