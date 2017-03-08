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

#import "EaseTextView.h"

@implementation EaseTextView

#pragma mark - Setters

- (void)setPlaceHolder:(NSString *)placeHolder {
    if([placeHolder isEqualToString:_placeHolder])
    {
        return;
    }
    NSUInteger maxChars = [EaseTextView maxCharactersPerLine];
    if([placeHolder length] > maxChars)
    {
        placeHolder = [placeHolder substringToIndex:maxChars - 8];
        placeHolder = [[placeHolder stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] stringByAppendingFormat:@"..."];
    }
    _placeHolder = placeHolder;
    [self setNeedsDisplay];
}

- (void)setPlaceHolderTextColor:(UIColor *)placeHolderTextColor {
    if([placeHolderTextColor isEqual:_placeHolderTextColor])
    {
        return;
    }
    _placeHolderTextColor = placeHolderTextColor;
    [self setNeedsDisplay];
}

#pragma mark - Message text view


/**
 文本行数

 @return 当前文本的行数
 */
- (NSUInteger)numberOfLinesOfText
{
    return [EaseTextView numberOfLinesForMessage:self.text];
}


/**
 每行显示的最长字符数

 @return 每行显示的最长字符数
 */
+ (NSUInteger)maxCharactersPerLine {
    return ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) ? 33 : 109;
}


/**
 消息的行数

 @param text 当前消息字符

 @return 当前的消息显示需要的行数
 */
+ (NSUInteger)numberOfLinesForMessage:(NSString *)text {
    return (text.length / [EaseTextView maxCharactersPerLine]) + 1;
}

#pragma mark - Textview overrides 重写父类方法

- (void)setText:(NSString *)text {
    [super setText:text];
    [self setNeedsDisplay];
}

- (void)setAttributedText:(NSAttributedString *)attributedText {
    [super setAttributedText:attributedText];
    [self setNeedsDisplay];
}

//- (void)setContentInset:(UIEdgeInsets)contentInset {
//    [super setContentInset:contentInset];
//    [self setNeedsDisplay];
//}

- (void)setFont:(UIFont *)font {
    [super setFont:font];
    [self setNeedsDisplay];
}

- (void)setTextAlignment:(NSTextAlignment)textAlignment {
    [super setTextAlignment:textAlignment];
    [self setNeedsDisplay];
}


#pragma mark - 生命周期

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveTextDidChangeNotification:)
                                                 name:UITextViewTextDidChangeNotification
                                               object:self];
    
    _placeHolderTextColor = [UIColor lightGrayColor];
    
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.scrollIndicatorInsets = UIEdgeInsetsMake(10.0f, 0.0f, 10.0f, 8.0f);
    self.contentInset = UIEdgeInsetsZero;
    self.scrollEnabled = YES;
    self.scrollsToTop = NO;
    self.userInteractionEnabled = YES;
    self.font = [UIFont systemFontOfSize:16.0f];
    self.textColor = [UIColor blackColor];
    self.backgroundColor = [UIColor whiteColor];
    self.keyboardAppearance = UIKeyboardAppearanceDefault;
    self.keyboardType = UIKeyboardTypeDefault;
    self.returnKeyType = UIReturnKeyDefault;
    self.textAlignment = NSTextAlignmentLeft;
}


#pragma mark - Drawing

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    if([self.text length] == 0 && self.placeHolder)
    {
        CGRect placeHolderRect = CGRectMake(10.0f,7.0f,rect.size.width,rect.size.height);
        
        [self.placeHolderTextColor set];
        
        if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_7_0)
        {
            //段落方式
            NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
            paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
            paragraphStyle.alignment = self.textAlignment;
            
            [self.placeHolder drawInRect:placeHolderRect
                          withAttributes:@{ NSFontAttributeName:self.font,
                                            NSForegroundColorAttributeName:self.placeHolderTextColor,
                                            NSParagraphStyleAttributeName:paragraphStyle}];
        }
        else
        {
            [self.placeHolder drawInRect:placeHolderRect
                                withFont:self.font
                           lineBreakMode:NSLineBreakByTruncatingTail
                               alignment:self.textAlignment];
        }
    }
}

#pragma mark - NSNotification 文本框输入字符变化收到通知

- (void)didReceiveTextDidChangeNotification:(NSNotification *)notification {
    //重置文本框显示
    [self setNeedsDisplay];
}

- (void)dealloc {
    _placeHolder = nil;
    _placeHolderTextColor = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidChangeNotification object:self];
}

@end
