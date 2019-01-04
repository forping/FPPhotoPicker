//
//  FPPhotoBrowseInteractiveTransition.m
//  判断相片是否存在
//
//  Created by 金医桥 on 2018/12/12.
//  Copyright © 2018 forping. All rights reserved.
//

#import "FPPhotoBrowseInteractiveTransition.h"
#import "FPPhotoNotiConfig.h"
#import "FPPhotosBrowseController.h"
#import "FPPhotosSelectController.h"

#import "FPPhotosCell.h"

#import "UICollectionViewCell+FPPhotos.h"
#import "FPPhotosBrowseImageCell.h"
#import "FPPhotosBrowseLiveCell.h"
#import "FPPhotosBrowseVideoCell.h"

@interface FPPhotoBrowseInteractiveTransition ()

@property (nonatomic, weak) id<UIViewControllerContextTransitioning> transitionContext;

@property (nonatomic , strong) UIViewController *controller;


@property (nonatomic, assign) CGFloat beginX;
@property (nonatomic, assign) CGFloat beginY;

@property (nonatomic , strong) UIView *bgView;

@property (nonatomic , strong) UIImageView *tempImageView; //
@property (nonatomic, assign) CGPoint transitionImgViewCenter;

@property (nonatomic , strong) UICollectionViewCell *fromCell;
@property (weak, nonatomic) FPPhotosCell *tempCell;


// 播放用的
@property (strong, nonatomic) AVPlayerLayer *playerLayer;

@end

@implementation FPPhotoBrowseInteractiveTransition
- (instancetype)initWithController:(UIViewController *)viewController{
    if (self = [super init]) {
        self.controller = viewController;
        
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognizeDidPress:)];
        [viewController.view addGestureRecognizer:pan];
    }
    return self;
}

- (void)panGestureRecognizeDidPress:(UIPanGestureRecognizer *)sender{
    
    CGFloat scale = 0;
    
    CGPoint translation = [sender translationInView:sender.view];
    CGFloat transitionY = translation.y;
    scale = transitionY / ((sender.view.frame.size.height) / 2);
    if (scale > 1.f) {
        scale = 1.f;
    }
    
    switch (sender.state) {
            
        case UIGestureRecognizerStateBegan:
            
            NSLog(@"UIGestureRecognizerStateBegan");
            
            if (scale < 0) {
                [sender cancelsTouchesInView];
                return;
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:FPBrowseTooBarChangedHiddenStateNotification object:nil];
            
            self.beginX = [sender locationInView:sender.view].x;
            self.beginY = [sender locationInView:sender.view].y;
            
            self.interation = YES;
            
            [self.controller.navigationController popViewControllerAnimated:YES];
            break;
            
        case UIGestureRecognizerStateChanged:
            
            if (self.interation == NO) {return;}
        
            if (scale < 0.f) {
                scale = 0.f;
            }
            CGFloat imageViewScale = 1 - scale * 0.5;
            if (imageViewScale < 0.4) {
                imageViewScale = 0.4;
            }
            self.tempImageView.center = CGPointMake(self.transitionImgViewCenter.x + translation.x, self.transitionImgViewCenter.y + translation.y);
            self.tempImageView.transform = CGAffineTransformMakeScale(imageViewScale, imageViewScale);
            
            [self updateInterPercent:1 - scale * scale];
            [self updateInteractiveTransition:scale];
            
            break;
        case UIGestureRecognizerStateEnded:
            if (self.interation) {
                if (scale < 0.f) {
                    scale = 0.f;
                }
                self.interation = NO;
                if (scale < 0.15f){
                    NSLog(@"cancelInteractiveTransition");
                    [self cancelInteractiveTransition];
                    
                    [self interPercentCancel];
                }else {
                    NSLog(@"finishInteractiveTransition");
                    [self finishInteractiveTransition];
                    [self interPercentFinish];
                }
            }
            break;
        default:
            
            if (self.interation) {
                self.interation = NO;
                NSLog(@"cancelInteractiveTransition");
                [self interPercentCancel];
                [self cancelInteractiveTransition];
            }
            
            break;
    }
}


- (void)startInteractiveTransition:(id<UIViewControllerContextTransitioning>)transitionContext{
    
    NSLog(@"startInteractiveTransition");
    
    self.transitionContext = transitionContext;
 
    [self beginInterPercent];
}


- (void)beginInterPercent{
    
    id<UIViewControllerContextTransitioning> transitionContext = self.transitionContext;

    FPPhotosBrowseController *fromVC = (FPPhotosBrowseController *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    FPPhotosSelectController *toVC = (FPPhotosSelectController *)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    self.fromCell = [fromVC currentCollectionCell];
    
    

    UIView *containerView = [transitionContext containerView];

    CGRect tempImageViewFrame;

    if ([self.fromCell isKindOfClass:[FPPhotosBrowseImageCell class]]) {
        FPPhotosBrowseImageCell *fromCell = (FPPhotosBrowseImageCell*)self.fromCell;
        
        self.tempImageView = (UIImageView *)[fromCell.imageView snapshotViewAfterScreenUpdates:NO];

        NSLog(@"%@",NSStringFromCGRect(self.tempImageView.frame));
        
        tempImageViewFrame = [fromCell.imageView convertRect:fromCell.imageView.bounds toView:containerView];
        
    }
    else if ([self.fromCell isKindOfClass:[FPPhotosBrowseVideoCell class]]){
        FPPhotosBrowseVideoCell *fromCell = (FPPhotosBrowseVideoCell*)self.fromCell;

        if(!fromCell.playerLayer.player){
            
            
            self.tempImageView = (UIImageView *)[fromCell.imageView snapshotViewAfterScreenUpdates:NO];
            tempImageViewFrame = [fromCell.imageView convertRect:fromCell.imageView.bounds toView:containerView];
            
        }
        else{
            tempImageViewFrame = containerView.bounds;
            [fromCell.playerLayer removeFromSuperlayer];
            self.playerLayer = fromCell.playerLayer;
            self.tempImageView = [[UIImageView alloc] init];
            self.tempImageView.layer.masksToBounds = YES;
            [self.tempImageView.layer addSublayer:self.playerLayer];
            
        }
    }
    else if (@available(iOS 9.1, *)){
        if( [self.fromCell isKindOfClass:[FPPhotosBrowseLiveCell class]]) {
            
            FPPhotosBrowseLiveCell *fromCell = (FPPhotosBrowseLiveCell*)self.fromCell;
            
            self.tempImageView = (UIImageView *)[fromCell.imageView snapshotViewAfterScreenUpdates:NO];
            
            tempImageViewFrame = [fromCell.imageView convertRect:fromCell.imageView.bounds toView:containerView];
        }
    }
    else {
    }
    
    self.tempImageView.clipsToBounds = YES;
    self.tempImageView.contentMode = UIViewContentModeScaleAspectFill;
    
    //BOOL contains = toCell != nil
    self.bgView = [[UIView alloc] initWithFrame:containerView.bounds];
    self.bgView.backgroundColor = [UIColor blackColor];
    

    // 设置锚点
    CGFloat scaleX;
    CGFloat scaleY;
    if (self.beginX < tempImageViewFrame.origin.x) {
        scaleX = 0;
    }else if (self.beginX > CGRectGetMaxX(tempImageViewFrame)) {
        scaleX = 1.0f;
    }else {
        scaleX = (self.beginX - tempImageViewFrame.origin.x) / tempImageViewFrame.size.width;
    }
    if (self.beginY < tempImageViewFrame.origin.y) {
        scaleY = 0;
    }else if (self.beginY > CGRectGetMaxY(tempImageViewFrame)){
        scaleY = 1.0f;
    }else {
        scaleY = (self.beginY - tempImageViewFrame.origin.y) / tempImageViewFrame.size.height;
    }
    
    self.tempImageView.layer.anchorPoint = CGPointMake(scaleX, scaleY);
    self.tempImageView.frame = tempImageViewFrame;
    self.transitionImgViewCenter = self.tempImageView.center;

    [containerView addSubview:toVC.view];
//    [containerView addSubview:fromVC.view];
    
    [toVC.view insertSubview:self.bgView belowSubview:toVC.bottomView];
    [toVC.view insertSubview:self.tempImageView belowSubview:toVC.bottomView];
    
//    if (!fromVC.bottomView.userInteractionEnabled) { //
//        self.bgView.backgroundColor = [UIColor blackColor];
//        [[UIApplication sharedApplication] setStatusBarHidden:NO];
//        [toVC.navigationController setNavigationBarHidden:NO];
//        toVC.navigationController.navigationBar.alpha = 0;
//        toVC.bottomView.alpha = 0;
//    }else {
//        self.bgView.backgroundColor = [UIColor whiteColor];
//    }
    
//    toVC.navigationController.navigationBar.userInteractionEnabled = NO;
    
    FPPhotosCell *toCell = [toVC currentBrowseCellWithAsset:self.fromCell.currentAsset scrollTo:YES];
    
    fromVC.view.hidden = YES;
    
    toCell.hidden = YES;
    self.tempCell = toCell;
}

- (void)updateInterPercent:(CGFloat)scale{
    
    //FPPhotosBrowseController *fromVC = (FPPhotosBrowseController *)[self.transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    //fromVC.view.alpha = scale;
    self.bgView.alpha = scale;
    
//    if (!fromVC.bottomView.userInteractionEnabled && fromVC.bottomView.hidden == NO) {
//        FPPhotosSelectController *toVC = (FPPhotosSelectController *)[self.transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
//        toVC.bottomView.alpha = 1 - scale;
//        //toVC.navigationController.navigationBar.alpha = 1 - scale;
//    }
}

- (void)interPercentCancel{
    NSLog(@"interPercentCancel");
    id<UIViewControllerContextTransitioning> transitionContext = self.transitionContext;
    FPPhotosBrowseController *fromVC = (FPPhotosBrowseController *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
//
//    if (!fromVC.bottomView.userInteractionEnabled) {
//        [[UIApplication sharedApplication] setStatusBarHidden:YES];
//        [toVC.navigationController setNavigationBarHidden:YES];
//        toVC.navigationController.navigationBar.alpha = 1;
//    }
    [UIView animateWithDuration:0.2f animations:^{
        fromVC.view.alpha = 1;
        self.tempImageView.transform = CGAffineTransformIdentity;
        self.tempImageView.center = self.transitionImgViewCenter;
        self.bgView.alpha = 1;
//        if (!fromVC.bottomView.userInteractionEnabled) {
//            toVC.bottomView.alpha = 0;
//        }
    } completion:^(BOOL finished) {
//        toVC.navigationController.navigationBar.userInteractionEnabled = YES;
        fromVC.view.hidden = NO;
//        if (!fromVC.bottomView.userInteractionEnabled) {
//            fromVC.view.backgroundColor = [UIColor blackColor];
//        }else {
//            fromVC.view.backgroundColor = [UIColor whiteColor];
//        }
        self.tempCell.hidden = NO;
        self.tempCell = nil;
        [self.tempImageView removeFromSuperview];
        self.tempImageView = nil;
        if ([self.fromCell isKindOfClass:[FPPhotosBrowseVideoCell class]]){
            [((FPPhotosBrowseVideoCell*)self.fromCell).imageView.layer addSublayer:self.playerLayer];
        }
        self.playerLayer = nil;
        [self.bgView removeFromSuperview];
        self.bgView = nil;
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
    }];
}

//完成
- (void)interPercentFinish {
    NSLog(@"interPercentFinish");
    id<UIViewControllerContextTransitioning> transitionContext = self.transitionContext;
    UIView *containerView = [transitionContext containerView];
//    FPPhotosBrowseController *fromVC = (FPPhotosBrowseController *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    FPPhotosSelectController *toVC = (FPPhotosSelectController *)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    NSTimeInterval duration = 1.0f;
    UIViewAnimationOptions option = UIViewAnimationOptionCurveEaseOut;
    
    CGRect tempImageViewFrame = self.tempImageView.frame;
    self.tempImageView.layer.anchorPoint = CGPointMake(0.5, 0.5);
    self.tempImageView.transform = CGAffineTransformIdentity;
    self.tempImageView.frame = tempImageViewFrame;
    self.playerLayer.frame = CGRectMake(0, 0, self.tempCell.imageView.frame.size.width, self.tempCell.imageView.frame.size.height);
    
    [UIView animateWithDuration:0.3 delay:0.0 usingSpringWithDamping:0.8 initialSpringVelocity:0.1 options:option animations:^{
        if (self.tempCell) {
            self.tempImageView.transform = CGAffineTransformIdentity;

            self.tempImageView.frame = [self.tempCell convertRect:self.tempCell.bounds toView:containerView];


        }else {
            self.tempImageView.center = self.transitionImgViewCenter;
            self.tempImageView.alpha = 0;
            self.tempImageView.transform = CGAffineTransformMakeScale(0.3, 0.3);
        }

        self.bgView.alpha = 0;
//        toVC.navigationController.navigationBar.alpha = 1;
        toVC.bottomView.alpha = 1;

    }completion:^(BOOL finished) {
//        toVC.navigationController.navigationBar.userInteractionEnabled = YES;
//        [self.tempCell bottomViewPrepareAnimation];
        self.tempCell.hidden = NO;
        //        [self.tempCell bottomViewStartAnimation];
        self.playerLayer = nil;
        [self.tempImageView removeFromSuperview];
        [self.bgView removeFromSuperview];

        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
    }];
}


@end
