//
//  XKZoomingView.m
//  NewPractice
//
//  Created by SL123 on 2019/9/29.
//  Copyright © 2019 SL123. All rights reserved.
//

#import "XKZoomingView.h"

@interface XKZoomingView()<UIScrollViewDelegate>
/**
 当前图片偏移量
 */
@property (nonatomic,assign) CGPoint currPont;
@end
@implementation XKZoomingView

- (instancetype)init{
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}
- (void)setup{
    self.backgroundColor = [UIColor blackColor];
    self.delegate = self;
    self.showsHorizontalScrollIndicator = NO;
    self.showsVerticalScrollIndicator = NO;
    self.decelerationRate = UIScrollViewDecelerationRateFast;
    self.maximumZoomScale = 3;
    self.minimumZoomScale = 1;
    self.alwaysBounceHorizontal = NO;
    self.alwaysBounceVertical = NO;
    self.layer.masksToBounds = YES;
    if (@available(iOS 11.0, *)) {
        self.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    [self addSubview:self.mainImageView];
    
    _currPont = CGPointZero;
    
    ///监听屏幕旋转
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusBarOrientationChange:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    ///单击
    UITapGestureRecognizer *tapSingle = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapSingleSponse:)];
    //设置手势属性
    tapSingle.numberOfTapsRequired = 1;
    tapSingle.delaysTouchesEnded = NO;
    [self.mainImageView addGestureRecognizer:tapSingle];
    ///双击
    UITapGestureRecognizer *tapDouble = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapDoubleSponse:)];
    //设置手势属性
    tapDouble.numberOfTapsRequired = 2;
    [self.mainImageView addGestureRecognizer:tapDouble];
    ///避免手势冲突
    [tapSingle requireGestureRecognizerToFail:tapDouble];
}

#pragma mark - layoutSubviews
- (void)layoutSubviews{
    [super layoutSubviews];
    ///放大或缩小中
    if (self.zooming || self.zoomScale != 1.0 || self.zoomBouncing) {
        return;
    }
    
    ///设置图片尺寸
    if (_mainImage) {
        CGRect imgRect = [self getImageViewFrame];
        self.mainImageView.frame = imgRect;
        ///设置content size
        if (CGRectGetHeight(imgRect) > CGRectGetHeight(self.frame)) {
            [self setContentSize:CGSizeMake(CGRectGetWidth(self.frame), CGRectGetHeight(imgRect))];
        }
        else{
            [self setContentSize:CGSizeMake(CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
        }
    }
    
}
- (void)setMainImage:(UIImage *)mainImage{
    _mainImage = mainImage;
    self.mainImageView.image = _mainImage;
    [self setContentOffset:CGPointMake(0, 0)];
    [self setNeedsLayout];
}

/**
 根据图片原始大小，获取图片显示大小
 @return CGRect
 */
- (CGRect)getImageViewFrame{
    if (_mainImage) {
        CGRect imageRect;
        CGFloat scWidth = self.frame.size.width;
        CGFloat scHeight = self.frame.size.height;
        ///width
        if (_mainImage.size.width > scWidth) {
            imageRect.size.width = scWidth;
            CGFloat ratioHW = _mainImage.size.height/_mainImage.size.width;
            imageRect.size.height = ratioHW * imageRect.size.width;
            imageRect.origin.x = 0;
        }
        else{
            imageRect.size.width = _mainImage.size.width;
            imageRect.size.height = _mainImage.size.height;
            imageRect.origin.x = (scWidth - imageRect.size.width)/2;
        }
        ///height
        if (imageRect.size.height > scHeight) {
            
            imageRect.origin.y = 0;
        }
        else{
            imageRect.origin.y = (scHeight - imageRect.size.height)/2;
        }
        return imageRect;
    }
    return CGRectZero;
}
/**
 获取点击位置后所需的偏移量【目的是呈现点击位置在试图上】
 
 @param location 点击位置
 */
- (void)zoomingOffset:(CGPoint)location{
    CGFloat lo_x = location.x * self.zoomScale;
    CGFloat lo_y = location.y * self.zoomScale;
    
    CGFloat off_x;
    CGFloat off_y;
    ///off_x
    if (lo_x < CGRectGetWidth(self.frame)/2) {
        off_x = 0;
    }
    else if (lo_x > self.contentSize.width - CGRectGetWidth(self.frame)/2){
        off_x = self.contentSize.width - CGRectGetWidth(self.frame);
    }
    else{
        off_x = lo_x - CGRectGetWidth(self.frame)/2;
    }
    
    ///off_y
    if (lo_y < CGRectGetHeight(self.frame)/2) {
        off_y = 0;
    }
    else if (lo_y > self.contentSize.height - CGRectGetHeight(self.frame)/2){
        if (self.contentSize.height <= CGRectGetHeight(self.frame)) {
            off_y = 0;
        }
        else{
            off_y = self.contentSize.height - CGRectGetHeight(self.frame);
        }
        
    }
    else{
        off_y = lo_y - CGRectGetHeight(self.frame)/2;
    }
    [self setContentOffset:CGPointMake(off_x, off_y)];
}

#pragma mark - 重置图片
- (void)resetImageViewState{
    self.zoomScale = 1;
    _mainImage = nil;;
    self.mainImageView.image = nil;
    
}
#pragma mark - 变量
- (UIImageView *)mainImageView {
    if (!_mainImageView) {
        _mainImageView = [UIImageView new];
        _mainImageView.image = nil;
        _mainImageView.contentMode = UIViewContentModeScaleAspectFit;
        _mainImageView.userInteractionEnabled = YES;
    }
    return _mainImageView;
}


#pragma mark - 单击
- (void)tapSingleSponse:(UITapGestureRecognizer *)singleTap{
    if (!self.mainImageView.image) {
        return;
    }
    
    if (self.zoomScale != 1) {
        [UIView animateWithDuration:0.2 animations:^{
            self.zoomScale = 1;
        } completion:^(BOOL finished) {
            [self setContentOffset:_currPont animated:YES];
        }];
    }
}
#pragma mark - 双击
- (void)tapDoubleSponse:(UITapGestureRecognizer *)doubleTap{
    if (!self.mainImageView.image) {
        return;
    }
    CGPoint point = [doubleTap locationInView:self.mainImageView];
    if (self.zoomScale == 1) {
        [UIView animateWithDuration:0.2 animations:^{
            self.zoomScale = 2.0;
            [self zoomingOffset:point];
        }];
    }
    else{
        [UIView animateWithDuration:0.2 animations:^{
            self.zoomScale = 1;
        } completion:^(BOOL finished) {
            [self setContentOffset:_currPont animated:YES];
        }];
    }
}


#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    if (!self.mainImageView.image) {
        return;
    }
    CGRect imageViewFrame = self.mainImageView.frame;
    CGFloat width = imageViewFrame.size.width,
    height = imageViewFrame.size.height,
    sHeight = scrollView.bounds.size.height,
    sWidth = scrollView.bounds.size.width;
    if (height > sHeight) {
        imageViewFrame.origin.y = 0;
    } else {
        imageViewFrame.origin.y = (sHeight - height) / 2.0;
    }
    if (width > sWidth) {
        imageViewFrame.origin.x = 0;
    } else {
        imageViewFrame.origin.x = (sWidth - width) / 2.0;
    }
    self.mainImageView.frame = imageViewFrame;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.mainImageView;
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (self.isZooming || self.zoomScale != 1) {
        return;
    }
    _currPont = scrollView.contentOffset;
    
}
#pragma mark - 监听屏幕旋转通知
- (void)statusBarOrientationChange:(NSNotification *)notification{
    self.zoomScale = 1;
}
- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
}

@end
