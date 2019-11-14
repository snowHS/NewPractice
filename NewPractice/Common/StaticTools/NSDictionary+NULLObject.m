//
//  NSDictionary+NULLObject.m
//  WorkPortal
//
//  Created by liuxl on 14-10-11.
//  Copyright (c) 2014年 深圳四方精创资讯股份有限公司. All rights reserved.
//

#import "NSDictionary+NULLObject.h"

@implementation NSDictionary (NULLObject)

- (id)objectForKeyWithOutNull:(id)aKey
{
    if (!self) {
        return nil;
    }
    if (aKey && [self objectForKey:aKey] && ![[self objectForKey:aKey] isKindOfClass:[NSNull class]])
    {
        if ([[self objectForKey:aKey] isKindOfClass:[NSNumber class]])
        {
            return [NSString stringWithFormat:@"%@",[self objectForKey:aKey]];
        }
        return [self objectForKey:aKey];
    }
    return @"";
}

@end
