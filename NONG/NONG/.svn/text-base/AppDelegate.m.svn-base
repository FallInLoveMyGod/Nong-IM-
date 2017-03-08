//
//  AppDelegate.m
//  NONG
//
//  Created by 蔡成汉 on 16/8/15.
//  Copyright © 2016年 上海泰侠网络科技有限公司. All rights reserved.
//

#import "AppDelegate.h"
#import "ChatFriendListController.h"

#import "WJQEMClient.h"
#import "WJQChatHelper.h"



@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    //会话列表
    ChatFriendListController *chatlistVC = [[ChatFriendListController alloc]init];
    UINavigationController *nav          = [[UINavigationController alloc]initWithRootViewController:chatlistVC];

    self.window.rootViewController       = nav;
    self.window.backgroundColor          = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    /**
     *  初始化环信SDK
     */
    [[WJQEMClient sharedManager]start];

    /**
     *  注册环信推送
     */
    [self registerHuanxinPush:application];
    
    /**
     *  开启监控
     */
    [[WJQChatHelper sharedManager]start];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    /**
     *  程序进入后台时，需要调用此方法断开连接
     */
    [[WJQEMClient sharedManager]applicationDidEnterBackground:application];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    /**
     *  程序进入前台时，需要调用此方法进行重连
     */
    [[WJQEMClient sharedManager]applicationWillEnterForeground:application];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark ------------------ 注册了推送功能，会自动回调以下方法 --------------

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    /**
     *  将 注册推送 成功后获取到的 deviceToken 传给 SDK
     */
    [[WJQEMClient sharedManager]bindDeviceToken:deviceToken];
}
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    /**
     *  APNS 注册失败，一般是由于使用了通用证书或者是模拟器调试导致，请检查证书并用真机调试
     */
    NSLog(@"error -- %@",error);
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    [[WJQChatHelper sharedManager]dealLocalNotification:notification];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [[WJQChatHelper sharedManager]dealRemoteNotification:userInfo];
}

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    [[WJQChatHelper sharedManager]dealRemoteNotification:userInfo];
}

#pragma mark ------------------ 注册环信离线推送 --------------

- (void)registerHuanxinPush:(UIApplication *)application {
    if ([application respondsToSelector:@selector(registerForRemoteNotifications)])
    {
        [application registerForRemoteNotifications];
        UIUserNotificationType notificationTypes = UIUserNotificationTypeBadge |
        UIUserNotificationTypeSound |
        UIUserNotificationTypeAlert;
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:notificationTypes categories:nil];
        [application registerUserNotificationSettings:settings];
    }
    else
    {
        UIRemoteNotificationType notificationTypes = UIRemoteNotificationTypeBadge |
        UIRemoteNotificationTypeSound |
        UIRemoteNotificationTypeAlert;
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:notificationTypes];
    }
}

@end
