//
//  FPSelectImageController.m
//  判断相片是否存在
//
//  Created by 金医桥 on 2018/12/3.
//  Copyright © 2018 forping. All rights reserved.
//

#import "FPPhotosSelectController.h"
#import "FPPhotosBrowseController.h"


#import "FPPhotosDataManger.h"


#import <Masonry/Masonry.h>
#import "NSArray+FPExtension.h"
#import "UICollectionView+FPIndexPathsForElements.h"
#import "FPPhotosPreviewController.h"

#import "NSString+FPPhotos.h"
#import "FPPhotosBrowseAllDataSource.h"
#import "FPPhotosBrowseDataSource.h"
#import "FPPhotosMaker.h"

#import "FPUnility.h"
#import "FPPhotosTool.h"

typedef NSString FPDifferencesKey;
static FPDifferencesKey *const FPDifferencesKeyAdded = @"FPDifferencesKeyAdded";
static FPDifferencesKey *const FPDifferencesKeyRemoved = @"FPDifferencesKeyRemoved";


static NSString *const FPPhotosCellID = @"FPPhotosCellID";




@interface FPPhotosSelectController ()
<
UIViewControllerPreviewingDelegate, // 3Dtouch
UICollectionViewDelegateFlowLayout,
UICollectionViewDataSource,
UICollectionViewDataSourcePrefetching,
FPPhotosCellActionTarget
>

@property (nonatomic , strong) UICollectionView *collectionView;

@property (nonatomic, strong) PHPhotoLibrary *photoLibrary;
// 是一个负责渲染资源的类。比如获得PHAsset对象的原图等操作需要使用该类.
@property (nonatomic, strong) PHCachingImageManager* imageManager;
// 管理当前选择的照片的管理器
@property (nonatomic , strong) FPPhotosDataManger *dataManager;

// 当前相册
@property (nonatomic, strong) PHAssetCollection *assetCollection;
@property (nonatomic, strong) PHFetchResult <PHAsset *> *assets;

/// 用于iOS 10的缓存的队列
@property (nonatomic, strong) dispatch_queue_t photo_queue NS_AVAILABLE_IOS(10_0);
@property (nonatomic, assign) CGRect previousPreheatRect;



@end


@interface FPPhotosSelectController (FPCacheSetting)
- (void)updateCachedAssets;

@end

@implementation FPPhotosSelectController

- (void)viewDidLoad {
    [super viewDidLoad];
    //进行KVO观察
    [self.dataManager addObserver:self forKeyPath:@"count" options:NSKeyValueObservingOptionNew context:nil];
    [self.dataManager addObserver:self forKeyPath:@"hightQuality" options:NSKeyValueObservingOptionNew context:nil];
    if (@available(iOS 10.0,*)) {
        self.photo_queue = dispatch_queue_create("com.FP.photos", DISPATCH_QUEUE_CONCURRENT);
    }
    
    
    [self setLeftBarButtonAndRightBarButton];
    
    [self setUpView];

    //注册3D Touch
    if (@available(iOS 9.0,*)) {
        if (self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable){
            [self registerForPreviewingWithDelegate:self sourceView:self.view];
        }
    }
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (!FP_iOS_Version_GreaterThan(10.0)) {
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Wdeprecated-declarations"
        [self updateCachedAssets];
    #pragma clang diagnostic pop
    }
}

- (void)dealloc
{
    if (self.isViewLoaded) {
        [self.dataManager removeObserver:self forKeyPath:@"count"];
        [self.dataManager removeObserver:self forKeyPath:@"hightQuality"];
    }
    
    [self.imageManager stopCachingImagesForAllAssets];
    [self.dataManager removeAllPHAssets];
}



#pragma mark - 设置左侧和右侧按钮
- (void) setLeftBarButtonAndRightBarButton{
    
    UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(leftBarButtonDidPress:)];
    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(rightBarButtonDidPress:)];
    
    [self.navigationItem setLeftBarButtonItem:leftBarButton];
    [self.navigationItem setRightBarButtonItem:rightBarButton];
}

- (void)leftBarButtonDidPress:(UIBarButtonItem *)item{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)rightBarButtonDidPress:(UIBarButtonItem *)item{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}


#pragma mark - 初始化view
- (void)setUpView{
    // 底部视图
    self.bottomView = [[FPPhotosBottomView alloc] init];
    self.bottomView.previewButton.enabled = false;
    self.bottomView.sendButton.enabled = false;
    
    [self.bottomView.previewButton addTarget:self
                                      action:@selector(bottonPreviewButtonDidPress:)
                            forControlEvents:UIControlEventTouchUpInside];
    
    [self.bottomView.fullImageButton addTarget:self
                                        action:@selector(bottomHightQualityButtonDidPress:)
                              forControlEvents:UIControlEventTouchUpInside];
    
    [self.bottomView.sendButton addTarget:self
                                   action:@selector(pushPhotosMaker:)
                         forControlEvents:UIControlEventTouchUpInside];
    
    self.bottomView.backgroundColor = [UIColor.blackColor colorWithAlphaComponent:0.8];

    [self.collectionView registerClass:[FPPhotosCell class] forCellWithReuseIdentifier:FPPhotosCellID];
    
    [self.view addSubview:self.collectionView];
    [self.view addSubview:self.bottomView];
    
    
    // Layout
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.bottom.left.right.offset(0);
        make.height.mas_equalTo(FP_DefaultTabBarHeight - 3);
    }];
    
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.top.right.offset(0);
        make.bottom.equalTo(self.bottomView.mas_top).offset(0);
    }];
    
    //加载数据
    if (self.localIdentifier) {
        //加载
        self.assetCollection = [PHAssetCollection fetchAssetCollectionsWithLocalIdentifiers:@[self.localIdentifier] options:nil].firstObject;
    }
    
    [FPPhotosTool hasPhotosAuthorization:^(BOOL has) {
        if (has) {
            [self showPicktureWhenHasAuth];
        }
        else{
            NSAssert(1!=1, @"没有权限访问相册");
        }
    }];
}

#pragma mark - 底部视图的点击事件
// 预览
- (void)bottonPreviewButtonDidPress:(UIButton *)sender
{
        [self.navigationController pushViewController:({
    
            FPPhotosBrowseController *browerController = [[FPPhotosBrowseController alloc] init];
            [self.navigationController setDelegate:browerController];
            browerController.config = self.config;
            FPPhotosBrowseDataSource *dataSource = [[FPPhotosBrowseDataSource alloc] init];
            dataSource.assets = self.dataManager.phassets;
            browerController.dataSource = dataSource;
            browerController.backHandler = ^{
    
                [self.collectionView reloadData];
            };
    
            browerController;
    
        }) animated:true];
}

// 高清
- (void)bottomHightQualityButtonDidPress:(UIButton *)sender
{
    self.dataManager.hightQuality = !self.dataManager.hightQuality;
}

//  发送
- (void)pushPhotosMaker:(UIButton *)sender
{
        [FPPhotosMaker.sharedInstance startMakePhotosComplete:^{
            [self dismissViewControllerAnimated:YES completion:^{
            }];
        }];
}

#pragma mark - 有权限的操作
- (void) showPicktureWhenHasAuth{
    self.imageManager = [PHCachingImageManager new];
    
    self.previousPreheatRect = CGRectZero;
    
    self.photoLibrary = PHPhotoLibrary.sharedPhotoLibrary;
    
    PHFetchOptions *options = [[PHFetchOptions alloc] init];

    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
    
    self.assets = [PHAsset fetchAssetsInAssetCollection:self.assetCollection options:options];
    
    //reload
    self.collectionView.hidden = true;
    [self.collectionView reloadData];
    
    //设置itemTitle
    self.navigationItem.title = self.assetCollection.localizedTitle;
    
    //计算行数,并滑动到最后一行
    self.collectionView.hidden = false;
    
    [self collectionViewScrollToBottomAnimatedNoneHandler:^NSInteger(NSInteger row) {
        return row;
    }];
    [self changedBottomViewStatus];
}

#pragma mark - 滑动到底部
- (void)collectionViewScrollToBottomAnimatedNoneHandler:(NSInteger(^)(NSInteger row))handler
{
    //获得所有的数据个数
    NSInteger itemCount = self.assets.count;
    
    if (itemCount < 4) { return; }
    
    //获得行数
    NSInteger row = (itemCount + 3) / 4;
    
    if (handler) { row = handler(row); }
    
    //item
    CGFloat itemHeight = (FP_SCREEN_WIDTH - 3.0f * 3) / 4;
    
    //进行高度换算
    CGFloat height = row * itemHeight;
    height += 3.0 * (row - 1);
    
    
    //底部bottom
    CGFloat bottomHeight = FP_DefaultTabBarHeight;
    
    //可以显示的区域
    CGFloat showSapce = FP_SCREEN_HEIGHT - FP_DefaultNaviBarHeight - bottomHeight;
    
    //进行单位换算

    self.collectionView.contentSize = CGSizeMake(self.collectionView.contentSize.width, MAX(MAX(0,height - showSapce),-1 * FP_DefaultNaviBarHeight));
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:itemCount - 1 inSection:0] atScrollPosition:UICollectionViewScrollPositionBottom animated:NO];
    });
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return self.assets ? self.assets.count : 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    FPPhotosCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:FPPhotosCellID forIndexPath:indexPath];
    //Asset
    PHAsset *asset = [self.assets objectAtIndex:indexPath.item];
    //Size
    CGSize size = [self collectionView:collectionView layout:collectionView.collectionViewLayout sizeForItemAtIndexPath:indexPath];

    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.networkAccessAllowed = true;
    // Configure the cell
    cell.representedAssetIdentifier = asset.localIdentifier;
    
    // 因为需要用到缓存, 所以在这里请求图片的数据
    [self.imageManager requestImageForAsset:asset targetSize:CGSizeMake(size.width*2, size.height*2) contentMode:PHImageContentModeAspectFill options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        if ([cell.representedAssetIdentifier isEqualToString:asset.localIdentifier] && result) {
            cell.actionTarget = self;
            cell.asset = asset;
            cell.indexPath = indexPath;
            cell.imageView.image = result;
        }
    }];
    
    return cell;
}

#pragma mark - <RITLPhotosCellActionTarget>
- (void)photosCellDidTouchUpInSlide:(FPPhotosCell *)cell asset:(PHAsset *)asset indexPath:(NSIndexPath *)indexPath complete:(FPPhotosCellStatusAction)animated
{
    if (self.dataManager.count >= self.config.maxPhotosCount &&
        ![self.dataManager containAsset:asset]/*是添加*/) { return; }//不能进行选择
    
    NSInteger index = [self.dataManager addOrRemoveAsset:asset].integerValue;
    
    animated(FPPhotosCellAnimatedStatusPermit,index > 0,MAX(0,index));
    
    NSArray<NSIndexPath *> *indexpaths = [self.collectionView indexPathsForVisibleItems];
    
    [self.collectionView reloadItemsAtIndexPaths:indexpaths];
}



// set value
- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    
    //Asset
    PHAsset *asset = [self.assets objectAtIndex:indexPath.item];
    //强转
    if (![cell isKindOfClass:FPPhotosCell.class]) { return; }
    
    FPPhotosCell *photoCell = (FPPhotosCell *)cell;
    
    photoCell.messageView.hidden = (asset.mediaType == PHAssetMediaTypeImage);
    
    if(!self.config.containVideo){//是否允许选择视频-不允许选择视频，去掉选择符
        photoCell.chooseButton.hidden = (asset.mediaType == PHAssetMediaTypeVideo);
    }
    
    BOOL isSelected = [self.dataManager.phassetsIds containsObject:asset.localIdentifier];
    
    //进行属性隐藏设置
    photoCell.indexLabel.hidden = !isSelected;
    
    if (self.dataManager.count >= self.config.maxPhotosCount && isSelected == NO) {
        [photoCell.shadeView setHidden:NO];
    }
    else{
        [photoCell.shadeView setHidden:YES];
    }
    
    if (isSelected) {
        photoCell.indexLabel.text = @([self.dataManager.phassetsIds indexOfObject:asset.localIdentifier] + 1).stringValue;
    }
    
    if (photoCell.imageView.hidden) { return; }
    
    if (@available(iOS 9.1,*)) {//Live图片
        photoCell.liveBadgeImageView.hidden = !(asset.mediaSubtypes == PHAssetMediaSubtypePhotoLive);
    }
    
    NSString *time = [NSString timeStringWithTimeDuration:asset.duration];
    photoCell.messageLabel.text = time;
}



#pragma mark <UIScrollViewDelegate>

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (!FP_iOS_Version_GreaterThan(10.0)) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        [self updateCachedAssets];
#pragma clang diagnostic pop
    }
}


#pragma mark - <UICollectionViewDataSourcePrefetching>
- (void)collectionView:(UICollectionView *)collectionView prefetchItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths NS_AVAILABLE_IOS(10_0)
{
    CGSize thimbnailSize = [self collectionView:collectionView layout:collectionView.collectionViewLayout sizeForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
    
    dispatch_async(self.photo_queue, ^{
        
        [self.imageManager startCachingImagesForAssets:[indexPaths fp_map:^id _Nonnull(NSIndexPath * _Nonnull obj) {
            return [self.assets objectAtIndex:obj.item];
            
        }] targetSize:thimbnailSize contentMode:PHImageContentModeAspectFill options:nil];
    });
}


- (void)collectionView:(UICollectionView *)collectionView cancelPrefetchingForItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths  NS_AVAILABLE_IOS(10_0)
{
    CGSize thimbnailSize = [self collectionView:collectionView layout:collectionView.collectionViewLayout sizeForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
    
    dispatch_async(self.photo_queue, ^{
        
        [self.imageManager stopCachingImagesForAssets:[indexPaths fp_map:^id _Nonnull(NSIndexPath * _Nonnull obj) {
            
            return [self.assets objectAtIndex:obj.item];
            
        }] targetSize:thimbnailSize contentMode:PHImageContentModeAspectFill options:nil];
    });
}

#pragma mark - <UIViewControllerPreviewingDelegate>
- (nullable UIViewController *)previewingContext:(id <UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location NS_AVAILABLE_IOS(9_0)
{
    CGPoint p = [self.collectionView convertPoint:location fromView:self.view];
    //获取当前cell的indexPath
    NSIndexPath * indexPath = [self.collectionView indexPathForItemAtPoint:p];
    NSUInteger item = indexPath.item;
    //获得当前的资源
    PHAsset *asset = self.assets[item];
    if (asset.mediaType != PHAssetMediaTypeImage)
    {
        return nil;
    }
    FPPhotosPreviewController * viewController = [FPPhotosPreviewController previewWithShowAsset:asset];
    
    return viewController;
}


- (void)previewingContext:(id <UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit NS_AVAILABLE_IOS(9_0)
{
    if([viewControllerToCommit isKindOfClass:[FPPhotosPreviewController class]]){
        FPPhotosPreviewController * viewController = (FPPhotosPreviewController *)viewControllerToCommit;
       PHAsset *asset = viewController.showAsset;
        //跳出控制器
     [self pushHorAllBrowseViewControllerWithAsset:asset];
    }
}


#pragma mark <UICollectionViewDelegateFlowLayout>
- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat sizeHeight = (MIN(FP_SCREEN_WIDTH,FP_SCREEN_HEIGHT) - 3.0f * 3) / 4;
    return CGSizeMake(sizeHeight, sizeHeight);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout*)collectionViewLayout
minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 3.f;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout *)collectionViewLayout
minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 3.f;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    //获取当前的资源
    PHAsset *asset = [self.assets objectAtIndex:indexPath.item];
    
    [self pushHorAllBrowseViewControllerWithAsset:asset];
}


- (FPPhotosCell *)currentBrowseCellWithAsset:(PHAsset *)asset scrollTo:(BOOL)scroll{

    NSUInteger index = [self.assets indexOfObject:asset];
    
    
    if (asset == nil || index == NSNotFound) {
        return nil;
    }
    
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];

    [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionNone animated:NO];

    [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
    FPPhotosCell *cell = (FPPhotosCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    
    return cell;
}


#pragma mark - Browse All Assets Display
/// 浏览点击的cell对应的资源
- (void)pushHorAllBrowseViewControllerWithAsset:(PHAsset *)asset
{
    
    
    [self.navigationController pushViewController:({
        
        FPPhotosBrowseController *browerController = [[FPPhotosBrowseController alloc] init];
        [self.navigationController setDelegate:browerController];
        browerController.config = self.config;
        FPPhotosBrowseAllDataSource *dataSource = [[FPPhotosBrowseAllDataSource alloc] init];
        dataSource.collection = self.assetCollection;
        dataSource.asset = asset;
        browerController.dataSource = dataSource;
        
        browerController.backHandler = ^{
            [self.collectionView reloadData];
        };
        browerController;
    }) animated:true];
}
#pragma mark - <KVO>
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"count"] && [object isEqual:self.dataManager]) {
        
        [self changedBottomViewStatus];
    }
    else if([keyPath isEqualToString:@"hightQuality"] && [object isEqual:self.dataManager]){
        BOOL hightQuality = [change[NSKeyValueChangeNewKey] boolValue];
        self.bottomView.fullImageButton.selected = hightQuality;
    }
}

#pragma mark - 检测
/// 更新底部视图的状态
- (void)changedBottomViewStatus
{
    NSInteger count = self.dataManager.count;
    
    self.bottomView.previewButton.enabled = !(count == 0);
    
    UIControlState state = (count == 0 ? UIControlStateDisabled : UIControlStateNormal);
    NSString *title = (count == 0 ? @"发送" : [NSString stringWithFormat:@"发送(%@)",@(count)]);
    [self.bottomView.sendButton setTitle:title forState:state];
    self.bottomView.sendButton.enabled = !(count == 0);
}

#pragma mark - settter && getter
- (FPPhotosDataManger *)dataManager{
    if (_dataManager == nil) {
        _dataManager = [FPPhotosDataManger sharedInstance];
    }
    return _dataManager;
}

-(UICollectionView *)collectionView
{
    if(_collectionView == nil)
    {
        _collectionView = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:[[UICollectionViewFlowLayout alloc]init]];
        //protocol
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        if (@available(iOS 10.0,*)) {
            _collectionView.prefetchDataSource = self;
        }
        //property
        _collectionView.backgroundColor = [UIColor whiteColor];
    }
    return _collectionView;
}
// 默认是
- (PHAssetCollection *)assetCollection
{
    if (!_assetCollection) {
        _assetCollection = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil].firstObject;
    }
    return _assetCollection;
}



@end




@implementation FPPhotosSelectController (FPCacheSetting)


#pragma mark - *************** cache ***************
#pragma mark - iOS 10 之前进行的手动计算，iOS 10 以后使用 UICollectionViewDataSourcePrefetching
- (void)updateCachedAssets __deprecated_msg("iOS 10 Use collectionView:prefetchItemsAtIndexPaths: and collectionView:cancelPrefetchingForItemsAtIndexPaths: instead.")
{
    if (!self.isViewLoaded || self.view.window == nil) { return; }
    
    //没有权限，关闭
    if (PHPhotoLibrary.authorizationStatus != PHAuthorizationStatusAuthorized) { return; }
    
    //可视化
    CGRect visibleRect = CGRectMake(self.collectionView.contentOffset.x, self.collectionView.contentOffset.y, self.collectionView.frame.size.width, self.collectionView.frame.size.height);
    
    //进行拓展 // 扩张
    CGRect preheatRect = CGRectInset(visibleRect, 0, -0.5 * visibleRect.size.height);
    
    //只有可视化的区域与之前的区域有显著的区域变化才需要更新
    CGFloat delta = ABS(CGRectGetMidY(preheatRect) - CGRectGetMidY(self.previousPreheatRect)); // 当前的中心点减去上次的中心点
    if (delta <= self.view.frame.size.height / 3.0) { return; } // 没有显著变化
    
    //获得比较后需要进行预加载以及需要停止缓存的区域 // 得到增加的和减去的frame
    NSDictionary *differences = [self differencesBetweenRects:self.previousPreheatRect new:preheatRect];
    NSArray <NSValue *> *addedRects = differences[FPDifferencesKeyAdded];
    NSArray <NSValue *> *removedRects = differences[FPDifferencesKeyRemoved];
    
    ///进行提前缓存的资源
    NSArray <PHAsset *> *addedAssets = [[[addedRects fp_map:^id _Nonnull(NSValue * _Nonnull rectValue) {
        return [self.collectionView indexPathsForElementsInRect:rectValue.CGRectValue];
        
    }] fp_reduce:@[] reduceHandler:^NSArray * _Nonnull(NSArray * _Nonnull result, NSArray <NSIndexPath *>*_Nonnull items) {
        return [result arrayByAddingObjectsFromArray:items];
        
    }] fp_map:^id _Nonnull(NSIndexPath *_Nonnull index) {
        return [self.assets objectAtIndex:index.item];
        
    }];
    
    ///提前停止缓存的资源
    NSArray <PHAsset *> *removedAssets = [[[removedRects fp_map:^id _Nonnull(NSValue * _Nonnull rectValue) {
        return [self.collectionView indexPathsForElementsInRect:rectValue.CGRectValue];
        
    }] fp_reduce:@[] reduceHandler:^NSArray * _Nonnull(NSArray * _Nonnull result, NSArray <NSIndexPath *>* _Nonnull items) {
        return [result arrayByAddingObjectsFromArray:items];
        
    }] fp_map:^id _Nonnull(NSIndexPath *_Nonnull index) {
        return [self.assets objectAtIndex:index.item];
    }];
    
    
    CGSize thimbnailSize = [self collectionView:self.collectionView layout:self.collectionView.collectionViewLayout sizeForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
    
    //更新缓存
    [self.imageManager startCachingImagesForAssets:addedAssets targetSize:thimbnailSize contentMode:PHImageContentModeAspectFill options:nil];
    [self.imageManager stopCachingImagesForAssets:removedAssets targetSize:thimbnailSize contentMode:PHImageContentModeAspectFill options:nil];
    
    //记录当前位置
    self.previousPreheatRect = preheatRect;
}

- (NSDictionary <FPDifferencesKey*,NSArray<NSValue *>*> *)differencesBetweenRects:(CGRect)old new:(CGRect)new __deprecated_msg("iOS 10 Use collectionView:prefetchItemsAtIndexPaths: and collectionView:cancelPrefetchingForItemsAtIndexPaths: instead.")
{
    if (CGRectIntersectsRect(old, new)) {//如果区域交叉
        
        NSMutableArray <NSValue *> * added = [NSMutableArray arrayWithCapacity:10];
        if (CGRectGetMaxY(new) > CGRectGetMaxY(old)) {//表示上拉
            [added addObject:[NSValue valueWithCGRect:CGRectMake(new.origin.x, CGRectGetMaxY(old), new.size.width, CGRectGetMaxY(new) - CGRectGetMaxY(old))]];
        }
        
        if(CGRectGetMinY(old) > CGRectGetMinY(new)){//表示下拉
            
            [added addObject:[NSValue valueWithCGRect:CGRectMake(new.origin.x, CGRectGetMinY(new), new.size.width, CGRectGetMinY(old) - CGRectGetMinY(new))]];
        }
        
        NSMutableArray <NSValue *> * removed = [NSMutableArray arrayWithCapacity:10];
        if (CGRectGetMaxY(new) < CGRectGetMaxY(old)) {//表示下拉
            [removed addObject:[NSValue valueWithCGRect:CGRectMake(new.origin.x, CGRectGetMaxY(new), new.size.width, CGRectGetMaxY(old) - CGRectGetMaxY(new))]];
        }
        
        if (CGRectGetMinY(old) < CGRectGetMinY(new)) {//表示上拉
            
            [removed addObject:[NSValue valueWithCGRect:CGRectMake(new.origin.x, CGRectGetMinY(old), new.size.width, CGRectGetMinY(new) - CGRectGetMinY(old))]];
        }
        
        return @{FPDifferencesKeyAdded:added,
                 FPDifferencesKeyRemoved:removed};
    }else {
        
        return @{FPDifferencesKeyAdded:@[[NSValue valueWithCGRect:new]],
                 FPDifferencesKeyRemoved:@[[NSValue valueWithCGRect:old]]};
    }
}

@end
