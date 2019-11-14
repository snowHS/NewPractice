//
//  XKZoomingView.h
//  NewPractice
//
//  Created by SL123 on 2019/9/29.
//  Copyright © 2019 SL123. All rights reserved.
//  
/*
 XKZoomingView *zoomView = [[XKZoomingView alloc]init];
 zoomView.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight);
 zoomView.mainImage = [UIImage imageNamed:@"imageScale"];
 [self.view addSubview:zoomView];
 */
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface XKZoomingView : UIScrollView
/**
 本地图片
 */
@property (nonatomic, strong) UIImage *mainImage;

/**
 图片显示
 */
@property (nonatomic, strong) UIImageView *mainImageView;
@end

NS_ASSUME_NONNULL_END
