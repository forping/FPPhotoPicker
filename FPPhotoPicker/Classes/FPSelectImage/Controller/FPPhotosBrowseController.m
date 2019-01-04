//
//  FPPhotosBrowseController.m
//  判断相片是否存在
//
//  Created by 金医桥 on 2018/12/3.
//  Copyright © 2018 forping. All rights reserved.


#import "FPPhotosBrowseController.h"
#import "FPPhotosBrowseVideoCell.h"
#import "FPPhotosBrowseImageCell.h"
#import "FPPhotosBrowseLiveCell.h"

#import "FPPhotosBrowseTopView.h"
#import "NSBundle+FPPhotos.h"
#import <Masonry/Masonry.h>

#import "FPPhotosDataManger.h"
#import "UICollectionView+FPIndexPathsForElements.h"

#import "FPPhotoNotiConfig.h"
#import "NSArray+FPExtension.h"
#import "FPPhotosMaker.h"
#import "FPUnility.h"
#import "UICollectionViewCell+FPPhotos.h"
#import "FPPhotoBrowseTransition.h"
#import "FPPhotoBrowseInteractiveTransition.h"



#define FPPhotosHorBrowseCollectionSpace 3



static NSString *const FPBrowsePhotoKey = @"photo";
static NSString *const FPBrowseLivePhotoKey = @"livephoto";
static NSString *const FPBrowseVideoKey = @"video";

typedef NSString FPHorBrowseDifferencesKey;
static FPHorBrowseDifferencesKey *const FPHorBrowseDifferencesKeyAdded = @"FPDifferencesKeyAdded";
static FPHorBrowseDifferencesKey *const FPHorBrowseDifferencesKeyRemoved = @"FPDifferencesKeyRemoved";

@interface FPPhotosBrowseController (FPCacheSetting)
// 更新需要缓存的资源
- (void)updateCachedAssets;
@end

@interface FPPhotosBrowseController ()<UICollectionViewDelegate>

/// 用于计算缓存的位置
@property (nonatomic, assign) CGRect previousPreheatRect;


/// 顶部模拟的导航
@property (nonatomic, strong) FPPhotosBrowseTopView *topBar;


/// 预览的collectionView
@property (nonatomic, strong) UICollectionView *browseCollectionView;

// Data
@property (nonatomic, strong) FPPhotosDataManger *dataManager;

@property (nonatomic , strong) FPPhotoBrowseInteractiveTransition *interactiveTransition;
@end

@implementation FPPhotosBrowseController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        
        self.dataManager = FPPhotosDataManger.sharedInstance;
        
    }
    
    return self;
}


- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC{
 
    if (operation == UINavigationControllerOperationPop && self.interactiveTransition.interation) {
        return [[FPPhotoBrowseTransition alloc] init];
    }
    return nil;
    
}

#pragma mark - UINavigationControllerDelegate
- (nullable id <UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController
                                   interactionControllerForAnimationController:(id <UIViewControllerAnimatedTransitioning>) animationController{
    
    if (self.interactiveTransition.interation) {
        return self.interactiveTransition;
    }
    else{
        return nil;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self interactiveTransition];
    
    self.previousPreheatRect = CGRectZero;
    [self resetCachedAssets];
    
    self.bottomView = [[FPPhotosBottomView alloc] init];
    self.bottomView.backgroundColor = [UIColor.blackColor colorWithAlphaComponent:0.8];
    
    self.bottomView.previewButton.hidden = true;//去掉图片预览
    
    self.bottomView.fullImageButton.selected = self.dataManager.isHightQuality;
    [self.bottomView.fullImageButton addTarget:self
                                        action:@selector(hightQualityShouldChanged:)
                              forControlEvents:UIControlEventTouchUpInside];
    
    [self.bottomView.sendButton addTarget:self
                                   action:@selector(sendButtonDidClick:)
                         forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:self.collectionView];
    
    //进行注册
    [self.collectionView registerClass:FPPhotosBrowseImageCell.class forCellWithReuseIdentifier:FPBrowsePhotoKey];
    [self.collectionView registerClass:FPPhotosBrowseVideoCell.class forCellWithReuseIdentifier:FPBrowseVideoKey];
    if (@available(iOS 9.1,*)) {
        [self.collectionView registerClass:FPPhotosBrowseLiveCell.class forCellWithReuseIdentifier:FPBrowseLivePhotoKey];
    }
    
    
    //初始化视图
    self.topBar = ({
        FPPhotosBrowseTopView *view = [[FPPhotosBrowseTopView alloc] init];
        view.backgroundColor = [UIColor.blackColor colorWithAlphaComponent:0.75];
        view;
    });
    
    [self.topBar.backButton addTarget:self action:@selector(leftBarButtonDidPress:) forControlEvents:UIControlEventTouchUpInside];
    [self.topBar.statusButton addTarget:self action:@selector(assetStatusDidChanged:) forControlEvents:UIControlEventTouchUpInside];

    [self.view addSubview:self.topBar];
    [self.view addSubview:self.bottomView];
    [self.view addSubview:self.browseCollectionView];

    
    UIView *lineView = ({
        
        UIView *view = [UIView new];
        view.backgroundColor = FPColorSimpleFromIntRBG(66);
        view.frame = CGRectMake(0, 79, FP_SCREEN_WIDTH, 0.7);
        
        view;
    });
    
    //模拟横线
    [self.browseCollectionView addSubview:lineView];
    
    //进行布局
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.bottom.offset(0);
        make.left.offset(-1 * FPPhotosHorBrowseCollectionSpace);
        make.right.offset(FPPhotosHorBrowseCollectionSpace);
    }];
    
    [self.topBar mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.top.right.offset(0);
        make.height.mas_equalTo(FP_DefaultNaviBarHeight);
    }];
    
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.bottom.left.right.offset(0);
        make.height.mas_equalTo(FP_DefaultTabBarHeight - 3);
    }];
    
    [self.browseCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.bottom.equalTo(self.bottomView.mas_top).offset(0);
        make.left.right.offset(0);
        make.height.mas_equalTo(80);
    }];
    
    //如果存在默认方法
    if ([self.dataSource respondsToSelector:@selector(defaultItemIndexPath)]) {
        
        [self.collectionView scrollToItemAtIndexPath:self.dataSource.defaultItemIndexPath atScrollPosition:UICollectionViewScrollPositionRight animated:false];
        
        [self updateTopViewWithAsset:[self.dataSource assetAtIndexPath:self.dataSource.defaultItemIndexPath]];
    }
    
    //接收cell的单击通知
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(horBrowseTooBarChangedHiddenStateNotificationationHandler:) name:FPBrowseTooBarChangedHiddenStateNotification object:nil];
    
    //KVO
    [self.dataManager addObserver:self forKeyPath:@"count" options:NSKeyValueObservingOptionNew context:nil];
    [self.dataManager addObserver:self forKeyPath:@"hightQuality" options:NSKeyValueObservingOptionNew context:nil];
    
    //更新发送按钮
    [self updateBottomSendButton];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:true animated:true];
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:false animated:true];
    
    if (self.backHandler) {
        
        self.backHandler();
        
    }
    
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self resetCachedAssets];
}

- (void)resetCachedAssets
{
    [self.dataSource.imageManager stopCachingImagesForAllAssets];
    self.previousPreheatRect = CGRectZero;
}


- (BOOL)prefersStatusBarHidden
{
    return true;
}

- (void)dealloc
{
    if (self.isViewLoaded) {
        
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        [self.dataManager removeObserver:self forKeyPath:@"count"];
        [self.dataManager removeObserver:self forKeyPath:@"hightQuality"];
    }
    [self.dataSource.imageManager stopCachingImagesForAllAssets];

}

- (void)leftBarButtonDidPress:(UIButton *)sender{
    [self.collectionView.visibleCells makeObjectsPerformSelector:@selector(reset)];
    [self.navigationController popViewControllerAnimated:true];
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self updateCachedAssets];
    [self.collectionView.visibleCells makeObjectsPerformSelector:@selector(reset)];
    
    //进行计算当前第几个位置
    [self adjustScrollIndexWithContentOffset:scrollView.contentOffset scrollView:scrollView];
}


/// 进行计算当前第几个位置
- (void)adjustScrollIndexWithContentOffset:(CGPoint)contentOffset scrollView:(UIScrollView *)scrollView
{
    //根据四舍五入获得的index
    NSInteger index = [self indexOfCurrentAsset:scrollView];
    
    //获得资源
    PHAsset *currentAsset = [self.dataSource assetAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
    
    [self updateTopViewWithAsset:currentAsset];
}


/// 根据偏移量获得当前响应到资源
- (NSInteger)indexOfCurrentAsset:(UIScrollView *)scrollView
{
    //获得当前正常位置的偏移量
    CGFloat contentOffsetX = MIN(MAX(0,scrollView.contentOffset.x),scrollView.contentSize.width);
    
    CGFloat space = 2 * FPPhotosHorBrowseCollectionSpace;
    
    //根据四舍五入获得的index
    NSInteger index = @(round((contentOffsetX + space) * 1.0 / (space + FP_SCREEN_WIDTH))).integerValue;
    
    return index;
}

- (UICollectionViewCell *)currentCollectionCell{
    
    return [self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:[self indexOfCurrentAsset:self.collectionView] inSection:0]];
    
}



#pragma mark - Update View

- (void)updateTopViewWithAsset:(PHAsset *)asset
{
    BOOL isSelected = [self.dataManager containAsset:asset];
    
    FPPhotosConfig *configuration = self.config;
    
    if (!configuration.containVideo) {  //如果不包含视频
        
        self.topBar.statusButton.hidden = (asset.mediaType == PHAssetMediaTypeVideo);
    }
    
    //进行属性隐藏设置
    self.topBar.indexLabel.hidden = !isSelected;
    
    if (isSelected) {
        
        self.topBar.indexLabel.text = @([self.dataManager.phassetsIds indexOfObject:asset.localIdentifier] + 1).stringValue;
    }
}


/// 更新发送按钮
- (void)updateBottomSendButton
{
    NSInteger count = self.dataManager.count;
    
    UIControlState state = (count == 0 ? UIControlStateDisabled : UIControlStateNormal);
    
    NSString *title = (count == 0 ? @"发送" : [NSString stringWithFormat:@"发送(%@)",@(count)]);
    
    self.bottomView.sendButton.enabled = !(count == 0);
    [self.bottomView.sendButton setTitle:title forState:state];
}


#pragma mark - Getter


- (FPPhotoBrowseInteractiveTransition *)interactiveTransition{

    if (_interactiveTransition == nil) {
        _interactiveTransition = [[FPPhotoBrowseInteractiveTransition alloc] initWithController:self];
    }
    return _interactiveTransition;
}
-(UICollectionView *)collectionView
{
    if (_collectionView == nil)
    {
        UICollectionViewFlowLayout * flowLayout = [[UICollectionViewFlowLayout alloc]init];
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        flowLayout.minimumLineSpacing = 2 * FPPhotosHorBrowseCollectionSpace;
        
        flowLayout.sectionInset = UIEdgeInsetsMake(0, FPPhotosHorBrowseCollectionSpace, 0, FPPhotosHorBrowseCollectionSpace);
        flowLayout.itemSize = CGSizeMake(FP_SCREEN_WIDTH, FP_SCREEN_HEIGHT);
        
        _collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(-1 * FPPhotosHorBrowseCollectionSpace, 0, self.view.frame.size.width + 2 * FPPhotosHorBrowseCollectionSpace, self.view.frame.size.height) collectionViewLayout:flowLayout];
        _collectionView.backgroundColor = UIColor.blackColor;
        
        //初始化collectionView属性
        _collectionView.dataSource = self.dataSource;
        
        _collectionView.delegate = self;
        
        _collectionView.pagingEnabled = true;
        _collectionView.showsHorizontalScrollIndicator = false;
        
        //不使用自动适配
        if (@available(iOS 11.0,*)) {
            _collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
    }
    
    return _collectionView;
}


- (UICollectionView *)browseCollectionView
{
    if (_browseCollectionView == nil)
    {
        UICollectionViewFlowLayout * flowLayout = [[UICollectionViewFlowLayout alloc]init];
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;

        _browseCollectionView = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        _browseCollectionView.backgroundColor = self.bottomView.backgroundColor;
        _browseCollectionView.hidden = true;
        _browseCollectionView.pagingEnabled = true;
        _browseCollectionView.showsHorizontalScrollIndicator = false;
        
        //不使用自动适配
        if (@available(iOS 11.0,*)) {
            _browseCollectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
    }
    
    return _browseCollectionView;
}

#pragma mark - < UICollectionViewDelegate >

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    [cell reset];
}


#pragma mark - Notification

- (void)horBrowseTooBarChangedHiddenStateNotificationationHandler:(NSNotification *)notification
{
    NSNumber *hiddenResult = [notification.userInfo valueForKey:@"hidden"];
    
    if (hiddenResult) {//存在控制
        /*self.browseCollectionView.hidden = */self.topBar.hidden = self.bottomView.hidden = hiddenResult.boolValue;
    }else {
        BOOL beforeStatus = self.topBar.hidden;
        /*self.browseCollectionView.hidden = */self.topBar.hidden = self.bottomView.hidden = !beforeStatus;
    }
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"count"] && [object isEqual:self.dataManager]) {
        
        // 预览功能现在是屏蔽状态
        //self.bottomView.previewButton.enabled = !(count == 0);
        
        //发送按钮
        [self updateBottomSendButton];
    }
    
    else if([keyPath isEqualToString:@"hightQuality"] && [object isEqual:self.dataManager]){
        
        BOOL hightQuality = [change[NSKeyValueChangeNewKey] boolValue];
        self.bottomView.fullImageButton.selected = hightQuality;
    }
}


#pragma mark - action

- (void)hightQualityShouldChanged:(UIButton *)sender
{
    self.dataManager.hightQuality = !self.dataManager.hightQuality;
}


- (void)sendButtonDidClick:(UIButton *)sender
{
    [FPPhotosMaker.sharedInstance startMakePhotosComplete:^{

        [self.collectionView.visibleCells makeObjectsPerformSelector:@selector(reset)];
        [self.navigationController dismissViewControllerAnimated:true completion:nil];
    }];
}


- (void)assetStatusDidChanged:(UIButton *)sender
{
    //获得当前的资源
    PHAsset *asset = [self.dataSource assetAtIndexPath:[NSIndexPath indexPathForItem:[self indexOfCurrentAsset:self.collectionView] inSection:0]];
    
    //如果是添加，需要坚持数量
    if (self.dataManager.count >= self.config.maxPhotosCount &&
        ![self.dataManager containAsset:asset]/*是添加*/) { return; }//不能进行选择
    
    //进行修正
    [self.dataManager addOrRemoveAsset:asset];
    
    //更新top
    [self updateTopViewWithAsset:asset];
}

@end


@implementation FPPhotosBrowseController (FPCacheSetting)


- (void)updateCachedAssets
{
    if (!self.isViewLoaded || self.view.window == nil) { return; }
    
    //可视化
    CGRect visibleRect = CGRectMake(self.collectionView.contentOffset.x, self.collectionView.contentOffset.y, self.collectionView.frame.size.width, self.collectionView.frame.size.height);
    
    //进行拓展
    CGRect preheatRect = CGRectInset(visibleRect, -0.5 * visibleRect.size.width, 0);
    
    //只有可视化的区域与之前的区域有显著的区域变化才需要更新
    CGFloat delta = ABS(CGRectGetMidX(preheatRect) - CGRectGetMidX(self.previousPreheatRect));
    if (delta <= self.view.frame.size.width / 3.0) { return; }
    
    //获得比较后需要进行预加载以及需要停止缓存的区域
    NSDictionary *differences = [self differencesBetweenRects:self.previousPreheatRect new:preheatRect];
    NSArray <NSValue *> *addedRects = differences[FPHorBrowseDifferencesKeyAdded];
    NSArray <NSValue *> *removedRects = differences[FPHorBrowseDifferencesKeyRemoved];
    
    ///进行提前缓存的资源
    NSArray <PHAsset *> *addedAssets = [[[addedRects fp_map:^id _Nonnull(NSValue * _Nonnull rectValue) {
        return [self.collectionView indexPathsForElementsInRect:rectValue.CGRectValue];
        
    }] fp_reduce:@[] reduceHandler:^NSArray * _Nonnull(NSArray * _Nonnull result, NSArray <NSIndexPath *>*_Nonnull items) {
        return [result arrayByAddingObjectsFromArray:items];
        
    }] fp_map:^id _Nonnull(NSIndexPath *_Nonnull index) {
        
        return [self.dataSource assetAtIndexPath:index];
        
    }];
    
    ///提前停止缓存的资源
    NSArray <PHAsset *> *removedAssets = [[[removedRects fp_map:^id _Nonnull(NSValue * _Nonnull rectValue) {
        return [self.collectionView indexPathsForElementsInRect:rectValue.CGRectValue];
        
    }] fp_reduce:@[] reduceHandler:^NSArray * _Nonnull(NSArray * _Nonnull result, NSArray <NSIndexPath *>* _Nonnull items) {
        return [result arrayByAddingObjectsFromArray:items];
        
    }] fp_map:^id _Nonnull(NSIndexPath *_Nonnull index) {
        
        return [self.dataSource assetAtIndexPath:index];
    }];
    
    CGSize thimbnailSize = ((UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout).itemSize;
    
    //更新缓存
    [self.dataSource.imageManager startCachingImagesForAssets:addedAssets targetSize:thimbnailSize contentMode:PHImageContentModeAspectFill options:nil];
    [self.dataSource.imageManager stopCachingImagesForAssets:removedAssets targetSize:thimbnailSize contentMode:PHImageContentModeAspectFill options:nil];
    
    //记录当前位置
    self.previousPreheatRect = preheatRect;
}

- (NSDictionary <FPHorBrowseDifferencesKey*,NSArray<NSValue *>*> *)differencesBetweenRects:(CGRect)old new:(CGRect)new
{
    if (CGRectIntersectsRect(old, new)) {//如果区域交叉
        
        NSMutableArray <NSValue *> * added = [NSMutableArray arrayWithCapacity:10];
        if (CGRectGetMaxX(new) > CGRectGetMaxX(old)) {//表示左滑
            [added addObject:[NSValue valueWithCGRect:CGRectMake(CGRectGetMaxX(old), new.origin.y, CGRectGetMaxX(new) - CGRectGetMaxX(old), new.size.height)]];
        }
        
        if(CGRectGetMinX(old) > CGRectGetMinX(new)){//表示右滑
            
            [added addObject:[NSValue valueWithCGRect:CGRectMake(CGRectGetMinX(new), new.origin.y, CGRectGetMinX(old) - CGRectGetMinX(new), new.size.height)]];
        }
        
        NSMutableArray <NSValue *> * removed = [NSMutableArray arrayWithCapacity:10];
        if (CGRectGetMaxX(new) < CGRectGetMaxX(old)) {//表示右滑
            [removed addObject:[NSValue valueWithCGRect:CGRectMake(CGRectGetMinX(new), new.origin.y, CGRectGetMaxX(old) - CGRectGetMaxX(new), new.size.height)]];
        }
        
        if (CGRectGetMinX(old) < CGRectGetMinX(new)) {//表示左滑
            
            [removed addObject:[NSValue valueWithCGRect:CGRectMake(CGRectGetMinX(new), new.origin.y, CGRectGetMinX(new) - CGRectGetMinX(old), new.size.height)]];
        }
        
        return @{FPHorBrowseDifferencesKeyAdded:added,
                 FPHorBrowseDifferencesKeyRemoved:removed};
    }else {
        
        return @{FPHorBrowseDifferencesKeyAdded:@[[NSValue valueWithCGRect:new]],
                 FPHorBrowseDifferencesKeyRemoved:@[[NSValue valueWithCGRect:old]]};
    }
}






@end
