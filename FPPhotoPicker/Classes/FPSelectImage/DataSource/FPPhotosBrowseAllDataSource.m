//
//  FPPhotosBrowseAllDataSource.m
//  判断相片是否存在
//
//  Created by 金医桥 on 2018/12/4.
//  Copyright © 2018 forping. All rights reserved.
//

#import "FPPhotosBrowseAllDataSource.h"
#import "FPPhotosBrowseImageCell.h"
#import "UICollectionViewCell+FPPhotos.h"

@interface FPPhotosBrowseAllDataSource ()
///存储资源的对象
@property (nonatomic, strong, readwrite) PHFetchResult<PHAsset *> *assetResult;
///进行资源化的Manager
@property (nonatomic, strong, readwrite) PHCachingImageManager* imageManager;
@end

@implementation FPPhotosBrowseAllDataSource
- (instancetype)init
{
    if (self = [super init]) {
        
        self.imageManager = PHCachingImageManager.new;
    }
    return self;
}

- (void)setCollection:(PHAssetCollection *)collection
{
    _collection = collection;
    self.assetResult = [PHAsset fetchAssetsInAssetCollection:self.collection options:nil];
}


#pragma mark - <UICollectionViewDataSource>

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.assetResult.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    //获得当前的对象
    PHAsset *asset = [self.assetResult objectAtIndex:indexPath.item];

    NSString *str = @"";
    
    if (asset.mediaType == PHAssetMediaTypeVideo) { str = @"video"; }
    
    else if(asset.mediaType == PHAssetMediaTypeImage){
        
        if (@available(iOS 9.1,*)) {
            
            str =( asset.mediaSubtypes == PHAssetMediaSubtypePhotoLive ? @"livephoto" : @"photo");
            
        }
        else{
            
            str = @"photo";
        }
    }
    
    FPPhotosBrowseImageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:str forIndexPath:indexPath];
    
    [cell updateAssets:asset atIndexPath:indexPath imageManager:self.imageManager];//即将显示，进行填充
    
    return cell;
}

#pragma mark - <RITLPhotosHorBrowseDataSource>

- (PHAsset *)assetAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.assetResult objectAtIndex:indexPath.item];
}

- (NSIndexPath *)defaultItemIndexPath
{
    return [NSIndexPath indexPathForItem:[self.assetResult indexOfObject:self.asset] inSection:0];
}


- (void)dealloc
{
    NSLog(@"[%@] is dealloc",NSStringFromClass(self.class));
}

@end
