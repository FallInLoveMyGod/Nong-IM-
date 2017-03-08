//
//  WJQChatHelper.h
//  NONG
//
//  Created by 吴 吴 on 16/8/19.
//  Copyright © 2016年 上海泰侠网络科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ChatController.h"
#import "ChatFriendListController.h"

/**
 *  此工具类专门负责消息变化,会话变化,联系人变化,环信登录变化处理等
 */
@interface WJQChatHelper : NSObject<EMClientDelegate,EMChatManagerDelegate>

/**
 *  记录上一次播放音频的时间(避免消息太过频繁导致的音频重复播放)
 */
@property (nonatomic,strong)NSDate *lastPlaySoundDate;

/**
 *  单例方法
 *
 *  @return WJQChatHelper
 */
+ (WJQChatHelper *)sharedManager;

/**
 *  启动监听代理
 */
- (void)start;

#pragma mark - 处理推送消息

/**
 *  处理本地推送消息
 *
 *  @param notification 当前点击的本地推送
 */
- (void)dealLocalNotification:(UILocalNotification *)notification;

/**
 *  处理远端推送消息
 *
 *  @param userInfo 消息内容字典
 */
- (void)dealRemoteNotification:(NSDictionary *)userInfo;
@end
