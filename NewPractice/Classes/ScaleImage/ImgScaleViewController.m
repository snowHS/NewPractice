//
//  ImgScaleViewController.m
//  NewPractice
//
//  Created by SL123 on 2019/9/29.
//  Copyright © 2019 SL123. All rights reserved.
//

#import "ImgScaleViewController.h"
#import "XKZoomingView.h"
@interface ImgScaleViewController ()

@end

@implementation ImgScaleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"图片缩放";
    XKZoomingView *zoomView = [[XKZoomingView alloc]init];
    zoomView.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight);
    zoomView.mainImage = [UIImage imageNamed:@"imageScale"];
    [self.view addSubview:zoomView];
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
