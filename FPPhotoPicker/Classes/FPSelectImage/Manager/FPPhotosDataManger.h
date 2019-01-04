//
//  FPPhotosDataManger.h
//  判断相片是否存在
//
//  Created by 金医桥 on 2018/12/3.
//  Copyright © 2018 forping. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class PHAsset;
@interface FPPhotosDataManger : NSObject

/// 是否为高质量，可以使用KVO:NSKeyValueObservingOptionNew
@property (nonatomic, assign, getter=isHightQuality)BOOL hightQuality;

/// 选中资源的标志位
@property (nonatomic, strong, readonly) NSMutableArray <PHAsset *> *phassets;
@property (nonatomic, strong, readonly) NSMutableArray <NSString *> *phassetsIds;


/// 选中的资源个数，可以用于KVO:NSKeyValueObservingOptionNew
@property (nonatomic, assign, readonly) NSInteger count;

/// 默认选中的标志位,用来二次进入默认选中的标志位
@property (nonatomic, copy)NSArray <NSString *> *defaultIdentifers;

/// 可自动销毁的单例对象
+ (instancetype)sharedInstance;

/// action
- (void)addPHAsset:(PHAsset *)asset;
- (void)removePHAsset:(PHAsset *)asset;
- (void)removePHAssetAtIndex:(NSUInteger)index;
- (void)removeAllPHAssets;
- (void)exchangePHAssetAtIndex:(NSUInteger)idx1 withPHAssetAtIndex:(NSUInteger)idx2;


/**
 * 进行自动添加或者删除的操作
 * 如果不存在该资源，追加，并返回当前所在的个数(索引+1)
 * 如果存在该资源，删除，并返回-1
 */
- (nullable NSNumber *)addOrRemoveAsset:(PHAsset *)asset;

/// 是否已经选择了asset
- (BOOL)containAsset:(PHAsset *)asset;

@end

NS_ASSUME_NONNULL_END
