
#import "FPPhotosBrowseVideoCell.h"
#import "NSBundle+FPPhotos.h"

#import <Masonry/Masonry.h>
#import <Photos/Photos.h>
#import "FPPhotoNotiConfig.h"

//static NSString *const RITLPhotosBrowseVideoCellVideoImageName = @"RITLPhotos.bundle/ritl_video_play";

@interface FPPhotosBrowseVideoCell ()
@property (nonatomic, strong)UITapGestureRecognizer *tapGestureRecognizer;

@end

@implementation FPPhotosBrowseVideoCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        [self buildViews];
    }
    
    return self;
}


- (void)buildViews
{
    self.contentView.backgroundColor = UIColor.blackColor;
    
    self.imageView = [[UIImageView alloc]init];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;

    [self.contentView addSubview:self.imageView];
    
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.edges.offset(0);
    }];
    
    self.playImageView = ({
        
        UIImageView *imageView = [UIImageView new];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.image = /*RITLPhotosBrowseVideoCellVideoImageName.ritl_image*/NSBundle.fp_video_play;
        
        imageView;
    });
    
    [self.contentView addSubview:self.playImageView];
    
    [self.playImageView mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.height.width.mas_equalTo(80);
        make.center.offset(0);
    }];
    
    //追加点击时间
    self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] init];
    self.tapGestureRecognizer.numberOfTapsRequired = 1;
    [self.tapGestureRecognizer addTarget:self action:@selector(tapGestureRecognizerDidPress:)];
    [self.contentView addGestureRecognizer:self.tapGestureRecognizer];
    
 

}

- (void)tapGestureRecognizerDidPress:(UITapGestureRecognizer *)sender{
    
    if (!self.playerLayer) { [self playerAsset]; return; }//如果是stop，就进行播放
    [self reset];
}


- (void)updateViews:(UIImage *)image info:(NSDictionary *)info
{
    self.imageView.image = image;
}

- (void)playerAsset
{
    if (!self.currentAsset || self.currentAsset.mediaType != PHAssetMediaTypeVideo) {  return; }
    
    if (self.playerLayer && self.playerLayer.player) {//直接播放即可
        
        //进行对比
        [self.playerLayer.player play]; return;
    }
    
    PHVideoRequestOptions *options = PHVideoRequestOptions.new;
    options.networkAccessAllowed = true;
    options.deliveryMode = PHVideoRequestOptionsDeliveryModeAutomatic;
    
    //开始请求
    [PHImageManager.defaultManager requestPlayerItemForVideo:self.currentAsset options:options resultHandler:^(AVPlayerItem * _Nullable playerItem, NSDictionary * _Nullable info) {
        
        if (!playerItem) { return; }
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            
            AVPlayer *player = [[AVPlayer alloc]initWithPlayerItem:playerItem];
            self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:player];
            
            //Notication
            [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(reset) name:AVPlayerItemDidPlayToEndTimeNotification object:player.currentItem];
            
            //config
            self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
            self.playerLayer.frame = self.imageView.layer.bounds;
            self.playImageView.hidden = true;
            [self.imageView.layer addSublayer:self.playerLayer];
            
            [[NSNotificationCenter defaultCenter]postNotificationName:FPBrowseTooBarChangedHiddenStateNotification object:self userInfo:@{@"hidden":@(true)}];
            [player play];//播放
        });
    }];
}



- (void)reset
{
    if (self.playerLayer && self.playerLayer.player) {
        
        [[NSNotificationCenter defaultCenter]postNotificationName:FPBrowseTooBarChangedHiddenStateNotification object:nil userInfo:@{@"hidden":@(false)}];
        [self.playerLayer.player pause];;
        [self.playerLayer removeFromSuperlayer];//移除
        [NSNotificationCenter.defaultCenter removeObserver:self];
        
        self.playImageView.hidden = false;
        self.playerLayer = nil;
    }
}


- (void)prepareForReuse
{
    if (self.playerLayer.superlayer) {
        
        [self.playerLayer removeFromSuperlayer];
        self.playerLayer = nil;
    }
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
