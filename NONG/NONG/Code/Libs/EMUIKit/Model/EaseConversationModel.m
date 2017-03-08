//
//  ChatFriendListController.h
//  NONG
//
//  Created by 吴 吴 on 16/8/16.
//  Copyright © 2016年 上海泰侠网络科技有限公司. All rights reserved.
//

#import "EaseConversationModel.h"

#import "EMConversation.h"

@implementation EaseConversationModel

- (instancetype)initWithConversation:(EMConversation *)conversation {
    self = [super init];
    if (self) {
        _conversation = conversation;
        _title = _conversation.conversationId;
        if (conversation.type == EMConversationTypeChat)
        {
            _avatarImage = [UIImage imageNamed:@"user"];
        }
        else
        {
            _avatarImage = [UIImage imageNamed:@"EaseUIResource.bundle/group"];
        }
    }
    
    return self;
}

@end
