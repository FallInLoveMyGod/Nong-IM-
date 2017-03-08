//
//  ChatFriendListController.m
//  NONG
//
//  Created by 吴 吴 on 16/8/16.
//  Copyright © 2016年 上海泰侠网络科技有限公司. All rights reserved.
//

#import "ChatFriendListController.h"
#import "ChatController.h"

#import "ChatFriendListTableCell.h"
#import "WJQEMClient.h"
#import "EaseConversationModel.h"
#import "EMCDDeviceManager.h"

@interface ChatFriendListController ()<UITableViewDataSource,UITableViewDelegate,EMChatManagerDelegate,EMGroupManagerDelegate>
{
    UITableView    *infoTable;
    NSMutableArray *dataArray;
}

@end

@implementation ChatFriendListController

- (id)init {
    self = [super init];
    if (self) {
        dataArray = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"好友列表";
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self login];
    [self setupUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self registerNotifications];
    [self refreshData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self unregisterNotifications];
}


#pragma mark - 创建UI

- (void)setupUI {
    infoTable = [[UITableView alloc]initWithFrame:AppFrame(0,64,AppWidth,AppHeight-64) style:UITableViewStylePlain];
    infoTable.backgroundColor = [UIColor clearColor];
    infoTable.separatorColor  = [UIColor clearColor];
    infoTable.separatorStyle  = UITableViewCellSeparatorStyleNone;
    infoTable.dataSource      = self;
    infoTable.delegate        = self;
    infoTable.mj_header       = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(refreshData)];
    [self.view addSubview:infoTable];
}

#pragma mark - 网络数据

- (void)login {
    [[WJQEMClient sharedManager]loginWithUsername:MyAccount Password:MyAccountPwd Callback:^(EMError *error) {
        
    }];
    
    [[WJQEMClient sharedManager]getConversationWithConversationId:@"13207278860" Type:EMConversationTypeChat CreateIfNotExist:YES Callback:^(EMConversation *conversation) {
        
    }];
}

- (void)refreshData {
    [self tableViewDidTriggerHeaderRefresh];
}

- (void)endRefresh {
    [infoTable.mj_header endRefreshing];
}

- (void)reloadUI {
    [infoTable reloadData];
    [self endRefresh];
}

#pragma mark - UITableViewDataSource && Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellID = @"ChatFriendListTableCell";
    ChatFriendListTableCell *cell = (ChatFriendListTableCell *)[tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil)
    {
        cell = [[ChatFriendListTableCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    cell.backgroundColor = [UIColor clearColor];
    cell.accessoryType   = UITableViewCellAccessoryNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row >=dataArray.count)
    {
        return;
    }
    EaseConversationModel *model = dataArray[indexPath.row];
    [((ChatFriendListTableCell *)cell) initCellWithModel:model];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [ChatFriendListTableCell getCellHeight];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    EaseConversationModel *model = dataArray[indexPath.row];
    /**
     * 进聊天界面
     */
    NSString *tempChatterID                   = model.conversation.conversationId;
    EMConversationType tempConversationType   = model.conversation.type;
    ChatController *chatVC = [[ChatController alloc]initWithConversationChatter:tempChatterID conversationType:tempConversationType];
    chatVC.title = model.title;
    [self.navigationController pushViewController:chatVC animated:YES];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"删除";
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        EaseConversationModel *model = dataArray[indexPath.row];
        NSString *tempChatterID      = model.conversation.conversationId;
        [[WJQEMClient sharedManager]deleteConversationWithConversationId:tempChatterID DeleteMessages:YES];
        [dataArray removeObjectAtIndex:indexPath.row];
        [infoTable deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

#pragma mark ------------------ 获取对话列表 --------------

- (void)tableViewDidTriggerHeaderRefresh {
    /**
     *  获取所有会话
     */
    NSArray *allConversationsArr = [[EMClient sharedClient].chatManager getAllConversations];
    /**
     * 对会话记录进行排序,最新的放在前面
     */
    NSArray* sortedArray = [allConversationsArr sortedArrayUsingComparator:^(EMConversation *obj1, EMConversation* obj2) {
                           EMMessage *message1 = [obj1 latestMessage];
                           EMMessage *message2 = [obj2 latestMessage];
                           if(message1.timestamp > message2.timestamp)
                           {
                               return(NSComparisonResult)NSOrderedAscending;
                           }
                           else
                           {
                               return(NSComparisonResult)NSOrderedDescending;
                           }
                       }];

    [dataArray removeAllObjects];
    
    /**
     *  遍历所有会话
     */
    for (EMConversation *converstion in sortedArray)
    {
        /**
         *  转换为自己的会话model
         */
        EaseConversationModel *model  = [self getTempConversationModelWithConversation:converstion];
        if (model)
        {
            [dataArray addObject:model];
        }
    }
    [self setupUnreadMessageCount];
    [self reloadUI];
}

- (id<IConversationModel>)getTempConversationModelWithConversation:(EMConversation *)conversation {
    /**
     *  某个会话下
     */
    EaseConversationModel *model = [[EaseConversationModel alloc] initWithConversation:conversation];
    if (model.conversation.type == EMConversationTypeChat)
    {
        /**
         *  单聊情况下,转化当前会话里面 对方给我发送的最后一条消息 的属性字典(属性值里面可以存储当前会话对方的头像和昵称)
         *  不能自己和自己聊天(所以收到消息肯定是对方消息)
         *  头像赋值只显示对方的头像
         */
        EMMessage *latestMsgFromOthers = [conversation latestMessageFromOthers];
        model.avatarURLPath = [latestMsgFromOthers.ext objectForKey:@"MyAvaterURL"];
    }
    else if (model.conversation.type == EMConversationTypeGroupChat)
    {
        NSString *imageName = @"groupPublicHeader";
        
        /**
         *  conversation.ext = @{@"isPublic":@"1",@"subject":@"泰侠制片群"};
         */
        if (![conversation.ext objectForKey:@"subject"])
        {
            /**
             *  获取所有群组
             */
            NSArray *groupArray = [[EMClient sharedClient].groupManager getAllGroups];
            for (EMGroup *group in groupArray)
            {
                if ([group.groupId isEqualToString:conversation.conversationId])
                {
                    NSMutableDictionary *ext = [NSMutableDictionary dictionaryWithDictionary:conversation.ext];
                    [ext setObject:group.subject forKey:@"subject"];
                    [ext setObject:[NSNumber numberWithBool:group.isPublic] forKey:@"isPublic"];
                    conversation.ext = ext;
                    break;
                }
            }
        }
        NSDictionary *ext = conversation.ext;
        /**
         *  群组名称
         */
        model.title = [ext objectForKey:@"subject"];
        /**
         *  是否为公开群
         */
        imageName = [[ext objectForKey:@"isPublic"] boolValue] ? @"groupPublicHeader" : @"groupPrivateHeader";
        
        EMMessage *latestMsgFromOthers = [conversation latestMessageFromOthers];
        
        NSDictionary *latestMsgExt = latestMsgFromOthers.ext;
        
        model.avatarURLPath = [latestMsgExt objectForKey:@"MyAvaterURL"];
        
        model.avatarImage = [UIImage imageNamed:imageName];
    }
    else
    {
        NSAssert(@"", nil);
    }
    return model;
}

/**
 *  设置未读消息数:tabBarItem.badgeValue,角标
 */
- (void)setupUnreadMessageCount {
    NSArray *allConversationArr = [[EMClient sharedClient].chatManager getAllConversations];
    __block NSInteger unreadCount = 0;
    [allConversationArr enumerateObjectsUsingBlock:^(EMConversation * obj, NSUInteger idx, BOOL * _Nonnull stop) {
        unreadCount += obj.unreadMessagesCount;
    }];
    [UIApplication sharedApplication].applicationIconBadgeNumber = unreadCount;
}

#pragma mark - registerNotifications

- (void)registerNotifications {
    [self unregisterNotifications];
    [[EMClient sharedClient].chatManager addDelegate:self delegateQueue:nil];
    [[EMClient sharedClient].groupManager addDelegate:self delegateQueue:nil];
}

- (void)unregisterNotifications{
    [[EMClient sharedClient].chatManager removeDelegate:self];
    [[EMClient sharedClient].groupManager removeDelegate:self];
}

#pragma mark - EMChatManagerDelegate

/**
 *  会话列表发生变化
 *
 *  @param aConversationList <#aConversationList description#>
 */
- (void)didUpdateConversationList:(NSArray *)aConversationList {
    [self refreshData];
}

- (void)didReceiveMessages:(NSArray *)aMessages {
    /**
     *  刷新会话列表,更改消息未读数
     */
    [self refreshData];
}

- (void)dealloc {
    [self unregisterNotifications];
}

@end
