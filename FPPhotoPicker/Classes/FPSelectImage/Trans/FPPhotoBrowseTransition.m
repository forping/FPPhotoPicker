//
//  FPPhotoBrowseTransition.m
//  判断相片是否存在
//
//  Created by 金医桥 on 2018/12/12.
//  Copyright © 2018 forping. All rights reserved.
//

#import "FPPhotoBrowseTransition.h"

@implementation FPPhotoBrowseTransition

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext{
    
    NSLog(@"transitionDuration");
    return 0.3;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext{
    NSLog(@"animateTransition");
}

@end
