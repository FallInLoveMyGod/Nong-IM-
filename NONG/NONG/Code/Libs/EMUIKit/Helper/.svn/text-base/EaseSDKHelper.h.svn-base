//
//  EaseSDKHelper.h
//  NONG
//
//  Created by 吴 吴 on 16/8/19.
//  Copyright © 2016年 上海泰侠网络科技有限公司. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

#import "EMSDK.h"

#define KNOTIFICATION_LOGINCHANGE              @"loginStateChange"
#define KNOTIFICATION_CALL                     @"callOutWithChatter"
#define KNOTIFICATION_CALL_CLOSE               @"callControllerClose"

#define kGroupMessageAtList                    @"em_at_list"
#define kGroupMessageAtAll                     @"all"

#define kSDKConfigEnableConsoleLogger          @"SDKConfigEnableConsoleLogger"
#define kEaseUISDKConfigIsUseLite              @"isUselibHyphenateClientSDKLite"

@interface EaseSDKHelper : NSObject<EMClientDelegate>

@property (nonatomic) BOOL isShowingimagePicker;

@property (nonatomic) BOOL isLite;

+ (instancetype)shareHelper;

#pragma mark - init Hyphenate

- (void)hyphenateApplication:(UIApplication *)application
didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
                    appkey:(NSString *)appkey
              apnsCertName:(NSString *)apnsCertName
               otherConfig:(NSDictionary *)otherConfig;

#pragma mark - send message

#pragma mark ------------------ 组装当前发送消息 --------------

/**
 *  组装文本消息
 *
 *  @param text        消息内容
 *  @param to          发送目标对象
 *  @param messageType 消息类型
 *  @param messageExt  消息扩展属性字典
 *
 *  @return EMMessage
 */
+ (EMMessage *)sendTextMessage:(NSString *)text
                            to:(NSString *)to
                   messageType:(EMChatType)messageType
                    messageExt:(NSDictionary *)messageExt;



/**
 *  组装命令消息
 *
 *  @param action      <#action description#>
 *  @param to          <#to description#>
 *  @param messageType <#messageType description#>
 *  @param messageExt  <#messageExt description#>
 *  @param params      <#params description#>
 *
 *  @return <#return value description#>
 */
+ (EMMessage *)sendCmdMessage:(NSString *)action
                            to:(NSString *)to
                   messageType:(EMChatType)messageType
                    messageExt:(NSDictionary *)messageExt
                     cmdParams:(NSArray *)params;


+ (EMMessage *)sendLocationMessageWithLatitude:(double)latitude
                                     longitude:(double)longitude
                                       address:(NSString *)address
                                            to:(NSString *)to
                                   messageType:(EMChatType)messageType
                                    messageExt:(NSDictionary *)messageExt;

+ (EMMessage *)sendImageMessageWithImageData:(NSData *)imageData
                                          to:(NSString *)to
                                 messageType:(EMChatType)messageType
                                  messageExt:(NSDictionary *)messageExt;

+ (EMMessage *)sendImageMessageWithImage:(UIImage *)image
                                      to:(NSString *)to
                             messageType:(EMChatType)messageType
                              messageExt:(NSDictionary *)messageExt;

+ (EMMessage *)sendVoiceMessageWithLocalPath:(NSString *)localPath
                                    duration:(NSInteger)duration
                                          to:(NSString *)to
                                messageType:(EMChatType)messageType
                                  messageExt:(NSDictionary *)messageExt;

+ (EMMessage *)sendVideoMessageWithURL:(NSURL *)url
                                    to:(NSString *)to
                           messageType:(EMChatType)messageType
                            messageExt:(NSDictionary *)messageExt;


#pragma mark ------------------ 自定义方法 --------------

/**
 *  根据当前聊天会话对象,获取当前聊天类型
 *
 *  @param conversation 当前 聊天会话 model
 *
 *  @return 当前聊天类型
 */
+ (EMChatType)getMessageChatTypeWithEMConversation:(EMConversation *)conversation;

@end
