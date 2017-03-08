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

#import "EMSDK.h"

@class EMMessage;
@protocol IMessageModel <NSObject>

@property (nonatomic) CGFloat cellHeight;
@property (strong, nonatomic, readonly) EMMessage *message;
@property (strong, nonatomic, readonly) NSString *messageId;
@property (nonatomic, readonly) EMMessageStatus messageStatus;
@property (nonatomic, readonly) EMMessageBodyType bodyType;
@property (nonatomic) BOOL isMessageRead;

#pragma mark - 当前用户是消息发送者
/**
 * 标记是否消息发送帧
 */
@property (nonatomic) BOOL isSender;
/**
 *  用户昵称
 */
@property (strong, nonatomic) NSString *nickname;
/**
 *  用户头像链接
 */
@property (strong, nonatomic) NSString *avatarURLPath;
/**
 *  用户头像图片
 */
@property (strong, nonatomic) UIImage *avatarImage;
/**
 *  消息内容
 */
@property (strong, nonatomic) NSString *text;
/**
 *  <#Description#>
 */
@property (strong, nonatomic) NSAttributedString *attrBody;

//Placeholder image when download fails
@property (strong, nonatomic) NSString *failImageName;
@property (nonatomic) CGSize imageSize;
@property (nonatomic) CGSize thumbnailImageSize;
@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) UIImage *thumbnailImage;
@property (strong, nonatomic) NSString *address;
@property (nonatomic) double latitude;
@property (nonatomic) double longitude;
@property (nonatomic) BOOL isMediaPlaying;
@property (nonatomic) BOOL isMediaPlayed;
@property (nonatomic) CGFloat mediaDuration;
@property (strong, nonatomic) NSString *fileIconName;
@property (strong, nonatomic) NSString *fileName;
@property (strong, nonatomic) NSString *fileSizeDes;
//progress of uploading or downloading the attachment message
@property (nonatomic) float progress;
@property (strong, nonatomic, readonly) NSString *fileLocalPath;
@property (strong, nonatomic) NSString *thumbnailFileLocalPath;
@property (strong, nonatomic) NSString *fileURLPath;
@property (strong, nonatomic) NSString *thumbnailFileURLPath;

- (instancetype)initWithMessage:(EMMessage *)message;

@end
