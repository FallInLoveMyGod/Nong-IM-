//
//  EaseAtTarget.m
//  NONG
//
//  Created by 吴 吴 on 16/8/17.
//  Copyright © 2016年 上海泰侠网络科技有限公司. All rights reserved.
//

#import "EaseAtTarget.h"

@implementation EaseAtTarget

- (id)initWithUserId:(NSString*)userId andNickname:(NSString*)nickname {
    if (self = [super init])
    {
        _userId = [userId copy];
        _nickname = [nickname copy];
    }
    return self;
}

@end
