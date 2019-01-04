//
//  FPPhotosDataManger.m
//  判断相片是否存在
//
//  Created by 金医桥 on 2018/12/3.
//  Copyright © 2018 forping. All rights reserved.
//

#import "FPPhotosDataManger.h"

#import <Photos/Photos.h>
#import "PHFetchResult+FPPhotos.h"

@interface FPPhotosDataManger()

/// 选择资源的数组
@property (nonatomic, strong, readwrite) NSMutableArray <PHAsset *> *phassets;
@property (nonatomic, strong, readwrite) NSMutableArray <NSString *> *phassetsIds;
@property (nonatomic, assign, readwrite) NSInteger count;

@end

@implementation FPPhotosDataManger

- (instancetype)init{
    if (self = [super init]) {
    
        self.phassets = [NSMutableArray array];
        
        self.phassetsIds = [NSMutableArray array];
        
        self.count = 0;
    }
    return self;
}

+ (instancetype)sharedInstance{
    
    static __weak FPPhotosDataManger *instance;
    FPPhotosDataManger *strongInstance = instance;
    @synchronized (self) {
        if (strongInstance == nil) {
            strongInstance = [[self alloc] init];
            instance = strongInstance;
        }
    }
    return strongInstance;
}



/// action
- (void)addPHAsset:(PHAsset *)asset{
    [self.phassets addObject:asset];
    [self.phassetsIds addObject:asset.localIdentifier];
    
    self.count = self.phassetsIds.count;
}
- (void)removePHAsset:(PHAsset *)asset{
    [self.phassets removeObject:asset];
    [self.phassetsIds removeObject:asset.localIdentifier];
    self.count = self.phassetsIds.count;
}
- (void)removePHAssetAtIndex:(NSUInteger)index{
    [self.phassets removeObjectAtIndex:index];
    [self.phassetsIds removeObjectAtIndex:index];
    self.count = self.phassetsIds.count;
}
- (void)removeAllPHAssets{
    [self.phassets removeAllObjects];
    [self.phassetsIds removeAllObjects];
    self.count = self.phassetsIds.count;
}
- (void)exchangePHAssetAtIndex:(NSUInteger)idx1 withPHAssetAtIndex:(NSUInteger)idx2{
    [self.phassets exchangeObjectAtIndex:idx1 withObjectAtIndex:idx2];
    [self.phassetsIds exchangeObjectAtIndex:idx1 withObjectAtIndex:idx2];
}


/**
 * 进行自动添加或者删除的操作
 * 如果不存在该资源，追加，并返回当前所在的个数(索引+1)
 * 如果存在该资源，删除，并返回-1
 */
- (nullable NSNumber *)addOrRemoveAsset:(PHAsset *)asset{
    BOOL isSelected = [self.phassetsIds containsObject:asset.localIdentifier];
    
    if (isSelected) {//如果选中了，进行删除
        
        [self removePHAsset:asset]; return @(-1);
    }
    
    [self addPHAsset:asset];
    return @(self.count);
}


- (void)setCount:(NSInteger)count
{
    _count = count;
    [self didChangeValueForKey:@"count"];
}

- (void)setHightQuality:(BOOL)hightQuality
{
    _hightQuality = hightQuality;
    [self didChangeValueForKey:@"hightQuality"];
}


- (void)setDefaultIdentifers:(NSArray<NSString *> *)defaultIdentifers
{
    if (defaultIdentifers.count  == 0 || !defaultIdentifers) { return; }
    
    [self.phassetsIds addObjectsFromArray:defaultIdentifers];
    
    //追加资源对象
    [self.phassets addObjectsFromArray:[PHAsset fetchAssetsWithLocalIdentifiers:defaultIdentifers options:nil].array];
    
    self.count = self.phassetsIds.count;
}



- (BOOL)containAsset:(PHAsset *)asset
{
    return [self.phassetsIds containsObject:asset.localIdentifier];
}

- (void)dealloc{
    
    
    NSLog(@"测试会不会释放%@",self);
    
}

@end
