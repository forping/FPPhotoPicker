

#import <UIKit/UIKit.h>

@class PHAsset, PHLivePhotoView, PHCachingImageManager;

NS_ASSUME_NONNULL_BEGIN

/// 装载live图片的cell
NS_CLASS_AVAILABLE_IOS(9_1) @interface FPPhotosBrowseLiveCell : UICollectionViewCell

/// 显示图片的imageView
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
/// 支持iOS9.1之后的livePhoto
@property (nonatomic, strong) UIImageView *liveBadgeImageView;
/// 用于描述
@property (nonatomic, strong) UILabel *liveLabel;
/// 用于播放的视图
@property (nonatomic, strong) PHLivePhotoView *livePhotoView;
/// 是否播放
@property (nonatomic, assign) BOOL isPlaying;

@property (nonatomic , nullable)PHAsset *currentAsset;
@property (nonatomic, copy) NSString *representedAssetIdentifier;



@end

NS_ASSUME_NONNULL_END
