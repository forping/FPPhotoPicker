//
//  FPSelectImageController.h
//  判断相片是否存在
//
//  Created by 金医桥 on 2018/12/3.
//  Copyright © 2018 forping. All rights reserved.
//
// 选择照片控制器
#import <UIKit/UIKit.h>
#import "FPPhotosConfig.h"
#import "FPPhotosCell.h"
#import <Photos/Photos.h>
#import "FPPhotosBottomView.h"

NS_ASSUME_NONNULL_BEGIN

@interface FPPhotosSelectController : UIViewController

@property (nonatomic , strong) FPPhotosConfig *config;

/// `PHCollection`的`localIdentifier`   标识相册
@property (nonatomic, copy) NSString *localIdentifier;


#pragma 做动画展示给外部的

@property (nonatomic , strong) FPPhotosBottomView *bottomView;

// 当前预览的资源对应的cell
- (FPPhotosCell *)currentBrowseCellWithAsset:(PHAsset *)asset scrollTo:(BOOL)scroll;

@end

NS_ASSUME_NONNULL_END
