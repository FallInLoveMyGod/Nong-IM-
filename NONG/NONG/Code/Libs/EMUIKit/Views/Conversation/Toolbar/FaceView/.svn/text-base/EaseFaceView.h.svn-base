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

#import "EaseFacialView.h"

@protocol EMFaceDelegate

@required
- (void)selectedFacialView:(NSString *)str isDelete:(BOOL)isDelete;
- (void)sendFace;
- (void)sendFaceWithEmotion:(EaseEmotion *)emotion;

@end

@interface EaseFaceView : UIView <EaseFacialViewDelegate>

@property (nonatomic, assign) id<EMFaceDelegate> delegate;

/**
 *  判断字符是否是系统表情
 *
 *  @param string 目标字符
 *
 *  @return YES是;反正不是
 */
- (BOOL)stringIsFace:(NSString *)string;

- (void)setEmotionManagers:(NSArray*)emotionManagers;

@end
