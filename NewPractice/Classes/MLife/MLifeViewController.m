//
//  MLifeViewController.m
//  NewPractice
//
//  Created by SL123 on 2019/8/8.
//  Copyright © 2019 SL123. All rights reserved.
//

#import "MLifeViewController.h"

#import "ChoiseViewController.h"
#import "LifeViewController.h"
#import "CardViewController.h"
#import "MyViewController.h"
#import "MyNavigationController.h"

@interface MLifeViewController ()

@end

@implementation MLifeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self naviLeftItem];
    
    //初始化自己
    [self setViewControllersForTab];
}
-(void)setViewControllersForTab
{
    ChoiseViewController * choiseVC = [[ChoiseViewController alloc] init];
    LifeViewController * lifeVC = [[LifeViewController alloc] init];
    CardViewController * cardVC = [[CardViewController alloc] init];
    MyViewController * myVC = [[MyViewController alloc] init];
    
    MyNavigationController * navChoise = [[MyNavigationController alloc] initWithRootViewController:choiseVC];
    MyNavigationController * navLife = [[MyNavigationController alloc] initWithRootViewController:lifeVC];
    MyNavigationController * navCard = [[MyNavigationController alloc] initWithRootViewController:cardVC];
    MyNavigationController * navMy = [[MyNavigationController alloc] initWithRootViewController:myVC];
    
    UITabBarItem * itemChoise = [[UITabBarItem alloc] initWithTitle:@"精选" image:[[UIImage imageNamed:@"btn_select"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:[[UIImage imageNamed:@"btn_select_p"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    itemChoise.tag = 0;
    choiseVC.tabBarItem = itemChoise;
    
    UITabBarItem * itemLife = [[UITabBarItem alloc] initWithTitle:@"生活" image:[[UIImage imageNamed:@"btn_polite"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:[[UIImage imageNamed:@"btn_polite_p"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    itemChoise.tag = 1;
    lifeVC.tabBarItem = itemLife;
    
    UITabBarItem * itemCard = [[UITabBarItem alloc] initWithTitle:@"用卡" image:[[UIImage imageNamed:@"btn_card"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:[[UIImage imageNamed:@"btn_card_p"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    itemChoise.tag = 2;
    cardVC.tabBarItem = itemCard;
    
    UITabBarItem * itemMy = [[UITabBarItem alloc] initWithTitle:@"我的" image:[[UIImage imageNamed:@"btn_my"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:[[UIImage imageNamed:@"btn_my_p"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    itemChoise.tag = 3;
    myVC.tabBarItem = itemMy;
    
    self.viewControllers = [NSArray arrayWithObjects:navChoise,navLife,navCard,navMy, nil];

}
-(void)naviLeftItem
{
    UIButton * backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(0, 0, 40, 44);
    [backBtn setImage:[UIImage imageNamed:@"backimage_btn"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(mlifeBack) forControlEvents:UIControlEventTouchUpInside];
    [backBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    UIBarButtonItem * item = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    self.navigationItem.leftBarButtonItem = item;
}
-(void)mlifeBack
{
    [self.navigationController popViewControllerAnimated:YES];
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
