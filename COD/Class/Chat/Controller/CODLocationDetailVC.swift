//
//  CODLocationDetailVC.swift
//  COD
//
//  Created by 1 on 2019/4/15.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit
import CoreLocation

class CODLocationDetailVC: BaseViewController {
    
    private var optionRow:Int = 0
    private var isClick:Bool = true
    private var currentLocation:BMKLocation? ///CELL定位位置信息
    private var codLocation:BMKUserLocation? ///当前定位位置信息

    var locationModel = LocationInfo()
    
    //地图视图
    private lazy var mapView: BMKMapView = {
        let mapView = BMKMapView(frame: CGRect.zero)
        mapView.delegate = self
        mapView.mapType = .standard
        mapView.showsUserLocation = true
        mapView.zoomLevel = 17
        mapView.showMapScaleBar = true
        mapView.userTrackingMode = BMKUserTrackingModeNone
        mapView.isChangeCenterWithDoubleTouchPointEnabled = false
        
        mapView.updateLocationView(with: self.displayParam)
        
        return mapView
    }()
    private lazy var bottomView: CODLocationBottomView = {
        let bottomV = CODLocationBottomView.init()
        bottomV.titleLabel.text = locationModel.name
        bottomV.subTitleLabel.text = locationModel.address
        bottomV.locationBtn.addTarget(self, action: #selector(locationAction), for: .touchUpInside)
//        let blur = UIBlurEffect.init(style: .light)
//        let HUDView = UIVisualEffectView.init(effect: blur)
        bottomV.backgroundColor = RGBA(r: 243, g: 243, b: 243, a: 0.9)
        return bottomV
    }()
    //    我的位置的精度圆 也可以替换自己的图片
    lazy var displayParam: BMKLocationViewDisplayParam = {
        let displayParam = BMKLocationViewDisplayParam()
        displayParam.locationViewOffsetX=0;//定位偏移量(经度)
        displayParam.locationViewOffsetY=0;//定位偏移量（纬度）
        //用户自定义定位图标
        //param.locationViewImage = [UIImage imageNamed:@"location.png"];
        displayParam.isAccuracyCircleShow = false;
        return displayParam
    }()
    //定位
    lazy var locService:BMKLocationManager = {
        let locService = BMKLocationManager()
        locService.delegate = self
        locService.coordinateType = BMKLocationCoordinateType.BMK09LL
        locService.desiredAccuracy = kCLLocationAccuracyBest
        locService.activityType = CLActivityType.automotiveNavigation
        locService.pausesLocationUpdatesAutomatically = false
        locService.allowsBackgroundLocationUpdates = false
        locService.locationTimeout = 15
        //开始连续定位。调用此方法会cancel掉所有的单次定位请求。
        return locService
    }()
    //城市POI检索
    lazy var poiSearch:BMKPoiSearch = {
        let poiSearch = BMKPoiSearch()
        poiSearch.delegate = self
        return poiSearch
    }()
    //地理反编码检索
    lazy var geocodeSerch: BMKGeoCodeSearch = {
        let geocodeSerch = BMKGeoCodeSearch()
        geocodeSerch.delegate = self
        return geocodeSerch
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = NSLocalizedString("地点", comment: "")
        setUpSubviews()
        ///开始验证权限的问题
//        self.requestCLAuthorizationStatus()
        ///开始定位
        self.startLocation()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.mapView.viewWillAppear()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.mapView.viewWillDisappear()
        self.mapView.delegate = nil;
        self.poiSearch.delegate = nil;
        self.geocodeSerch.delegate = nil;
    }
    fileprivate func setUpSubviews(){
        
        self.setBackButton()
        self.view.addSubviews([self.mapView,self.bottomView])
     
        addSnpkit()
    }
    fileprivate func addSnpkit(){
  
        mapView.snp.makeConstraints({ (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(self.view).offset(0)
            make.height.equalTo(kScreenHeight)
        })
     
        bottomView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalTo(self.view)
            make.height.equalTo(80)
        }
    }
    //权限的处理
    func requestCLAuthorizationStatus() {
        let status = CLLocationManager.authorizationStatus()
        if status == .authorizedAlways || status == .authorizedWhenInUse || status == .notDetermined {
            self.startLocation()
        }else{
            ///提示用户
            CODAlertViewToSetting_show("无法访问您的位置", message: CustomUtil.formatterStringWithAppName(str: "请到设置 -> %@ -> 位置 -> 打开访问权限") )
        }
    }
    @objc fileprivate func cancleAction(){
        self.dismiss(animated: true, completion: nil)
    }
  
}

extension CODLocationDetailVC:BMKLocationManagerDelegate,BMKPoiSearchDelegate{
    //权限变化
    func bmkLocationManager(_ manager: BMKLocationManager, didChange status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse || status == .authorizedAlways || status == .notDetermined{///权限正常
            self.startLocation()
        }
    }
    
    //开始定位
    func startLocation(){
        ///显示自己定位的位置
        self.currentLocation = BMKLocation.init(location: CLLocation.init(latitude: self.locationModel.latitude, longitude: self.locationModel.longitude), withRgcData: nil)
        let userLocation  = BMKUserLocation()
        userLocation.location = self.currentLocation?.location
        self.mapView.updateLocationData(userLocation)
        ///添加大头针
        let annotation = BMKPointAnnotation()
        annotation.coordinate = (self.currentLocation!.location?.coordinate)!
        self.mapView.addAnnotation(annotation)///设置大头针
        self.mapView.setCenter(annotation.coordinate, animated: true) ///设置显示的中心是大头针
        self.locService.requestLocation(withReGeocode: true, withNetworkState: true) { [weak self] (location, state, error) in
            
            guard let `self` = self else { return }
            
            if (error != nil) {
                ///定位失败 提示用户
                return
            }
            if (location != nil) {
                ///显示自己定位的位置
                let userLocation  = BMKUserLocation()
                userLocation.location = location?.location
                self.codLocation = userLocation

            }
            
        }
    }
    //开始周边搜索
    fileprivate func searchNearbyWithCoordinate(coordinate:CLLocationCoordinate2D){
        
        let option = BMKReverseGeoCodeSearchOption()
        option.location = coordinate
        let flag = self.geocodeSerch.reverseGeoCode(option)
        if(flag == true){
            print("周边GEO搜索发送成功")
        }else{
            print("周边GEO搜索发送失败")
        }
       
    }
  
    //城市搜索地点
    func onGetPoiResult(_ searcher: BMKPoiSearch!, result poiResult: BMKPOISearchResult!, errorCode: BMKSearchErrorCode) {
     
    }
    func onGetPoiDetailResult(_ searcher: BMKPoiSearch!, result poiDetailResult: BMKPOIDetailSearchResult!, errorCode: BMKSearchErrorCode) {
    }
}
//周边反编码
extension CODLocationDetailVC:BMKGeoCodeSearchDelegate{
    func onGetReverseGeoCodeResult(_ searcher: BMKGeoCodeSearch!, result: BMKReverseGeoCodeSearchResult!, errorCode error: BMKSearchErrorCode) {
       
    }
}
extension CODLocationDetailVC:BMKMapViewDelegate{
    func mapView(_ mapView: BMKMapView!, regionDidChangeAnimated animated: Bool) {
        if !self.isClick {//如果是用户滚动中心点
            self.optionRow = 0
            self.searchNearbyWithCoordinate(coordinate: self.mapView.region.center)
        }
        self.isClick = false
    }
    //设置大头针 并显示在中间
    func setMapViewCenterCoordinate(coor:CLLocationCoordinate2D)  {
        ///先移除全部的大头针
        self.mapView.removeAnnotations(self.mapView.annotations)
        
        let annotation = BMKPointAnnotation()
        annotation.coordinate = coor
        self.mapView.addAnnotation(annotation)
        
        self.mapView.setCenter(coor, animated: true)
    }
}

extension CODLocationDetailVC{
    @objc func locationAction() {
        
        CCMapGuide.judgeMapAppInPhoneAndJumpInto(targetLat: self.locationModel.latitude, targetLong: self.locationModel.longitude, targetName: self.locationModel.name, VC: self)
    }
    
   
}
