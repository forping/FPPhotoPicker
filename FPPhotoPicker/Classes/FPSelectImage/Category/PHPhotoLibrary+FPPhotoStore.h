//
//  PHPhotoLibrary+FPPhotoStore.h
//  判断相片是否存在
//
//  Created by 金医桥 on 2018/12/7.
//  Copyright © 2018 forping. All rights reserved.
//

#import <Photos/Photos.h>

NS_ASSUME_NONNULL_BEGIN

@interface PHPhotoLibrary (FPPhotoStore)

// PHFetchResult 转成NSArray
- (void)fetchAlbumRegularGroups:(void(^)(NSArray <PHAssetCollection *> *))complete;
/// 获取的将'胶卷相册'放在第一位
- (void)fetchAlbumRegularGroupsByUserLibrary:(void(^)(NSArray <PHAssetCollection *> *))complete;



#pragma mark - 用于替代废除数组作为数据源的方法
/// 获取photos提供的所有的分类智能相册组和相关相册组
- (void)fetchAblumRegularAndTopLevelUserResults:(void(^)(PHFetchResult<PHAssetCollection *>* regular,
                                                         PHFetchResult<PHCollection *>* topUser))complete;






@end

NS_ASSUME_NONNULL_END
