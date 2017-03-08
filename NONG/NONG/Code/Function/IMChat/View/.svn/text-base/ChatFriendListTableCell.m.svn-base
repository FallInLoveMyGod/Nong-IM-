//
//  ChatFriendListTableCell.m
//  NONG
//
//  Created by 吴 吴 on 16/8/16.
//  Copyright © 2016年 上海泰侠网络科技有限公司. All rights reserved.
//

#import "ChatFriendListTableCell.h"
#import "EaseConvertToCommonEmoticonsHelper.h"
#import "NSDate+Category.h"

@implementation ChatFriendListTableCell
{
    UIImageView *userIcon;
    UIView      *redBageView;
    UILabel     *bageNumLbl;
    
    UILabel     *userNameLbl;
    UILabel     *latesMsgLbl;
    UILabel     *latesMsgTimeLbl;
    
    UIView      *gapline;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        [self setupUI];
    }
    return self;
}


#pragma mark - 创建UI

- (void)setupUI {
    float totalH = [ChatFriendListTableCell getCellHeight];
    /**
     * 用户头像
     */
    userIcon = [[UIImageView alloc]initWithFrame:AppFrame(10,(totalH-50.5)/2, 50.5, 50.5)];
    userIcon.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:userIcon];
    
    
    /**
     * 消息红色背景
     */
    redBageView = [[UIView alloc]initWithFrame:AppFrame(userIcon.width-20+2,-4, 20, 20)];
    redBageView.backgroundColor = [UIColor redColor];
    redBageView.layer.cornerRadius = redBageView.height/2;
    redBageView.layer.masksToBounds = YES;
    redBageView.clipsToBounds = YES;
    [userIcon addSubview:redBageView];
    
    
    /**
     * 未读消息数标签
     */
    bageNumLbl = [[UILabel alloc]initWithFrame:AppFrame(0,(redBageView.height-11)/2,redBageView.width,11)];
    bageNumLbl.font = FONT11;
    bageNumLbl.textColor = [UIColor whiteColor];
    bageNumLbl.textAlignment = NSTextAlignmentCenter;
    [redBageView addSubview:bageNumLbl];
    
    
    /**
     * 用户名称标签
     */
    userNameLbl = [[UILabel alloc]initWithFrame:AppFrame(userIcon.right + 10, userIcon.top, AppWidth-userNameLbl.left, 17)];
    userNameLbl.font = FONT17;
    userNameLbl.textColor = [UIColor blackColor];
    userNameLbl.textAlignment = NSTextAlignmentLeft;
    [self.contentView addSubview:userNameLbl];
    
    /**
     * 最新消息显示标签
     */
    latesMsgLbl = [[UILabel alloc]initWithFrame:AppFrame(userIcon.right + 10, userIcon.bottom-15, AppWidth-latesMsgLbl.left, 15)];
    latesMsgLbl.font = FONT15;
    latesMsgLbl.textColor = [UIColor lightGrayColor];
    latesMsgLbl.textAlignment = NSTextAlignmentLeft;
    [self.contentView addSubview:latesMsgLbl];
    
    /**
     * 最新消息显示标签
     */
    latesMsgTimeLbl = [[UILabel alloc]initWithFrame:AppFrame(userIcon.right + 10, userIcon.top, AppWidth-latesMsgLbl.left-10,13)];
    latesMsgTimeLbl.font = FONT13;
    latesMsgTimeLbl.textColor = [UIColor blackColor];
    latesMsgTimeLbl.textAlignment = NSTextAlignmentRight;
    [self.contentView addSubview:latesMsgTimeLbl];
    
    gapline = [[UIView alloc]initWithFrame:AppFrame(0,totalH-0.5,AppWidth,0.5)];
    gapline.backgroundColor = [UIColor colorWithHexString:@"#e6e6e6"];
    [self.contentView addSubview:gapline];
}

#pragma mark - 数据源

- (void)initCellWithModel:(EaseConversationModel *)model {
    /**
     * 用户头像
     */
    if (model.avatarURLPath.length >0)
    {
        [userIcon sd_setImageWithURL:[NSURL URLWithString:model.avatarURLPath] placeholderImage:[UIImage imageNamed:@"user"]];
    }
    else
    {
        userIcon.image = model.avatarImage;
    }
    
    /**
     * 消息未读数
     */
    if (model.conversation.unreadMessagesCount == 0)
    {
        redBageView.hidden = YES;
        bageNumLbl.text    = @"";
    }
    else
    {
        redBageView.hidden = NO;
        if (model.conversation.unreadMessagesCount >99)
        {
            bageNumLbl.text = @"99+";
        }
        else
        {
            bageNumLbl.text = [NSString stringWithFormat:@"%d",model.conversation.unreadMessagesCount];
        }
    }
    
    /**
     * 消息标题
     */
    if (model.title.length >0)
    {
        userNameLbl.text = model.title;
    }
    else
    {
        userNameLbl.text = model.conversation.conversationId;
    }
    
    /**
     * 最新消息显示
     */
    latesMsgLbl.text = [self getLatestMsgWithModel:model];
    
    /**
     * 消息时间
     */
    latesMsgTimeLbl.text = [self getLatestMsgTimeWithModel:model];
}

- (NSString *)getLatestMsgWithModel:(EaseConversationModel *)model {
    EMMessage *lastMessage = [model.conversation latestMessage];
    NSString *latestMessageTitle = @"";
    if (lastMessage)
    {
        EMMessageBody *messageBody = lastMessage.body;
        switch (messageBody.type)
        {
            case EMMessageBodyTypeImage:
                latestMessageTitle = @"[图片]";
                break;
                
            case EMMessageBodyTypeText:
            {
                /**
                 *  文本中表情映射
                 */
                NSString *didReceiveText = [EaseConvertToCommonEmoticonsHelper convertToSystemEmoticons:((EMTextMessageBody *)messageBody).text];
                latestMessageTitle = didReceiveText;
                if ([lastMessage.ext objectForKey:@"em_is_big_expression"])
                {
                    latestMessageTitle = @"[动画表情]";
                }
            }
                break;
                
            case EMMessageBodyTypeVoice:
                latestMessageTitle = @"[音频]";
                break;
                
            case EMMessageBodyTypeLocation:
                latestMessageTitle = @"[位置]";
                break;
                
            case EMMessageBodyTypeVideo:
                latestMessageTitle = @"[视频]";
                break;
                
            default:
                break;
        }
        
        /**
         *  根据会话扩展属性来判断(群组聊天中)
         */
        NSDictionary *ext = model.conversation.ext;
        if (ext && [ext[@"kHaveAtMessage"] intValue] == 2)
        {
            latestMessageTitle = [NSString stringWithFormat:@"%@ %@",@"[有全体消息]", latestMessageTitle];
        }
        else if (ext && [ext[@"kHaveAtMessage"] intValue] == 1)
        {
            latestMessageTitle = [NSString stringWithFormat:@"%@ %@",@"[有人@我]", latestMessageTitle];
        }
        else
        {
            NSAssert(@"", nil);
        }
    }
    return latestMessageTitle;
}

- (NSString *)getLatestMsgTimeWithModel:(EaseConversationModel *)model {
    NSString *latestMessageTime = @"";
    EMMessage *lastMessage = [model.conversation latestMessage];
    if (lastMessage)
    {
        double timeInterval = lastMessage.timestamp ;
        if(timeInterval > 140000000000)
        {
            timeInterval = timeInterval / 1000;
        }
        NSDateFormatter* formatter = [[NSDateFormatter alloc]init];
        [formatter setDateFormat:@"YYYY-MM-dd"];
        latestMessageTime = [formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:timeInterval]];
    }
    return latestMessageTime;
}

#pragma mark - 获取高度

+ (CGFloat)getCellHeight {
    return 80.0;
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}


@end
