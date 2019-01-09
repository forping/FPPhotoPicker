//
//  FPPhotosTool.h
//  判断相片是否存在
//
//  Created by 金医桥 on 2018/12/6.
//  Copyright © 2018 forping. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FPUnility.h"

NS_ASSUME_NONNULL_BEGIN

@interface FPPhotosTool : NSObject

fp_singleH(FPPhotosTool)


// 是否有相册权限
+ (void) hasPhotosAuthorization:(void(^)(BOOL has))block;

// 是否有相机权限
+ (void)hasCameraAuthorization:(void(^)(BOOL has))block;
// 是否有资源
+ (void) systemAlbumHasPtotoWithAssetIdentifier:(NSString *)Identifier has:(void(^)(BOOL has))block;


@end

NS_ASSUME_NONNULL_END
