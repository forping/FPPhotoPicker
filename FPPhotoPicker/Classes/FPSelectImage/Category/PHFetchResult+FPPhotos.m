//
//  PHFetchResult+FPPhotos.m
//  判断相片是否存在
//
//  Created by 金医桥 on 2018/12/3.
//  Copyright © 2018 forping. All rights reserved.
//

#import "PHFetchResult+FPPhotos.h"

@implementation PHFetchResult (FPPhotos)

@end
@implementation PHFetchResult (FPFilter)

-(void)filterWithType:(PHAssetMediaType)mediaType
  matchingObjectBlock:(void(^)(PHAsset *))matchingObjectBlock
 enumerateObjectBlock:(void (^)(PHAsset * _Nonnull))enumerateObjectBlock
             complete:(void (^)(NSArray<PHAsset *> * _Nullable))completeBlock
{
    __weak typeof(self) weakSelf = self;
    
    __block NSMutableArray <__kindof PHAsset *> * assets = [NSMutableArray arrayWithCapacity:0];
    
    if (weakSelf.count == 0) {
        
        if (completeBlock)
        {
            completeBlock([NSArray arrayWithArray:assets]);
            assets = nil;
            return;
        }
    }
    
    
    [self enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if (enumerateObjectBlock)
        {
            enumerateObjectBlock(obj);
        }
   
        if ([obj isKindOfClass:[PHAsset class]] && ((PHAsset *)obj).mediaType == mediaType)
        {
            if (matchingObjectBlock)
            {
                matchingObjectBlock(obj);
            }
            
            [assets addObject:obj];
        }
        
        if (idx == weakSelf.count - 1)
        {
            if (completeBlock)
            {
                completeBlock([NSArray arrayWithArray:assets]);
            }
        }
        
    }];
    
}

-(void)filterWithType:(PHAssetMediaType)mediaType
             complete:(void (^)(NSArray<PHAsset *> * _Nonnull))completeBlock
{
    [self filterWithType:mediaType matchingObjectBlock:nil enumerateObjectBlock:nil complete:completeBlock];
}

@end
@implementation PHFetchResult (FPArray)

- (NSArray *)array
{
    NSMutableArray *array = [NSMutableArray array];
    
    [self enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        [array addObject:obj];
    }];
    
    return array;
}



-(void)transToArrayComplete:(void (^)(NSArray<id> * _Nonnull, PHFetchResult * _Nonnull))arrayObject
{
    __weak typeof(self) weakSelf = self;
    
    NSMutableArray *  array = [NSMutableArray array];
    if (weakSelf.count == 0)
    {
        arrayObject([array mutableCopy],weakSelf);
        return;
    }
    
    [self enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        [array addObject:obj];
        
        if (idx == self.count - 1)
        {
            arrayObject(array,weakSelf);
        }
    }];
}



@end
