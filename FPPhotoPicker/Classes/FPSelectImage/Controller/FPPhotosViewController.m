//
//  FPPhotosViewController.m
//  判断相片是否存在
//
//  Created by 金医桥 on 2018/12/3.
//  Copyright © 2018 forping. All rights reserved.
//

#import "FPPhotosViewController.h"
#import "FPPhotosGroupController.h"
#import "FPPhotosSelectController.h"
#import "FPPhotosDataManger.h"
#import "FPPhotosMaker.h"

@interface FPPhotosViewController ()
@property (nonatomic , strong) FPPhotosConfig *config;

@property (nonatomic , strong) FPPhotosMaker *maker;
@property (nonatomic , strong) FPPhotosDataManger *dataManger;

@end

@implementation FPPhotosViewController

- (instancetype)init{
 
    if (self = [super init]) {
        self.config = [[FPPhotosConfig alloc] init];
        
        self.maker = [FPPhotosMaker sharedInstance];
        self.maker.configuration = self.config;
        self.maker.bindViewController = self;
        self.dataManger = [FPPhotosDataManger sharedInstance];
        
        FPPhotosGroupController *groupController = [[FPPhotosGroupController alloc] init];
        FPPhotosSelectController *selectController = [[FPPhotosSelectController alloc] init];
        
        groupController.configuration = self.config;
        selectController.config = self.config;
        
        self.viewControllers = @[groupController, selectController];
    }
    return self;
}


- (void)setPhotoDelegate:(id<FPPhotosViewControllerDelegate>)photoDelegate{
    
    _photoDelegate = photoDelegate;
    
    self.maker.delegate = photoDelegate;
}

-(void)setDefaultIdentifers:(NSArray<NSString *> *)defaultIdentifers{
    
    _defaultIdentifers = defaultIdentifers;
    self.dataManger.defaultIdentifers = _defaultIdentifers;
}


- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    
}

@end
