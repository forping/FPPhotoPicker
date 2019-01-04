//
//  PHPhotoLibrary+FPPhotoStore.m
//  判断相片是否存在
//
//  Created by 金医桥 on 2018/12/7.
//  Copyright © 2018 forping. All rights reserved.
//

#import "PHPhotoLibrary+FPPhotoStore.h"
#import "FPPhotosTool.h"
#import "PHFetchResult+FPPhotos.h"
#import "NSArray+FPExtension.h"
#import "NSArray+FPPhotos.h"

@implementation PHPhotoLibrary (FPPhotoStore)


- (void)fetchAlbumRegularGroups:(void(^)(NSArray <PHAssetCollection *> *))complete{
    [self fetchAssetAlbumRegularCollection:^(PHFetchResult * _Nullable albumRegular) {
        
        [albumRegular transToArrayComplete:^(NSArray<id> * _Nonnull group, PHFetchResult * _Nonnull result) {
            complete(group);
        }];
    }];
    
    
}
/// 获取的将'胶卷相册'放在第一位
- (void)fetchAlbumRegularGroupsByUserLibrary:(void(^)(NSArray <PHAssetCollection *> *))complete{
    
    [self fetchAlbumRegularGroups:^(NSArray<PHAssetCollection *> * _Nonnull collections) {
        
        //进行排序
        NSArray <PHAssetCollection *> *sortCollections = collections.sortRegularAblumsWithUserLibraryFirst.copy;
        
        complete([sortCollections fp_filter:^BOOL(PHAssetCollection * _Nonnull item) {
            
            PHAssetCollectionSubtype subType = item.assetCollectionSubtype;
            
            //取出不需要的数据
            return !(subType == PHAssetCollectionSubtypeSmartAlbumAllHidden || [item.localizedTitle isEqualToString:NSLocalizedString(@"Recently Deleted", @"")]);
        }]);
    }];
    
}

/// 获取photos提供的所有的分类智能相册组和相关相册组
- (void)fetchAblumRegularAndTopLevelUserResults:(void(^)(PHFetchResult<PHAssetCollection *>* regular,
                                                         PHFetchResult<PHCollection *>* topUser))complete{
    [FPPhotosTool hasPhotosAuthorization:^(BOOL has) {
        
        if (has == NO) {
            return ;
        }
        /// 智能相册
        PHFetchResult<PHAssetCollection *> *smartAlbum = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
        
        /// 个人相册
        PHFetchResult <PHCollection *> *topLevelUser = [PHCollectionList fetchTopLevelUserCollectionsWithOptions:nil];
        
        complete(smartAlbum,topLevelUser);
    }];
    
}


/// 获得SmartAlbum
- (void)fetchAssetAlbumRegularCollection:(void(^)(PHFetchResult * _Nullable albumRegular))albumRegular
{
    [FPPhotosTool hasPhotosAuthorization:^(BOOL has) {
       
        if (has == NO) {
            return ;
        }
        
        PHFetchOptions *fetchOptions = [[PHFetchOptions alloc] init];
       PHFetchResult<PHAssetCollection *> *collections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:fetchOptions];
        
        if (albumRegular) {
            albumRegular(collections);
        }
    }];
}




@end
