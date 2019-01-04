//
//  FPPhotosBrowseDataSource.h
//  判断相片是否存在
//
//  Created by 金医桥 on 2018/12/3.
//  Copyright © 2018 forping. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FPPhotosBrowseDataSourceDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface FPPhotosBrowseDataSource : NSObject<FPPhotosBrowseDataSourceDelegate>

/// 资源对象
@property (nonatomic, copy)NSArray <PHAsset *>*assets;


///进行资源化的Manager
@property (nonatomic, strong, readonly)PHCachingImageManager* imageManager;

@end

NS_ASSUME_NONNULL_END
