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

#import <Foundation/Foundation.h>

/**
 * 是否含有自定义表情扩展字段
 */
#define EASEUI_EMOTION_DEFAULT_EXT        @"em_emotion"

/**
 * 是否是自定义表情
 */
#define MESSAGE_ATTR_IS_BIG_EXPRESSION    @"em_is_big_expression"
/**
 *  自定义表情 表情ID
 */
#define MESSAGE_ATTR_EXPRESSION_ID        @"em_expression_id"

typedef NS_ENUM(NSUInteger, EMEmotionType) {
    /**
     *  系统表情
     */
    EMEmotionDefault = 0,
    /**
     *  png表情
     */
    EMEmotionPng,
    /**
     *  gif表情
     */
    EMEmotionGif
};

@interface EaseEmotionManager : NSObject

@property (nonatomic, strong) NSArray *emotions;

/*!
 @property
 @brief number of lines of emotion
 */
@property (nonatomic, assign) NSInteger emotionRow;

/*!
 @property
 @brief number of columns of emotion
 */
@property (nonatomic, assign) NSInteger emotionCol;

/*!
 @property
 @brief emotion type
 */
@property (nonatomic, assign) EMEmotionType emotionType;

@property (nonatomic, strong) UIImage *tagImage;

- (id)initWithType:(EMEmotionType)Type
        emotionRow:(NSInteger)emotionRow
        emotionCol:(NSInteger)emotionCol
          emotions:(NSArray*)emotions;

/**
 *  初始化某个表情系列
 *
 *  @param Type       表情类型
 *  @param emotionRow 行数
 *  @param emotionCol 每行的个数
 *  @param emotions   表情数组
 *  @param tagImage   显示在底部的标记表情
 *
 *  @return 某个表情系列
 */
- (id)initWithType:(EMEmotionType)Type
        emotionRow:(NSInteger)emotionRow
        emotionCol:(NSInteger)emotionCol
          emotions:(NSArray*)emotions
          tagImage:(UIImage*)tagImage;

@end

@interface EaseEmotion : NSObject

@property (nonatomic, assign) EMEmotionType emotionType;

@property (nonatomic, copy) NSString *emotionTitle;

@property (nonatomic, copy) NSString *emotionId;

@property (nonatomic, copy) NSString *emotionThumbnail;

@property (nonatomic, copy) NSString *emotionOriginal;

@property (nonatomic, copy) NSString *emotionOriginalURL;

- (id)initWithName:(NSString*)emotionTitle
         emotionId:(NSString*)emotionId
  emotionThumbnail:(NSString*)emotionThumbnail
   emotionOriginal:(NSString*)emotionOriginal
emotionOriginalURL:(NSString*)emotionOriginalURL
       emotionType:(EMEmotionType)emotionType;

@end
