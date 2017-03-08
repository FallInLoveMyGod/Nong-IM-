//
//  WJQChatHelper.m
//  NONG
//
//  Created by 吴 吴 on 16/8/19.
//  Copyright © 2016年 上海泰侠网络科技有限公司. All rights reserved.
//

#import "WJQChatHelper.h"
#import "EMCDDeviceManager.h"
#import "TWVCManager.h"
#import "EaseConvertToCommonEmoticonsHelper.h"

/**
 *  两次两次提示的默认间隔
 */
static const CGFloat kDefaultPlaySoundInterval = 3.0;

/**
 *  消息类型字段
 */
static NSString *kMessageType                  = @"MessageType";
/**
 *  消息会话ID
 */
static NSString *kConversationChatter          = @"ConversationChatter";

static WJQChatHelper *myManager = nil;
@implementation WJQChatHelper

+ (WJQChatHelper *)sharedManager {
    @synchronized (self) {
        static dispatch_once_t pred;
        dispatch_once(&pred,^{
            myManager = [[self alloc]init];
        });
    }
    return myManager;
}

- (id)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)start {
    [[EMClient sharedClient] addDelegate:self delegateQueue:nil];
    [[EMClient sharedClient].chatManager addDelegate:self delegateQueue:nil];
}

#pragma mark ------------------ EMClientDelegate 一些实用工具类的回调--------------

/**
 *  SDK连接服务器的状态变化时会接收到该回调
 *
 *  @param aConnectionState 网络连接状态
 */
- (void)didConnectionStateChanged:(EMConnectionState)aConnectionState {
}


/**
 *  自动登录失败时的回调
 *
 *  @param error 错误信息
 */
- (void)didAutoLoginWithError:(EMError *)error {
    if (error)
    {
        /**
         * 需要重新登录
         */
    }
    else if ([[EMClient sharedClient]isConnected])
    {
        /**
         *  是否连上聊天服务器
         */
    }
    else
    {
        
    }
}

/**
 *  当前登录账号在其它设备登录时会接收到该回调
 */
- (void)didLoginFromOtherDevice {
    /**
     *  需要退出app登录,但是不解除设备的deviceToken的绑定
     */
    NSString *alerTitle = @"你的账号已在其他地方登录";
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:alerTitle delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alertView show];
}


/**
 *  当前登录账号已经被从服务器端删除时会收到该回调
 */
- (void)didRemovedFromServer {
    /**
     *  需要退出app登录,但是不解除设备的deviceToken的绑定
     */
    NSString *alerTitle = @"你的账号已被从服务器端移除";
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:alerTitle delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alertView show];
}

#pragma mark ------------------ EMChatManagerDelegate 聊天相关回调--------------

/**
 *  会话列表发生变化
 *
 *  @param aConversationList 会话列表
 */
- (void)didUpdateConversationList:(NSArray *)aConversationList {
    /**
     *  1.会话列表控制器刷新列表数据  2.重新设置未读消息数
     */
}

/**
 *  收到消息
 *
 *  @param aMessages 消息列表
 */
- (void)didReceiveMessages:(NSArray *)aMessages {
    [aMessages enumerateObjectsUsingBlock:^(EMMessage *message, NSUInteger idx, BOOL * _Nonnull stop) {
        BOOL needShowNotification = YES;
        if (needShowNotification)
        {
            UIApplicationState state = [[UIApplication sharedApplication] applicationState];
            switch (state) {
                case UIApplicationStateActive:
                    [self playSoundAndVibration];
                    break;
                case UIApplicationStateInactive:
                    [self playSoundAndVibration];
                    break;
                case UIApplicationStateBackground:
                    /**
                     *  程序在后台,需要发送本地推送(环信只会在程序杀死的情况下发送通知)
                     */
                    [self showNotificationWithMessage:message];
                    break;
                default:
                    break;
            }
        }
    }];
}

/**
 *  收到新消息,发出音频和震动
 */
- (void)playSoundAndVibration {
    NSTimeInterval timeInterval = [[NSDate date]timeIntervalSinceDate:self.lastPlaySoundDate];
    if (timeInterval < kDefaultPlaySoundInterval)
    {
        /**
         *  如果距离上次响铃和震动时间太短,则跳过响铃
         */
        NSLog(@"距离上次响铃和震动时间太短,则跳过响铃 %@, %@",[NSDate date],self.lastPlaySoundDate);
        return;
    }
    
    /**
     *  保存最后一次响铃时间
     */
    self.lastPlaySoundDate = [NSDate date];
    /**
     *  收到消息时，播放音频
     */
    [[EMCDDeviceManager sharedInstance] playNewMessageSound];
    /**
     *  收到消息时，震动
     */
    [[EMCDDeviceManager sharedInstance] playVibration];
}

- (void)showNotificationWithMessage:(EMMessage *)message {
    /**
     * 本地推送
     */
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    /**
     *  触发通知的时间
     */
    notification.fireDate             = [NSDate date];
    /**
     *  设置alertBody 如果推送样式是显示消息内容
     */
    EMMessageBody *messageBody        = message.body;
    NSString *messageStr              = @"";
    switch (messageBody.type)
    {
        case EMMessageBodyTypeText:
        {
            /**
             * 当消息是系统自带表情的文本消息，需要转成系统表情样式
             */
            messageStr = ((EMTextMessageBody *)messageBody).text;
            
            /**
             * 系统自带表情转换为具体表情样式
             */
            messageStr = [EaseConvertToCommonEmoticonsHelper convertToSystemEmoticons:((EMTextMessageBody *)messageBody).text];
            
            /**
             *  当扩展字典中有描述是大表情的扩展字段时
             */
            if ([message.ext objectForKey:@"em_is_big_expression"])
            {
                messageStr = @"[动画表情]";
            }
        }
            break;
        case EMMessageBodyTypeImage:
        {
            messageStr = @"图片";
        }
            break;
        case EMMessageBodyTypeLocation:
        {
            messageStr = @"位置";
        }
            break;
        case EMMessageBodyTypeVoice:
        {
            messageStr = @"音频";
        }
            break;
        case EMMessageBodyTypeVideo:
        {
            messageStr = @"视频";
        }
            break;
        default:
            break;
    }
    
    do
    {
        /**
         *  获取用户昵称
         */
        NSString *title = message.from;
        if (message.chatType == EMChatTypeGroupChat)
        {
            /**
             * 群聊消息
             */
        }
        else if (message.chatType == EMChatTypeChatRoom)
        {
            /**
             * 聊天室消息
             */
        }
        else
        {
            /**
             * 单聊消息
             */
            
        }
        notification.alertBody = [NSString stringWithFormat:@"%@:%@",title,messageStr];
        
    } while (0);

    
    /**
     * test:区分是本地推送还是服务端推送
     */
    notification.alertBody      = [[NSString alloc] initWithFormat:@"[本地]%@", notification.alertBody];
    
    notification.alertAction    = @"打开";
    notification.timeZone       = [NSTimeZone defaultTimeZone];
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:self.lastPlaySoundDate];
    if (timeInterval < kDefaultPlaySoundInterval)
    {
        NSLog(@"距离上次响铃和震动时间太短,则跳过响铃%@, %@", [NSDate date], self.lastPlaySoundDate);
    }
    else
    {
        notification.soundName = UILocalNotificationDefaultSoundName;
        self.lastPlaySoundDate = [NSDate date];
    }
    
    /**
     *  设置推送的userInfo,用于在收到推送时做需要的操作
     */
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    [userInfo setObject:[NSNumber numberWithInt:message.chatType] forKey:kMessageType];
    [userInfo setObject:message.conversationId forKey:kConversationChatter];
    notification.userInfo         = userInfo;
    
    /**
     *  发送通知
     */
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    
    /**
     *  应用程序边角数+1
     */
    [UIApplication sharedApplication].applicationIconBadgeNumber++;
}

- (void)dealLocalNotification:(UILocalNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    UIViewController *topVC = [[TWVCManager shareVCManager]getTopViewController];
    if (userInfo)
    {
        /**
         *  本地推送消息
         */
        NSString           *tempConversationID       = userInfo[kConversationChatter];
        EMChatType         tempChatType              = [userInfo[kMessageType]intValue];
        EMConversationType tempConversationType      = [self conversationTypeFromMessageType:tempChatType];
        

        if ([topVC isKindOfClass:[ChatController class]])
        {
            /**
             *  如果已经是在聊天界面
             */
            ChatController *chatVC = (ChatController *)topVC;

            if ([chatVC.conversation.conversationId isEqualToString:tempConversationID])
            {
                /**
                 *  当前的聊天对象 正和 本地推送过来的消息发送人 一致
                 */
                NSAssert(@"不需要处理,聊天界面自动刷新的", nil);
            }
            else
            {
                /**
                 *  不一致,需先返回到聊天界面的上一级界面,在push进来
                 */
                [chatVC.navigationController popViewControllerAnimated:NO];
                topVC = [[TWVCManager shareVCManager]getTopViewController];
                
                ChatController *vc = [[ChatController alloc]initWithConversationChatter:tempConversationID conversationType:tempConversationType];
                vc.title =  tempConversationID;
                [topVC.navigationController pushViewController:vc animated:YES];
            }
        }
        else
        {
            /**
             *  如果当前不在聊天界面,看界面处在的层级
             */
            
            /**
             *  当前界面是否在会话列表界面
             */
            if ([topVC isKindOfClass:[ChatFriendListController class]])
            {
                /**
                 * 在会话列表界面
                 */
                ChatController *vc = [[ChatController alloc]initWithConversationChatter:tempConversationID conversationType:tempConversationType];
                vc.title =  tempConversationID;
                [topVC.navigationController pushViewController:vc animated:YES];
            }
            else
            {
                /**
                 *  不在会话列表界面,先返回Tab界面,然后选中会话列表的tab，再push进聊天界面
                 */
                [topVC.navigationController popToRootViewControllerAnimated:NO];
                topVC = [[TWVCManager shareVCManager]getTopViewController];
            }
        }
    }
    else
    {
        NSAssert(@"无userInfo", nil);
    }
}

- (void)dealRemoteNotification:(NSDictionary *)userInfo {
    /**
     * 只需判断当前界面是否在会话列表Tab下即可(因为此处程序相当于第一次启动)
     */
}

- (EMConversationType)conversationTypeFromMessageType:(EMChatType)type {
    EMConversationType conversatinType = EMConversationTypeChat;
    switch (type) {
        case EMChatTypeChat:
            conversatinType = EMConversationTypeChat;
            break;
        case EMChatTypeGroupChat:
            conversatinType = EMConversationTypeGroupChat;
            break;
        case EMChatTypeChatRoom:
            conversatinType = EMConversationTypeChatRoom;
            break;
        default:
            break;
    }
    return conversatinType;
}

- (void)dealloc {
    [[EMClient sharedClient] removeDelegate:self];
    [[EMClient sharedClient].chatManager removeDelegate:self];
}

@end
