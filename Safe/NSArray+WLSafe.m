//
//  NSArray+WLSafe.m
//  cook
//
//  Created by yuyu on 2018/7/25.
//  Copyright © 2018年 fanlai. All rights reserved.
//

#import "NSArray+WLSafe.h"
#import <objc/runtime.h>
#import "NSObject+Swizzling.h"
@implementation NSArray (WLSafe)

- (id)objectForKey:(id)key{
#ifdef DEBUG
    NSAssert(NO, @"NSArray should not call objectForKey, you should check your code!");
    return nil;
#else
    return nil;
#endif
}

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
#ifndef DEBUG
        [self exchangeImplementation];
#else
        [self exchangeImplementation];
#endif
    });
}
+ (void)exchangeImplementation{
    //越界崩溃方式一：[array objectAtIndex:1000];
    [objc_getClass("__NSArrayI") swizzleSelector:@selector(objectAtIndex:) withSwizzledSelector:@selector(safeObjectAtIndex:)];
    
    //越界崩溃方式二：arr[1000];   Subscript n:下标、脚注
    [objc_getClass("__NSArrayI") swizzleSelector:@selector(objectAtIndexedSubscript:) withSwizzledSelector:@selector(safeobjectAtIndexedSubscript:)];
}

- (instancetype)safeObjectAtIndex:(NSUInteger)index {
    // 数组越界也不会崩，但是开发的时候并不知道数组越界
    if (index > (self.count - 1)) { // 数组越界
        return nil;
    }else { // 没有越界
        return [self safeObjectAtIndex:index];
    }
}

- (instancetype)safeobjectAtIndexedSubscript:(NSUInteger)index{
    
    if (index > (self.count - 1)) { // 数组越界
        return nil;
    }else { // 没有越界
        return [self safeobjectAtIndexedSubscript:index];
    }
    
}






@end
