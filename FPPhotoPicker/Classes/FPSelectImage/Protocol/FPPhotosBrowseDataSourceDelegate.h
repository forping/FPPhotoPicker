//
//  FPPhotosBrowseDataSourceDelegate.h
//  判断相片是否存在
//
//  Created by 金医桥 on 2018/12/3.
//  Copyright © 2018 forping. All rights reserved.
//

#ifndef FPPhotosBrowseDataSourceDelegate_h
#define FPPhotosBrowseDataSourceDelegate_h

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

@protocol FPPhotosBrowseDataSourceDelegate <UICollectionViewDataSource>

/// 请求图片的对象
@property (nonatomic, strong, readonly) PHCachingImageManager* imageManager;
/// 当前位置的资源对象
- (PHAsset *)assetAtIndexPath:(NSIndexPath *)indexPath;

@optional

/// 默认的第一次进入显示的item
- (NSIndexPath *)defaultItemIndexPath;

@end
#endif /* FPPhotosBrowseDataSourceDelegate_h */
