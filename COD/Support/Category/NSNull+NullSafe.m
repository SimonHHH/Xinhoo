//
//  NSNull+NullSafe.m
//  SmarterStore
//
//  Created by Simon_HHH on 2017/9/18.
//  Copyright © 2017年 Simon. All rights reserved.
//

#import "NSNull+NullSafe.h"
#import <objc/runtime.h>
#import <Foundation/Foundation.h>


//#pragma GCC diagnostic ignored "-Wgnu-conditional-omitted-operand"

@implementation NSNull (NullSafe)

#if NULLSAFE_ENABLED

- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector
{
    @synchronized([self class])
    {
        // 查找方法签名
        NSMethodSignature *signature = [super methodSignatureForSelector:selector];
        if (!signature)
        {
            // 不支持Null，搜索其他类
            static NSMutableSet *classList = nil;
            static NSMutableDictionary *signatureCache = nil;
            if (signatureCache == nil)
            {
                classList = [[NSMutableSet alloc] init];
                signatureCache = [[NSMutableDictionary alloc] init];
                
                // 获取已注册的类定义的列表
                int numClasses = objc_getClassList(NULL, 0);
                Class *classes = (Class *)malloc(sizeof(Class) * (unsigned long)numClasses);
                numClasses = objc_getClassList(classes, numClasses);
                
                // 添加到检查列表中
                NSMutableSet *excluded = [NSMutableSet set];
                for (int i = 0; i < numClasses; i++)
                {
                    //检查类是否有父类
                    Class someClass = classes[i];
                    Class superclass = class_getSuperclass(someClass);
                    while (superclass)
                    {
                        if (superclass == [NSObject class])
                        {
                            [classList addObject:someClass];
                            break;
                        }
                        [excluded addObject:NSStringFromClass(superclass)];
                        superclass = class_getSuperclass(superclass);
                    }
                }
                
                // 删除所有具有子类的类
                for (Class someClass in excluded)
                {
                    [classList removeObject:someClass];
                }
                
                // 释放类列表
                free(classes);
            }
            
            // 先检查缓存执行
            NSString *selectorString = NSStringFromSelector(selector);
            signature = signatureCache[selectorString];
            if (!signature)
            {
                // 查找执行
                for (Class someClass in classList)
                {
                    if ([someClass instancesRespondToSelector:selector])
                    {
                        signature = [someClass instanceMethodSignatureForSelector:selector];
                        break;
                    }
                }
                
                // 下一步缓存
                signatureCache[selectorString] = signature ?: [NSNull null];
            }
            else if ([signature isKindOfClass:[NSNull class]])
            {
                signature = nil;
            }
        }
        return signature;
    }
}

- (void)forwardInvocation:(NSInvocation *)invocation
{
    invocation.target = nil;
    [invocation invoke];
}

#endif

@end
