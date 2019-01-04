//
//  FPPhotosPreviewController.h
//  判断相片是否存在
//
//  Created by 金医桥 on 2018/12/4.
//  Copyright © 2018 forping. All rights reserved.
//
//
// 响应3dtouch
#import <UIKit/UIKit.h>


NS_ASSUME_NONNULL_BEGIN
@class PHAsset;
@interface FPPhotosPreviewController : UIViewController


/// 资源大小
@property (nonatomic, readonly, assign) CGSize assetSize;
/// 当前显示的Image
@property (nonatomic, readonly, strong) PHAsset * showAsset;

/// 便利初始化方法
-(instancetype)initWithShowAsset:(PHAsset *)showAsset;
/// 便利构造器
+(instancetype)previewWithShowAsset:(PHAsset *)showAsset;


@end

NS_ASSUME_NONNULL_END
