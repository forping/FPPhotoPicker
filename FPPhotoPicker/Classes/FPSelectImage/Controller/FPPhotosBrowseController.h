//
//  FPPhotosBrowseController.h
//  判断相片是否存在
//
//  Created by 金医桥 on 2018/12/3.
//  Copyright © 2018 forping. All rights reserved.
//
// 展示图片的controller

#import <UIKit/UIKit.h>
#import "FPPhotosBrowseDataSourceDelegate.h"
#import "FPPhotosConfig.h"
#import "FPPhotosBottomView.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^FPPhotosHorBrowseWillBack)(void);

@interface FPPhotosBrowseController : UIViewController<UINavigationControllerDelegate>

// 返回的block
@property (nonatomic, copy) FPPhotosHorBrowseWillBack backHandler;

@property (nonatomic , strong) FPPhotosConfig *config;

@property (nonatomic , strong) id<FPPhotosBrowseDataSourceDelegate> dataSource;


#pragma 做动画展示给外部的


// 当前的cell
- (UICollectionViewCell *)currentCollectionCell;
/// 底部的视图
@property (nonatomic, strong) FPPhotosBottomView *bottomView;
/// 展示图片的collectionView
@property (strong, nonatomic) UICollectionView *collectionView;




@end

NS_ASSUME_NONNULL_END
