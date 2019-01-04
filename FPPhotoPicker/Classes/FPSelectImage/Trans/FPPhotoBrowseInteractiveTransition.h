//
//  FPPhotoBrowseInteractiveTransition.h
//  判断相片是否存在
//
//  Created by 金医桥 on 2018/12/12.
//  Copyright © 2018 forping. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FPPhotoBrowseInteractiveTransition : UIPercentDrivenInteractiveTransition

// 是否正在响应事件
@property (nonatomic, assign) BOOL interation;
- (instancetype)initWithController:(UIViewController *)viewController;


@end

NS_ASSUME_NONNULL_END
