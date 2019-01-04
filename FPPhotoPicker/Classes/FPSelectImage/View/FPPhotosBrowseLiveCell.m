
#import "FPPhotosBrowseLiveCell.h"

#import <PhotosUI/PhotosUI.h>
#import <Masonry/Masonry.h>

#import "FPUnility.h"

@interface FPPhotosBrowseLiveCell() <PHLivePhotoViewDelegate>

/// 是否是按压唤醒
@property (nonatomic, assign)BOOL isForce;
@property (nonatomic, strong)UITapGestureRecognizer *tapGestureRecognizer;

@end

@implementation FPPhotosBrowseLiveCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        [self buildViews];
    }
    return self;
}


- (void)prepareForReuse
{
    [self reset];
}


- (void)buildViews
{
    self.isPlaying = false;
    self.imageView = [[UIImageView alloc]init];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    
  
    [self.contentView addSubview:self.imageView];

    self.livePhotoView = ({
        
        PHLivePhotoView *view = [PHLivePhotoView new];
        view.hidden = true;
        view.delegate = self;
        view.userInteractionEnabled = false;
        
        view;
    });
    
    [self.contentView addSubview:self.livePhotoView];
 
    
    
    self.liveBadgeImageView = ({
        
        UIImageView *imageView = [UIImageView new];
        imageView.backgroundColor = UIColor.clearColor;
        imageView.contentMode = UIViewContentModeScaleToFill;
        imageView.image = [PHLivePhotoView livePhotoBadgeImageWithOptions:PHLivePhotoBadgeOptionsOverContent];
        
        imageView;
    });
  

    [self.contentView addSubview:self.liveBadgeImageView];
    
    
    self.liveLabel = ({
        
        UILabel *label = [UILabel new];
        label.text = @"Live";
        label.font = [UIFont systemFontOfSize:14.0f];
        label.textColor = UIColor.whiteColor;
        
        label;
    });
    
    [self.contentView addSubview:self.liveLabel];

    [self.liveBadgeImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.height.width.mas_equalTo(25);
        make.left.offset(10);
        make.top.offset(FP_DefaultNaviBarHeight + 18);
    }];
    
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.edges.offset(0);
    }];
    
    [self.liveLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.centerY.equalTo(self.liveBadgeImageView);
        make.left.equalTo(self.liveBadgeImageView.mas_right).offset(3);
    }];
    
    
    [self.livePhotoView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.center.equalTo(self.imageView);
    }];
    
    //追加点击事件
    self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] init];
    self.tapGestureRecognizer.numberOfTapsRequired = 1;
    [self.tapGestureRecognizer addTarget:self action:@selector(tapGestureRecognizerDidPress:)];
    [self.contentView addGestureRecognizer:self.tapGestureRecognizer];
}

- (void)tapGestureRecognizerDidPress:(UITapGestureRecognizer *)sender{
    
    if (self.isPlaying) { [self reset]; return; }
    
    else if (!self.isPlaying && self.livePhotoView.hidden) {//处理0.2秒的延迟
        [self playerAsset];
    }
}


- (void)reset
{
    if (self.isPlaying) {
        [self.livePhotoView stopPlayback];
    }
}

- (void)playerAsset
{
    if (!self.currentAsset || self.currentAsset.mediaSubtypes != PHAssetMediaSubtypePhotoLive) {  return; }
    
    [self layoutIfNeeded];//重新布局
    
    //请求播放
    PHLivePhotoRequestOptions *options = PHLivePhotoRequestOptions.new;
    options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    options.networkAccessAllowed = true;
    
    [PHImageManager.defaultManager requestLivePhotoForAsset:self.currentAsset targetSize:CGSizeMake(self.currentAsset.pixelWidth,self.currentAsset.pixelHeight) contentMode:PHImageContentModeAspectFill options:options resultHandler:^(PHLivePhoto * _Nullable livePhoto, NSDictionary * _Nullable info) {
        
        if (!livePhoto) { return; }
        
        self.livePhotoView.livePhoto = livePhoto;
        
        if (!self.isPlaying) {
            [self.livePhotoView startPlaybackWithStyle:PHLivePhotoViewPlaybackStyleHint];
        }
    }];
}


- (void)updateViews:(UIImage *)image info:(NSDictionary *)info
{
    self.imageView.image = image;
    
    //设置
    [self.livePhotoView mas_remakeConstraints:^(MASConstraintMaker *make) {
        
        make.center.equalTo(self.imageView);
        make.width.equalTo(self.imageView);
        make.height.mas_equalTo(FP_SCREEN_WIDTH * self.currentAsset.pixelHeight / self.currentAsset.pixelWidth);
    }];
}





#pragma mark - <PHLivePhotoViewDelegate>

- (void)livePhotoView:(PHLivePhotoView *)livePhotoView willBeginPlaybackWithStyle:(PHLivePhotoViewPlaybackStyle)playbackStyle
{
    self.isPlaying = true;
    self.livePhotoView.hidden = false;
}

- (void)livePhotoView:(PHLivePhotoView *)livePhotoView didEndPlaybackWithStyle:(PHLivePhotoViewPlaybackStyle)playbackStyle
{
    self.isPlaying = false;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.livePhotoView.hidden = true;
    });
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

@end
