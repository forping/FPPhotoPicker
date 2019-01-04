//
//  FPPhotosBrowseAllDataSource.h
//  判断相片是否存在
//
//  Created by 金医桥 on 2018/12/4.
//  Copyright © 2018 forping. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FPPhotosBrowseDataSourceDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface FPPhotosBrowseAllDataSource : NSObject <FPPhotosBrowseDataSourceDelegate>
///当前预览组的对象
@property (nonatomic, strong)PHAssetCollection *collection;
///当前点击进入的资源对象
@property (nonatomic, strong)PHAsset *asset;
///存储资源的对象
@property (nonatomic, strong, readonly) PHFetchResult<PHAsset *> *assetResult;
///进行资源化的Manager
@property (nonatomic, strong, readonly) PHCachingImageManager* imageManager;

@end

NS_ASSUME_NONNULL_END
