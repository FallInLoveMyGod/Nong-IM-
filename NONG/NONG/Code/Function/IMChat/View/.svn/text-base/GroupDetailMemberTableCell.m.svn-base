//
//  GroupDetailMemberTableCell.m
//  NONG
//
//  Created by 吴 吴 on 16/9/9.
//  Copyright © 2016年 上海泰侠网络科技有限公司. All rights reserved.
//

#import "GroupDetailMemberTableCell.h"

@implementation GroupDetailMemberTableCell
{
    UIImageView *userIcon;
    UILabel     *userNameLbl;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
    }
    return self;
}

#pragma mark - 创建UI

- (void)setupUI {
    userIcon = [[UIImageView alloc]initWithFrame:AppFrame(0,0,50,50)];
    userIcon.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:userIcon];
    
    userNameLbl = [[UILabel alloc]initWithFrame:AppFrame(10, 10,100, 14)];
    userNameLbl.textColor = [UIColor blackColor];
    userNameLbl.font = FONT14;
    userNameLbl.textAlignment = NSTextAlignmentLeft;
    [self.contentView addSubview:userNameLbl];
}

#pragma mark - 数据源

- (void)initCellWithModel:(NSString *)model {
    userNameLbl.text = model;
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
