//
//  NSMutableArray+WLSafe.m
//  cook
//
//  Created by yuyu on 2018/7/25.
//  Copyright © 2018年 fanlai. All rights reserved.
//

#import "NSMutableArray+WLSafe.h"
#import <objc/runtime.h>
#import "NSObject+Swizzling.h"
@implementation NSMutableArray (WLSafe)

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
    //1、提示移除的数据不能为空
    [self swizzleSelector:@selector(removeObject:)
     withSwizzledSelector:@selector(wl_safeRemoveObject:)];

    //2、提示数组不能添加为nil的数据
    [objc_getClass("__NSArrayM") swizzleSelector:@selector(addObject:)
                            withSwizzledSelector:@selector(wl_safeAddObject:)];
    //3、移除数据越界
    [objc_getClass("__NSArrayM") swizzleSelector:@selector(removeObjectAtIndex:)
                            withSwizzledSelector:@selector(wl_safeRemoveObjectAtIndex:)];
    //4、插入数据越界
    [objc_getClass("__NSArrayM") swizzleSelector:@selector(insertObject:atIndex:)
                            withSwizzledSelector:@selector(wl_insertObject:atIndex:)];

    //5、处理[arr objectAtIndex:1000]这样的越界
    [objc_getClass("__NSArrayM") swizzleSelector:@selector(objectAtIndex:) withSwizzledSelector:@selector(wl_objectAtIndex:)];

    //6、处理arr[1000]这样的越界
    [objc_getClass("__NSArrayM") swizzleSelector:@selector(objectAtIndexedSubscript:) withSwizzledSelector:@selector(safeobjectAtIndexedSubscript:)];


    
}

- (instancetype)wl_initWithObjects:(const id  _Nonnull __unsafe_unretained *)objects count:(NSUInteger)cnt {
    BOOL hasNilObject = NO;
    for (NSUInteger i = 0; i < cnt; i++) {
        if ([objects[i] isKindOfClass:[NSArray class]]) {
            NSLog(@"%@", objects[i]);
        }
        if (objects[i] == nil) {
            hasNilObject = YES;
            NSLog(@"%s object at index %lu is nil, it will be filtered", __FUNCTION__, i);
        }
    }
    
    // 因为有值为nil的元素，那么我们可以过滤掉值为nil的元素
    if (hasNilObject) {
        id __unsafe_unretained newObjects[cnt];
        
        NSUInteger index = 0;
        for (NSUInteger i = 0; i < cnt; ++i) {
            if (objects[i] != nil) {
                newObjects[index++] = objects[i];
            }
        }
        
        NSLog(@"%@", [NSThread callStackSymbols]);
        return [self wl_initWithObjects:newObjects count:index];
    }
    
    return [self wl_initWithObjects:objects count:cnt];
}


- (void)wl_safeAddObject:(id)obj {
    if (obj == nil) {
        NSLog(@"%s can add nil object into NSMutableArray", __FUNCTION__);
    } else {
        [self wl_safeAddObject:obj];
    }
}

- (void)wl_safeRemoveObject:(id)obj {
    if (obj == nil) {
        NSLog(@"%s call -removeObject:, but argument obj is nil", __FUNCTION__);
        return;
    }
    
    [self wl_safeRemoveObject:obj];
}

- (void)wl_insertObject:(id)anObject atIndex:(NSUInteger)index {
    if (anObject == nil) {
        NSLog(@"%s can't insert nil into NSMutableArray", __FUNCTION__);
    } else if (index > self.count) {
        NSLog(@"%s index is invalid", __FUNCTION__);
    } else {
        [self wl_insertObject:anObject atIndex:index];
    }
}

- (id)wl_objectAtIndex:(NSUInteger)index {
    if (self.count == 0) {
        NSLog(@"%s can't get any object from an empty array", __FUNCTION__);
        return nil;
    }
    
    if (index > self.count) {
        NSLog(@"%s index out of bounds in array", __FUNCTION__);
        return nil;
    }
    
    return [self wl_objectAtIndex:index];
}

- (void)wl_safeRemoveObjectAtIndex:(NSUInteger)index {
    if (self.count <= 0) {
        NSLog(@"%s can't get any object from an empty array", __FUNCTION__);
        return;
    }
    
    if (index >= self.count) {
        NSLog(@"%s index out of bound", __FUNCTION__);
        return;
    }
    
    [self wl_safeRemoveObjectAtIndex:index];
}

// 1、索引越界 2、移除索引越界 3、替换索引越界
- (instancetype)safeobjectAtIndexedSubscript:(NSUInteger)index{
    
    if (index > (self.count - 1)) { // 数组越界
        NSLog(@"索引越界");
        return nil;
    }else { // 没有越界
        return [self safeobjectAtIndexedSubscript:index];
    }
    
}


@end
