//
//  ChatFriendListController.h
//  NONG
//
//  Created by 吴 吴 on 16/8/16.
//  Copyright © 2016年 上海泰侠网络科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IConversationModel.h"

@interface EaseConversationModel : NSObject<IConversationModel>

/**
 *  当前的聊天会话model
 */
@property (strong, nonatomic, readonly) EMConversation *conversation;
/**
 *  当前的聊天标题
 */
@property (strong, nonatomic) NSString *title;
/**
 *  会话头像路径
 */
@property (strong, nonatomic) NSString *avatarURLPath;
/**
 *  会话默认头像
 */
@property (strong, nonatomic) UIImage *avatarImage;

- (instancetype)initWithConversation:(EMConversation *)conversation;

@end
