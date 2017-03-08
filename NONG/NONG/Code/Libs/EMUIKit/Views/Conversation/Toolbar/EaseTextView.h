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

typedef NS_ENUM(NSUInteger, DXTextViewInputViewType) {
    //正常输入类型
    DXTextViewNormalInputType = 0,
    //文本输入类型
    DXTextViewTextInputType,
    //表情输入类型
    DXTextViewFaceInputType,
    DXTextViewShareMenuInputType,
};

@interface EaseTextView : UITextView

@property (nonatomic,copy)NSString *placeHolder;
@property (nonatomic,strong)UIColor *placeHolderTextColor;

#pragma mark ------------------ 对外方法 --------------

/**
 * 获取文本行数
 */
- (NSUInteger)numberOfLinesOfText;


/**
 * 获取每行能够显示的最大字符数
 */
+ (NSUInteger)maxCharactersPerLine;



/**
 * 获取当前消息能够显示的最大行数
 */
+ (NSUInteger)numberOfLinesForMessage:(NSString *)text;

@end
