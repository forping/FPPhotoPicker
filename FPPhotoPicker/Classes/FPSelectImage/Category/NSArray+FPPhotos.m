//
//  NSArray+FPPhotos.m
//  判断相片是否存在
//
//  Created by 金医桥 on 2018/12/7.
//  Copyright © 2018 forping. All rights reserved.
//

#import "NSArray+FPPhotos.h"
#import <Photos/Photos.h>
#import "NSArray+FPExtension.h"

@implementation NSArray (FPPhotos)

- (NSArray<PHAssetCollection *> *)sortRegularAblumsWithUserLibraryFirst
{
    //进行排序
    NSMutableArray <PHAssetCollection *> *sortCollections = [NSMutableArray arrayWithArray:self];
    
    //选出对象
    PHAssetCollection *userLibrary = [self fp_filter:^BOOL(PHAssetCollection * _Nonnull item) {
        
        return (item.assetCollectionSubtype == PHAssetCollectionSubtypeSmartAlbumUserLibrary);
        
    }].fp_safeFirstObject;
    
    if (userLibrary) {
        
        //进行变换
        [sortCollections removeObject:userLibrary];
        [sortCollections insertObject:userLibrary atIndex:0];
    }
    
    return sortCollections;
}

@end
