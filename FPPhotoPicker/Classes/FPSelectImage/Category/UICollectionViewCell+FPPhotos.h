//
//  UICollectionViewCell+FPPhotos.h
//  判断相片是否存在
//
//  Created by 金医桥 on 2018/12/6.
//  Copyright © 2018 forping. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

NS_ASSUME_NONNULL_BEGIN

@interface UICollectionViewCell (FPPhotos)

@property (nonatomic, weak, nullable)PHAsset *currentAsset;
@property (nonatomic, copy) NSString *representedAssetIdentifier;



// 以下方法由具体类实现, 这里扩充,只是方便collectionDatasource能通过UICollectionViewCell的方法调用到
/// 更新数据
- (void)updateAssets:(PHAsset *)asset atIndexPath:(NSIndexPath *)indexPath imageManager:(PHCachingImageManager *)cacheManager;

/// 用于普通图片，恢复缩放 ,视频,停止播放
- (void)reset;

@end

NS_ASSUME_NONNULL_END
