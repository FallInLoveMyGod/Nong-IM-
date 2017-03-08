//
//  ChatController.h
//  NONG
//
//  Created by 吴 吴 on 16/8/16.
//  Copyright © 2016年 上海泰侠网络科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <MobileCoreServices/MobileCoreServices.h>

/**
 * 时间扩展类
 */
#import "NSDate+Category.h"

/**
 *  表情管理类
 */
#import "EaseEmoji.h"
#import "EaseEmotionManager.h"

/**
 *  聊天底部工具栏视图
 */
#import "EaseChatToolbar.h"

/**
 * 设备管理工具类
 */
#import "EMCDDeviceManager.h"
#import "EMCDDeviceManager+Media.h"
#import "EMCDDeviceManager+ProximitySensor.h"

/**
 * 消息model
 */
#import "IMessageModel.h"
#import "EaseMessageModel.h"

/**
 * 消息cel
 */
#import "EaseBaseMessageCell.h"
#import "EaseMessageTimeCell.h"
#import "EaseCustomMessageCell.h"

/**
 * 显示gif图片
 */
#import "UIImage+EMGIF.h"

/**
 * 扩展属性类
 */
#import "EaseAtTarget.h"

/**
 * 消息发送管理类
 */
#import "EaseSDKHelper.h"

/**
 * 图片读取管理类
 */
#import "EaseMessageReadManager.h"


/**
 *  聊天界面
 */
@interface ChatController : UIViewController<UINavigationControllerDelegate,UIImagePickerControllerDelegate,EMChatManagerDelegate, EMCDDeviceManagerDelegate,EMChatToolbarDelegate, EaseChatBarMoreViewDelegate,EaseMessageCellDelegate>

/**
 *  当前会话对象(很重要,需要暴露给外面访问)
 */
@property(nonatomic,strong)EMConversation *conversation;

#pragma mark - 聊天底部栏下的视图

@property (nonatomic,strong) UIView *chatToolbar;
/**
 *  +号点击的功能按钮视图
 */
@property(nonatomic,strong) EaseChatBarMoreView *chatBarMoreView;
/**
 *  表情所在视图
 */
@property(nonatomic,strong) EaseFaceView *faceView;
/**
 *  录音显示所在视图
 */
@property(nonatomic,strong) EaseRecordView *recordView;


#pragma mark - 时间戳标记

@property (nonatomic) NSTimeInterval messageTimeIntervalTag;

/**
 *  标记视图是否在出现
 */
@property (nonatomic) BOOL isViewDidAppear;
/**
 *  标记当视图出现时滚动到底部,默认为YES
 */
@property (nonatomic) BOOL scrollToBottomWhenAppear;


/**
 *  重写初始化方法
 *
 *  @param conversationChatter 当前会话对象
 *  @param conversationType    当前会话类型
 *
 *  @return ChatController
 */
- (id)initWithConversationChatter:(NSString *)conversationChatter
                           conversationType:(EMConversationType)conversationType;

@end
