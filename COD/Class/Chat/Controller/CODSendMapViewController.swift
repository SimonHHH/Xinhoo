//
//  CODSendMapViewController.swift
//  COD
//
//  Created by 1 on 2019/3/20.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit

private let mapHeight:CGFloat = 250
private let LocationCell_identity:String = "UITableViewCell_identity"
class CODSendMapViewController: BaseViewController {
    
    typealias SendLocationCompeleteBlock = (_ locationImage:UIImage,_ poi:BMKPoiInfo) -> Void ///发送地址信息
    public var sendLocationBlock:SendLocationCompeleteBlock?
    private var isSearch:Bool = false
    private var optionRow:Int = 0
    private var isClick:Bool = true
    private var currentPOI:BMKPoiInfo? //当前搜索选中的位置
    private var currentLocation:BMKLocation? ///当前定位位置信息
    private var mainDatas:[BMKPoiInfo] = [BMKPoiInfo]() ///当前地址的周边数据
    private var searchDatas:[BMKPoiInfo] = [BMKPoiInfo]() ///搜索的数据
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
    //搜索的笼罩视图
    fileprivate lazy var view_back: UIView = {
        let view_back = UIView(frame: CGRect.zero)
        view_back.backgroundColor = UIColor.init(white: 0, alpha: 0.2)
        view_back.alpha = 0;
        return view_back
    }()
    //搜索的显示视图
    fileprivate lazy var searchTableView:UITableView = {
        let searchTableView = UITableView(frame: CGRect.zero, style: UITableView.Style.grouped)
        searchTableView.alpha = 0;
        searchTableView.tag = 1001
        searchTableView.delegate = self
        searchTableView.dataSource = self
        searchTableView.backgroundColor = UIColor.white
        searchTableView.estimatedRowHeight = 0
        searchTableView.estimatedSectionHeaderHeight = 0
        searchTableView.estimatedSectionFooterHeight = 0
        searchTableView.tableHeaderView =  UIView(frame: CGRect(x: 0, y: 0, width: KScreenWidth, height: 0.01))
        if #available(iOS 11.0, *) {
            searchTableView.contentInsetAdjustmentBehavior = .never
        }
        return searchTableView
    }()
    ///当前的位置信息视图
    fileprivate lazy var mainTableView:UITableView = {
        let mainTableView = UITableView(frame: CGRect.zero, style: UITableView.Style.grouped)
        mainTableView.tag = 1000
        mainTableView.delegate = self
        mainTableView.dataSource = self
        mainTableView.backgroundColor = UIColor.white
        mainTableView.estimatedRowHeight = 0
        mainTableView.estimatedSectionHeaderHeight = 0
        mainTableView.estimatedSectionFooterHeight = 0
        mainTableView.tableHeaderView =  UIView(frame: CGRect(x: 0, y: 0, width: KScreenWidth, height: 0.01))
        if #available(iOS 11.0, *) {
            mainTableView.contentInsetAdjustmentBehavior = .never
        }
        return mainTableView
    }()
    fileprivate lazy var searchBar: CODSearchBar = {
        let searchBar = CODSearchBar(frame: CGRect.zero)
        searchBar.backgroundColor = UIColor(hexString: kVCBgColorS)
        searchBar.placeholder = NSLocalizedString("搜索附近地点", comment: "")
        searchBar.delegate = self
        searchBar.customTextField?.addTarget(self, action: #selector(textFieldChanged(textField:)), for: UIControl.Event.editingChanged)
        searchBar.customTextField?.backgroundColor = UIColor(hexString: kSearchBarTextFieldBackGdColorS)
        searchBar.barTintColor = UIColor.init(hexString: kVCBgColorS)
        searchBar.tintColor = UIColor.init(hexString: kBlueTitleColorS)
        let searchBarTF = searchBar.customTextField
        searchBarTF?.font = UIFont.systemFont(ofSize: 17)
        return searchBar
    }()
    fileprivate lazy var tipLable: UILabel = {
        let tipLb = UILabel(frame: CGRect.zero)
        tipLb.backgroundColor = UIColor.clear
        tipLb.textColor = UIColor.init(hexString: kSubmitBtnBgColorS)
        tipLb.font = UIFont.systemFont(ofSize: 16)
        tipLb.textAlignment = .center
        tipLb.text = NSLocalizedString("未找到相应地点", comment: "")
        return tipLb
    }()
    fileprivate lazy var sendButtonItem: UIBarButtonItem = {
        let rightItem = UIBarButtonItem(title: NSLocalizedString("发送    ", comment: ""), style: UIBarButtonItem.Style.done, target: self, action: #selector(sendLocationAction))
        rightItem.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor.init(hexString: kSubmitBtnBgColorS) ?? UIColor.white], for: UIControl.State.normal)
        return rightItem
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpSubviews()
        ///开始验证权限的问题
        let status = CLLocationManager.authorizationStatus()
        if status == .authorizedAlways || status == .authorizedWhenInUse || status == .notDetermined {
           
        }else{
            ///提示用户
            CODAlertViewToSetting_show("无法访问您的位置", message: CustomUtil.formatterStringWithAppName(str: "请到设置 -> %@ -> 位置 -> 打开访问权限") )
        }
        
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
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: NSLocalizedString("    取消", comment: ""), style: UIBarButtonItem.Style.done, target: self, action: #selector(cancleAction))
        self.navigationItem.leftBarButtonItem?.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor.init(hexString: kSubmitBtnBgColorS) ?? UIColor.white], for: UIControl.State.normal)
        self.navigationItem.rightBarButtonItem = self.sendButtonItem
        
        self.view.addSubview(self.searchBar)
        self.view.addSubview(self.mapView)
        self.view.addSubview(self.mainTableView)
        self.view.addSubview(self.view_back)
        self.view_back.addSubview(self.searchTableView)
        self.view_back.addSubview(self.tipLable)

        addSnpkit()
    }
    fileprivate func addSnpkit(){
        searchBar.snp.makeConstraints({ (make) in
            make.left.top.right.equalToSuperview()
            make.height.equalTo(50)
        })
        mapView.snp.makeConstraints({ (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo((self.searchBar.snp.bottom)).offset(0)
            make.height.equalTo(mapHeight)
        })
        mainTableView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo((self.mapView.snp.bottom)).offset(0)
            make.bottom.equalToSuperview()
        }
        view_back.snp.makeConstraints { (make) in
            make.top.equalTo((self.searchBar.snp.bottom)).offset(0)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        searchTableView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view_back)
        }
        tipLable.snp.makeConstraints { (make) in
            make.centerX.equalTo(self.view_back)
            make.top.equalTo(self.view_back).offset(120)
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
    @objc fileprivate func sendLocationAction(){
        let status = CLLocationManager.authorizationStatus()
        if status == .authorizedAlways || status == .authorizedWhenInUse || status == .notDetermined {
            if self.sendLocationBlock != nil ,self.mainDatas.count > 0 {
                let poi:BMKPoiInfo = self.mainDatas[optionRow]
                if let locationImage = self.mapView.takeSnapshot() {
                    self.sendLocationBlock!(locationImage,poi)
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }else{
            ///提示用户
            CODAlertViewToSetting_show("无法访问您的位置", message: CustomUtil.formatterStringWithAppName(str: "请到设置 -> %@ -> 位置 -> 打开访问权限") )
        }
    }
}
extension CODSendMapViewController:UIScrollViewDelegate{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        ///关闭编辑
        self.searchBar.endEditing(true)
    }
}
extension CODSendMapViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView.tag == 1000{
            return self.mainDatas.count
        }else{
            return self.searchDatas.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: LocationCell_identity)
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: LocationCell_identity)
        }
        cell?.selectionStyle = .none
        cell?.textLabel?.font = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.thin)
        cell?.detailTextLabel?.font = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.thin)
        cell?.detailTextLabel?.textColor = UIColor.gray
        if tableView.tag == 1000{
            if indexPath.row == self.optionRow {
                cell!.accessoryType = .checkmark
            }else{
                cell!.accessoryType = .none
            }
            let poi = self.mainDatas[indexPath.row]
            cell?.textLabel?.text = poi.name
            cell?.detailTextLabel?.text = poi.address
        }else{
            let tip = self.searchDatas[indexPath.row]
            cell?.textLabel?.text = tip.name
            cell?.detailTextLabel?.text = tip.address
        }
        return cell!
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.tag == 1000{
            self.isClick = true ///是自己选中或者拖动
            self.optionRow = indexPath.row
            self.mainTableView.reloadData()
            if self.mainDatas.count > indexPath.row {
                let poi = self.mainDatas[indexPath.row]
                
                setMapViewCenterCoordinate(coor:poi.pt)
            }
          
        }else{
            self.isClick = true ///是自己选中或者拖动 不要去自动请求
            let tip = self.searchDatas[indexPath.row]
            
            setMapViewCenterCoordinate(coor:tip.pt)
            ///取消编辑
            self.searchBarCancelButtonClicked(self.searchBar)
            self.currentPOI = tip
            ///开始搜索附近
            self.searchNearbyWithCoordinate(coordinate:tip.pt)
        }
    }
}

extension CODSendMapViewController:BMKLocationManagerDelegate,BMKPoiSearchDelegate{
    //权限变化
    func bmkLocationManager(_ manager: BMKLocationManager, didChange status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse || status == .authorizedAlways || status == .notDetermined{///权限正常
            self.startLocation()
        }
    }
    
    //开始定位
    func startLocation(){
        self.locService.requestLocation(withReGeocode: true, withNetworkState: true) { [weak self](location, state, error) in
            
            guard let self = self else {
                return
            }
            
            if (error != nil) {
                ///定位失败 提示用户
                return
            }
            if (location != nil) {
                self.currentLocation = location
                ///显示自己定位的位置
                let userLocation  = BMKUserLocation()
                userLocation.location = self.currentLocation!.location
                self.mapView.updateLocationData(userLocation)
                ///添加大头针
                let annotation = BMKPointAnnotation()
                annotation.coordinate = (self.currentLocation!.location?.coordinate)!
                self.mapView.addAnnotation(annotation)///设置大头针
                
                self.mapView.setCenter(annotation.coordinate, animated: true) ///设置显示的中心是大头针
                ///开始搜索周边数据
                self.isSearch = false
                self.searchNearbyWithCoordinate(coordinate: location!.location!.coordinate)
            }else{
                
                ///定位失败
                print(error?.localizedDescription as Any)
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
    //开始城市搜索
    fileprivate func searchCityWithCoordinate(){
        
//        let option  = BMKPOICitySearchOption()
//        option.keyword = self.searchBar.text
//        option.city = self.currentLocation!.rgcData!.city!
        //下面方法不可行
        let  option = BMKPOINearbySearchOption()
        option.location = self.mapView.region.center
        option.pageSize = 50
        option.radius = 20000 ///周边搜索半径
        option.keywords = [self.searchBar.text ?? ""]
//        option.keywords = ["道路","地点","大厦","学校","广场","大道","花苑","体育场","KTV","中学","小学","地址","广场","酒店","医院","美食"]
        let flag = self.poiSearch.poiSearchNear(by: option)
        if(flag == true){
            print("周边搜索发送成功")
        }else{
            print("周边搜索发送失败")
        }
        
//        let flag = self.poiSearch.poiSearch(inCity: option)
//        if(flag == true){
//            print("城市POI搜索发送成功")
//        }else{
//            print("城市POI搜索发送失败")
//        }
    }
    //城市搜索地点
    func onGetPoiResult(_ searcher: BMKPoiSearch!, result poiResult: BMKPOISearchResult!, errorCode: BMKSearchErrorCode) {
        if (errorCode == BMK_SEARCH_NO_ERROR) {
            if self.isSearch == true {//城市
                if poiResult.poiInfoList.count == 0 {
                    self.tipLable.isHidden = false
                    return
                }
                self.tipLable.isHidden = true
                self.searchDatas.removeAll()
                poiResult.poiInfoList.forEach { (amapPoI) in
                    self.searchDatas.append(amapPoI)
                }
                self.searchTableView.reloadData()
            }
        }else{
            self.tipLable.isHidden = false

        }
    }
    func onGetPoiDetailResult(_ searcher: BMKPoiSearch!, result poiDetailResult: BMKPOIDetailSearchResult!, errorCode: BMKSearchErrorCode) {
    }
}
//周边反编码
extension CODSendMapViewController:BMKGeoCodeSearchDelegate{
    func onGetReverseGeoCodeResult(_ searcher: BMKGeoCodeSearch!, result: BMKReverseGeoCodeSearchResult!, errorCode error: BMKSearchErrorCode) {
        if error == BMK_SEARCH_NO_ERROR {
            ///周边
            self.mainDatas.removeAll()
            if result.poiList.count == 0{
                self.mainTableView.reloadData()
                self.tipLable.isHidden = false
                return
            }
            self.tipLable.isHidden = true

            if self.currentPOI != nil{
                ///添加数据
                self.mainDatas.append(self.currentPOI!)
            }
            result.poiList.forEach { (amapPoI) in
                self.mainDatas.append(amapPoI)
            }
            self.mainTableView.reloadData()
            ///先移除全部的大头针
            self.mapView.removeAnnotations(self.mapView.annotations)
            
            //添加当前的大头针
            let poi = self.mainDatas.first
            let annotation = BMKPointAnnotation()
            annotation.coordinate = poi!.pt
            self.mapView.addAnnotation(annotation)
        }
    }
}
extension CODSendMapViewController:BMKMapViewDelegate{
    func mapView(_ mapView: BMKMapView!, regionDidChangeAnimated animated: Bool) {
        if !self.isClick {//如果是用户滚动中心点
            self.optionRow = 0
            self.currentPOI = nil
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
extension CODSendMapViewController:UISearchBarDelegate{
    ///开始编辑
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        //开始
        self.isSearch = true
        self.view_back.alpha = 1
        self.searchTableView.alpha = 0
        
        UIView.animate(withDuration: 0.25, animations: {
            self.navigationController?.navigationBar.isHidden = true
            var view_frame = self.view.frame
            view_frame.origin.y = CGFloat(KNAV_STATUSHEIGHT)
            view_frame.size.height = KScreenHeight - CGFloat(KNAV_STATUSHEIGHT)
            self.view.frame = view_frame
            self.view.setNeedsLayout()
            self.view.setNeedsUpdateConstraints()
        }) { (finished) in
            searchBar.showsCancelButton = true
            searchBar.setCancelButton()
        }
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        ///取消
        searchBar.endEditing(true)
        searchBar.showsCancelButton = false
        searchBar.text = ""
        
        self.isSearch = false
        self.view_back.alpha = 0
        self.searchTableView.alpha = 0
        
        self.searchDatas.removeAll()
        self.searchTableView.reloadData()
        
        UIView.animate(withDuration: 0.25, animations: {
            self.navigationController?.navigationBar.isHidden = true
            var view_frame = self.view.frame
            view_frame.origin.y = CGFloat(KNAV_HEIGHT)
            view_frame.size.height = KScreenHeight - CGFloat(KNAV_HEIGHT)
            self.view.frame = view_frame
        }) { (finished) in
            self.navigationController?.navigationBar.isHidden = false
            searchBar.showsCancelButton = false
        }
    }
    
    /* 点击了清空文字按钮 */
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if (searchBar.text?.count)! > 0 {
            self.searchTableView.alpha = 1
        }else{
            self.searchTableView.alpha = 0
        }
        self.searchDatas.removeAll()
        self.searchTableView.reloadData()
    }
    /*点击搜索*/
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if searchBar.text?.count == 0 {
            self.searchTableView.alpha = 0
            return
        }
        self.searchTableView.alpha = 1
        ///搜索模式
        self.isSearch = true
        ///关闭编辑
        searchBar.endEditing(true)
        
        ///搜索这个城市地点
        self.searchCityWithCoordinate()
    }
    ///内容变化
    @objc func textFieldChanged(textField:UITextField) {
        if textField.text?.count == 0 {
            return
        }
        ///搜索模式
        self.isSearch = true
        ///搜索这个城市的地点
        self.searchCityWithCoordinate()
    }
}
