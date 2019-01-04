//
//  FPPhotosViewController.h
//  判断相片是否存在
//
//  Created by 金医桥 on 2018/12/3.
//  Copyright © 2018 forping. All rights reserved.
//
// 导航控制器
#import <UIKit/UIKit.h>
#import "FPPhotosConfig.h"
#import "FPPhotoViewControllerDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface FPPhotosViewController : UINavigationController

// 默认的配置
@property (nonatomic , strong, readonly) FPPhotosConfig *config;

// 代理
@property (nonatomic , weak) id<FPPhotosViewControllerDelegate> photoDelegate;


#pragma mark - 记录当前选择过的图片

/// 默认选中的标
@property (nonatomic, copy)NSArray <NSString *> *defaultIdentifers;

@end

NS_ASSUME_NONNULL_END
