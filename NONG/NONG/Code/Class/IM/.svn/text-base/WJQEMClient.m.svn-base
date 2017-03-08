//
//  WJQEMClient.m
//  NONG
//
//  Created by 吴 吴 on 16/8/16.
//  Copyright © 2016年 上海泰侠网络科技有限公司. All rights reserved.
//

#import "WJQEMClient.h"

static WJQEMClient *myManager = nil;
@implementation WJQEMClient

+ (WJQEMClient *)sharedManager {
    @synchronized (self) {
        static dispatch_once_t pred;
        dispatch_once(&pred,^{
            myManager = [[self alloc]init];
        });
    }
    return myManager;
}

- (void)start {
    EMOptions *options   = [EMOptions optionsWithAppkey:HuanxinAppKey];
    options.apnsCertName = HuanxinPushDevName;
    [[EMClient sharedClient] initializeSDKWithOptions:options];
}

#pragma mark ------------------ 程序生命周期相关 --------------

- (void)applicationDidEnterBackground:(UIApplication *)application {
    [[EMClient sharedClient] applicationDidEnterBackground:application];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    [[EMClient sharedClient] applicationWillEnterForeground:application];
}

#pragma mark ------------------ APNS相关 ------------------

- (void)bindDeviceToken:(NSData *)deviceToken {
    [[EMClient sharedClient] bindDeviceToken:deviceToken];
}

- (void)setApnsNickName:(NSString *)nickName {
    EMPushOptions *options = [[EMClient sharedClient] pushOptions];
    options.displayStyle   = EMPushDisplayStyleMessageSummary;
    options.nickname       = nickName;
    [[EMClient sharedClient] asyncUpdatePushOptionsToServer:^{
        NSLog(@"更新推送设置到服务器成功");
    } failure:^(EMError *aError) {
        NSLog(@"更新推送设置到服务器失败");
    }];
}

#pragma mark ------------------ 用户注册登录相关 ------------------

- (void)registerWithUsername:(NSString *)username Password:(NSString *)password Callback:(void(^)(EMError *error))callback {
    [[EMClient sharedClient]asyncRegisterWithUsername:username password:password success:^{
        if (callback)
        {
            callback(nil);
        }
    } failure:^(EMError *aError) {
        if (callback)
        {
            callback(aError);
        }
    }];
}

- (void)loginWithUsername:(NSString *)username Password:(NSString *)password Callback:(void (^)(EMError *error))callback {
    /**
     *  检测是否已经设置过自动登录,若已经设置不需要再次重新登录,SDK会自动发起
     *  自动登录在以下几种情况下会被取消:1.用户调用了 SDK 的登出动作 2.用户在别的设备上更改了密码，导致此设备上自动登录失败
        3.用户的账号被从服务器端删除  4.用户从另一个设备登录，把当前设备上登录的用户踢出
     */
    BOOL isAutoLogin = [EMClient sharedClient].options.isAutoLogin;
    if (isAutoLogin)
    {
        return;
    }
    [[EMClient sharedClient]asyncLoginWithUsername:username password:password success:^{
        /**
         *  SDK 中自动登录属性默认是关闭的，需要您在登录成功后设置，以便您在下次 APP 启动时不需要再次调用环信登录，并且能在没有网的情况下得到会话列表。
         */
        [[EMClient sharedClient].options setIsAutoLogin:YES];
        /**
         *  更新推送设置到服务器
         */
        [self setApnsNickName:username];
        if (callback)
        {
            callback(nil);
        }
    } failure:^(EMError *aError) {
        if (callback)
        {
            callback(aError);
        }
    }];
}

- (void)logoutWithUsername:(NSString *)username Password:(NSString *)password Callback:(void (^)(EMError *))callback {
    [[EMClient sharedClient]asyncLoginWithUsername:username password:password success:^{
        if (callback)
        {
            callback(nil);
        }
    } failure:^(EMError *aError) {
        if (callback)
        {
            callback(aError);
        }
    }];
}

- (void)setAutoLogin {
    /**
     *  SDK 中自动登录属性默认是关闭的，需要您在登录成功后设置，以便您在下次 APP 启动时不需要再次调用环信登录，并且能在没有网的情况下得到会话列表。
     */
    [[EMClient sharedClient].options setIsAutoLogin:YES];
}


#pragma mark - 聊天会话相关

- (void)getConversationWithConversationId:(NSString *)conversationId
                                     Type:(EMConversationType)type
                         CreateIfNotExist:(BOOL)createIfNotExist Callback:(void(^)(EMConversation *conversation))callback {
    EMConversation *conversation = [[EMClient sharedClient].chatManager getConversation:conversationId type:type createIfNotExist:createIfNotExist];
    if (callback)
    {
        callback(conversation);
    }
}

- (BOOL)deleteConversationWithConversationId:(NSString *)conversationId DeleteMessages:(BOOL)deleteMessages {
    BOOL result =  [[EMClient sharedClient].chatManager deleteConversation:conversationId deleteMessages:deleteMessages];
    return result;
}

@end
