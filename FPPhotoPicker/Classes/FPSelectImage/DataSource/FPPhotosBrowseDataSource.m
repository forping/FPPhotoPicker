//
//  FPPhotosBrowseDataSource.m
//  判断相片是否存在
//
//  Created by 金医桥 on 2018/12/3.
//  Copyright © 2018 forping. All rights reserved.
//

#import "FPPhotosBrowseDataSource.h"
#import "FPPhotosBrowseImageCell.h"
#import "UICollectionViewCell+FPPhotos.h"

@interface FPPhotosBrowseDataSource()

///进行资源化的Manager
@property (nonatomic, strong, readwrite) PHCachingImageManager* imageManager;

@end
@implementation FPPhotosBrowseDataSource

- (instancetype)init{
    if (self = [super init]) {
        self.imageManager = [[PHCachingImageManager alloc] init];
    }
    return self;
}

#pragma mark - <UICollectionViewDataSource>

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.assets.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    //获得当前的对象
    PHAsset *asset = self.assets[indexPath.item];
    
    NSString *str = @"";
    
    if (asset.mediaType == PHAssetMediaTypeVideo) { str = @"video"; }
    
    else if(asset.mediaType == PHAssetMediaTypeImage){
        
        if (@available(iOS 9.1,*)) {
            
            str =( asset.mediaSubtypes == PHAssetMediaSubtypePhotoLive ? @"livephoto" : @"photo");
        }
        
        str = @"photo";
    }
    
    FPPhotosBrowseImageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:str forIndexPath:indexPath];

    [cell updateAssets:asset atIndexPath:indexPath imageManager:self.imageManager];//即将显示，进行填充
    
    return cell;
}

#pragma mark - <RITLPhotosHorBrowseDataSource>

- (PHAsset *)assetAtIndexPath:(NSIndexPath *)indexPath
{
    return self.assets[indexPath.item];
}

- (NSIndexPath *)defaultItemIndexPath
{
    return [NSIndexPath indexPathForItem:0 inSection:0];
}




@end
