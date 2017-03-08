//
//  GroupDetailController.h
//  NONG
//
//  Created by 吴 吴 on 16/9/9.
//  Copyright © 2016年 上海泰侠网络科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  群组详情界面
 */
@interface GroupDetailController : UIViewController

/**
 *  根据群组model初始化本身
 *
 *  @param chatGroup 当前查看的群组对象
 *
 *  @return GroupDetailController
 */
- (id)initWithGroup:(EMGroup *)chatGroup;


/**
 *  根据群组ID初始化本身
 *
 *  @param chatGroupId 当前查看的群组id
 *
 *  @return GroupDetailController
 */
- (id)initWithGroupId:(NSString *)chatGroupId;

@end
