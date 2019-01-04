//
//  FPPhotosGroupController.m
//  判断相片是否存在
//
//  Created by 金医桥 on 2018/12/3.
//  Copyright © 2018 forping. All rights reserved.
//
// 照片组控制器

#import "FPPhotosGroupController.h"
#import <Photos/Photos.h>
#import "FPPhotosConfig.h"
#import "FPPhotosGroupCell.h"
#import "FPPhotoNotiConfig.h"

#import "PHAssetCollection+FPPhoto.h"
#import "FPPhotosSelectController.h"
#import "FPUnility.h"
#import "PHFetchResult+FPPhotos.h"
#import "NSArray+FPExtension.h"
#import "NSArray+FPPhotos.h"

#import "PHFetchResult+FPPhotos.h"
#import "PHPhotoLibrary+FPPhotoStore.h"
#import "NSBundle+FPPhotos.h"

static NSString * const FPPhotosGroupCellID = @"FPPhotosGroupCell";

@interface FPPhotosGroupController ()

@property (nonatomic, strong)NSMutableArray<NSArray<PHAssetCollection *>*>*groups;

/// 用于比较变化的原生相册
@property (nonatomic, strong)PHFetchResult *regular;
@property (nonatomic, strong)PHFetchResult *moment;

/// 图片库
@property (nonatomic, strong)PHPhotoLibrary *photoLibrary;

@end



@interface FPPhotosGroupController (FPString)

- (NSAttributedString *)titleForCollection:(PHAssetCollection *)collection count:(NSInteger)count;

@end



@interface FPPhotosGroupController (PHPhotoLibraryChangeObserver)<PHPhotoLibraryChangeObserver>

@end


@interface FPPhotosGroupController (AssetData)

/// 加载默认的组
- (void)loadDefaultAblumGroups;

@end


@interface FPPhotosGroupController (FPPhotosCollectionViewController)

- (void)pushPhotosCollectionViewController:(NSIndexPath *)indexPath animated:(BOOL)animated;

@end



@implementation FPPhotosGroupController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //navigationItem
    self.navigationItem.title = @"照片";
    
    //register
    self.photoLibrary = PHPhotoLibrary.sharedPhotoLibrary;
    [self.photoLibrary registerChangeObserver:self];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(dismissPhotoControllers)];
    
    //data
    self.groups = [NSMutableArray arrayWithCapacity:10];
    
    //tableView
    self.tableView.tableFooterView = [[UIView alloc]init];
    
    //cell
    [self.tableView registerClass:FPPhotosGroupCell.class forCellReuseIdentifier:FPPhotosGroupCellID];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (self.groups.count == 0) {
        [self loadDefaultAblumGroups];
    }
}
- (void)dealloc
{
    if ([self isViewLoaded]) {
        [self.photoLibrary unregisterChangeObserver:self];//消除注册
    }
}


#pragma mark - Dismiss

- (void)dismissPhotoControllers
{
    //获得绑定viewController
    [NSNotificationCenter.defaultCenter postNotificationName:FPPhotosControllerDidDismissNotification object:nil];
    
    [self dismissViewControllerAnimated:true completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.groups.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.groups[section].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    FPPhotosGroupCell *cell = [tableView dequeueReusableCellWithIdentifier:FPPhotosGroupCellID forIndexPath:indexPath];
    
    // Configure the cell...
    PHAssetCollection *collection = self.groups[indexPath.section][indexPath.row];
    
    [collection fp_headerImageWithSize:CGSizeMake(30, 30) mode:PHImageRequestOptionsDeliveryModeOpportunistic complete:^(NSString * _Nonnull title, NSUInteger count, UIImage * _Nullable image) {
        //set value
        cell.titleLabel.attributedText = [self titleForCollection:collection count:count];
        cell.imageView.image = count > 0 ? image : NSBundle.fp_placeholder;
    }];
    
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self pushPhotosCollectionViewController:indexPath animated:true];
}




@end

@implementation FPPhotosGroupController (AssetData)

- (void)loadDefaultAblumGroups
{
    [PHPhotoLibrary.sharedPhotoLibrary fetchAblumRegularAndTopLevelUserResults:^(PHFetchResult<PHAssetCollection *> * _Nonnull regular, PHFetchResult<PHAssetCollection *> * _Nullable moment) {
        self.regular = regular;
        self.moment = moment;
        [self filterGroups];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];//reload
        });
    }];
}

/// 进行筛选
- (void)filterGroups
{
    NSArray <PHAssetCollection *> *regularCollections = self.regular.array.sortRegularAblumsWithUserLibraryFirst;
    NSArray <PHAssetCollection *> *momentCollections = self.moment.array;
    
    [self.groups removeAllObjects];//移除所有的，进行重新添加
    
    if (self.configuration.hiddenGroupWhenNoPhotos == false) {
        [self.groups addObject:regularCollections];
        [self.groups addObject:momentCollections];
    }else {//进行数量的二次筛选
        [self.groups addObject:[self filterGroupsWhenHiddenNoPhotos:regularCollections]];
        [self.groups addObject:[self filterGroupsWhenHiddenNoPhotos:momentCollections]];
    }
}

- (NSArray<PHAssetCollection *> *)filterGroupsWhenHiddenNoPhotos:(NSArray<PHAssetCollection *> *)groups
{
    return [groups fp_filter:^BOOL(PHAssetCollection * _Nonnull obj) {
        
        PHFetchResult * assetResult = [PHAsset fetchAssetsInAssetCollection:obj options:nil];
        return assetResult != nil && assetResult.count > 0;
    }];
}

@end






@implementation FPPhotosGroupController (FPString)

- (NSAttributedString *)titleForCollection:(PHAssetCollection *)collection count:(NSInteger)count
{
    //数据拼接
    NSMutableAttributedString *result = [[NSMutableAttributedString alloc]
                                         initWithString:collection.localizedTitle
                                         attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:15]}];
    
    if (count < 0 || count == NSNotFound) {
        
        count = 0;
    }
    
    //
    NSString *countString = [NSString stringWithFormat:@"  (%@)",@(count).stringValue];
    
    //数量
    NSMutableAttributedString *countResult = [[NSMutableAttributedString alloc]
                                              initWithString:countString
                                              attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15.0f],NSForegroundColorAttributeName:FPColorSimpleFromIntRBG(102)}];
    
    [result appendAttributedString:countResult];
    return result;
}

@end

@implementation FPPhotosGroupController (FPPhotosCollectionViewController)

- (void)pushPhotosCollectionViewController:(NSIndexPath *)indexPath animated:(BOOL)animated
{
    PHAssetCollection *collection = self.groups[indexPath.section][indexPath.row];
    
    [self.navigationController pushViewController:({
        
        FPPhotosSelectController *collectionViewController = [[FPPhotosSelectController alloc] init];
        
        [collectionViewController setConfig:self.configuration];
        
        collectionViewController.localIdentifier = collection.localIdentifier;
        
        collectionViewController;
        
    }) animated:animated];
}
@end

@implementation FPPhotosGroupController (PHPhotoLibraryChangeObserver)
- (void)photoLibraryDidChange:(PHChange *)changeInstance
{
    // 刷新UI
    dispatch_sync(dispatch_get_main_queue(), ^{
        // 还能相册发生变化
        PHFetchResultChangeDetails *regularChangeDetails = [changeInstance changeDetailsForFetchResult:self.regular];
        if (regularChangeDetails != nil) {
            self.regular = regularChangeDetails.fetchResultAfterChanges;
            [self filterGroups];
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        
        // 个人组相册发生变化
        PHFetchResultChangeDetails *momentChangeDetails = [changeInstance changeDetailsForFetchResult:self.moment];
        if (momentChangeDetails != nil) {
            self.moment = momentChangeDetails.fetchResultAfterChanges;
            [self filterGroups];
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    });
}

@end








