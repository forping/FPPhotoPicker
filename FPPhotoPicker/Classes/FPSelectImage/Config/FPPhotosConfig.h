//
//  FPSelectImageConfig.h
//  判断相片是否存在
//
//  Created by 金医桥 on 2018/12/3.
//  Copyright © 2018 forping. All rights reserved.
//
// 关于照片显示的一些基本属性

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FPPhotosConfig : NSObject

@property (nonatomic , assign) NSInteger maxPhotosCount; // 最大的图片数  默认 9
@property (nonatomic , assign) BOOL containVideo; // 是否包含视频  默认YES
@property (nonatomic, assign)BOOL hiddenGroupWhenNoPhotos; // 隐藏没有图片的分组, 默认YES

/**
 非原图的图片大小
 */
@property (nonatomic, assign)CGSize thumbnailSize;


// self.max(4);
// 链式编程
- (FPPhotosConfig * (^)(NSInteger maxPhotosCount)) setMaxPhotosCount;
- (FPPhotosConfig * (^)(BOOL containVideo)) setContainVideo;
- (FPPhotosConfig * (^)(BOOL hiddenGroupWhenNoPhotos)) setHiddenGroupWhenNoPhotos;

- (FPPhotosConfig * (^)(CGSize thumbnailSize)) setThumbnailSize;







@end

NS_ASSUME_NONNULL_END
