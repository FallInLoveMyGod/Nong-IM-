//
//  WJQEMClient.h
//  NONG
//
//  Created by 吴 吴 on 16/8/16.
//  Copyright © 2016年 上海泰侠网络科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  是 SDK 的入口，主要完成登录、退出、连接管理等功能。也是获取其他模块的入口
 */
@interface WJQEMClient : NSObject

/**
 *  单例
 *
 *  @return WJQEMClient
 */
+ (WJQEMClient *)sharedManager;

/**
 *  初始化环信SDK
 */
- (void)start;

#pragma mark - 程序生命周期相关

/**
 *  程序进入后台
 *
 *  @param application UIApplication
 */
- (void)applicationDidEnterBackground:(UIApplication *)application;

/**
 *  程序将要从后台返回
 *
 *  @param application UIApplication
 */
- (void)applicationWillEnterForeground:(UIApplication *)application;


#pragma mark - APNS相关

/**
 *  将 注册推送 成功后获取到的 deviceToken 传给 SDK
 *
 *  @param deviceToken 注册推送成功后获取到的deviceToken
 */
- (void)bindDeviceToken:(NSData *)deviceToken;


/**
 *  设置用户推送显示的昵称
 *
 *  @param nickName 当前用户的昵称
 */
- (void)setApnsNickName:(NSString *)nickName;


#pragma mark - 用户注册登录相关

/**
 *  注册环信
 *
 *  @param username 当前注册的用户名
 *  @param password 当前注册的用户密码
 */
- (void)registerWithUsername:(NSString *)username Password:(NSString *)password Callback:(void(^)(EMError *error))callback;


/**
 *  登录环信
 *
 *  @param username 当前登录的用户名
 *  @param password 当前登录的用户密码
 */
- (void)loginWithUsername:(NSString *)username Password:(NSString *)password Callback:(void(^)(EMError *error))callback;

/**
 *  登出环信
 *
 *  @param username 当前退出登录的用户名
 *  @param password 当前退出登录的用户密码
 */
- (void)logoutWithUsername:(NSString *)username Password:(NSString *)password Callback:(void(^)(EMError *error))callback;


/**
 *  登录成功后设置环信自动登录(注册环信和登录环信在后台完成时用到)
 */
- (void)setAutoLogin;


#pragma mark - 聊天会话相关

/**
 *  获取/创建会话
 *
 *  @param conversationId   会话ID
 *  @param type             会话类型
 *  @param createIfNotExist 会话不存在是否去创建 YES,是;反之不
 *  @param callback         创建结果回调
 */
- (void)getConversationWithConversationId:(NSString *)conversationId
                                     Type:(EMConversationType)type
                         CreateIfNotExist:(BOOL)createIfNotExist Callback:(void(^)(EMConversation *conversation))callback;



/**
 *  删除单个会话(有方法支持批量删除,暂时未列出)
 *
 *  @param conversationId 当前要删除的会话ID
 *  @param deleteMessages 是否删除会话中的消息 YES,删除;反之不删除
 *
 *  @return YES,删除成功;反之失败
 */
- (BOOL)deleteConversationWithConversationId:(NSString *)conversationId DeleteMessages:(BOOL)deleteMessages;


@end
