//
//  NSString+WLSafe.m
//  cook
//
//  Created by yuyu on 2018/7/25.
//  Copyright © 2018年 fanlai. All rights reserved.
//

#import "NSString+WLSafe.h"

@implementation NSString (WLSafe)

- (NSUInteger)count{
#ifdef DEBUG
    NSAssert(NO, @"NSString should not call count, you should check your code!");
    return 0;
#else
    return 0;
#endif
}

- (id)objectForKey:(id)key{
#ifdef DEBUG
    NSAssert(NO, @"NSString should not call objectForKey, you should check your code!");
    return nil;
#else
    return nil;
#endif
}

@end
