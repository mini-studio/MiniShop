//
//  LSObject.m
//  xcmg
//
//  Created by Wuquancheng on 12-11-22.
//  Copyright (c) 2012年 mini. All rights reserved.
//

#import "MiniObject.h"
#import "MiniLog.h"

@implementation MiniObject

- (void)convertWithJson:(id)json
{
    if ( json == [NSNull null])
    {
        return;
    }
    for ( NSString *key in [json allKeys] )
    {
        id value = [json valueForKey:key];
        if ( value==[NSNull null] )
        {
            continue;
        }
        if ( [@"errno" isEqualToString:key] )
        {
             [self setValue:value forKey:@"_errno"];
        }
        else if ( [@"id" isEqualToString:key])
        {
            [self setValue:value forKey:@"mid"];
        }
        else
        {
            if ( [value isKindOfClass:[NSArray class]] )
            {
                Class clazz = [self classForAttri:key];
                if ( clazz != nil )
                {
                    NSMutableArray *array = [NSMutableArray array];
                    for ( id v in value )
                    {
                        MSObject *o = (MSObject *)[[clazz alloc] init];
                        [o convertWithJson:v];
                        [array addObject:o];
                    }
                    value = array;
                }
            }
            else if ( [value isKindOfClass:[NSDictionary class]] )
            {
                Class clazz = [self classForAttri:key];
                MSObject *o = (MSObject *)[[clazz alloc] init];
                [o convertWithJson:value];
                value = o;
            }
            [self setValue:value forKey:key];
        }
    }
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    LOG_DEBUG(@"=========%@ undefinedKey==============",key);
}

- (Class)classForAttri:(NSString *)attriName
{
    return nil;
}

@end
