 //
//  ChatController.m
//  NONG
//
//  Created by 吴 吴 on 16/8/16.
//  Copyright © 2016年 上海泰侠网络科技有限公司. All rights reserved.
//

#import "ChatController.h"
#import "MyLocationController.h"
#import "ChatFriendListController.h"
#import "GroupDetailController.h"

#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface ChatController ()<UITableViewDataSource,UITableViewDelegate,MyLocationControllerDelegate>
{
    UITableView *infoTable;
    
    /**
     *  复制菜单item
     */
    UIMenuItem *_copyMenuItem;
    /**
     *  删除菜单item
     */
    UIMenuItem *_deleteMenuItem;
    /**
     *  转发菜单item
     */
    UIMenuItem *_transpondMenuItem;
    
    /**
     *  列表消息数组(最重要,所有消息均在这个数组控制)
     */
    NSMutableArray *dataArray;
    /**
     *  长按手势
     */
    UILongPressGestureRecognizer *_lpgr;
    /**
     *  消息数组
     */
    NSMutableArray *messsagesSource;
    
    
    /**
     *  自定义表情字典
     */
    NSMutableDictionary *emotionDic;
    /**
     *  用于存放扩展信息数组
     */
    NSMutableArray *_atTargets;
    
    /**
     *  多线程对象
     */
    dispatch_queue_t _messageQueue;
}
/**
 *  系统相册管理对象
 */
@property (nonatomic,strong) UIImagePickerController *imagePicker;


@property(nonatomic,strong) id<IMessageModel> playingVoiceModel;

/**
 *  标记是否正在播放语音
 */
@property (nonatomic,assign) BOOL isPlayingAudio;

/**
 *  菜单控制器
 */
@property (nonatomic,strong) UIMenuController *menuController;
@property (nonatomic,strong) NSIndexPath *menuIndexPath;

@end

@implementation ChatController
@synthesize chatToolbar,chatBarMoreView,faceView;
@synthesize messageTimeIntervalTag = _messageTimeIntervalTag;

- (id)initWithConversationChatter:(NSString *)conversationChatter conversationType:(EMConversationType)conversationType {
    self = [super init];
    if (self)
    {
        /**
         *  获取当前会话对象
         */
        _conversation = [[EMClient sharedClient].chatManager getConversation:conversationChatter type:conversationType createIfNotExist:YES];
        [_conversation markAllMessagesAsRead];
        
        /**
         *  默认滚动到底部
         */
        _scrollToBottomWhenAppear = YES;
        
        messsagesSource = [NSMutableArray array];
        dataArray       = [NSMutableArray array];
        _atTargets      = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor whiteColor];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didBecomeActive)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    
    /**
     *  如果是群聊
     */
    if (_conversation.type == EMConversationTypeGroupChat)
    {
        UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithTitle:@"群组详情" style:UIBarButtonItemStylePlain target:self action:@selector(rightItemPressed)];
        self.navigationItem.rightBarButtonItem = rightItem;
    }
    
    _messageQueue = dispatch_queue_create("taixia", NULL);
    [self setupUI];
    [self setMessageCell];
    [self refreshData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[IQKeyboardManager sharedManager]setEnableAutoToolbar:NO];
    self.isViewDidAppear = YES;
    [[EaseSDKHelper shareHelper] setIsShowingimagePicker:NO];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[EMCDDeviceManager sharedInstance] disableProximitySensor];
    self.isViewDidAppear = NO;
    
    if (self.scrollToBottomWhenAppear)
    {
        [self _scrollViewToBottom:NO];
    }
    self.scrollToBottomWhenAppear = YES;
}

- (void)rightItemPressed {
    GroupDetailController *vc = [[GroupDetailController alloc]initWithGroupId:_conversation.conversationId];
    vc.title                  = self.title;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - 创建UI

- (void)setupUI {
    /**
     *  底部聊天栏
     */
    CGFloat chatbarHeight     = [EaseChatToolbar defaultHeight];
    EMChatToolbarType barType = _conversation.type == EMConversationTypeChat ? EMChatToolbarTypeChat : EMChatToolbarTypeGroup;
    chatToolbar = [[EaseChatToolbar alloc] initWithFrame:AppFrame(0,self.view.height - chatbarHeight, self.view.width,chatbarHeight) type:barType];
    chatToolbar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [self.view addSubview:chatToolbar];
    if ([chatToolbar isKindOfClass:[EaseChatToolbar class]])
    {
        [(EaseChatToolbar *)chatToolbar setDelegate:self];
        chatBarMoreView = (EaseChatBarMoreView*)[(EaseChatToolbar *)chatToolbar moreView];
        faceView = (EaseFaceView*)[(EaseChatToolbar *)chatToolbar faceView];
        _recordView = (EaseRecordView*)[(EaseChatToolbar *)chatToolbar recordView];
        /**
         *  添加表情
         */
        [self setupEmotion];
    }
    
    /**
     * 消息列表
     */
    infoTable = [[UITableView alloc]initWithFrame:AppFrame(0,64,AppWidth,self.view.height-64-chatbarHeight) style:UITableViewStylePlain];
    infoTable.backgroundColor = [UIColor clearColor];
    infoTable.separatorColor  = [UIColor clearColor];
    infoTable.separatorStyle  = UITableViewCellSeparatorStyleNone;
    infoTable.dataSource      = self;
    infoTable.delegate        = self;
    infoTable.mj_header       = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(refreshData)];
    [self.view addSubview:infoTable];
    
    _imagePicker = [[UIImagePickerController alloc] init];
    _imagePicker.modalPresentationStyle= UIModalPresentationOverFullScreen;
    _imagePicker.delegate = self;
    _imagePicker.allowsEditing = NO;
    
    /**
     * 退出键盘手势
     */
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyBoardHidden:)];
    [self.view addGestureRecognizer:tap];
    
    /**
     * 列表上长按手势
     */
    _lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    _lpgr.minimumPressDuration = 0.5;
    [infoTable addGestureRecognizer:_lpgr];
    
    /**
     *  注册代理
     */
    [EMCDDeviceManager sharedInstance].delegate = self;
    [[EMClient sharedClient].chatManager addDelegate:self delegateQueue:nil];
}

- (void)setMessageCell  {
    /**
     *  配置消息cell的显示
     */
    [[EaseBaseMessageCell appearance] setSendBubbleBackgroundImage:[[UIImage imageNamed:@"chat_sender_bg"] stretchableImageWithLeftCapWidth:5 topCapHeight:35]];
    
    [[EaseBaseMessageCell appearance] setRecvBubbleBackgroundImage:[[UIImage imageNamed:@"chat_receiver_bg"] stretchableImageWithLeftCapWidth:35 topCapHeight:35]];
    
    [[EaseBaseMessageCell appearance] setSendMessageVoiceAnimationImages:@[[UIImage imageNamed:@"chat_sender_audio_playing_full"],
                                                                           [UIImage imageNamed:@"chat_sender_audio_playing_000"],
                                                                           [UIImage imageNamed:@"chat_sender_audio_playing_001"],
                                                                           [UIImage imageNamed:@"chat_sender_audio_playing_002"],
                                                                           [UIImage imageNamed:@"chat_sender_audio_playing_003"]]];
    
    [[EaseBaseMessageCell appearance] setRecvMessageVoiceAnimationImages:@[[UIImage imageNamed:@"chat_receiver_audio_playing_full"],
                                                                           [UIImage imageNamed:@"chat_receiver_audio_playing000"],
                                                                           [UIImage imageNamed:@"chat_receiver_audio_playing001"],
                                                                           [UIImage imageNamed:@"chat_receiver_audio_playing002"],
                                                                           [UIImage imageNamed:@"chat_receiver_audio_playing003"]]];
    
    [[EaseBaseMessageCell appearance] setAvatarSize:40.f];
    [[EaseBaseMessageCell appearance] setAvatarCornerRadius:20.f];
    
    [[EaseChatBarMoreView appearance] setMoreViewBackgroundColor:[UIColor colorWithRed:240 / 255.0 green:242 / 255.0 blue:247 / 255.0 alpha:1.0]];
}

#pragma mark - 网络数据

- (void)refreshData {
    self.messageTimeIntervalTag = -1;
    NSString *messageId = nil;
    if ([messsagesSource count] > 0)
    {
        /**
         *  在有消息的情况下，以当前为界,继续获取更多
         */
        messageId = [(EMMessage *)messsagesSource.firstObject messageId];
    }
    else
    {
        messageId = nil;
    }
    /**
     *  以每页10条数据拉去更多消息
     */
    [self _loadMessagesBefore:messageId count:10 append:YES];
    [self reloadUI];
}

- (void)endRefresh {
    [infoTable.mj_header endRefreshing];
}

- (void)reloadUI {
    [infoTable reloadData];
    [self endRefresh];
}

#pragma mark ------------------ EMChatToolbarDelegate --------------

- (void)chatToolbarDidChangeFrameToHeight:(CGFloat)toHeight {
    [UIView animateWithDuration:0.3 animations:^{
        CGRect rect = infoTable.frame;
        rect.origin.y = 64;
        rect.size.height = self.view.height-64 - toHeight;
        infoTable.frame = rect;
    }];
    [self _scrollViewToBottom:NO];
}

- (void)inputTextViewWillBeginEditing:(EaseTextView *)inputTextView {
    if (_menuController == nil) {
        _menuController = [UIMenuController sharedMenuController];
    }
    [_menuController setMenuItems:nil];
}

- (void)didSendText:(NSString *)text {
    if (text && text.length > 0)
    {
        [self sendTextMessage:text];
        [_atTargets removeAllObjects];
    }
}

- (BOOL)didInputAtInLocation:(NSUInteger)location {
    return YES;
}

- (BOOL)didDeleteCharacterFromLocation:(NSUInteger)location {
    NSLog(@"键盘上的x按钮点击事件");
    EaseChatToolbar *toolbar = (EaseChatToolbar*)self.chatToolbar;
    
    if ([toolbar.inputTextView.text length] == location + 1)
    {
        //如果删除的是最后边的字符
        NSString *inputText = toolbar.inputTextView.text;
        NSRange range = [inputText rangeOfString:@"@" options:NSBackwardsSearch];
        if (range.location != NSNotFound)
        {
            if (location - range.location > 1)
            {
                NSString *sub = [inputText substringWithRange:NSMakeRange(range.location + 1, location - range.location - 1)];
                for (EaseAtTarget *target in _atTargets)
                {
                    if ([sub isEqualToString:target.userId] || [sub isEqualToString:target.nickname])
                    {
                        inputText = range.location > 0 ? [inputText substringToIndex:range.location] : @"";
                        toolbar.inputTextView.text = inputText;
                        toolbar.inputTextView.selectedRange = NSMakeRange(inputText.length, 0);
                        [_atTargets removeObject:target];
                        return YES;
                    }
                }
            }
        }
    }
    return NO;
}

#pragma mark ------------------ 发送自定义表情消息 --------------

/**
 *  发送gif表情
 *
 *  @param text 当前发送的gif表情名称
 *  @param ext  当前发送的gif表情信息扩展字典
 */
- (void)didSendText:(NSString *)text withExt:(NSDictionary*)ext {
    if ([ext objectForKey:EASEUI_EMOTION_DEFAULT_EXT])
    {
        /**
         *  当前需要发送的自定义表情消息
         */
        EaseEmotion *emotion = [ext objectForKey:EASEUI_EMOTION_DEFAULT_EXT];
        
        /**
         *  表情消息的扩展字典
         */
        NSDictionary *ext = [self getEmotionExtFormessageWithEaseEmotion:emotion];
        
        /**
         *  扩展信息字典增加用户头像字段
         */
        NSMutableDictionary *extDic = [NSMutableDictionary dictionaryWithDictionary:ext];
        [extDic setObject:MyAvaterURL forKey:@"MyAvaterURL"];
        
        [self sendTextMessage:emotion.emotionTitle withExt:extDic];
        return;
    }
    if (text && text.length > 0)
    {
        NSMutableDictionary *extDic = [NSMutableDictionary dictionaryWithDictionary:ext];
        [extDic setObject:MyAvaterURL forKey:@"MyAvaterURL"];
        
        [self sendTextMessage:text withExt:extDic];
    }
}

- (void)didStartRecordingVoiceAction:(UIView *)recordView {
    if ([self.recordView isKindOfClass:[EaseRecordView class]])
    {
        [(EaseRecordView *)self.recordView recordButtonTouchDown];
    }
    if ([self _canRecord])
    {
        EaseRecordView *tmpView = (EaseRecordView *)recordView;
        tmpView.center = self.view.center;
        [self.view addSubview:tmpView];
        [self.view bringSubviewToFront:recordView];
        int x = arc4random() % 100000;
        NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
        NSString *fileName = [NSString stringWithFormat:@"%d%d",(int)time,x];
        
        [[EMCDDeviceManager sharedInstance] asyncStartRecordingWithFileName:fileName completion:^(NSError *error)
         {
             if (error) {
                 NSLog(@"开始录音失败");
             }
         }];
    }
}

- (void)didCancelRecordingVoiceAction:(UIView *)recordView {
    [[EMCDDeviceManager sharedInstance] cancelCurrentRecording];
    if ([self.recordView isKindOfClass:[EaseRecordView class]])
    {
        [(EaseRecordView *)self.recordView recordButtonTouchUpOutside];
    }
    [self.recordView removeFromSuperview];
}

- (void)didFinishRecoingVoiceAction:(UIView *)recordView {
    if ([self.recordView isKindOfClass:[EaseRecordView class]])
    {
        [(EaseRecordView *)self.recordView recordButtonTouchUpInside];
    }
    [self.recordView removeFromSuperview];
    __weak typeof(self) weakSelf = self;
    [[EMCDDeviceManager sharedInstance] asyncStopRecordingWithCompletion:^(NSString *recordPath, NSInteger aDuration, NSError *error) {
        if (!error)
        {
            NSLog(@"发送语音");
            /**
             *  发送语音消息
             */
            [weakSelf sendVoiceMessageWithLocalPath:recordPath duration:aDuration];
        }
        else
        {
            NSLog(@"提示:录音时间太短了");
        }
    }];
}

- (void)didDragInsideAction:(UIView *)recordView {
    if ([self.recordView isKindOfClass:[EaseRecordView class]])
    {
        [(EaseRecordView *)self.recordView recordButtonDragInside];
    }
}

- (void)didDragOutsideAction:(UIView *)recordView {
    if ([self.recordView isKindOfClass:[EaseRecordView class]])
    {
        [(EaseRecordView *)self.recordView recordButtonDragOutside];
    }
}

#pragma mark ------------------ EaseChatBarMoreViewDelegate 聊天栏上几大功能按钮点击事件--------------

- (void)moreViewPhotoAction:(EaseChatBarMoreView *)moreView {
    [chatToolbar endEditing:YES];
    _imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    /**
     * 如果需要选择视频的话，需要在这里添加媒体类型
     */
    _imagePicker.mediaTypes = @[(NSString *)kUTTypeImage];
    [self presentViewController:_imagePicker animated:YES completion:NULL];
    
    self.isViewDidAppear = NO;
    [[EaseSDKHelper shareHelper] setIsShowingimagePicker:YES];
}

- (void)moreViewTakePicAction:(EaseChatBarMoreView *)moreView {
    [chatToolbar endEditing:YES];
    _imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    /**
     * 如果需要拍摄视频的话，需要在这里添加媒体类型
     */
    _imagePicker.mediaTypes = @[(NSString *)kUTTypeImage];
    [self presentViewController:_imagePicker animated:YES completion:NULL];
    
    self.isViewDidAppear = NO;
    [[EaseSDKHelper shareHelper] setIsShowingimagePicker:YES];
}

- (void)moreViewLocationAction:(EaseChatBarMoreView *)moreView {
    NSLog(@"发送当前位置");
    [chatToolbar endEditing:YES];
    MyLocationController *vc = [[MyLocationController alloc]init];
    vc.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)moreViewAudioCallAction:(EaseChatBarMoreView *)moreView {
    NSLog(@"语音按钮点击");
}

- (void)moreViewVideoCallAction:(EaseChatBarMoreView *)moreView {
    NSLog(@"视频按钮点击");
}

#pragma mark ------------------ MyLocationControllerDelegate --------------

- (void)sendLocationLatitude:(double)latitude longitude:(double)longitude andAddress:(NSString *)address {
    [self sendLocationMessageLatitude:latitude longitude:longitude andAddress:address];
}

#pragma mark ------------------ EMChatManagerDelegate 聊天管理代理(收到消息,消息状态变更)--------------

- (void)didReceiveMessages:(NSArray *)aMessages {
    /**
     *  收到消息时，播放音频
     */
    [[EMCDDeviceManager sharedInstance] playNewMessageSound];
    /**
     *  收到消息时，震动
     */
    [[EMCDDeviceManager sharedInstance] playVibration];
    /**
     *  收到新消息(肯定是别人发送的)
     */
    for (EMMessage *message in aMessages)
    {
        if ([self.conversation.conversationId isEqualToString:message.conversationId])
        {
            /**
             *  将收到的消息加入数据库
             */
            [self addMessageToDataSource:message progress:nil];
            
            [self _sendHasReadResponseForMessages:@[message] isRead:NO];
            
            if ([self _shouldMarkMessageAsRead])
            {
                [self.conversation markMessageAsReadWithId:message.messageId];
            }
        }
    }
}

- (void)didReceiveCmdMessages:(NSArray *)aCmdMessages {
    for (EMMessage *message in aCmdMessages)
    {
        if ([self.conversation.conversationId isEqualToString:message.conversationId]) {
            NSLog(@"有透传消息");
            break;
        }
    }
}

- (void)didReceiveHasDeliveredAcks:(NSArray *)aMessages {
    for(EMMessage *message in aMessages)
    {
        [self _updateMessageStatus:message];
    }
}

- (void)didReceiveHasReadAcks:(NSArray *)aMessages {
    for (EMMessage *message in aMessages)
    {
        if (![self.conversation.conversationId isEqualToString:message.conversationId]){
            continue;
        }
        
        __block id<IMessageModel> model = nil;
        __block BOOL isHave = NO;
        [dataArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
         {
             if ([obj conformsToProtocol:@protocol(IMessageModel)])
             {
                 model = (id<IMessageModel>)obj;
                 if ([model.messageId isEqualToString:message.messageId])
                 {
                     model.message.isReadAcked = YES;
                     isHave = YES;
                     *stop = YES;
                 }
             }
         }];
        
        if(!isHave)
        {
            return;
        }
        [infoTable reloadData];
    }
}

- (void)didMessageStatusChanged:(EMMessage *)aMessage
                          error:(EMError *)aError {
    [self _updateMessageStatus:aMessage];
    
}

- (void)didMessageAttachmentsStatusChanged:(EMMessage *)message
                                     error:(EMError *)error {
    if (!error)
    {
        EMFileMessageBody *fileBody = (EMFileMessageBody*)[message body];
        if ([fileBody type] == EMMessageBodyTypeImage)
        {
            EMImageMessageBody *imageBody = (EMImageMessageBody *)fileBody;
            if ([imageBody thumbnailDownloadStatus] == EMDownloadStatusSuccessed)
            {
                [self _reloadTableViewDataWithMessage:message];
            }
        }
        else if([fileBody type] == EMMessageBodyTypeVideo)
        {
            EMVideoMessageBody *videoBody = (EMVideoMessageBody *)fileBody;
            if ([videoBody thumbnailDownloadStatus] == EMDownloadStatusSuccessed)
            {
                [self _reloadTableViewDataWithMessage:message];
            }
        }
        else if([fileBody type] == EMMessageBodyTypeVoice)
        {
            if ([fileBody downloadStatus] == EMDownloadStatusSuccessed)
            {
                [self _reloadTableViewDataWithMessage:message];
            }
        }
        
    }
    else
    {
        
    }
}

#pragma mark ------------------ EMCDDeviceManagerProximitySensorDelegate --------------

- (void)proximitySensorChanged:(BOOL)isCloseToUser {
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    if (isCloseToUser)
    {
        [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    }
    else
    {
        [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
        if (self.playingVoiceModel == nil)
        {
            [[EMCDDeviceManager sharedInstance] disableProximitySensor];
        }
    }
    [audioSession setActive:YES error:nil];
}

#pragma mark ------------------ UITableViewDataSource && Delegate --------------

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    id object = [dataArray objectAtIndex:indexPath.row];
    /**
     *  时间cell
     */
    if ([object isKindOfClass:[NSString class]])
    {
        NSString *TimeCellIdentifier = [EaseMessageTimeCell cellIdentifier];
        EaseMessageTimeCell *timeCell = (EaseMessageTimeCell *)[tableView dequeueReusableCellWithIdentifier:TimeCellIdentifier];
        if (timeCell == nil)
        {
            timeCell = [[EaseMessageTimeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TimeCellIdentifier];
            timeCell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        timeCell.title = object;
        return timeCell;
    }
    else
    {
        /**
         *  不是时间cell
         */
        id<IMessageModel> model = object;
        
        /**
         *  检测是否是自定义大表情消息
         */
        BOOL flag = [self checkIsEmotionMsgWithModel:model];
        if (flag)
        {
            NSString *CellIdentifier = [EaseCustomMessageCell cellIdentifierWithModel:model];
            EaseCustomMessageCell *sendCell = (EaseCustomMessageCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (sendCell == nil)
            {
                sendCell = [[EaseCustomMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier model:model];
                sendCell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            
            EaseEmotion *emotion = [self getEmotionWithModel:model];
            if (emotion)
            {
                model.image = [UIImage sd_animatedGIFNamed:emotion.emotionOriginal];
                model.fileURLPath = emotion.emotionOriginalURL;
            }
            sendCell.model = model;
            sendCell.delegate = self;
            return sendCell;
        }
        
        /**
         *  当不是自定义表情消息
         */
        NSString *CellIdentifier = [EaseMessageCell cellIdentifierWithModel:model];
        EaseBaseMessageCell *sendCell = (EaseBaseMessageCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (sendCell == nil)
        {
            sendCell = [[EaseBaseMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier model:model];
            sendCell.selectionStyle = UITableViewCellSelectionStyleNone;
            sendCell.delegate = self;
        }
        sendCell.model = model;
        return sendCell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    id object = [dataArray objectAtIndex:indexPath.row];
    if ([object isKindOfClass:[NSString class]])
    {
        return 30.0;
    }
    else
    {
        id<IMessageModel> model = object;
        BOOL flag = [self checkIsEmotionMsgWithModel:model];
        if (flag)
        {
            return [EaseCustomMessageCell cellHeightWithModel:model];
        }
        return [EaseBaseMessageCell cellHeightWithModel:model];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}

#pragma mark ------------------ 发送消息 --------------

/**
 *  发送文本消息
 */
- (void)sendTextMessage:(NSString *)text {
    /**
     *  消息的扩展属性字典
     */
    NSDictionary *ext = nil;
    if (self.conversation.type == EMConversationTypeGroupChat)
    {
        /**
         *  群聊
         */
        NSArray *targets = [self _searchAtTargets:text];
        if ([targets count])
        {
            __block BOOL atAll = NO;
            [targets enumerateObjectsUsingBlock:^(NSString *target, NSUInteger idx, BOOL *stop) {
                if ([target compare:@"em_at_list" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
                    atAll = YES;
                    *stop = YES;
                }
            }];
            if (atAll)
            {
                ext = @{@"em_at_list": @"all",
                        @"MyAvaterURL":MyAvaterURL};
            }
            else
            {
                ext = @{@"em_at_list":targets,
                        @"MyAvaterURL":MyAvaterURL};
            }
        }
        else
        {
           ext = @{@"MyAvaterURL":MyAvaterURL,HuanxinApnExt:@"1"};
        }
    }
    else
    {
        /**
         *  单聊
         */
        ext = @{@"MyAvaterURL":MyAvaterURL,HuanxinApnExt:@"1"};
    }
    [self sendTextMessage:text withExt:ext];
}

- (void)sendTextMessage:(NSString *)text withExt:(NSDictionary*)ext {
    /**
     *  组装文本消息,包括系统表情消息
     */
    EMMessage *message = [EaseSDKHelper sendTextMessage:text
                                                     to:_conversation.conversationId
                                            messageType:[EaseSDKHelper getMessageChatTypeWithEMConversation:_conversation]
                                             messageExt:ext];
    [self _sendMessage:message];
}

- (void)sendLocationMessageLatitude:(double)latitude longitude:(double)longitude andAddress:(NSString *)address {
    /**
     *  消息的扩展属性字典
     */
    NSDictionary *ext = @{@"MyAvaterURL":MyAvaterURL};
    EMMessage *message = [EaseSDKHelper sendLocationMessageWithLatitude:latitude
                                                              longitude:longitude
                                                                address:address
                                                                     to:_conversation.conversationId
                                                            messageType:[EaseSDKHelper getMessageChatTypeWithEMConversation:_conversation]
                                                             messageExt:ext];
    [self _sendMessage:message];
}

- (void)sendImageMessageWithData:(NSData *)imageData {
    id progress = nil;
    progress = self;
    /**
     *  消息的扩展属性字典
     */
    NSDictionary *ext = @{@"MyAvaterURL":MyAvaterURL};
    EMMessage *message = [EaseSDKHelper sendImageMessageWithImageData:imageData
                                                                   to:_conversation.conversationId
                                                          messageType:[EaseSDKHelper getMessageChatTypeWithEMConversation:_conversation]
                                                           messageExt:ext];
    [self _sendMessage:message];
}

- (void)sendImageMessage:(UIImage *)image {
    id progress = nil;
    progress = self;
    /**
     *  消息的扩展属性字典
     */
    NSDictionary *ext = @{@"MyAvaterURL":MyAvaterURL};
    EMMessage *message = [EaseSDKHelper sendImageMessageWithImage:image
                                                               to:_conversation.conversationId
                                                      messageType:[EaseSDKHelper getMessageChatTypeWithEMConversation:_conversation]
                                                       messageExt:ext];
    [self _sendMessage:message];
}

- (void)sendVoiceMessageWithLocalPath:(NSString *)localPath duration:(NSInteger)duration {
    id progress = nil;
    progress = self;
    /**
     *  消息的扩展属性字典
     */
    NSDictionary *ext = @{@"MyAvaterURL":MyAvaterURL};
    EMMessage *message = [EaseSDKHelper sendVoiceMessageWithLocalPath:localPath
                                                             duration:duration
                                                                   to:_conversation.conversationId
                                                          messageType:[EaseSDKHelper getMessageChatTypeWithEMConversation:_conversation]
                                                           messageExt:ext];
    [self _sendMessage:message];
}

- (void)sendVideoMessageWithURL:(NSURL *)url {
    id progress = nil;
    progress = self;
    /**
     *  消息的扩展属性字典
     */
    NSDictionary *ext = @{@"MyAvaterURL":MyAvaterURL};
    EMMessage *message = [EaseSDKHelper sendVideoMessageWithURL:url
                                                             to:_conversation.conversationId
                                                    messageType:[EaseSDKHelper getMessageChatTypeWithEMConversation:_conversation]
                                                     messageExt:ext];
    [self _sendMessage:message];
}

- (void)_sendMessage:(EMMessage *)message {
    if (self.conversation.type == EMConversationTypeGroupChat)
    {
        message.chatType = EMChatTypeGroupChat;
    }
    else if (self.conversation.type == EMConversationTypeChatRoom)
    {
        message.chatType = EMChatTypeChatRoom;
    }
    else
    {
        message.chatType = EMChatTypeChat;
    }
    
    /**
     *  将当前消息加入数据库
     */
    [self addMessageToDataSource:message progress:nil];
    
    __weak typeof(self) weakself = self;
    [[EMClient sharedClient].chatManager asyncSendMessage:message progress:nil completion:^(EMMessage *aMessage, EMError *aError) {
        if (!aError)
        {
            [weakself _refreshAfterSentMessage:aMessage];
        }
        else
        {
            [infoTable reloadData];
        }
    }];
}

#pragma mark ------------------ 加载消息 --------------

- (void)_loadMessagesBefore:(NSString*)messageId count:(NSInteger)count append:(BOOL)isAppend {
    __weak typeof(self) weakSelf = self;
    dispatch_async(_messageQueue, ^{
        NSArray *moreMessages = nil;
        
        /**
         * 以每页10条数据进行加载
         */
        moreMessages = [weakSelf.conversation loadMoreMessagesFromId:messageId limit:(int)count direction:EMMessageSearchDirectionUp];
        if (moreMessages.count == 0)
        {
            return;
        }
        
        /**
         *  格式化消息
         */
        NSArray *formattedMessages = [weakSelf formatMessages:moreMessages];
        
        /**
         *  刷新界面
         */
        dispatch_async(dispatch_get_main_queue(), ^{
            NSInteger scrollToIndex = 0;
            if (isAppend)
            {
                [messsagesSource insertObjects:moreMessages atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0,moreMessages.count)]];

                /**
                 *  合并消息
                 */
                id object = [dataArray firstObject];
                if ([object isKindOfClass:[NSString class]])
                {
                    NSString *timestamp = object;
                    [formattedMessages enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id model, NSUInteger idx, BOOL *stop) {
                        if ([model isKindOfClass:[NSString class]] && [timestamp isEqualToString:model])
                        {
                            [dataArray removeObjectAtIndex:0];
                            *stop = YES;
                        }
                    }];
                }
                scrollToIndex = [dataArray count];
                [dataArray insertObjects:formattedMessages atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0,formattedMessages.count)]];
            }
            else
            {
                [messsagesSource removeAllObjects];
                [messsagesSource addObjectsFromArray:moreMessages];
                
                [dataArray removeAllObjects];
                [dataArray addObjectsFromArray:formattedMessages];
            }
            
            EMMessage *latest = [messsagesSource lastObject];
            weakSelf.messageTimeIntervalTag = latest.timestamp;
            
            [infoTable reloadData];
            
            [infoTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:dataArray.count - scrollToIndex - 1 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
        });
        
        /**
         *  重新下载未成功下载的消息
         */
        for (EMMessage *message in moreMessages)
        {
            [weakSelf _downloadMessageAttachments:message];
        }

        /**
         *  发送回执
         */
        [weakSelf _sendHasReadResponseForMessages:moreMessages isRead:NO];
    });
}

#pragma mark - 更新消息的状态

- (void)_updateMessageStatus:(EMMessage *)aMessage {
    BOOL isChatting = [aMessage.conversationId isEqualToString:self.conversation.conversationId];
    if (aMessage && isChatting)
    {
        id<IMessageModel> model = [self getMsgWithModel:aMessage];
        if (model)
        {
            __block NSUInteger index = NSNotFound;
            [dataArray enumerateObjectsUsingBlock:^(EaseMessageModel *model, NSUInteger idx, BOOL *stop){
                if ([model conformsToProtocol:@protocol(IMessageModel)]) {
                    if ([aMessage.messageId isEqualToString:model.message.messageId])
                    {
                        index = idx;
                        *stop = YES;
                    }
                }
            }];
            
            if (index != NSNotFound)
            {
                [dataArray replaceObjectAtIndex:index withObject:model];
                [infoTable beginUpdates];
                [infoTable reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                [infoTable endUpdates];
            }
        }
    }
}

#pragma mark - 是否将消息标记为已读

- (BOOL)_shouldMarkMessageAsRead {
    BOOL isMark = YES;
    if (([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) || !self.isViewDidAppear)
    {
        isMark = NO;
    }
    return isMark;
}

#pragma mark ------------------ 发送已读回执消息 --------------

- (void)_sendHasReadResponseForMessages:(NSArray*)messages isRead:(BOOL)isRead {
    NSMutableArray *unreadMessages = [NSMutableArray array];
    for (NSInteger i = 0; i < messages.count; i++)
    {
        EMMessage *message = messages[i];
        BOOL isSend = [self shouldSendHasReadAckForMessage:message read:isRead];;

        if (isSend)
        {
            [unreadMessages addObject:message];
        }
    }
    
    if ([unreadMessages count])
    {
        for (EMMessage *message in unreadMessages)
        {
            [[EMClient sharedClient].chatManager asyncSendReadAckForMessage:message];
        }
    }
}

#pragma mark - 是否发送回执消息

- (BOOL)shouldSendHasReadAckForMessage:(EMMessage *)message  read:(BOOL)read {
    /**
     *  当前登录账号
     */
    NSString *account = [[EMClient sharedClient]currentUsername];
    
    if (message.chatType != EMChatTypeChat || message.isReadAcked || [account isEqualToString:message.from] || ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) || !self.isViewDidAppear)
    {
        return NO;
    }
    
    EMMessageBody *body = message.body;
    if (((body.type == EMMessageBodyTypeVideo) ||(body.type == EMMessageBodyTypeVoice) || (body.type == EMMessageBodyTypeImage)) &&
        !read)
    {
        return NO;
    }
    else
    {
        return YES;
    }
}

#pragma mark ------------------ 下载消息(主要是图片和语音消息) --------------

- (void)_downloadMessageAttachments:(EMMessage *)message {
    __weak typeof(self) weakSelf = self;
    void (^completion)(EMMessage *aMessage, EMError *error) = ^(EMMessage *aMessage, EMError *error) {
        if (!error)
        {
            [weakSelf _reloadTableViewDataWithMessage:message];
        }
        else
        {
            /**
             *  提示框提示
             */
            NSLog(@"缩略图获取失败!");
        }
    };
    
    EMMessageBody *messageBody = message.body;
    if ([messageBody type] == EMMessageBodyTypeImage)
    {
        EMImageMessageBody *imageBody = (EMImageMessageBody *)messageBody;
        if (imageBody.thumbnailDownloadStatus > EMDownloadStatusSuccessed)
        {
            /**
             *  下载缩略图
             */
            [[[EMClient sharedClient] chatManager] asyncDownloadMessageThumbnail:message progress:nil completion:completion];
        }
    }
    else if ([messageBody type] == EMMessageBodyTypeVideo)
    {
        EMVideoMessageBody *videoBody = (EMVideoMessageBody *)messageBody;
        if (videoBody.thumbnailDownloadStatus > EMDownloadStatusSuccessed)
        {
            /**
             *  下载缩略图
             */
            [[[EMClient sharedClient] chatManager] asyncDownloadMessageThumbnail:message progress:nil completion:completion];
        }
    }
    else if ([messageBody type] == EMMessageBodyTypeVoice)
    {
        EMVoiceMessageBody *voiceBody = (EMVoiceMessageBody*)messageBody;
        if (voiceBody.downloadStatus > EMDownloadStatusSuccessed)
        {
            /**
             *  下载附件
             */
            [[EMClient sharedClient].chatManager asyncDownloadMessageAttachments:message progress:nil completion:completion];
        }
    }
}

#pragma mark - 重新下载消息成功后,刷新指定行消息

- (void)_reloadTableViewDataWithMessage:(EMMessage *)message {
    if ([_conversation.conversationId isEqualToString:message.conversationId])
    {
        for (int i = 0; i < dataArray.count; i ++)
        {
            id object = [dataArray objectAtIndex:i];
            if ([object isKindOfClass:[EaseMessageModel class]])
            {
                id<IMessageModel> model = object;
                if ([message.messageId isEqualToString:model.messageId])
                {
                    id<IMessageModel> model = [self getMsgWithModel:message];;
                    [infoTable beginUpdates];
                    [dataArray replaceObjectAtIndex:i withObject:model];
                    [infoTable reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                    [infoTable endUpdates];
                    break;
                }
            }
        }
    }
}

#pragma mark - 发送消息后刷新

- (void)_refreshAfterSentMessage:(EMMessage*)aMessage {
    if ([messsagesSource count] && [EMClient sharedClient].options.sortMessageByServerTime)
    {
        NSString *msgId = aMessage.messageId;
        EMMessage *last = messsagesSource.lastObject;
        if ([last isKindOfClass:[EMMessage class]])
        {
            __block NSUInteger index = NSNotFound;
            index = NSNotFound;
            [messsagesSource enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(EMMessage *obj, NSUInteger idx, BOOL *stop) {
                if ([obj isKindOfClass:[EMMessage class]] && [obj.messageId isEqualToString:msgId]) {
                    index = idx;
                    *stop = YES;
                }
            }];
            if (index != NSNotFound) {
                [messsagesSource removeObjectAtIndex:index];
                [messsagesSource addObject:aMessage];
                
                /**
                 *  格式化消息
                 */
                self.messageTimeIntervalTag = -1;
                NSArray *formattedMessages = [self formatMessages:messsagesSource];
                [dataArray removeAllObjects];
                [dataArray addObjectsFromArray:formattedMessages];
                [infoTable reloadData];
                [infoTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[dataArray count] - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
                return;
            }
        }
    }
    [infoTable reloadData];
}

#pragma mark ------------------ UIGestureRecognizer --------------

- (void)keyBoardHidden:(UITapGestureRecognizer *)tapRecognizer {
    if (tapRecognizer.state == UIGestureRecognizerStateEnded)
    {
        [chatToolbar endEditing:YES];
    }
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateBegan && [dataArray count] > 0)
    {
        CGPoint location = [recognizer locationInView:infoTable];
        NSIndexPath * indexPath = [infoTable indexPathForRowAtPoint:location];
        
        /**
         * 能否长按权限
         */
        BOOL canLongPress = YES;
        
        if (!canLongPress)
        {
            return;
        }
        
        /**
         * 获取当前编辑行和在气泡上显示功能按键
         */
        if (indexPath.row>=dataArray.count)
        {
            return;
        }
        id object = [dataArray objectAtIndex:indexPath.row];
        
        /**
         *  不是时间消息
         */
        if (![object isKindOfClass:[NSString class]])
        {
            EaseMessageCell *cell = (EaseMessageCell *)[infoTable cellForRowAtIndexPath:indexPath];
            [cell becomeFirstResponder];
            self.menuIndexPath = indexPath;
            [self showMenuViewController:cell.bubbleView andIndexPath:indexPath messageType:cell.model.bodyType];
        }
    }
}


#pragma mark ------------------ NSNotification --------------

- (void)didBecomeActive {
    dataArray = [[self formatMessages:messsagesSource] mutableCopy];
    [infoTable reloadData];
    
    if (self.isViewDidAppear)
    {
        NSMutableArray *unreadMessages = [NSMutableArray array];
        for (EMMessage *message in messsagesSource)
        {
            if ([self shouldSendHasReadAckForMessage:message read:NO])
            {
                [unreadMessages addObject:message];
            }
        }
        if ([unreadMessages count])
        {
            [self _sendHasReadResponseForMessages:unreadMessages isRead:YES];
        }
        
        [_conversation markAllMessagesAsRead];
    }
}

#pragma mark ------------------ 自定义方法 --------------

- (void)_scrollViewToBottom:(BOOL)animated {
    if (infoTable.contentSize.height > infoTable.frame.size.height)
    {
        CGPoint offset = CGPointMake(0,infoTable.contentSize.height - infoTable.frame.size.height);
        [infoTable setContentOffset:offset animated:animated];
    }
}

#pragma mark ------------------ 添加表情 --------------

- (void)setupEmotion {
    NSMutableArray *emotions = [NSMutableArray array];
    /**
     *  添加所有系统表情
     */
    for (NSString *name in [EaseEmoji allEmoji])
    {
        EaseEmotion *emotion = [[EaseEmotion alloc] initWithName:@"" emotionId:name emotionThumbnail:name emotionOriginal:name emotionOriginalURL:@"" emotionType:EMEmotionDefault];
        [emotions addObject:emotion];
    }
    EaseEmotion *temp = [emotions objectAtIndex:0];
    EaseEmotionManager *managerDefault = [[EaseEmotionManager alloc] initWithType:EMEmotionDefault emotionRow:3 emotionCol:7 emotions:emotions tagImage:[UIImage imageNamed:temp.emotionId]];
    
    
    
    /**
     *  添加自定义丸子表情
     */
    NSMutableArray *wanziEmotionArr = [NSMutableArray array];
    emotionDic                      = [NSMutableDictionary dictionary];
    
    NSArray *wanziImages = @[@"Wanzi_001",@"Wanzi_002",@"Wanzi_003",@"Wanzi_004",
                             @"Wanzi_005",@"Wanzi_006",@"Wanzi_007",@"Wanzi_008"];
    int wanziIndex = 0;
    for (NSString *name in wanziImages)
    {
        wanziIndex++;
        EaseEmotion *emotion = [[EaseEmotion alloc] initWithName:@"" emotionId:[NSString stringWithFormat:@"em%d",(10000 + wanziIndex)] emotionThumbnail:name emotionOriginal:name emotionOriginalURL:@"" emotionType:EMEmotionGif];
        [wanziEmotionArr addObject:emotion];
        [emotionDic setObject:emotion forKey:[NSString stringWithFormat:@"em%d",(10000 + wanziIndex)]];
    }
    EaseEmotionManager *managerWanzi = [[EaseEmotionManager alloc] initWithType:EMEmotionGif emotionRow:2 emotionCol:4 emotions:wanziEmotionArr tagImage:[UIImage imageNamed:@"Wanzi_001"]];
    
    
    /**
     *  兔斯基gif图片
     */
    NSMutableArray *emotionGifs = [NSMutableArray array];
    
    
    /**
     *  gif图片名称
     */
    NSArray *names = @[@"icon_002",@"icon_007",@"icon_010",@"icon_012",
                       @"icon_013",@"icon_018",@"icon_019",@"icon_020",
                       @"icon_021",@"icon_022",@"icon_024",@"icon_027",
                       @"icon_029",@"icon_030",@"icon_035",@"icon_040"];
    int index = 0;
    for (NSString *name in names)
    {
        index++;
        /**
         * 此处可以更换gif图片对应名称,对应的将资源里面的缩略图图片名称替换掉
         */
        EaseEmotion *emotion = [[EaseEmotion alloc] initWithName:@"" emotionId:[NSString stringWithFormat:@"em%d",(1000 + index)] emotionThumbnail:[NSString stringWithFormat:@"%@_cover",name] emotionOriginal:[NSString stringWithFormat:@"%@",name] emotionOriginalURL:@"" emotionType:EMEmotionGif];
        [emotionGifs addObject:emotion];
        [emotionDic setObject:emotion forKey:[NSString stringWithFormat:@"em%d",(1000 + index)]];
    }
    EaseEmotionManager *managerGif= [[EaseEmotionManager alloc] initWithType:EMEmotionGif emotionRow:2 emotionCol:4 emotions:emotionGifs tagImage:[UIImage imageNamed:@"icon_002_cover"]];
    
    
    
    /**
     *  自定义摇钱兔gif图片
     */
    NSMutableArray *tuziGifs = [NSMutableArray array];
    
    
    /**
     *  gif图片名称
     */
    NSArray *tuziNames = @[@"tuzi_001",@"tuzi_002",@"tuzi_003",@"tuzi_004"];
    index = 0;
    for (NSString *name in tuziNames)
    {
        index++;
        /**
         * 此处可以更换gif图片对应名称,对应的将资源里面的缩略图图片名称替换掉
         */
        EaseEmotion *emotion = [[EaseEmotion alloc] initWithName:@"" emotionId:[NSString stringWithFormat:@"em%d",(100000 + index)] emotionThumbnail:[NSString stringWithFormat:@"%@_cover",name] emotionOriginal:[NSString stringWithFormat:@"%@",name] emotionOriginalURL:@"" emotionType:EMEmotionGif];
        [tuziGifs addObject:emotion];
        [emotionDic setObject:emotion forKey:[NSString stringWithFormat:@"em%d",(100000 + index)]];
    }
    EaseEmotionManager *tuziManagerGif= [[EaseEmotionManager alloc] initWithType:EMEmotionGif emotionRow:1 emotionCol:4 emotions:tuziGifs tagImage:[UIImage imageNamed:@"tuzi_001_cover"]];
    
    /**
     *  设置表情(此处可以添加多个,底部可以滑动)
     */
    NSArray* emotionManagers  = @[managerDefault,managerWanzi,managerGif,tuziManagerGif];
    [faceView setEmotionManagers:emotionManagers];
}

- (BOOL)checkIsEmotionMsgWithModel:(id<IMessageModel>)messageModel {
    BOOL flag = NO;
    /**
     *  检测是否是大表情
     */
    if ([messageModel.message.ext objectForKey:MESSAGE_ATTR_IS_BIG_EXPRESSION])
    {
        flag = YES;
    }
    return flag;
}

- (EaseEmotion *)getEmotionWithModel:(id<IMessageModel>)messageModel {
    /**
     *  根据设置的表情id获取这个表情
     */
    NSString *emotionId  = [messageModel.message.ext objectForKey:MESSAGE_ATTR_EXPRESSION_ID];
    EaseEmotion *emotion = [emotionDic objectForKey:emotionId];
    if (emotion == nil)
    {
        emotion = [[EaseEmotion alloc] initWithName:@"" emotionId:emotionId emotionThumbnail:@"" emotionOriginal:@"" emotionOriginalURL:@"" emotionType:EMEmotionGif];
    }
    return emotion;
}

- (BOOL)_canRecord {
    __block BOOL bCanRecord = YES;
    if ([[[UIDevice currentDevice] systemVersion] compare:@"7.0"] != NSOrderedAscending)
    {
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        if ([audioSession respondsToSelector:@selector(requestRecordPermission:)]) {
            [audioSession performSelector:@selector(requestRecordPermission:) withObject:^(BOOL granted) {
                bCanRecord = granted;
            }];
        }
    }
    return bCanRecord;
}

- (NSArray*)_searchAtTargets:(NSString*)text {
    NSMutableArray *targets = nil;
    if (text.length > 1)
    {
        targets = [NSMutableArray array];
        NSArray *splits = [text componentsSeparatedByString:@"@"];
        if ([splits count])
        {
            for (NSString *split in splits)
            {
                if (split.length) {
                    NSString *atALl = @"[有全体消息]";
                    if ([split compare:atALl options:NSCaseInsensitiveSearch range:NSMakeRange(0, atALl.length)] == NSOrderedSame)
                    {
                        [targets removeAllObjects];
                        [targets addObject:@"all"];
                        return targets;
                    }
                    for (EaseAtTarget *target in _atTargets)
                    {
                        if ([target.userId length])
                        {
                            if ([split hasPrefix:target.userId] || (target.nickname && [split hasPrefix:target.nickname]))
                            {
                                [targets addObject:target.userId];
                                [_atTargets removeObject:target];
                                break;
                            }
                        }
                    }
                }
            }
        }
    }
    return targets;
}

- (id<IMessageModel>)getMsgWithModel:(EMMessage *)message {
    /**
     *  转化当前的聊天消息:可以在此处更改用户的头像链接和昵称(可以考虑用扩展属性来读取用户的昵称和头像)
     */
    id<IMessageModel> model = nil;
    model               = [[EaseMessageModel alloc] initWithMessage:message];
    model.avatarImage   = [UIImage imageNamed:@"user"];
    
    /**
     *  从扩展信息中读取用户带过来的头像(当然昵称也可以，可以很多)
     */
    model.avatarURLPath = [message.ext objectForKey:@"MyAvaterURL"];
    model.nickname      = @"";
    model.failImageName = @"imageDownloadFail";
    return model;
}

#pragma mark ------------------ 将消息加入数据库 --------------

- (void)addMessageToDataSource:(EMMessage *)message progress:(id)progress {
    [messsagesSource addObject:message];
    __weak ChatController *weakSelf = self;
    dispatch_async(_messageQueue, ^{
        NSArray *messages = [weakSelf formatMessages:@[message]];
        dispatch_async(dispatch_get_main_queue(), ^{
            [dataArray addObjectsFromArray:messages];
            [infoTable reloadData];
            [infoTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[dataArray count] - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        });
    });
}

#pragma mark ------------------ 格式化消息 --------------

- (NSArray *)formatMessages:(NSArray *)messages {
    NSMutableArray *formattedArray = [NSMutableArray array];
    if (messages.count == 0)
    {
        return formattedArray;
    }
    
    for (EMMessage *message in messages)
    {
        CGFloat interval = (self.messageTimeIntervalTag - message.timestamp) / 1000;
        if (self.messageTimeIntervalTag < 0 || interval > 60 || interval < -60)
        {
            NSDate *messageDate = [NSDate dateWithTimeIntervalInMilliSecondSince1970:(NSTimeInterval)message.timestamp];
            NSString *timeStr = @"";
            timeStr = [messageDate formattedTime];
            [formattedArray addObject:timeStr];
            self.messageTimeIntervalTag = message.timestamp;
        }
        
        /**
         *  转换消息:此处可以更换用户头像
         */
        id<IMessageModel> model = [self getMsgWithModel:message];
        if (model)
        {
            [formattedArray addObject:model];
        }
    }
    return formattedArray;
}


/**
 * 获取发送表情消息的扩展字典
 */
- (NSDictionary *)getEmotionExtFormessageWithEaseEmotion:(EaseEmotion*)easeEmotion {
    return @{MESSAGE_ATTR_EXPRESSION_ID:easeEmotion.emotionId,MESSAGE_ATTR_IS_BIG_EXPRESSION:@(YES)};
}

#pragma mark ------------------ Setter --------------

- (void)setIsViewDidAppear:(BOOL)isViewDidAppear
{
    _isViewDidAppear =isViewDidAppear;
    if (_isViewDidAppear)
    {
        NSMutableArray *unreadMessages = [NSMutableArray array];
        for (EMMessage *message in messsagesSource)
        {
            if ([self shouldSendHasReadAckForMessage:message read:NO])
            {
                [unreadMessages addObject:message];
            }
        }
        if ([unreadMessages count])
        {
            [self _sendHasReadResponseForMessages:unreadMessages isRead:YES];
        }
        
        [_conversation markAllMessagesAsRead];
    }
}

#pragma mark - UIImagePickerControllerDelegate 挑选完图片或者视频

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:(NSString *)kUTTypeMovie])
    {
        /**
         *  媒体类型是视频
         */
    }
    else
    {
        /**
         *  图片
         */
        NSURL *url = info[UIImagePickerControllerReferenceURL];
        if (url == nil)
        {
            /**
             *  拍照时
             */
            UIImage *orgImage = info[UIImagePickerControllerOriginalImage];
            [self sendImageMessage:orgImage];
        }
        else
        {
            if ([[UIDevice currentDevice].systemVersion doubleValue] >= 9.0f)
            {
                PHFetchResult *result = [PHAsset fetchAssetsWithALAssetURLs:@[url] options:nil];
                [result enumerateObjectsUsingBlock:^(PHAsset *asset , NSUInteger idx, BOOL *stop){
                    if (asset) {
                        [[PHImageManager defaultManager] requestImageDataForAsset:asset options:nil resultHandler:^(NSData *data, NSString *uti, UIImageOrientation orientation, NSDictionary *dic)
                         {
                             if (data.length > 10 * 1000 * 1000)
                             {
                                 NSLog(@"图片太大,请重新选一张");
                                 return;
                             }
                             if (data != nil)
                             {
                                 [self sendImageMessageWithData:data];
                             }
                             else
                             {
                                 NSLog(@"图片太大,请重新选一张");
                             }
                         }];
                    }
                }];
            }
            else
            {
                ALAssetsLibrary *alasset = [[ALAssetsLibrary alloc] init];
                [alasset assetForURL:url resultBlock:^(ALAsset *asset)
                 {
                     if (asset)
                     {
                         ALAssetRepresentation* assetRepresentation = [asset defaultRepresentation];
                         Byte* buffer = (Byte*)malloc([assetRepresentation size]);
                         NSUInteger bufferSize = [assetRepresentation getBytes:buffer fromOffset:0.0 length:[assetRepresentation size] error:nil];
                         NSData* fileData = [NSData dataWithBytesNoCopy:buffer length:bufferSize freeWhenDone:YES];
                         if (fileData.length > 10 * 1000 * 1000)
                         {
                             NSLog(@"图片太大,请重新选一张");
                             return;
                         }
                         [self sendImageMessageWithData:fileData];
                     }
                 } failureBlock:NULL];
            }
        }

    }
    [picker dismissViewControllerAnimated:YES completion:NULL];
    self.isViewDidAppear = YES;
    [[EaseSDKHelper shareHelper] setIsShowingimagePicker:NO];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self.imagePicker dismissViewControllerAnimated:YES completion:NULL];
    self.isViewDidAppear = YES;
    [[EaseSDKHelper shareHelper] setIsShowingimagePicker:NO];
}

#pragma mark ------------------ EaseMessageCellDelegate --------------

- (void)messageCellSelected:(id<IMessageModel>)model {
    switch (model.bodyType)
    {
        case EMMessageBodyTypeImage:
        {
            _scrollToBottomWhenAppear = NO;
            [self _imageMessageCellSelected:model];
        }
            break;
            
        case EMMessageBodyTypeLocation:
        {
            [self _locationMessageCellSelected:model];
        }
            break;
            
        case EMMessageBodyTypeVoice:
        {
            [self _audioMessageCellSelected:model];
        }
            break;
            
        case EMMessageBodyTypeVideo:
        {
            [self _videoMessageCellSelected:model];
            
        }
            break;
        case EMMessageBodyTypeFile:
        {
            _scrollToBottomWhenAppear = NO;
        }
            break;
            
        default:
            break;
    }
}

- (void)avatarViewSelcted:(id<IMessageModel>)model {
    NSLog(@"%@头像点击事件",model.message.from);
}

#pragma mark - 消息状态按钮点击事件(目测是重新发送按钮)

- (void)statusButtonSelcted:(id<IMessageModel>)model withMessageCell:(EaseMessageCell*)messageCell {
    if ((model.messageStatus != EMMessageStatusFailed) && (model.messageStatus != EMMessageStatusPending))
    {
        return;
    }
    __weak typeof(self) weakself = self;
    [[[EMClient sharedClient] chatManager] asyncResendMessage:model.message progress:nil completion:^(EMMessage *message, EMError *error) {
        if (!error) {
            [weakself _refreshAfterSentMessage:message];
        }
        else {
            [infoTable reloadData];
        }
    }];
    
    [infoTable reloadData];
}

#pragma mark ------------------ 各种消息cell点击事件 --------------

- (void)_locationMessageCellSelected:(id<IMessageModel>)model {
    NSLog(@"位置消息cell点击");
    _scrollToBottomWhenAppear = NO;
    MyLocationController *vc = [[MyLocationController alloc] initWithLocation:CLLocationCoordinate2DMake(model.latitude, model.longitude)];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)_videoMessageCellSelected:(id<IMessageModel>)model {
     NSLog(@"视频消息cell点击");
}

- (void)_imageMessageCellSelected:(id<IMessageModel>)model {
    NSLog(@"图片消息cell点击");
    __weak ChatController *weakSelf = self;
    EMImageMessageBody *imageBody = (EMImageMessageBody*)[model.message body];
    
    if ([imageBody type] == EMMessageBodyTypeImage)
    {
        if (imageBody.thumbnailDownloadStatus == EMDownloadStatusSuccessed)
        {
            if (imageBody.downloadStatus == EMDownloadStatusSuccessed)
            {
                /**
                 *  发送确认回执
                 */
                [weakSelf _sendHasReadResponseForMessages:@[model.message] isRead:YES];
                NSString *localPath = model.message == nil ? model.fileLocalPath : [imageBody localPath];
                if (localPath && localPath.length > 0)
                {
                    UIImage *image = [UIImage imageWithContentsOfFile:localPath];
                    if (image)
                    {
                        [[EaseMessageReadManager defaultManager] showBrowserWithImages:@[image]];
                    }
                    else
                    {
                        NSLog(@"Read %@ failed!", localPath);
                    }
                    return;
                }
            }
            /**
             * 提示语:正在获取大图...
             */
            [[EMClient sharedClient].chatManager asyncDownloadMessageAttachments:model.message progress:nil completion:^(EMMessage *message, EMError *error) {
                if (!error)
                {
                    [weakSelf _sendHasReadResponseForMessages:@[model.message] isRead:YES];
                    NSString *localPath = message == nil ? model.fileLocalPath : [(EMImageMessageBody*)message.body localPath];
                    if (localPath && localPath.length > 0)
                    {
                        UIImage *image = [UIImage imageWithContentsOfFile:localPath];
                        if (image)
                        {
                            [[EaseMessageReadManager defaultManager] showBrowserWithImages:@[image]];
                        }
                        else
                        {
                            NSLog(@"Read %@ failed!", localPath);
                        }
                        return ;
                    }
                }
                /**
                 * 提示语:大图获取失败!
                 */
                NSLog(@"大图获取失败!");
            }];
        }
        else
        {
            /**
             * 获取消息缩略图
             */
            [[EMClient sharedClient].chatManager asyncDownloadMessageThumbnail:model.message progress:nil completion:^(EMMessage *message, EMError *error) {
                if (!error)
                {
                    [weakSelf _reloadTableViewDataWithMessage:model.message];
                }
                else
                {
                    /**
                     * 提示语:缩略图获取失败!
                     */
                    NSLog(@"缩略图获取失败!");
                }
            }];
        }
    }
}

- (void)_audioMessageCellSelected:(id<IMessageModel>)model {
   NSLog(@"语音消息cell点击");
    _scrollToBottomWhenAppear = NO;
    EMVoiceMessageBody *body = (EMVoiceMessageBody*)model.message.body;
    EMDownloadStatus downloadStatus = [body downloadStatus];
    if (downloadStatus == EMDownloadStatusDownloading)
    {
        /**
         *  提示语:正在下载语音，稍后点击
         */
        NSLog(@"正在下载语音，稍后点击");
        return;
    }
    else if (downloadStatus == EMDownloadStatusFailed)
    {
        /**
         *  提示语:正在下载语音，稍后点击
         */
        NSLog(@"正在下载语音，稍后点击");
        [[EMClient sharedClient].chatManager asyncDownloadMessageAttachments:model.message progress:nil completion:NULL];
        return;
    }
    
    /**
     *  播放语音
     */
    if (model.bodyType == EMMessageBodyTypeVoice)
    {
        [self _sendHasReadResponseForMessages:@[model.message] isRead:YES];
        BOOL isPrepare = [[EaseMessageReadManager defaultManager] prepareMessageAudioModel:model updateViewCompletion:^(EaseMessageModel *prevAudioModel, EaseMessageModel *currentAudioModel)
        {
            if (prevAudioModel || currentAudioModel)
            {
                [infoTable reloadData];
            }
        }];
        
        if (isPrepare)
        {
            _isPlayingAudio = YES;
            __weak ChatController *weakSelf = self;
            [[EMCDDeviceManager sharedInstance] enableProximitySensor];
            [[EMCDDeviceManager sharedInstance] asyncPlayingWithPath:model.fileLocalPath completion:^(NSError *error) {
                [[EaseMessageReadManager defaultManager] stopMessageAudioModel];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [infoTable reloadData];
                    weakSelf.isPlayingAudio = NO;
                    [[EMCDDeviceManager sharedInstance] disableProximitySensor];
                });
            }];
        }
        else
        {
            _isPlayingAudio = NO;
        }
    }
}

- (void)showMenuViewController:(UIView *)showInView andIndexPath:(NSIndexPath *)indexPath messageType:(EMMessageBodyType)messageType {
    if (self.menuController == nil)
    {
        self.menuController = [UIMenuController sharedMenuController];
    }
    
    if (_deleteMenuItem == nil)
    {
        _deleteMenuItem = [[UIMenuItem alloc] initWithTitle:@"删除" action:@selector(deleteMenuAction:)];
    }
    
    if (_copyMenuItem == nil)
    {
        _copyMenuItem = [[UIMenuItem alloc] initWithTitle:@"复制" action:@selector(copyMenuAction:)];
    }
    
    if (_transpondMenuItem == nil)
    {
        _transpondMenuItem = [[UIMenuItem alloc] initWithTitle:@"转发" action:@selector(transpondMenuAction:)];
    }
    
    /**
     *  暂时去掉转发了(转发需要好友列表)
     */
    if (messageType == EMMessageBodyTypeText)
    {
        [self.menuController setMenuItems:@[_copyMenuItem, _deleteMenuItem]];
    }
    else if (messageType == EMMessageBodyTypeImage)
    {
        [self.menuController setMenuItems:@[_deleteMenuItem]];
    }
    else
    {
        [self.menuController setMenuItems:@[_deleteMenuItem]];
    }
    [self.menuController setTargetRect:showInView.frame inView:showInView.superview];
    [self.menuController setMenuVisible:YES animated:YES];
}

#pragma mark ------------------ 菜单功能键点击事件 --------------

- (void)deleteMenuAction:(id)sender {
    if (self.menuIndexPath && self.menuIndexPath.row > 0)
    {
        id<IMessageModel> model = [dataArray objectAtIndex:self.menuIndexPath.row];
        NSMutableIndexSet *indexs = [NSMutableIndexSet indexSetWithIndex:self.menuIndexPath.row];
        NSMutableArray *indexPaths = [NSMutableArray arrayWithObjects:self.menuIndexPath, nil];
        
        [self.conversation deleteMessageWithId:model.message.messageId];
        [messsagesSource removeObject:model.message];
        
        if (self.menuIndexPath.row - 1 >= 0)
        {
            id nextMessage = nil;
            id prevMessage = [dataArray objectAtIndex:(self.menuIndexPath.row - 1)];
            if (self.menuIndexPath.row + 1 < [dataArray count])
            {
                nextMessage = [dataArray objectAtIndex:(self.menuIndexPath.row + 1)];
            }
            if ((!nextMessage || [nextMessage isKindOfClass:[NSString class]]) && [prevMessage isKindOfClass:[NSString class]])
            {
                [indexs addIndex:self.menuIndexPath.row - 1];
                [indexPaths addObject:[NSIndexPath indexPathForRow:(self.menuIndexPath.row - 1) inSection:0]];
            }
        }
        
        [dataArray removeObjectsAtIndexes:indexs];
        [infoTable beginUpdates];
        [infoTable deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
        [infoTable endUpdates];
        
        if ([dataArray count] == 0)
        {
            self.messageTimeIntervalTag = -1;
        }
    }
    self.menuIndexPath = nil;
}

- (void)copyMenuAction:(id)sender {
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    if (self.menuIndexPath && self.menuIndexPath.row > 0)
    {
        id<IMessageModel> model = [dataArray objectAtIndex:self.menuIndexPath.row];
        pasteboard.string = model.text;
    }
    
    self.menuIndexPath = nil;
}

- (void)transpondMenuAction:(id)sender {
    if (self.menuIndexPath && self.menuIndexPath.row > 0)
    {
//        id<IMessageModel> model = [dataArray objectAtIndex:self.menuIndexPath.row];
        NSLog(@"转发");
    }
    self.menuIndexPath = nil;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter]removeObserver:self];

    [[EMCDDeviceManager sharedInstance] stopPlaying];
    [EMCDDeviceManager sharedInstance].delegate = nil;
    
    if (_imagePicker)
    {
        [_imagePicker dismissViewControllerAnimated:NO completion:nil];
        _imagePicker = nil;
    }
    
    [[EMClient sharedClient] removeDelegate:self];
}

@end
