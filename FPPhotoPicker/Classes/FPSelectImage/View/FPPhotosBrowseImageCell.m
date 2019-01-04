

#import "FPPhotosBrowseImageCell.h"
#import <Masonry/Masonry.h>

#import "FPPhotoNotiConfig.h"
#import <Photos/Photos.h>

@interface FPPhotosBrowseImageCell ()<UIScrollViewDelegate,UIGestureRecognizerDelegate>

/// @brief 是否已经缩放的标志位
@property (nonatomic, assign)BOOL isScale;

/// @brief 底部负责滚动的滚动视图
@property (strong, nonatomic, readwrite) IBOutlet UIScrollView *bottomScrollView;

//手势
@property (nonatomic, strong) UITapGestureRecognizer * simpleTapGesture;
@property (nonatomic, strong) UITapGestureRecognizer * doubleTapGesture;
/// 滑动手势
@property (nonatomic, strong) UIPanGestureRecognizer * panTapGesture;

/// @brief 缩放比例
@property (nonatomic, assign) CGFloat minScaleZoome;
@property (nonatomic, assign) CGFloat maxScaleZoome;

@end

@implementation FPPhotosBrowseImageCell

-(void)dealloc
{

}

-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self browerCellLoad];
    }
    
    return self;
}


- (void)browerCellLoad
{
    self.minScaleZoome = 1.0f;
    self.maxScaleZoome = 2.0f;
    
    [self createBottomScrollView];
    [self createImageView];
    [self createDoubleTapGesture];
    [self createSimpleTapGesture];
}


-(void)prepareForReuse
{
    _imageView.image = nil;
    _bottomScrollView.zoomScale = 1.0f;
}


#pragma mark - create Subviews
- (void)createBottomScrollView
{
    if (self.bottomScrollView == nil)
    {
        self.bottomScrollView = [[UIScrollView alloc]init];
        self.bottomScrollView.backgroundColor = [UIColor blackColor];
        self.bottomScrollView.delegate = self;
        self.bottomScrollView.bounces = false;
        self.bottomScrollView.minimumZoomScale = self.minScaleZoome;
        self.bottomScrollView.maximumZoomScale = self.maxScaleZoome;
        [self.contentView addSubview:self.bottomScrollView];
        
//        self.panTapGesture = UIPanGestureRecognizer.new;
//        self.panTapGesture.delegate = self;
//        [self.bottomScrollView addGestureRecognizer:self.panTapGesture];
        
        __weak typeof(self) weakSelf = self;
        
        //添加约束
        [self.bottomScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(weakSelf.contentView).offset(0);
        }];
    }
}


- (void)createImageView
{
    if (self.imageView == nil)
    {
        self.imageView = [[UIImageView alloc]init];
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.bottomScrollView addSubview:self.imageView];
        
        __weak typeof(self) weakSelf = self;
        
        [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.edges.equalTo(weakSelf.bottomScrollView);
            make.width.equalTo(weakSelf.bottomScrollView.mas_width);
            make.height.equalTo(weakSelf.bottomScrollView.mas_height);
        }];
    }
}


- (void)createDoubleTapGesture
{
    if (self.doubleTapGesture == nil)
    {
        self.doubleTapGesture = [UITapGestureRecognizer new];
        self.doubleTapGesture.numberOfTapsRequired = 2;
        [self.bottomScrollView addGestureRecognizer:self.doubleTapGesture];
        
        [self.doubleTapGesture addTarget:self action:@selector(doubleTapGestureRecognizerDidPress:)];
        
    }
}

- (void)doubleTapGestureRecognizerDidPress:(UITapGestureRecognizer *)sender{
    
    
    if (self.bottomScrollView.zoomScale != 1.0f){
        [self.bottomScrollView setZoomScale:1.0f animated:true];
    }
    else{
        CGFloat width = self.frame.size.width;//获得Cell的宽度
        CGFloat scale = width / self.maxScaleZoome;//触及范围
        CGPoint point = [sender locationInView:self.imageView];//获取当前的触摸点
        
        //对点进行处理
        CGFloat originX = MAX(0, point.x - width / scale);
        CGFloat originY = MAX(0, point.y - width / scale);
        
        //进行位置的计算
        CGRect rect = CGRectMake(originX, originY, width / scale , width / scale);
        [self.bottomScrollView zoomToRect:rect animated:true];//进行缩放
    }
}

- (void)createSimpleTapGesture
{
    if (self.simpleTapGesture == nil)
    {
        self.simpleTapGesture = [UITapGestureRecognizer new];
        self.simpleTapGesture.numberOfTapsRequired = 1;
        [self.simpleTapGesture requireGestureRecognizerToFail:self.doubleTapGesture];
        [self.bottomScrollView addGestureRecognizer:self.simpleTapGesture];
        [self.simpleTapGesture addTarget:self action:@selector(simpleTapGestureRecognizerDidPress:)];
    }
}

- (void)simpleTapGestureRecognizerDidPress:(UITapGestureRecognizer *)sender{
    [NSNotificationCenter.defaultCenter postNotificationName:FPBrowseTooBarChangedHiddenStateNotification object:nil];
}

#pragma mark - <UIScrollViewDelegate>
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}


- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(nullable UIView *)view atScale:(CGFloat)scale
{
    NSLog(@"scale - zoom = %@",@(scale));
    [scrollView setZoomScale:scale animated:true];
    NSLog(@"imageView = %@",@(self.imageView.bounds));
    
    
}



/// 默认不做任何事情
- (void)updateAssets:(PHAsset *)asset
         atIndexPath:(nonnull NSIndexPath *)indexPath
        imageManager:(PHCachingImageManager *)cacheManager
{
    self.representedAssetIdentifier = asset.localIdentifier;
    self.currentAsset = asset;
    
    PHImageRequestOptions *options = PHImageRequestOptions.new;
    options.networkAccessAllowed = true;
    
    [cacheManager requestImageForAsset:asset targetSize:CGSizeMake(asset.pixelWidth, asset.pixelHeight) contentMode:PHImageContentModeAspectFill options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        
        //如果标志位一样
        if ([self.representedAssetIdentifier isEqualToString:asset.localIdentifier]) {//进行赋值操作
            
            [self updateViews:result info:info];
        }
    }];
}

- (void)updateViews:(UIImage *)image info:(NSDictionary *)info
{
    //适配长图
    self.imageView.image = image;
    //对缩放进行适配
    CGFloat height = self.currentAsset.pixelHeight / 2;
    CGFloat width = self.currentAsset.pixelWidth / 2;
    CGFloat max = MAX(width, height);
    CGFloat scale = 2.0;
    if (height > width) {
        scale = max / MAX(1,self.imageView.bounds.size.height);
    }else {
        scale = max / MAX(1,self.imageView.bounds.size.width);
    }
    self.bottomScrollView.maximumZoomScale = MAX(2.0,scale);
}

- (void)reset {
    self.bottomScrollView.maximumZoomScale = 2.0;
    [self.bottomScrollView setZoomScale:1.0];
}


@end
