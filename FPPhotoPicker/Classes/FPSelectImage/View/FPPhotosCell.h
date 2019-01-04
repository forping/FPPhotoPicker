//
//  YPPhotosCell.h
//  FPPhotoDemo
//
//  Created by YueWen on 16/7/14.
//  Copyright © 2017年 YueWen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PHAsset;
@class FPPhotosCell;

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger,FPPhotosCellAnimatedStatus){
    
    FPPhotosCellAnimatedStatusPermit//允许使用动画
};

typedef void(^FPPhotosCellStatusAction)(FPPhotosCellAnimatedStatus,BOOL,NSUInteger);

@protocol FPPhotosCellActionTarget <NSObject>

@optional
/**
 上方的响应按钮被点击
 
 action必须调用
 */
- (void)photosCellDidTouchUpInSlide:(FPPhotosCell *)cell
                              asset:(PHAsset *)asset
                          indexPath:(NSIndexPath *)indexPath
                           complete:(FPPhotosCellStatusAction)animated;

@end


@interface FPPhotosCell : UICollectionViewCell

/// delegate
@property (nonatomic, weak, nullable)id <FPPhotosCellActionTarget> actionTarget;
/// 显示照片的视图
@property (strong, nonatomic) UIImageView *imageView;

/// 显示索引的标签
@property (strong, nonatomic) UILabel *indexLabel;


/// 展示视频出现的信息搭载视图，默认为隐藏
@property (strong, nonatomic) UIView *messageView;
/// 展示视频时的录像小图标
@property (strong, nonatomic) UIImageView *messageImageView;
/// 展示视频时长的小标签
@property (strong, nonatomic) UILabel *messageLabel;


/// 支持iOS9.1之后的livePhoto
@property (nonatomic, strong) UIImageView *liveBadgeImageView;



/// 负责显示选中的按钮
@property (strong, nonatomic) UIButton *chooseButton;


/// 不能点击进行的遮罩层
@property (nonatomic, strong, readonly)UIView *shadeView;



@property (nonatomic , copy) NSString *representedAssetIdentifier;


@property (nonatomic, weak, nullable) PHAsset *asset;
// 记录当前的indexPath
@property (nonatomic, strong, nullable) NSIndexPath *indexPath;








@end


NS_ASSUME_NONNULL_END
