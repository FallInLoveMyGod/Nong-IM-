//
//  GroupDetailController.m
//  NONG
//
//  Created by 吴 吴 on 16/9/9.
//  Copyright © 2016年 上海泰侠网络科技有限公司. All rights reserved.
//

#import "GroupDetailController.h"
#import "GroupDetailMemberTableCell.h"

@interface GroupDetailController ()<UITableViewDataSource,UITableViewDelegate>
{
    UITableView *infoTable;
    
    /**
     *  当前查看的群组
     */
    EMGroup     *tempGroup;
}

@end

@implementation GroupDetailController

- (id)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (id)initWithGroup:(EMGroup *)chatGroup {
    self = [super init];
    if (self) {
        tempGroup = chatGroup;
    }
    return self;
}

- (id)initWithGroupId:(NSString *)chatGroupId {
    __block EMGroup *chatGroup = nil;
    NSArray *groupArray = [[EMClient sharedClient].groupManager getAllGroups];
    [groupArray enumerateObjectsUsingBlock:^(EMGroup *group, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([group.groupId isEqualToString:chatGroupId])
        {
            chatGroup = group;
            *stop     = YES;
        }
    }];
    
    /**
     *  群组不存在则创建
     */
    if (chatGroup == nil)
    {
        chatGroup = [EMGroup groupWithId:chatGroupId];
    }
    
    self = [self initWithGroup:chatGroup];
    if (self)
    {
        
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor whiteColor];
    [self setupUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - 创建UI

- (void)setupUI {
    infoTable = [[UITableView alloc]initWithFrame:AppFrame(0,64,AppWidth,self.view.height-64) style:UITableViewStylePlain];
    infoTable.backgroundColor = [UIColor clearColor];
//    infoTable.separatorColor  = [UIColor clearColor];
//    infoTable.separatorStyle  = UITableViewCellSeparatorStyleNone;
    infoTable.dataSource      = self;
    infoTable.delegate        = self;
    [self.view addSubview:infoTable];
    
    if ([infoTable respondsToSelector:@selector(setSeparatorInset:)])
    {
        [infoTable setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([infoTable respondsToSelector:@selector(setLayoutMargins:)])
    {
        [infoTable setLayoutMargins:UIEdgeInsetsZero];
    }
}


#pragma mark - 按钮点击事件

#pragma mark - UITableViewDataSource && Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0)
    {
        return tempGroup.occupants.count;
    }
    else
    {
        return 3;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIDOne = @"GroupDetailMemberTableCell";
    if (indexPath.section == 0)
    {
        GroupDetailMemberTableCell *cell = (GroupDetailMemberTableCell *)[tableView dequeueReusableCellWithIdentifier:cellIDOne];
        if (cell == nil)
        {
            cell = [[GroupDetailMemberTableCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIDOne];
        }
        cell.backgroundColor = [UIColor whiteColor];
        return cell;
    }
    static NSString *cellIDTwo = @"UITableViewCell";
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIDTwo];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIDTwo];
    }
    cell.backgroundColor = [UIColor whiteColor];
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0)
    {
        [((GroupDetailMemberTableCell *)cell) initCellWithModel:tempGroup.occupants[indexPath.row]];
    }
    else
    {
        if (indexPath.row == 0)
        {
            cell.textLabel.text       = [NSString stringWithFormat:@"群组ID: %@",tempGroup.groupId];
            cell.accessoryType        = UITableViewCellAccessoryNone;
        }
        else if (indexPath.row == 1)
        {
            cell.textLabel.text       = [NSString stringWithFormat:@"群组人数 : %i / %i",(int)[tempGroup.occupants count],(int)tempGroup.setting.maxUsersCount];
            cell.accessoryType        = UITableViewCellAccessoryNone;
        }
        else
        {
            cell.textLabel.text       = @"修改群名称";
            cell.accessoryType        = UITableViewCellAccessoryDisclosureIndicator;
        }
    }
    
    /**
     * cell间隔线位移为0
     */
    if ([cell respondsToSelector:@selector(setSeparatorInset:)])
    {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)])
    {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0)
    {
        return 40.0;
    }
    return 0.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0)
    {
        UIView *headerView = [[UIView alloc]initWithFrame:AppFrame(0, 0, AppWidth, 40)];
        headerView.backgroundColor = [UIColor clearColor];
        
        UILabel *titleLbl = [[UILabel alloc]initWithFrame:AppFrame(10,(headerView.height-16)/2,100,16)];
        titleLbl.textColor = [UIColor darkTextColor];
        titleLbl.font = FONT16;
        titleLbl.textAlignment = NSTextAlignmentLeft;
        titleLbl.text = @"群成员";
        [headerView addSubview:titleLbl];
    
        [headerView drawBottomLine];
        return headerView;
    }
    return nil;
}

@end
