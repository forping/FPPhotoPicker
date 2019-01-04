//
//  FPPhotosMaker.h
//  判断相片是否存在
//
//  Created by 金医桥 on 2018/12/5.
//  Copyright © 2018 forping. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "FPPhotoViewControllerDelegate.h"
#import "FPPhotosConfig.h"

NS_ASSUME_NONNULL_BEGIN

typedef dispatch_block_t FPCompleteReaderHandle;


@interface FPPhotosMaker : NSObject

/// 绑定的viewController
@property (nonatomic, weak, nullable) UIViewController *bindViewController;
/// 真正的代理对象
@property (nonatomic, weak, nullable)id<FPPhotosViewControllerDelegate>delegate;


@property (nonatomic , strong) FPPhotosConfig *configuration;




/// 局部单例对象
+ (instancetype)sharedInstance;
/// 开始生成图片，并开始触发各种回调
- (void)startMakePhotosComplete:(nullable FPCompleteReaderHandle)complete;


@end

NS_ASSUME_NONNULL_END
