//
//  CODLocationTool.swift
//  COD
//
//  Created by xinhooo on 2020/5/18.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import UIKit

class CODLocationTool: NSObject {

    var searchResult: (([BMKPoiInfo]) -> ())? = nil
    var searchKeywordResult: (([BMKPoiInfo]) -> ())? = nil
    
    var coordinate: CLLocationCoordinate2D? = nil
    var location: BMKLocation? = nil
    
    
    lazy var locationManager: BMKLocationManager = {
        let locationManager = BMKLocationManager()
        locationManager.delegate = self
        locationManager.coordinateType = BMKLocationCoordinateType.BMK09LL
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.activityType = CLActivityType.automotiveNavigation
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.allowsBackgroundLocationUpdates = false
        locationManager.locationTimeout = 10;
        locationManager.reGeocodeTimeout = 10;
        return locationManager
    }()
    
    
    /// 反地理编码检索
    lazy var search: BMKGeoCodeSearch = {
        let search = BMKGeoCodeSearch()
        search.delegate = self
        return search
    }()
    
    
    /// 周边检索
    lazy var poiSearch: BMKPoiSearch = {
        let poiSearch = BMKPoiSearch()
        poiSearch.delegate = self
        return poiSearch
    }()
    
    
    /// 反地理编码属性
    lazy var reverseGeoCodeOption: BMKReverseGeoCodeSearchOption = {
        let reverseGeoCodeOption = BMKReverseGeoCodeSearchOption()
        reverseGeoCodeOption.isLatestAdmin = true
        reverseGeoCodeOption.pageSize = 20
        return reverseGeoCodeOption
    }()
    
    /// 周边检索属性
    lazy var poiOption: BMKPOINearbySearchOption = {
        let poiOption = BMKPOINearbySearchOption()
        poiOption.pageSize = 20
        return poiOption
    }()
    
    
    static let share = CODLocationTool()
    
    
    /// 开始获取poi
    func starLocation() {
        
        locationManager.requestLocation(withReGeocode: true, withNetworkState: true) { [weak self] (location, state, error) in
            guard let `self` = self, let location = location, let coordinate = location.location?.coordinate else{
                return
            }
            
            self.location = location
            self.coordinate = coordinate
            self.reverseGeoCodeOption.location = coordinate
            self.reverseGeoCodeOption.pageNum = 1
            self.search.reverseGeoCode(self.reverseGeoCodeOption)
            
        }
    }
    
    
    /// 获取周边poi
    /// - Parameter pageNum: 分页
    func getPoiList(pageNum:Int32) {
        
        self.reverseGeoCodeOption.pageNum = pageNum
        self.search.reverseGeoCode(self.reverseGeoCodeOption)
        
    }
    
    func searchPoiWithKeyword(keyword: String, searchResult: @escaping ([BMKPoiInfo]) -> ()) {
        self.searchKeywordResult = searchResult
        self.poiOption.radius = 20000
        self.poiOption.keywords = [keyword]
        if let coordinate = self.location?.location?.coordinate {
            self.poiOption.location = coordinate
        }
        self.poiSearch.poiSearchNear(by: self.poiOption)
    }
}

extension CODLocationTool : BMKGeoCodeSearchDelegate,BMKLocationManagerDelegate,BMKPoiSearchDelegate{
    
    func onGetReverseGeoCodeResult(_ searcher: BMKGeoCodeSearch!, result: BMKReverseGeoCodeSearchResult!, errorCode error: BMKSearchErrorCode) {
        if error == BMK_SEARCH_NO_ERROR {
            
            if let searchResult = searchResult {
                searchResult(result.poiList)
            }
        }
    }
    
    func onGetPoiResult(_ searcher: BMKPoiSearch!, result poiResult: BMKPOISearchResult!, errorCode: BMKSearchErrorCode) {
        if errorCode == BMK_SEARCH_NO_ERROR {
            
            if let searchResult = searchKeywordResult {
                searchResult(poiResult.poiInfoList)
            }
        }
    }
}
