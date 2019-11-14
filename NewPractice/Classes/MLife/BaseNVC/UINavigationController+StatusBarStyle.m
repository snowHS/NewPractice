//
//  UINavigationController+StatusBarStyle.m
//  MLife
//
//  Created by fang on 2018/7/3.
//  Copyright © 2018年 四方精创. All rights reserved.
//
//
//  iOS 10 以上修改状态栏风格需要

#import "UINavigationController+StatusBarStyle.h"

@implementation UINavigationController (StatusBarStyle)


- (UIViewController *)childViewControllerForStatusBarStyle
{
    return self.visibleViewController;
}

- (UIViewController *)childViewControllerForStatusBarHidden
{
    return self.visibleViewController;
}

@end
