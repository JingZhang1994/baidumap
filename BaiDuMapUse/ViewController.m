//
//  ViewController.m
//  BaiDuMapUse
//
//  Created by apple on 2018/2/27.
//  Copyright © 2018年 zj. All rights reserved.
//

#import "ViewController.h"
#import <BaiduMapAPI_Map/BMKMapComponent.h>
#import <BaiduMapAPI_Location/BMKLocationComponent.h>
#import <BaiduMapAPI_Search/BMKGeocodeSearch.h>
@interface ViewController ()<BMKMapViewDelegate,BMKLocationServiceDelegate,BMKGeoCodeSearchDelegate>{
    BMKLocationService* _locService;
    BMKMapView* _mapView;
    BMKGeoCodeSearch *_geoCodeSearch;
}

@end

@implementation ViewController

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _locService.delegate = self;
    _mapView.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    _locService.delegate = nil;
    _mapView.delegate = nil; // 不用时，置nil
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // 设置地图定位
    [self setupBMKLocation];
    
}
- (void)setupBMKLocation {
    _mapView = [[BMKMapView alloc]init];
    _mapView.frame = self.view.bounds;
    [self.view addSubview:_mapView];
    //初始化BMKLocationService
    _locService = [[BMKLocationService alloc]init];
    _locService.delegate = self;
    // 初始化编码服务
    _geoCodeSearch = [[BMKGeoCodeSearch alloc] init];
    _geoCodeSearch.delegate = self;
    //启动LocationService
    [_locService startUserLocationService];
    _mapView.showsUserLocation = YES;//显示定位图层
    _mapView.userTrackingMode = BMKUserTrackingModeFollow;//设置定位的状态为普通定位模式
}



#pragma mark - BMKLocationServiceDelegate 实现相关delegate 处理位置信息更新

/**
 *在地图View将要启动定位时，会调用此函数
 *@param mapView 地图View
 */
- (void)willStartLocatingUser
{
    NSLog(@"start locate");
}

/**
 *用户方向更新后，会调用此函数
 *@param userLocation 新的用户位置
 */
- (void)didUpdateUserHeading:(BMKUserLocation *)userLocation
{
    NSLog(@"heading is %@",userLocation.heading);
}

/**
 *用户位置更新后，会调用此函数
 *@param userLocation 新的用户位置
 */
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation
{
    
    BMKCoordinateRegion region;
    region.center.latitude = userLocation.location.coordinate.latitude;
    region.center.longitude = userLocation.location.coordinate.longitude;
    region.span.latitudeDelta = 0.2;
    region.span.longitudeDelta = 0.2;
    if (_mapView)
    {
        _mapView.region = region;
    }
    [_mapView setZoomLevel:19.0];
    [_locService stopUserLocationService];//定位完成停止位置更新
    
    //添加当前位置的标注
    CLLocationCoordinate2D coord;
    coord.latitude = userLocation.location.coordinate.latitude;
    coord.longitude = userLocation.location.coordinate.longitude;
    
    BMKPointAnnotation *_pointAnnotation = [[BMKPointAnnotation alloc] init];
    _pointAnnotation.coordinate = coord;
    
    //反地理编码出地理位置
    CLLocationCoordinate2D pt=(CLLocationCoordinate2D){0,0};
    pt=(CLLocationCoordinate2D){coord.latitude,coord.longitude};
    BMKReverseGeoCodeOption *reverseGeoCodeOption = [[BMKReverseGeoCodeOption alloc] init];
    reverseGeoCodeOption.reverseGeoPoint = pt;
    //发送反编码请求.并返回是否成功
    BOOL flag = [_geoCodeSearch reverseGeoCode:reverseGeoCodeOption];
    
    if (flag) {
        NSLog(@"反geo检索发送成功");
    } else {
        NSLog(@"反geo检索发送失败");
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [_mapView removeOverlays:_mapView.overlays];
        [_mapView setCenterCoordinate:coord animated:true];
        [_mapView addAnnotation:_pointAnnotation];
        
    });
    
}

/**
 *在地图View停止定位后，会调用此函数
 *@param mapView 地图View
 */
- (void)didStopLocatingUser
{
    NSLog(@"stop locate");
}

/**
 *定位失败后，会调用此函数
 *@param mapView 地图View
 *@param error 错误号，参考CLError.h中定义的错误号
 */
- (void)didFailToLocateUserWithError:(NSError *)error
{
    NSLog(@"location error");
    //    NSString *city = [[NSUserDefaults standardUserDefaults] objectForKey:@"cityNmae"];
    //    [self.cityBtn setTitle:city forState:UIControlStateNormal];
}

// 反地理编码
- (void)onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error {
    
    if (error == 0) {
        
        NSString *cityName = [result.poiList.firstObject city];
        
        
        NSLog(@"%@, %@", [result.poiList.firstObject city], result.address);
        
        
        
        //        // 定位的city
        //        [[NSUserDefaults standardUserDefaults] setObject:[result.poiList.firstObject city] forKey:@"city"];
        //        [[NSUserDefaults standardUserDefaults] synchronize];
        //
        //        // 保存定位的街道地址
        //        [[NSUserDefaults standardUserDefaults] setObject:result.addressDetail.streetName forKey:@"street"];
        //        [[NSUserDefaults standardUserDefaults] synchronize];
        
    }
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
