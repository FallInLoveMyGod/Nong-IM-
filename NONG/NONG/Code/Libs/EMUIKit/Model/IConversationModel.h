/************************************************************
 *  * Hyphenate CONFIDENTIAL
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 * Dissemination of this information or reproduction of this material
 * is strictly forbidden unless prior written permission is obtained
 * from Hyphenate Inc.
 */

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@class EMConversation;

@protocol IConversationModel <NSObject>

/**
 *  聊天会话model
 */
@property (strong, nonatomic, readonly) EMConversation *conversation;
/**
 *  聊天标题
 */
@property (strong, nonatomic) NSString *title;
/**
 *  聊天头像路径
 */
@property (strong, nonatomic) NSString *avatarURLPath;
/**
 *  聊天默认头像
 */
@property (strong, nonatomic) UIImage *avatarImage;

/**
 *  重写初始化方法
 *
 *  @param conversation EMConversation
 *
 *  @return IConversationModel
 */
- (id)initWithConversation:(EMConversation *)conversation;

@end
