//
//  NSObject+Swizzling.h
//  cook
//
//  Created by yuyu on 2018/7/25.
//  Copyright © 2018年 fanlai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (Swizzling)

+ (void)swizzleSelector:(SEL)originalSelector withSwizzledSelector:(SEL)swizzledSelector;

@end
