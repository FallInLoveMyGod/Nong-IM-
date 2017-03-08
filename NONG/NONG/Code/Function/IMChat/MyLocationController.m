//
//  MyLocationController.m
//  NONG
//
//  Created by 吴 吴 on 16/8/17.
//  Copyright © 2016年 上海泰侠网络科技有限公司. All rights reserved.
//

#import "MyLocationController.h"

@interface MyLocationController ()<MKMapViewDelegate,CLLocationManagerDelegate>
{
    /**
     *  标记是否是发送位置信息 YES是;反之是显示位置信息
     */
    BOOL isSendLocation;
    
    /**
     *  当前的位置经纬度
     */
    CLLocationCoordinate2D currentLocationCoordinate;
    
    /**
     *  地图
     */
    MKMapView *_mapView;
    /**
     *  大头针气泡
     */
    MKPointAnnotation *_annotation;
    /**
     *  定位管理类
     */
    CLLocationManager *_locationManager;
}
@property (nonatomic,strong)NSString *addressString;

@end

@implementation MyLocationController
@synthesize addressString = _addressString;

- (id)init {
    self = [super init];
    if (self) {
        isSendLocation = YES;
    }
    return self;
}

- (id)initWithLocation:(CLLocationCoordinate2D)locationCoordinate {
    self = [super init];
    if (self) {
        isSendLocation = NO;
        currentLocationCoordinate = locationCoordinate;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"位置信息";
    if (isSendLocation)
    {
        UIBarButtonItem *rightBtn = [[UIBarButtonItem alloc]initWithTitle:@"发送" style:UIBarButtonItemStylePlain target:self action:@selector(rightBtnPressed)];
        self.navigationItem.rightBarButtonItem = rightBtn;
    }
    else
    {
        self.navigationItem.rightBarButtonItem = nil;
    }
    [self setupUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

#pragma mark - 创建UI

- (void)setupUI {
    _mapView = [[MKMapView alloc] initWithFrame:self.view.bounds];
    _mapView.delegate = self;
    _mapView.mapType = MKMapTypeStandard;
    _mapView.zoomEnabled = YES;
    [self.view addSubview:_mapView];
    
    if (isSendLocation)
    {
        _mapView.showsUserLocation = YES;
        [self startLocation];
    }
    else
    {
        [self removeToLocation:currentLocationCoordinate];
    }
}

- (void)startLocation {
    if([CLLocationManager locationServicesEnabled])
    {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _locationManager.distanceFilter = 5;
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0)
        {
            [_locationManager requestWhenInUseAuthorization];
        }
    }
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    switch (status)
    {
        case kCLAuthorizationStatusNotDetermined:
            if ([_locationManager respondsToSelector:@selector(requestAlwaysAuthorization)])
            {
                [_locationManager requestWhenInUseAuthorization];
            }
            break;
            
        case kCLAuthorizationStatusDenied:
            break;
            
        default:
            break;
    }
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    __weak typeof(self) weakSelf = self;
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:userLocation.location completionHandler:^(NSArray *array, NSError *error) {
        if (!error && array.count > 0) {
            CLPlacemark *placemark = [array objectAtIndex:0];
            weakSelf.addressString = placemark.name;
            /**
             *  显示当前位置
             */
            [self removeToLocation:userLocation.coordinate];
        }
    }];
}

- (void)mapView:(MKMapView *)mapView didFailToLocateUserWithError:(NSError *)error {
    NSLog(@"%@",error.description);
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views {
    if ([[[views objectAtIndex:0]annotation] isKindOfClass:[MKPointAnnotation class]])
    {
        /**
         * 第一次进来就显示
         */
        MKAnnotationView * piview = (MKAnnotationView *)[views objectAtIndex:0];
        [_mapView selectAnnotation:piview.annotation animated:YES];
    }
}


- (void)removeToLocation:(CLLocationCoordinate2D)locationCoordinate {
    currentLocationCoordinate = locationCoordinate;
    
    float zoomLevel = 0.01;
    MKCoordinateRegion region = MKCoordinateRegionMake(currentLocationCoordinate, MKCoordinateSpanMake(zoomLevel, zoomLevel));
    [_mapView setRegion:[_mapView regionThatFits:region] animated:YES];
    
    /**
     *  创建标注视图
     */
    [self createAnnotationWithCoords:currentLocationCoordinate];
}

#pragma mark - 创建标注

- (void)createAnnotationWithCoords:(CLLocationCoordinate2D)coords {
    if (_annotation == nil)
    {
        _annotation = [[MKPointAnnotation alloc] init];
    }
    else
    {
        [_mapView removeAnnotation:_annotation];
    }
    _annotation.coordinate = coords;
    _annotation.title = _addressString;
    [_mapView addAnnotation:_annotation];
}

#pragma mark - 按钮点击事件

- (void)rightBtnPressed {
    if ([self.delegate respondsToSelector:@selector(sendLocationLatitude:longitude:andAddress:)])
    {
        [self.delegate sendLocationLatitude:currentLocationCoordinate.latitude longitude:currentLocationCoordinate.longitude andAddress:_addressString];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

@end
