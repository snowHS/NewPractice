//
//  PhotosViewController.m
//  NewPractice
//
//  Created by SL123 on 2019/8/27.
//  Copyright © 2019 SL123. All rights reserved.
//

#import "PhotosViewController.h"
#import "RITLPhotosViewController.h"
@interface PhotosViewController ()<RITLPhotosViewControllerDelegate>
@property (nonatomic, copy)NSArray <UIImage *> * assets;
@property (nonatomic, copy)NSArray <NSString *> *saveAssetIds;
@end

@implementation PhotosViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"相册多选";
    UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn addTarget:self action:@selector(selectPhotoes) forControlEvents:UIControlEventTouchUpInside];
    [btn setTitle:@"选择图片" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [btn setBackgroundColor:[UIColor redColor]];
    [self.view addSubview:btn];
    [btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(100);
        make.left.mas_equalTo(100);
        make.right.mas_equalTo(-100);
        make.height.mas_equalTo(50);
    }];
}
-(void)selectPhotoes
{
    RITLPhotosViewController *photoController = RITLPhotosViewController.photosViewController;
    photoController.configuration.maxCount = 5;//最大的选择数目
    photoController.configuration.containVideo = false;//选择类型，目前只选择图片不选择视频
    photoController.configuration.hiddenGroupWhenNoPhotos = true;//当相册不存在照片的时候隐藏
    photoController.photo_delegate = self;
//    photoController.thumbnailSize = self.assetSize;//缩略图的尺寸
    photoController.defaultIdentifers = self.saveAssetIds;//记录已经选择过的资源
    
    [self presentViewController:photoController animated:true completion:^{}];
}




#pragma mark - RITLPhotosViewControllerDelegate
/**
 即将消失的回调
 
 @param viewController RITLPhotosViewController
 */
- (void)photosViewControllerWillDismiss:(UIViewController *)viewController
{
    NSLog(@"即将消失的回调");
}


/**
 选中图片以及视频等资源的本地identifer
 可用于设置默认选好的资源
 
 @param viewController RITLPhotosViewController
 @param identifiers 选中资源的本地标志位
 */
- (void)photosViewController:(UIViewController *)viewController
            assetIdentifiers:(NSArray <NSString *> *)identifiers
{
    NSLog(@"选择完图片了");
}


/**
 选中图片以及视频等资源的默认缩略图
 根据thumbnailSize设置所得，如果thumbnailSize为.Zero,则不进行回调
 与是否原图无关
 
 @param viewController RITLPhotosViewController
 @param thumbnailImages 选中资源的缩略图
 @param infos 选中图片的缩略图信息
 */
- (void)photosViewController:(UIViewController *)viewController
             thumbnailImages:(NSArray <UIImage *> *)thumbnailImages
                       infos:(NSArray <NSDictionary *> *)infos
{
    
}


/**
 选中图片以及视频等资源的原比例图片
 适用于不使用缩略图，或者展示高清图片
 与是否原图无关
 
 @param viewController RITLPhotosViewController
 @param images 选中资源的原比例图
 @param infos 选中图片的原比例图信息
 */
- (void)photosViewController:(UIViewController *)viewController
                      images:(NSArray <UIImage *> *)images
                       infos:(NSArray <NSDictionary *> *)infos
{
    NSLog(@"选中图片以及视频等资源的原比例图片");
}

/**
 选中图片以及视频等资源的数据
 根据是否选中原图所得
 如果为原图，则返回原图大小的数据
 如果不是原图，则返回原始比例的数据
 注: 不会返回thumbnailImages的数据大小
 
 @param viewController RITLPhotosViewController
 @param datas 选中资源的数据
 */
- (void)photosViewController:(UIViewController *)viewController
                       datas:(NSArray <NSData *> *)datas
{
    NSLog(@"根据是否选中原图所得");
}

/**
 选中图片以及视频等资源的源资源对象
 如果需要使用源资源对象进行相关操作，请实现该方法
 
 @param viewController RITLPhotosViewController
 @param assets 选中的源资源
 */
- (void)photosViewController:(UIViewController *)viewController
                      assets:(NSArray <PHAsset *> *)assets
{
    NSLog(@"如果需要使用源资源对象进行相关操作，请实现该方法");
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
