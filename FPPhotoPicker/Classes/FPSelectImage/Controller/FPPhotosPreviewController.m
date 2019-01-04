//
//  FPPhotosPreviewController.m
//  判断相片是否存在
//
//  Created by 金医桥 on 2018/12/4.
//  Copyright © 2018 forping. All rights reserved.
//

#import "FPPhotosPreviewController.h"
#import <Photos/Photos.h>
#import <Masonry/Masonry.h>

@interface FPPhotosPreviewController ()

@property (nonatomic, strong)PHImageManager *imageManager;
@property (nonatomic, strong)UIImageView *imageView;

@end

@implementation FPPhotosPreviewController

- (instancetype)init
{
    if (self = [super init]) {
        
        self.imageManager = [[PHCachingImageManager alloc] init];
    }
    
    return self;
}

-(instancetype)initWithShowAsset:(PHAsset *)showAsset
{
    if (self = [self init]){
        
        _showAsset = showAsset;
    }
    return self;
}


+(instancetype)previewWithShowAsset:(PHAsset *)showAsset
{
    return [[self alloc]initWithShowAsset:showAsset];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //获得图片的宽度与高度的比例
    CGFloat scale = self.showAsset.pixelHeight * 1.0 / self.showAsset.pixelWidth;
    CGSize assetSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.width * scale);
    
    // 设置 弹出框当前的大小
    self.preferredContentSize = assetSize;
    
    //进行约束布局
    self.imageView = [UIImageView new];
    [self.view addSubview:self.imageView];
    
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.edges.equalTo(self.view);
    }];
    
    self.imageView.backgroundColor = [UIColor whiteColor];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.imageView.layer.cornerRadius = 8;
    self.imageView.clipsToBounds = true;
    
    [self.imageManager requestImageForAsset:self.showAsset targetSize:CGSizeMake(self.showAsset.pixelWidth, self.showAsset.pixelHeight)  contentMode:PHImageContentModeAspectFit options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        
        self.imageView.image = result;
    }];
}

-(void)dealloc
{
    self.imageView.image = nil;
}
@end
