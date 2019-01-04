//
//  NSArray+FPPhotos.h
//  判断相片是否存在
//
//  Created by 金医桥 on 2018/12/7.
//  Copyright © 2018 forping. All rights reserved.
//

#import <Foundation/Foundation.h>
@class PHAssetCollection;

NS_ASSUME_NONNULL_BEGIN

@interface NSArray (FPPhotos)
- (NSArray<PHAssetCollection *> *)sortRegularAblumsWithUserLibraryFirst;
@end

NS_ASSUME_NONNULL_END
