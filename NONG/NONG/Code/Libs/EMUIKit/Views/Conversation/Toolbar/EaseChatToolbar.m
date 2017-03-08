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

#import "EaseChatToolbar.h"

#import "EaseFaceView.h"
#import "EaseEmoji.h"
#import "EaseEmotionEscape.h"
#import "EaseEmotionManager.h"

@interface EaseChatToolbar()<UITextViewDelegate, EMFaceDelegate>

@property (nonatomic) CGFloat version;
@property (strong, nonatomic) NSMutableArray *leftItems;
@property (strong, nonatomic) NSMutableArray *rightItems;
@property (strong, nonatomic) UIImageView *toolbarBackgroundImageView;
@property (strong, nonatomic) UIImageView *backgroundImageView;
@property (nonatomic) BOOL isShowButtomView;
@property (strong, nonatomic) UIView *activityButtomView;
/*
 * 输入框所在的tabbarView视图
 */
@property (strong, nonatomic) UIView *toolbarView;
@property (strong, nonatomic) UIButton *recordButton;
@property (strong, nonatomic) UIButton *moreButton;
@property (strong, nonatomic) UIButton *faceButton;
/*
 * 标记上一次inputTextView的contentSize.height
 */
@property (nonatomic) CGFloat previousTextViewContentHeight;
@property (nonatomic) NSLayoutConstraint *inputViewWidthItemsLeftConstraint;
@property (nonatomic) NSLayoutConstraint *inputViewWidthoutItemsLeftConstraint;

@end

@implementation EaseChatToolbar

@synthesize faceView = _faceView;
@synthesize moreView = _moreView;
@synthesize recordView = _recordView;

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [self initWithFrame:frame horizontalPadding:8 verticalPadding:5 inputViewMinHeight:36 inputViewMaxHeight:150 type:EMChatToolbarTypeGroup];
    if (self) {
        
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
                         type:(EMChatToolbarType)type
{
    self = [self initWithFrame:frame horizontalPadding:8 verticalPadding:5 inputViewMinHeight:36 inputViewMaxHeight:150 type:type];
    if (self) {
        
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
            horizontalPadding:(CGFloat)horizontalPadding
              verticalPadding:(CGFloat)verticalPadding
           inputViewMinHeight:(CGFloat)inputViewMinHeight
           inputViewMaxHeight:(CGFloat)inputViewMaxHeight
                         type:(EMChatToolbarType)type
{
    if (frame.size.height < (verticalPadding * 2 + inputViewMinHeight)) {
        frame.size.height = verticalPadding * 2 + inputViewMinHeight;
    }
    self = [super initWithFrame:frame];
    if (self) {
        _horizontalPadding = horizontalPadding;
        _verticalPadding = verticalPadding;
        _inputViewMinHeight = inputViewMinHeight;
        _inputViewMaxHeight = inputViewMaxHeight;
        _chatBarType = type;
        
        _leftItems = [NSMutableArray array];
        _rightItems = [NSMutableArray array];
        _version = [[[UIDevice currentDevice] systemVersion] floatValue];
        _activityButtomView = nil;
        _isShowButtomView = NO;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(chatKeyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
        
        [self _setupSubviews];
    }
    return self;
}

#pragma mark - 创建UI

//创建toolbar视图
- (void)_setupSubviews {
    //输入框所在视图背景图片拉伸
    _backgroundImageView = [[UIImageView alloc] initWithFrame:self.bounds];
    _backgroundImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    _backgroundImageView.backgroundColor = [UIColor clearColor];
    _backgroundImageView.image = [[UIImage imageNamed:@"messageToolbarBg"] stretchableImageWithLeftCapWidth:0.5 topCapHeight:10];
    [self addSubview:_backgroundImageView];
    
    //toolbar
    _toolbarView = [[UIView alloc] initWithFrame:self.bounds];
    _toolbarView.backgroundColor = [UIColor clearColor];
    [self addSubview:_toolbarView];
    
    _toolbarBackgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, _toolbarView.frame.size.width, _toolbarView.frame.size.height)];
    _toolbarBackgroundImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    _toolbarBackgroundImageView.backgroundColor = [UIColor clearColor];
    [_toolbarView addSubview:_toolbarBackgroundImageView];
    
    //输入框
    _inputTextView = [[EaseTextView alloc] initWithFrame:CGRectMake(self.horizontalPadding, self.verticalPadding, self.frame.size.width - self.verticalPadding * 2, self.frame.size.height - self.verticalPadding * 2)];
    _inputTextView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    _inputTextView.scrollEnabled = YES;
    _inputTextView.returnKeyType = UIReturnKeySend;
    _inputTextView.enablesReturnKeyAutomatically = YES; // UITextView内部判断send按钮是否可以用
    _inputTextView.placeHolder = @"输入新消息";
    _inputTextView.delegate = self;
    _inputTextView.backgroundColor = [UIColor clearColor];
    _inputTextView.layer.borderColor = [UIColor colorWithWhite:0.8f alpha:1.0f].CGColor;
    _inputTextView.layer.borderWidth = 0.65f;
    _inputTextView.layer.cornerRadius = 6.0f;
    _previousTextViewContentHeight = [self _getTextViewContentH:_inputTextView];
    [_toolbarView addSubview:_inputTextView];
    
    //左边录音文本切换按钮
    UIButton *styleChangeButton = [[UIButton alloc] init];
    styleChangeButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [styleChangeButton setImage:[UIImage imageNamed:@"chatBar_record"] forState:UIControlStateNormal];
    [styleChangeButton setImage:[UIImage imageNamed:@"chatBar_keyboard"] forState:UIControlStateSelected];
    [styleChangeButton addTarget:self action:@selector(styleButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    EaseChatToolbarItem *styleItem = [[EaseChatToolbarItem alloc] initWithButton:styleChangeButton withView:nil];
    [self setInputViewLeftItems:@[styleItem]];
    
    //按住说话按钮
    self.recordButton = [[UIButton alloc] initWithFrame:self.inputTextView.frame];
    self.recordButton.titleLabel.font = [UIFont systemFontOfSize:15.0];
    [self.recordButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [self.recordButton setBackgroundImage:[[UIImage imageNamed:@"chatBar_recordBg"] stretchableImageWithLeftCapWidth:10 topCapHeight:10] forState:UIControlStateNormal];
    [self.recordButton setBackgroundImage:[[UIImage imageNamed:@"chatBar_recordSelectedBg"] stretchableImageWithLeftCapWidth:10 topCapHeight:10] forState:UIControlStateHighlighted];
    [self.recordButton setTitle:kTouchToRecord forState:UIControlStateNormal];
    [self.recordButton setTitle:kTouchToFinish forState:UIControlStateHighlighted];
    [self.recordButton addTarget:self action:@selector(recordButtonTouchDown) forControlEvents:UIControlEventTouchDown];
    [self.recordButton addTarget:self action:@selector(recordButtonTouchUpOutside) forControlEvents:UIControlEventTouchUpOutside];
    [self.recordButton addTarget:self action:@selector(recordButtonTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
    [self.recordButton addTarget:self action:@selector(recordDragOutside) forControlEvents:UIControlEventTouchDragExit];
    [self.recordButton addTarget:self action:@selector(recordDragInside) forControlEvents:UIControlEventTouchDragEnter];
    self.recordButton.hidden = YES;
    [self.toolbarView addSubview:self.recordButton];
    
    //toolbar右侧表情按钮
    self.faceButton = [[UIButton alloc] init];
    self.faceButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [self.faceButton setImage:[UIImage imageNamed:@"chatBar_face"] forState:UIControlStateNormal];
    [self.faceButton setImage:[UIImage imageNamed:@"chatBar_faceSelected"] forState:UIControlStateHighlighted];
    [self.faceButton setImage:[UIImage imageNamed:@"chatBar_keyboard"] forState:UIControlStateSelected];
    [self.faceButton addTarget:self action:@selector(faceButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    EaseChatToolbarItem *faceItem = [[EaseChatToolbarItem alloc] initWithButton:self.faceButton withView:self.faceView];
    
    //toolbar右侧+号按钮
    self.moreButton = [[UIButton alloc] init];
    self.moreButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [self.moreButton setImage:[UIImage imageNamed:@"chatBar_more"] forState:UIControlStateNormal];
    [self.moreButton setImage:[UIImage imageNamed:@"chatBar_moreSelected"] forState:UIControlStateHighlighted];
    [self.moreButton setImage:[UIImage imageNamed:@"chatBar_keyboard"] forState:UIControlStateSelected];
    [self.moreButton addTarget:self action:@selector(moreButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    EaseChatToolbarItem *moreItem = [[EaseChatToolbarItem alloc] initWithButton:self.moreButton withView:self.moreView];
    
    [self setInputViewRightItems:@[faceItem, moreItem]];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
    _delegate = nil;
    _inputTextView.delegate = nil;
    _inputTextView = nil;
}

#pragma mark - getter

//录音显示视图
- (UIView *)recordView {
    if (_recordView == nil) {
        _recordView = [[EaseRecordView alloc] initWithFrame:CGRectMake(90, 130, 140, 140)];
    }
    return _recordView;
}

//表情选择视图
- (UIView *)faceView {
    if (_faceView == nil) {
        _faceView = [[EaseFaceView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_toolbarView.frame), self.frame.size.width, 180)];
        [(EaseFaceView *)_faceView setDelegate:self];
        _faceView.backgroundColor = [UIColor colorWithRed:240 / 255.0 green:242 / 255.0 blue:247 / 255.0 alpha:1.0];
        _faceView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    }
    
    return _faceView;
}


//加号按钮点击显示的功能按钮所在视图
- (UIView *)moreView
{
    if (_moreView == nil) {
        _moreView = [[EaseChatBarMoreView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_toolbarView.frame), self.frame.size.width, 80) type:self.chatBarType];
        _moreView.backgroundColor = [UIColor colorWithRed:240 / 255.0 green:242 / 255.0 blue:247 / 255.0 alpha:1.0];
        _moreView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    }
    
    return _moreView;
}

#pragma mark - setter

- (void)setDelegate:(id)delegate
{
    _delegate = delegate;
    if ([_moreView isKindOfClass:[EaseChatBarMoreView class]]) {
        [(EaseChatBarMoreView *)_moreView setDelegate:delegate];
    }
}

- (void)setRecordView:(UIView *)recordView
{
    if(_recordView != recordView){
        _recordView = recordView;
    }
}

- (void)setMoreView:(UIView *)moreView
{
    if (_moreView != moreView) {
        _moreView = moreView;
        
        for (EaseChatToolbarItem *item in self.rightItems) {
            if (item.button == self.moreButton) {
                item.button2View = _moreView;
                break;
            }
        }
    }
}

- (void)setFaceView:(UIView *)faceView
{
    if (_faceView != faceView) {
        _faceView = faceView;
        
        for (EaseChatToolbarItem *item in self.rightItems) {
            if (item.button == self.faceButton) {
                item.button2View = _faceView;
                break;
            }
        }
    }
}

- (NSArray*)inputViewLeftItems
{
    return self.leftItems;
}

- (void)setInputViewLeftItems:(NSArray *)inputViewLeftItems
{
    for (EaseChatToolbarItem *item in self.leftItems) {
        [item.button removeFromSuperview];
        [item.button2View removeFromSuperview];
    }
    [self.leftItems removeAllObjects];
    
    CGFloat oX = self.horizontalPadding;
    CGFloat itemHeight = self.toolbarView.frame.size.height - self.verticalPadding * 2;
    for (id item in inputViewLeftItems) {
        if ([item isKindOfClass:[EaseChatToolbarItem class]]) {
            EaseChatToolbarItem *chatItem = (EaseChatToolbarItem *)item;
            if (chatItem.button) {
                CGRect itemFrame = chatItem.button.frame;
                if (itemFrame.size.height == 0) {
                    itemFrame.size.height = itemHeight;
                }
                
                if (itemFrame.size.width == 0) {
                    itemFrame.size.width = itemFrame.size.height;
                }
                
                itemFrame.origin.x = oX;
                itemFrame.origin.y = (self.toolbarView.frame.size.height - itemFrame.size.height) / 2;
                chatItem.button.frame = itemFrame;
                oX += (itemFrame.size.width + self.horizontalPadding);
                
                [self.toolbarView addSubview:chatItem.button];
                [self.leftItems addObject:chatItem];
            }
        }
    }
    
    CGRect inputFrame = self.inputTextView.frame;
    CGFloat value = inputFrame.origin.x - oX;
    inputFrame.origin.x = oX;
    inputFrame.size.width += value;
    self.inputTextView.frame = inputFrame;
    
    CGRect recordFrame = self.recordButton.frame;
    recordFrame.origin.x = inputFrame.origin.x;
    recordFrame.size.width = inputFrame.size.width;
    self.recordButton.frame = recordFrame;
}

- (NSArray*)inputViewRightItems
{
    return self.rightItems;
}

- (void)setInputViewRightItems:(NSArray *)inputViewRightItems
{
    for (EaseChatToolbarItem *item in self.rightItems) {
        [item.button removeFromSuperview];
        [item.button2View removeFromSuperview];
    }
    [self.rightItems removeAllObjects];
    
    CGFloat oMaxX = self.toolbarView.frame.size.width - self.horizontalPadding;
    CGFloat itemHeight = self.toolbarView.frame.size.height - self.verticalPadding * 2;
    if ([inputViewRightItems count] > 0) {
        for (NSInteger i = (inputViewRightItems.count - 1); i >= 0; i--) {
            id item = [inputViewRightItems objectAtIndex:i];
            if ([item isKindOfClass:[EaseChatToolbarItem class]]) {
                EaseChatToolbarItem *chatItem = (EaseChatToolbarItem *)item;
                if (chatItem.button) {
                    CGRect itemFrame = chatItem.button.frame;
                    if (itemFrame.size.height == 0) {
                        itemFrame.size.height = itemHeight;
                    }
                    
                    if (itemFrame.size.width == 0) {
                        itemFrame.size.width = itemFrame.size.height;
                    }
                    
                    oMaxX -= itemFrame.size.width;
                    itemFrame.origin.x = oMaxX;
                    itemFrame.origin.y = (self.toolbarView.frame.size.height - itemFrame.size.height) / 2;
                    chatItem.button.frame = itemFrame;
                    oMaxX -= self.horizontalPadding;
                    
                    [self.toolbarView addSubview:chatItem.button];
                    [self.rightItems addObject:item];
                }
            }
        }
    }
    
    CGRect inputFrame = self.inputTextView.frame;
    CGFloat value = oMaxX - CGRectGetMaxX(inputFrame);
    inputFrame.size.width += value;
    self.inputTextView.frame = inputFrame;
    
    CGRect recordFrame = self.recordButton.frame;
    recordFrame.origin.x = inputFrame.origin.x;
    recordFrame.size.width = inputFrame.size.width;
    self.recordButton.frame = recordFrame;
}

#pragma mark ------------------ 根据输入框的输入文本改变，调整自身视图和输入框所在的tabbarView视图 --------------

- (CGFloat)_getTextViewContentH:(UITextView *)textView {
    if (self.version >= 7.0)
    {
        //向上取整 返回“最佳”大小
        return ceilf([textView sizeThatFits:textView.frame.size].height);
    }
    else
    {
        return textView.contentSize.height;
    }
}

- (void)_willShowInputTextViewToHeight:(CGFloat)toHeight {
    //当小于文本输入框的最低高度
    if (toHeight < self.inputViewMinHeight)
    {
        toHeight = self.inputViewMinHeight;
    }
    
    //当大于文本输入框的最大高度
    if (toHeight > self.inputViewMaxHeight)
    {
        toHeight = self.inputViewMaxHeight;
    }
    
    //如果和上一次的文本内容高度一致，不需要重新调整位置
    if (toHeight == _previousTextViewContentHeight)
    {
        return;
    }
    else
    {
        //s
        CGFloat changeHeight = toHeight - _previousTextViewContentHeight;
        
        //重置自身视图的位置
        CGRect rect = self.frame;
        rect.size.height += changeHeight;
        rect.origin.y -= changeHeight;
        self.frame = rect;
        
        //重置输入框所在的tabbarView视图位置
        rect = self.toolbarView.frame;
        rect.size.height += changeHeight;
        self.toolbarView.frame = rect;
        
        //重置文本输入框位置
        if (self.version < 7.0)
        {
            [self.inputTextView setContentOffset:CGPointMake(0.0f, (self.inputTextView.contentSize.height - self.inputTextView.frame.size.height) / 2) animated:YES];
        }
        
        //修改文本输入框上一次高度标记值
        _previousTextViewContentHeight = toHeight;
        
        if (_delegate && [_delegate respondsToSelector:@selector(chatToolbarDidChangeFrameToHeight:)])
        {
            //代理出去，改变消息列表位置
            [_delegate chatToolbarDidChangeFrameToHeight:self.frame.size.height];
        }
    }
}

#pragma mark ------------------ 显示tabbarView上的按钮点击出现的视图 --------------

- (void)_willShowBottomHeight:(CGFloat)bottomHeight {
    //上一次的位置
    CGRect fromFrame = self.frame;
    
    //整体要变化的目标高度
    CGFloat toHeight = self.toolbarView.frame.size.height + bottomHeight;
    
    //整体要变化的目标位置
    CGRect toFrame   = CGRectMake(fromFrame.origin.x, fromFrame.origin.y + (fromFrame.size.height - toHeight), fromFrame.size.width, toHeight);
    
    //如若不显示各内容返回
    if(bottomHeight == 0 && self.frame.size.height == self.toolbarView.frame.size.height)
    {
        return;
    }
    
    if (bottomHeight == 0)
    {
        self.isShowButtomView = NO;
    }
    else
    {
        self.isShowButtomView = YES;
    }
    
    //显示内容视图后，重置自身位置
    self.frame = toFrame;
    
    if (_delegate && [_delegate respondsToSelector:@selector(chatToolbarDidChangeFrameToHeight:)])
    {
        [_delegate chatToolbarDidChangeFrameToHeight:toHeight];
    }
}

- (void)_willShowBottomView:(UIView *)bottomView
{
    if (![self.activityButtomView isEqual:bottomView]) {
        CGFloat bottomHeight = bottomView ? bottomView.frame.size.height : 0;
        [self _willShowBottomHeight:bottomHeight];
        
        if (bottomView) {
            CGRect rect = bottomView.frame;
            rect.origin.y = CGRectGetMaxY(self.toolbarView.frame);
            bottomView.frame = rect;
            [self addSubview:bottomView];
        }
        
        if (self.activityButtomView) {
            [self.activityButtomView removeFromSuperview];
        }
        self.activityButtomView = bottomView;
    }
}

- (void)_willShowKeyboardFromFrame:(CGRect)beginFrame toFrame:(CGRect)toFrame
{
    if (beginFrame.origin.y == [[UIScreen mainScreen] bounds].size.height)
    {
        [self _willShowBottomHeight:toFrame.size.height];
        if (self.activityButtomView) {
            [self.activityButtomView removeFromSuperview];
        }
        self.activityButtomView = nil;
    }
    else if (toFrame.origin.y == [[UIScreen mainScreen] bounds].size.height)
    {
        [self _willShowBottomHeight:0];
    }
    else
    {
        [self _willShowBottomHeight:toFrame.size.height];
    }
}

#pragma mark ------------------ UITextViewDelegate --------------

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    if ([self.delegate respondsToSelector:@selector(inputTextViewWillBeginEditing:)]) {
        [self.delegate inputTextViewWillBeginEditing:self.inputTextView];
    }
    
    for (EaseChatToolbarItem *item in self.leftItems) {
        item.button.selected = NO;
    }
    
    for (EaseChatToolbarItem *item in self.rightItems) {
        item.button.selected = NO;
    }
    
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    [textView becomeFirstResponder];
    
    if ([self.delegate respondsToSelector:@selector(inputTextViewDidBeginEditing:)]) {
        [self.delegate inputTextViewDidBeginEditing:self.inputTextView];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    [textView resignFirstResponder];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        if ([self.delegate respondsToSelector:@selector(didSendText:)]) {
            [self.delegate didSendText:textView.text];
            self.inputTextView.text = @"";
            [self _willShowInputTextViewToHeight:[self _getTextViewContentH:self.inputTextView]];
        }
        
        return NO;
    }
    else if ([text isEqualToString:@"@"]) {
        if ([self.delegate respondsToSelector:@selector(didInputAtInLocation:)]) {
            if ([self.delegate didInputAtInLocation:range.location]) {
                [self _willShowInputTextViewToHeight:[self _getTextViewContentH:self.inputTextView]];
                return NO;
            }
        }
    }
    else if ([text length] == 0) {
        //delete one character
        if (range.length == 1 && [self.delegate respondsToSelector:@selector(didDeleteCharacterFromLocation:)]) {
            return ![self.delegate didDeleteCharacterFromLocation:range.location];
        }
    }
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
    [self _willShowInputTextViewToHeight:[self _getTextViewContentH:textView]];
}

#pragma mark - DXFaceDelegate

/**
 *  选中某个表情视图
 *
 *  @param str      当前选中的表情视图
 *  @param isDelete <#isDelete description#>
 */
- (void)selectedFacialView:(NSString *)str isDelete:(BOOL)isDelete
{
    /**
     *  取出当前文本输入框编写的内容
     */
    NSString *chatText = self.inputTextView.text;
    
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithAttributedString:self.inputTextView.attributedText];
    
    if (!isDelete && str.length > 0)
    {
        if (self.version >= 7.0)
        {
            NSRange range = [self.inputTextView selectedRange];
            [attr insertAttributedString:[[EaseEmotionEscape sharedInstance] attStringFromTextForInputView:str textFont:self.inputTextView.font] atIndex:range.location];
            self.inputTextView.attributedText = attr;
        }
        else
        {
            self.inputTextView.text = @"";
            self.inputTextView.text = [NSString stringWithFormat:@"%@%@",chatText,str];
        }
    }
    else
    {
        if (self.version >= 7.0)
        {
            if (chatText.length > 0)
            {
                NSInteger length = 1;
                if (chatText.length >= 2)
                {
                    NSString *subStr = [chatText substringFromIndex:chatText.length-2];
                    if ([EaseEmoji stringContainsEmoji:subStr])
                    {
                        length = 2;
                    }
                }
                self.inputTextView.attributedText = [self backspaceText:attr length:length];
            }
        }
        else
        {
            if (chatText.length >= 2)
            {
                NSString *subStr = [chatText substringFromIndex:chatText.length-2];
                if ([(EaseFaceView *)self.faceView stringIsFace:subStr])
                {
                    self.inputTextView.text = [chatText substringToIndex:chatText.length-2];
                    [self textViewDidChange:self.inputTextView];
                    return;
                }
            }
            
            if (chatText.length > 0)
            {
                self.inputTextView.text = [chatText substringToIndex:chatText.length-1];
            }
        }
    }
    
    [self textViewDidChange:self.inputTextView];
}

-(NSMutableAttributedString*)backspaceText:(NSMutableAttributedString*) attr length:(NSInteger)length
{
    NSRange range = [self.inputTextView selectedRange];
    if (range.location == 0) {
        return attr;
    }
    [attr deleteCharactersInRange:NSMakeRange(range.location - length, length)];
    return attr;
}

- (void)sendFace
{
    NSString *chatText = self.inputTextView.text;
    if (chatText.length > 0) {
        if ([self.delegate respondsToSelector:@selector(didSendText:)]) {
            
            if (![_inputTextView.text isEqualToString:@""]) {
                
                //转义回来
                NSMutableString *attStr = [[NSMutableString alloc] initWithString:self.inputTextView.attributedText.string];
                [_inputTextView.attributedText enumerateAttribute:NSAttachmentAttributeName
                                                          inRange:NSMakeRange(0, self.inputTextView.attributedText.length)
                                                          options:NSAttributedStringEnumerationReverse
                                                       usingBlock:^(id value, NSRange range, BOOL *stop)
                 {
                     if (value) {
                         EMTextAttachment* attachment = (EMTextAttachment*)value;
                         NSString *str = [NSString stringWithFormat:@"%@",attachment.imageName];
                         [attStr replaceCharactersInRange:range withString:str];
                     }
                 }];
                [self.delegate didSendText:attStr];
                self.inputTextView.text = @"";
                [self _willShowInputTextViewToHeight:[self _getTextViewContentH:self.inputTextView]];;
            }
        }
    }
}

- (void)sendFaceWithEmotion:(EaseEmotion *)emotion
{
    if (emotion)
    {
        if ([self.delegate respondsToSelector:@selector(didSendText:withExt:)]) {
            [self.delegate didSendText:emotion.emotionTitle withExt:@{EASEUI_EMOTION_DEFAULT_EXT:emotion}];
            [self _willShowInputTextViewToHeight:[self _getTextViewContentH:self.inputTextView]];;
        }
    }
}

#pragma mark - UIKeyboardNotification

- (void)chatKeyboardWillChangeFrame:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    CGRect endFrame = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect beginFrame = [userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    CGFloat duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve curve = [userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
    
    void(^animations)() = ^{
        [self _willShowKeyboardFromFrame:beginFrame toFrame:endFrame];
    };
    
    [UIView animateWithDuration:duration delay:0.0f options:(curve << 16 | UIViewAnimationOptionBeginFromCurrentState) animations:animations completion:nil];
}

#pragma mark - action 按钮点击事件

- (void)styleButtonAction:(id)sender
{
    UIButton *button = (UIButton *)sender;
    button.selected = !button.selected;
    if (button.selected)
    {
        for (EaseChatToolbarItem *item in self.rightItems)
        {
            item.button.selected = NO;
        }
        
        for (EaseChatToolbarItem *item in self.leftItems)
        {
            if (item.button != button)
            {
                item.button.selected = NO;
            }
        }
        
        [self _willShowBottomView:nil];
        
        self.inputTextView.text = @"";
        [self textViewDidChange:self.inputTextView];
        [self.inputTextView resignFirstResponder];
    }
    else
    {
        [self.inputTextView becomeFirstResponder];
    }
    
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.recordButton.hidden = !button.selected;
        self.inputTextView.hidden = button.selected;
    } completion:nil];
}

- (void)faceButtonAction:(id)sender
{
    UIButton *button = (UIButton *)sender;
    button.selected = !button.selected;
    
    EaseChatToolbarItem *faceItem = nil;
    for (EaseChatToolbarItem *item in self.rightItems)
    {
        if (item.button == button)
        {
            faceItem = item;
            continue;
        }
        
        item.button.selected = NO;
    }
    
    for (EaseChatToolbarItem *item in self.leftItems)
    {
        item.button.selected = NO;
    }
    
    if (button.selected)
    {
        [self.inputTextView resignFirstResponder];
        
        [self _willShowBottomView:faceItem.button2View];
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.recordButton.hidden = button.selected;
            self.inputTextView.hidden = !button.selected;
        } completion:^(BOOL finished) {
            
        }];
    }
    else
    {
        [self.inputTextView becomeFirstResponder];
    }
}

- (void)moreButtonAction:(id)sender
{
    UIButton *button = (UIButton *)sender;
    button.selected = !button.selected;
    
    EaseChatToolbarItem *moreItem = nil;
    for (EaseChatToolbarItem *item in self.rightItems) {
        if (item.button == button){
            moreItem = item;
            continue;
        }
        
        item.button.selected = NO;
    }
    
    for (EaseChatToolbarItem *item in self.leftItems) {
        item.button.selected = NO;
    }
    
    if (button.selected) {
        [self.inputTextView resignFirstResponder];
        
        [self _willShowBottomView:moreItem.button2View];
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.recordButton.hidden = button.selected;
            self.inputTextView.hidden = !button.selected;
        } completion:nil];
    }
    else
    {
        [self.inputTextView becomeFirstResponder];
    }
}

- (void)recordButtonTouchDown
{
    if (_delegate && [_delegate respondsToSelector:@selector(didStartRecordingVoiceAction:)]) {
        [_delegate didStartRecordingVoiceAction:self.recordView];
    }
}

- (void)recordButtonTouchUpOutside
{
    if (_delegate && [_delegate respondsToSelector:@selector(didCancelRecordingVoiceAction:)])
    {
        [_delegate didCancelRecordingVoiceAction:self.recordView];
    }
}

- (void)recordButtonTouchUpInside
{
    self.recordButton.enabled = NO;
    if ([self.delegate respondsToSelector:@selector(didFinishRecoingVoiceAction:)])
    {
        [self.delegate didFinishRecoingVoiceAction:self.recordView];
    }
    self.recordButton.enabled = YES;
}

- (void)recordDragOutside
{
    if ([self.delegate respondsToSelector:@selector(didDragOutsideAction:)])
    {
        [self.delegate didDragOutsideAction:self.recordView];
    }
}

- (void)recordDragInside
{
    if ([self.delegate respondsToSelector:@selector(didDragInsideAction:)])
    {
        [self.delegate didDragInsideAction:self.recordView];
    }
}

#pragma mark - public

+ (CGFloat)defaultHeight
{
    return 5 * 2 + 36;
}

- (BOOL)endEditing:(BOOL)force
{
    BOOL result = [super endEditing:force];
    
    for (EaseChatToolbarItem *item in self.rightItems) {
        item.button.selected = NO;
    }
    [self _willShowBottomView:nil];
    
    return result;
}

- (void)cancelTouchRecord
{
    if ([_recordView isKindOfClass:[EaseRecordView class]]) {
        [(EaseRecordView *)_recordView recordButtonTouchUpInside];
        [_recordView removeFromSuperview];
    }
}

- (void)willShowBottomView:(UIView *)bottomView
{
    [self _willShowBottomView:bottomView];
}

@end
