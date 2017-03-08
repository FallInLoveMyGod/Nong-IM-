//
//  MyLocationController.h
//  NONG
//
//  Created by 吴 吴 on 16/8/17.
//  Copyright © 2016年 上海泰侠网络科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MyLocationControllerDelegate <NSObject>

@optional

/**
 *  发送我的位置
 *
 *  @param latitude  当前维度
 *  @param longitude 当前经度
 *  @param address   当前位置描述
 */
- (void)sendLocationLatitude:(double)latitude
                  longitude:(double)longitude
                 andAddress:(NSString *)address;

@end

@interface MyLocationController : UIViewController

@property(nonatomic,assign)id<MyLocationControllerDelegate>delegate;

- (id)initWithLocation:(CLLocationCoordinate2D)locationCoordinate;


@end
