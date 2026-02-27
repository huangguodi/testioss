//
//  RKLBSManager.m
//  YBVideo
//
//  Created by YB007 on 2020/10/19.
//  Copyright © 2020 cat. All rights reserved.
//

#import "RKLBSManager.h"
#import <MapKit/MapKit.h>
#import "RKActionSheet.h"

@interface RKLBSManager()<CLLocationManagerDelegate>

@property(nonatomic,strong)CLLocationManager *clManager;
@property(nonatomic,copy)RKLbsBlock lbsEvent;

@end

static RKLBSManager *_lbsManager = nil;

@implementation RKLBSManager

+(instancetype)shareManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _lbsManager = [[super allocWithZone:NULL]init];
        [_lbsManager createCL];
    });
    return _lbsManager;
}
-(void)createCL{
    if (!_clManager) {
        _clManager = [[CLLocationManager alloc] init];
        [_clManager setDesiredAccuracy:kCLLocationAccuracyBest];
        _clManager.delegate = self;
    }
}

-(void)startLocation {
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
        UIAlertController *alertContro = [UIAlertController alertControllerWithTitle:nil message:[NSString stringWithFormat:@"%@%@%@",YZMsg(@"打开“定位服务”来允许“"),[infoDictionary objectForKey:@"CFBundleDisplayName"],YZMsg(@"确定您的位置")] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:YZMsg(@"设置") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:^(BOOL success) {
                
            }];
        }];
        [alertContro addAction:cancleAction];
        UIAlertAction *sureAction = [UIAlertAction actionWithTitle:YZMsg(@"取消") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }];
        [alertContro addAction:sureAction];
        [[YBAppDelegate sharedAppDelegate].topViewController presentViewController:alertContro animated:YES completion:nil];
        
    }else {
        SEL requestSelector = NSSelectorFromString(@"requestWhenInUseAuthorization");
        if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined && [_clManager respondsToSelector:requestSelector]) {
            [_clManager requestWhenInUseAuthorization];  //调用了这句,就会弹出允许框了.
        } else {
            [_clManager startUpdatingLocation];
        }
    }
}
-(void)locationComplete:(RKLbsBlock)complete; {
    self.lbsEvent = complete;
}
- (void)stopLocation {
    [_clManager stopUpdatingHeading];
    [_clManager stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status == kCLAuthorizationStatusRestricted || status == kCLAuthorizationStatusDenied) {
        [self stopLocation];
    } else {
        [_clManager startUpdatingLocation];
    }
}
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    [self stopLocation];
}
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CLLocation *newLocatioin = locations[0];
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    NSString* locationLat = [NSString stringWithFormat:@"%f",newLocatioin.coordinate.latitude];
    NSString* locationLng = [NSString stringWithFormat:@"%f",newLocatioin.coordinate.longitude];
    WeakSelf;
    [geocoder reverseGeocodeLocation:newLocatioin completionHandler:^(NSArray *placemarks, NSError *error) {
        if (!error) {
            CLPlacemark *placeMark = placemarks[0];
            
            NSString *city = placeMark.locality;
            [weakSelf updateCityInfo:locationLat andLng:locationLng];
            liveCity *locCity = [cityDefault myProfile];
            locCity.city = city;
            [cityDefault saveProfile:locCity];
            
            NSString *provinceStr = placeMark.administrativeArea?placeMark.administrativeArea:@"";
            NSString *areaStr = placeMark.subLocality?placeMark.subLocality:@"";
            
            /*
            if ([city hasSuffix:@"市"]) {
                city = [city substringToIndex:city.length-1];
            }
            if (_fromEdit) {
            }else{
                [PublicObj updataNewCity:city];
            }
            */
            [weakSelf updataTabbarWithCity:city];
            //
            if (exactCity) {
                [weakSelf getCityWithLat:locationLat andLng:locationLng andArray:placemarks cusArray:@[provinceStr,city,areaStr]];
            }else{
                if (weakSelf.lbsEvent) {
                    self.lbsEvent(placemarks, @[provinceStr,city,areaStr]);
                }
            }
        }
    }];
    [self stopLocation];
}

-(void)updateCityInfo:(NSString *)latitude andLng:(NSString *)longitude {
    liveCity *city = [cityDefault myProfile];
    city.lat = latitude;
    city.lng = longitude;
    [cityDefault saveProfile:city];
    [YBToolClass postNetworkWithUrl:[NSString stringWithFormat:@"User.SetLocal&lat=%@&lng=%@",latitude,longitude] andParameter:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        
    } fail:^{
        
    }];
}

#pragma mark - 打开导航软件开始
-(void)showNavigationsWithLat:(NSNumber *)lat lng:(NSNumber *)lng endName:(NSString *)endName{
    
    UIApplication * app = [UIApplication sharedApplication];
    WeakSelf;
    RKActionSheet *sheet = [[RKActionSheet alloc]initWithTitle:YZMsg(@"")];
    if ([app canOpenURL:[NSURL URLWithString:@"iosamap://"]]) {
        [sheet addActionWithType:RKSheet_Default andTitle:YZMsg(@"高德地图") complete:^{
            [weakSelf openGdMapWithLat:lat lng:lng endName:endName];
        }];
    }
    if ([app canOpenURL:[NSURL URLWithString:@"baidumap://"]]) {
        [sheet addActionWithType:RKSheet_Default andTitle:YZMsg(@"百度地图") complete:^{
            [weakSelf openBdMapWithLat:lat lng:lng endName:endName];
        }];
    }
    if ([app canOpenURL:[NSURL URLWithString:@"qqmap://"]]) {
        [sheet addActionWithType:RKSheet_Default andTitle:YZMsg(@"腾讯地图") complete:^{
            [weakSelf openTxMapWithLat:lat lng:lng endName:endName];
        }];
    }
    [sheet addActionWithType:RKSheet_Default andTitle:YZMsg(@"Apple地图") complete:^{
        [weakSelf openAppleMapWithLat:lat lng:lng endName:endName];
    }];
    /*
    // 谷歌
    if ([app canOpenURL:[NSURL URLWithString:@"comgooglemaps://"]]) {
        [sheet addActionWithType:RKSheet_Default andTitle:YZMsg(@"谷歌地图") complete:^{
            [weakSelf openGoogleMapWithLat:lat lng:lng endName:endName];
        }];
    }
    */
    [sheet addActionWithType:RKSheet_Cancle andTitle:YZMsg(@"取消") complete:^{
    }];
    [sheet showSheet];
}
/// 高德
-(void)openGdMapWithLat:(NSNumber *)lat lng:(NSNumber *)lng endName:(NSString *)endName{
    NSString *appName = [YBToolClass getAppName];
    NSString *urlString = [[NSString stringWithFormat:@"iosamap://path?sourceApplication=%@&sid=&sname=%@&did=&dlat=%@&dlon=%@&dname=%@&dev=0&t=0",appName,@"我的位置",lat,lng,endName] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString] options:@{} completionHandler:nil];
}
/// 百度
-(void)openBdMapWithLat:(NSNumber *)lat lng:(NSNumber *)lng endName:(NSString *)endName{
    
    /// 百度需要坐标转换
    double old_lat = [lat doubleValue];
    double old_lng = [lng doubleValue];
    NSArray *newLocA = [self gcjToBd09llLat:old_lat lon:old_lng];
    NSNumber *new_lat = newLocA[0];
    NSNumber *new_lng = newLocA[1];
    
    NSString *urlString = [[NSString stringWithFormat:@"baidumap://map/direction?origin={{我的位置}}&destination=latlng:%@,%@|name:%@&mode=driving&coord_type=bd09ll",new_lat,new_lng,endName] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString] options:@{} completionHandler:nil];
}
/// 腾讯
-(void)openTxMapWithLat:(NSNumber *)lat lng:(NSNumber *)lng endName:(NSString *)endName{
    NSString *appName = [YBToolClass getAppName];
    NSString *urlString = [[NSString stringWithFormat:@"qqmap://map/routeplan?type=drive&from=我的位置&to=%@&tocoord=%@,%@&policy=1&referer=%@", endName, lat, lng, appName] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
}
/// 苹果地图
-(void)openAppleMapWithLat:(NSNumber *)lat lng:(NSNumber *)lng endName:(NSString *)endName{
    float latVal = [NSString stringWithFormat:@"%@", lat].floatValue;
    float lngVal = [NSString stringWithFormat:@"%@", lng].floatValue;
    CLLocationCoordinate2D loc = CLLocationCoordinate2DMake(latVal, lngVal);
    MKMapItem *currentLoc = [MKMapItem mapItemForCurrentLocation];
    MKMapItem *toLocation = [[MKMapItem alloc]initWithPlacemark:[[MKPlacemark alloc]initWithCoordinate:loc addressDictionary:nil] ];
    toLocation.name = endName;
    NSArray *items = @[currentLoc,toLocation];
    NSDictionary *dic = @{
        MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving,
        MKLaunchOptionsMapTypeKey : @(MKMapTypeStandard),
        MKLaunchOptionsShowsTrafficKey : @(YES)
    };
    [MKMapItem openMapsWithItems:items launchOptions:dic];
}
/// 谷歌地图【未启用】
-(void)openGoogleMapWithLat:(NSNumber *)lat lng:(NSNumber *)lng endName:(NSString *)endName {
    NSString *appName = [YBToolClass getAppName];
    NSString *urlScheme = [NSBundle mainBundle].bundleIdentifier;
    NSString *urlString = [[NSString stringWithFormat:@"comgooglemaps://?x-source=%@&x-success=%@&q=%@,%@&saddr=&daddr=%@&directionsmode=driving",appName,urlScheme,lat, lng,endName] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
}
/// 百度坐标转高德坐标
-(NSArray *)bd09llToGCJLat:(double)blat lon:(double)blon {
    double X_PI = M_PI * 3000.0 / 180.0;
    double x = blon - 0.0065;
    double y = blat - 0.006;
    double z = sqrt(x * x + y * y) - 0.00002 * sin(y * X_PI);
    double theta = atan2(y, x) - 0.000003 * cos(x * X_PI);
    double lat = z * sin(theta);
    double lon = z * cos(theta);
    NSArray *latlon = @[[NSNumber numberWithDouble:lat],[NSNumber numberWithDouble:lon]];
    return latlon;
}
/// 高德坐标转百度坐标
-(NSArray *)gcjToBd09llLat:(double)glat lon:(double)glon{
    double X_PI = M_PI * 3000.0 / 180.0;
    double x = glon;
    double y = glat;
    double z = sqrt(x * x + y * y) + 0.00002 * sin(y * X_PI);
    double theta = atan2(y, x) + 0.000003 * cos(x * X_PI);
    double lat = z * sin(theta) + 0.006;
    double lon = z * cos(theta) + 0.0065;
    NSArray *latlon = @[[NSNumber numberWithDouble:lat],[NSNumber numberWithDouble:lon]];
    return latlon;
}
/*
//百度坐标转高德（传入经度、纬度）
function bd_decrypt(bd_lng, bd_lat) {
    var X_PI = Math.PI * 3000.0 / 180.0;
    var x = bd_lng - 0.0065;
    var y = bd_lat - 0.006;
    var z = Math.sqrt(x * x + y * y) - 0.00002 * Math.sin(y * X_PI);
    var theta = Math.atan2(y, x) - 0.000003 * Math.cos(x * X_PI);
    var gg_lng = z * Math.cos(theta);
    var gg_lat = z * Math.sin(theta);
    return {lng: gg_lng, lat: gg_lat}
}*/
/*
//高德坐标转百度（传入经度、纬度）
function bd_encrypt(gg_lng, gg_lat) {
    var X_PI = Math.PI * 3000.0 / 180.0;
    var x = gg_lng, y = gg_lat;
    var z = Math.sqrt(x * x + y * y) + 0.00002 * Math.sin(y * X_PI);
    var theta = Math.atan2(y, x) + 0.000003 * Math.cos(x * X_PI);
    var bd_lng = z * Math.cos(theta) + 0.0065;
    var bd_lat = z * Math.sin(theta) + 0.006;
    return {
        bd_lat: bd_lat,
        bd_lng: bd_lng
    };
}
*/
#pragma mark - 打开导航软件结束


#pragma mark - 针对海外获取精确定位城市、翻译【利用腾讯api】开始
-(void)updataTabbarWithCity:(NSString *)city {
    if ([city hasSuffix:@"市"]) {
        city = [city substringToIndex:city.length-1];
    }
    if (_fromEdit) {
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
//            [PublicObj updataNewCity:city];
        });
    }
}

-(void)getCountyCodeLat:(NSString *)lat andLng:(NSString *)lng {
    /**
     https://apis.map.qq.com/ws/geocoder/v1/?
     location=36.178019,117.086293
     &get_poi=0
     &poi_options=address_format=short;radius=1000;page_size=20;page_index=1;policy=5
     &key=TJSBZ-DMWE4-UM5US-DXW7F-RVZRJ-GFFFQ
     */
    NSString *gdy_lang = @"en";
    if ([lagType isEqual:ZH_CN]) {
        gdy_lang = @"cn";
    }
    NSString *baseUrl = @"https://apis.map.qq.com/ws/geocoder/v1/?";
    NSDictionary *pullDic = @{
        @"location":[NSString stringWithFormat:@"%@,%@",lat,lng],
        @"key":TencentKey,
        @"get_poi":@"0",
        @"poi_options":@"address_format=short;radius=1000;page_size=20;page_index=1;policy=5",
        @"language":gdy_lang,
    };
    baseUrl = [baseUrl stringByAppendingFormat:@"%@",[self dealWithParam:pullDic]];
    baseUrl = [baseUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:baseUrl]];
    [request setHTTPMethod:@"GET"];
    /*
    //把字典中的参数进行拼接
    NSString *body = @"";
    NSData *bodyData = [body dataUsingEncoding:NSUTF8StringEncoding];
    //设置请求体
    [request setHTTPBody:bodyData];
    //设置本次请求的数据请求格式
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    // 设置本次请求请求体的长度(因为服务器会根据你这个设定的长度去解析你的请求体中的参数内容)
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)bodyData.length] forHTTPHeaderField:@"Content-Length"];
    */
    //设置请求最长时间
    request.timeoutInterval = 15;
    NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (data) {
            //利用iOS自带原生JSON解析data数据 保存为Dictionary
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            
            int status = [minstr([dict valueForKey:@"status"]) intValue];
            if (status == 0) {
                NSDictionary *resDic = [dict valueForKey:@"result"];
                NSDictionary *ad_info = [resDic valueForKey:@"ad_info"];
                NSString *nation_code = minstr([ad_info valueForKey:@"nation_code"]);
                //[cityDefault saveGdyCountry:nation_code];
            }else{
                //[cityDefault saveGdyCountry:@""];
                NSLog(@"======出错:%@\%@",dict,baseUrl);
            }
        }else{
            //[cityDefault saveGdyCountry:@""];
            NSLog(@"======出错:未拿到数据\n%@",baseUrl);
        }
    }];
    [task resume];
}

#pragma mark - 城市
-(void)getCityWithLat:(NSString *)lat andLng:(NSString *)lng andArray:(NSArray *)placemarks cusArray:(NSArray *)cusArray{
    NSString *baseUrl = @"https://apis.map.qq.com/ws/geocoder/v1/?";
    NSString *gdy_lang = @"en";
    if ([lagType isEqual:ZH_CN]) {
        gdy_lang = @"cn";
    }
    NSDictionary *pullDic = @{
        @"location":[NSString stringWithFormat:@"%@,%@",lat,lng],
        @"key":TencentKey,
        @"get_poi":@"0",
        @"poi_options":@"address_format=short;radius=1000;page_size=20;page_index=1;policy=5",
        @"language":gdy_lang,
    };

    baseUrl = [baseUrl stringByAppendingFormat:@"%@",[self dealWithParam:pullDic]];
    baseUrl = [baseUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:baseUrl]];
    [request setHTTPMethod:@"GET"];
    //设置请求最长时间
    request.timeoutInterval = 15;
    WeakSelf;
    NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (data) {
            //利用iOS自带原生JSON解析data数据 保存为Dictionary
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            
            int status = [minstr([dict valueForKey:@"status"]) intValue];
            if (status == 0) {
                NSDictionary *resDic = [dict valueForKey:@"result"];
                NSDictionary *ad_info = [resDic valueForKey:@"ad_info"];
                NSString *nation_code = minstr([ad_info valueForKey:@"nation_code"]);
                NSDictionary *gdy_address_component = [resDic valueForKey:@"address_component"];
                NSString *gdy_city = @"";
                if ([nation_code isEqual:@"156"]) {
                    // 国内
                    gdy_city = minstr([gdy_address_component valueForKey:@"city"]);
                }else{
                    // 国外
                    gdy_city = minstr([gdy_address_component valueForKey:@"ad_level_3"]);
                    if ([YBToolClass checkNull:gdy_city]) {
                        gdy_city = minstr([gdy_address_component valueForKey:@"ad_level_2"]);
                    }
                    if ([YBToolClass checkNull:gdy_city]) {
                        gdy_city = minstr([gdy_address_component valueForKey:@"ad_level_1"]);
                    }
                }
                if (![YBToolClass checkNull:gdy_city]) {
                    liveCity *locCity = [cityDefault myProfile];
                    locCity.city = gdy_city;
                    //[cityDefault saveLocationCity:gdy_city];
                    [cityDefault saveProfile:locCity];
                    
                    if (weakSelf.lbsEvent) {
                        weakSelf.lbsEvent(placemarks, @[cusArray[0],gdy_city,cusArray[2]]);
                    }
                    [weakSelf updataTabbarWithCity:gdy_city];
                }else{
                    if (weakSelf.lbsEvent) {
                        weakSelf.lbsEvent(placemarks, cusArray);
                    }
                }
            }else{
                if (weakSelf.lbsEvent) {
                    weakSelf.lbsEvent(placemarks, cusArray);
                }
                NSLog(@"======city出错:%@\%@",dict,baseUrl);
            }
        }else{
            if (weakSelf.lbsEvent) {
                weakSelf.lbsEvent(placemarks, cusArray);
            }
            NSLog(@"======city出错:未拿到数据\n%@",baseUrl);
        }
    }];
    [task resume];
}
#pragma mark -- 拼接参数
-(NSString *)dealWithParam:(NSDictionary *)param {
    NSArray *allkeys = [param allKeys];
    NSMutableString *result = [NSMutableString string];
    
    for (NSString *key in allkeys) {
        NSString *string = [NSString stringWithFormat:@"%@=%@&", key, param[key]];
        [result appendString:string];
    }
    NSString *newStr = [result substringToIndex:(result.length-1)];
    return newStr;
}
#pragma mark - 周边
-(void)txMapPoisWithCoordinate:(CLLocationCoordinate2D)coordinate andPage:(NSInteger)page complete:(TencentListBlock)locList;{
    
    NSString *lat = [NSString stringWithFormat:@"%f",coordinate.latitude];
    NSString *lng = [NSString stringWithFormat:@"%f",coordinate.longitude];
    NSString *baseUrl = @"https://apis.map.qq.com/ws/geocoder/v1/?";
    NSString *gdy_lang = @"en";
    if ([lagType isEqual:ZH_CN]) {
        gdy_lang = @"cn";
    }
    NSDictionary *pullDic = @{
        @"location":[NSString stringWithFormat:@"%@,%@",lat,lng],
        @"key":TencentKey,
        @"get_poi":@"1",
        @"poi_options":[NSString stringWithFormat:@"address_format=short;radius=1000;page_size=20;page_index=%ld;policy=5",(long)page],
        @"language":gdy_lang,
    };
    baseUrl = [baseUrl stringByAppendingFormat:@"%@",[self dealWithParam:pullDic]];
    baseUrl = [baseUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:baseUrl]];
    [request setHTTPMethod:@"GET"];
    //设置请求最长时间
    request.timeoutInterval = 15;
    
    NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (data) {
            //利用iOS自带原生JSON解析data数据 保存为Dictionary
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            
            int status = [minstr([dict valueForKey:@"status"]) intValue];
            if (status == 0) {
                NSDictionary *resDic = [dict valueForKey:@"result"];
                NSLog(@"====:%@",resDic);
                NSArray *resArray = [resDic valueForKey:@"pois"];
                if (locList) {
                    locList(resArray);
                }
            }else{
                if (locList) {
                    locList(@[]);
                }
                NSLog(@"======周边出错:%@\%@",dict,baseUrl);
            }
        }else{
            if (locList) {
                locList(@[]);
            }
            NSLog(@"======周边出错:未拿到数据\n%@",baseUrl);
        }
    }];
    [task resume];
}

#pragma mark - 搜索地区
-(void)txSearch:(NSString *)keys coordinate:(CLLocationCoordinate2D)coordinate andPage:(NSInteger)page complete:(TencentListBlock)locList;{
    /**
     https://apis.map.qq.com/ws/place/v1/search?
     keyword=万达
     &boundary=nearby(36.178032,117.086304,1000)
     &orderby=_distance
     &page_size=20
     &page_index=1
     &key=TJSBZ-DMWE4-UM5US-DXW7F-RVZRJ-GFFFQ
     &sig=c77652d4bcd47a14418511a4f45a829d
     &language=en
     */
    NSString *lat = [NSString stringWithFormat:@"%f",coordinate.latitude];
    NSString *lng = [NSString stringWithFormat:@"%f",coordinate.longitude];
    NSString *baseUrl = @"https://apis.map.qq.com/ws/place/v1/search?";
    NSString *gdy_lang = @"en";
    if ([lagType isEqual:ZH_CN]) {
        gdy_lang = @"cn";
    }
    NSDictionary *pullDic = @{
        @"keyword":keys,
        @"boundary":[NSString stringWithFormat:@"nearby(%@,%@,1000)",lat,lng],
        @"orderby":@"_distance",
        @"page_size":@"20",
        @"page_index":@(page),
        @"key":TencentKey,
        @"language":gdy_lang,
    };
    baseUrl = [baseUrl stringByAppendingFormat:@"%@",[self dealWithParam:pullDic]];
    baseUrl = [baseUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:baseUrl]];
    [request setHTTPMethod:@"GET"];
    //设置请求最长时间
    request.timeoutInterval = 15;
    
    NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (data) {
            //利用iOS自带原生JSON解析data数据 保存为Dictionary
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            
            int status = [minstr([dict valueForKey:@"status"]) intValue];
            if (status == 0) {
                NSArray *resArray = [dict valueForKey:@"data"];
                if (locList) {
                    locList(resArray);
                }
            }else{
                if (locList) {
                    locList(@[]);
                }
                NSLog(@"======搜索出错:%@\%@",dict,baseUrl);
            }
        }else{
            if (locList) {
                locList(@[]);
            }
            NSLog(@"======搜索出错:未拿到数据\n%@",baseUrl);
        }
    }];
    [task resume];
}
#pragma mark - 针对海外获取精确定位城市、翻译【利用腾讯api】结束


@end
