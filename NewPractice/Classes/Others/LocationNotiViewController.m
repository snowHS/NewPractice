//
//  LocationNotiViewController.m
//  NewPractice
//
//  Created by SL123 on 2019/9/3.
//  Copyright © 2019 SL123. All rights reserved.
//

#import "LocationNotiViewController.h"
#import <UserNotifications/UserNotifications.h>

#define LocalNotiReqIdentifer @"EnterEGClientManual"

@interface LocationNotiViewController ()<UNUserNotificationCenterDelegate>

@end

@implementation LocationNotiViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"本地推送通知";
    UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn addTarget:self action:@selector(addNoti) forControlEvents:UIControlEventTouchUpInside];
    [btn setTitle:@"发本地通知" forState:UIControlStateNormal];
    [btn setTitleColor: [UIColor redColor] forState:UIControlStateNormal];
    [self.view addSubview:btn];
    [btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(100);
        make.left.equalTo(self.view).offset(100);
        make.right.equalTo(self.view).offset(-100);
        make.height.offset(40);
    }];
}
-(void)addNoti
{
    if (@available (iOS 10.0 , *)) {
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        center.delegate = self;
        UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
        content.title = [NSString localizedUserNotificationStringForKey:@"人工客服已为您接通，点击进入咨询" arguments:nil];
        content.body = [NSString localizedUserNotificationStringForKey:@"可跳转人工客服界面了" arguments:nil];
        content.sound = [UNNotificationSound defaultSound];
        UNTimeIntervalNotificationTrigger * trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:60 repeats:NO];
        UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:LocalNotiReqIdentifer content:content trigger:trigger];
        
        [center addNotificationRequest:request withCompletionHandler:^(NSError *_Nullable error) {
            NSLog(@"成功添加推送");
        }];
    }
    else {
        //定义本地通知对象
        UILocalNotification *notification = [[UILocalNotification alloc] init];
        //设置调用时间
        notification.timeZone = [NSTimeZone localTimeZone];
        notification.fireDate = [NSDate dateWithTimeIntervalSinceNow:60];//通知触发的时间，10s以后
        notification.repeatInterval = 0;//通知重复次数
        notification.repeatCalendar=[NSCalendar currentCalendar];//当前日历，使用前最好设置时区等信息以便能够自动同步时间
        
        //设置通知属性
        notification.alertBody = @"3分钟到了,已断开人工链接"; //通知主体
        notification.applicationIconBadgeNumber += 1;//应用程序图标右上角显示的消息数
        notification.alertAction = @"打开应用"; //待机界面的滑动动作提示
        notification.alertLaunchImage = @"Default";//通过点击通知打开应用时的启动图片,这里使用程序启动图片
        notification.soundName = UILocalNotificationDefaultSoundName;//收到通知时播放的声音，默认消息声音
        //    notification.soundName=@"msg.caf";//通知声音（需要真机才能听到声音）
        
        //设置用户信息
        notification.userInfo = @{@"id": @1, @"user": @"cloudox"};//绑定到通知上的其他附加信息
        
        //调用通知
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    }
}

- (void)cancelLocalNotificaitons {
    
    // 取消一个特定的通知
    NSArray *notificaitons = [[UIApplication sharedApplication] scheduledLocalNotifications];
    // 获取当前所有的本地通知
    if (!notificaitons || notificaitons.count <= 0) { return; }
    for (UILocalNotification *notify in notificaitons) {
        if ([[notify.userInfo objectForKey:@"id"] isEqualToString:@"LOCAL_NOTIFY_SCHEDULE_ID"]) {
            if (@available(iOS 10.0, *)) {
                [[UNUserNotificationCenter currentNotificationCenter] removePendingNotificationRequestsWithIdentifiers:@[LocalNotiReqIdentifer]];
            } else {
                [[UIApplication sharedApplication] cancelLocalNotification:notify];
            }
            break;
        }
    }
    // 取消所有的本地通知
    //[[UIApplication sharedApplication] cancelAllLocalNotifications];
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
