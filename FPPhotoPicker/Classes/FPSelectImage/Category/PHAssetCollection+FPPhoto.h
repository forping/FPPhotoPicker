//
//  PHAssetCollection+FPPhoto.h
//  判断相片是否存在
//
//  Created by 金医桥 on 2018/12/7.
//  Copyright © 2018 forping. All rights reserved.
//

#import <Photos/Photos.h>

NS_ASSUME_NONNULL_BEGIN

@interface PHAssetCollection (FPPhoto)
/// 获取PHAssetCollection的详细信息
- (void)fp_headerImageWithSize:(CGSize)size
                          mode:(PHImageRequestOptionsDeliveryMode)mode
                      complete:(void (^)(NSString * title,NSUInteger count,UIImage * __nullable image)) completeBlock;


/**
 获取PHAssetCollection的详细信息
 
 @param size 获得封面图片的大小
 @param completeBlock 取组的标题、照片资源的预估个数以及封面照片,默认为最新的一张
 */
- (void)fp_headerImageWithSize:(CGSize)size
                      complete:(void (^)(NSString * title,NSUInteger count,UIImage * __nullable image)) completeBlock;



@end

NS_ASSUME_NONNULL_END
