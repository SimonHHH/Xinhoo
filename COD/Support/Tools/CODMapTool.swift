//
//  CODMapTool.swift
//  COD
//
//  Created by 1 on 2019/4/15.
//  Copyright © 2019 XinHoo. All rights reserved.
//

import UIKit
import MapKit

//地图类型
enum MapForm {
    enum MapURI:String {
        //百度
        case baiduMap = "baidumap://"
        //高德
        case gaodeMap = "iosamap://"
        //苹果
        case appleMap = "http://maps.apple.com/"
        //谷歌
        case googleMap = "comgooglemaps://"
        //腾讯
        case qqMap = "qqmap://"
    }
    enum MapName:String {
        //百度
        case baiduMap = "百度地图"
        //高德
        case gaodeMap = "高德地图"
        //苹果
        case appleMap = "苹果地图"
        //谷歌
        case googleMap = "谷歌地图"
        //腾讯
        case qqMap = "腾讯地图"
    }
}

//地图信息
struct MapInfo {
    static func baiDuUrlString(targetLat:Double,targetLon:Double,targetName:String) -> String {
        //return "baidumap://map/direction?origin={{我的位置}}&destination=\(targetName)&mode=driving&src=\(targetName)&coord_type=gcj02"
        /*
         注意：此处destination后面有三种写法：
         1,destination=\(targetLat),\(targetLon)
         2,destination=\(targetName)
         3,destination=name:\(targetName)|latlng:\(targetLat),\(targetLon)
         
         */
        return "baidumap://map/direction?origin={{我的位置}}&destination=name:\(targetName)|latlng:\(targetLat),\(targetLon)&mode=driving&src=\(targetName)&coord_type=gcj02"
    }
    static func gaoDeUrlString(targetLat:Double,targetLon:Double,targetName:String) -> String {
        return "iosamap://path?sourceApplication=导航功能&backScheme=\(kApp_Name)&poiname=\(targetName)&poiid=BGVIS&lat=\(targetLat)&lon=\(targetLon)&dname=\(targetName)&dev=0&m=0"
    }
    static func googleUrlString(targetLat:Double,targetLon:Double,targetName:String) -> String {
        return "comgooglemaps://?x-source=\(kApp_Name)&x-success=\(kApp_Name)&saddr=&daddr=\(targetLat),\(targetLon)&directionsmode=driving"
    }
    static func qqDuUrlString(targetLat:Double,targetLon:Double,targetName:String) -> String {
        return "qqmap://routeplan?type=bus&from=&fromcoord=&to=\(targetName)&tocoord=\(targetLat),\(targetLon)&policy=1&referer=\(kApp_Name)"
    }
}

//检测地图是否存在然后打开
struct CCMapGuide {
    static func judgeMapAppInPhoneAndJumpInto(targetLat:Double,targetLong:Double,targetName:String,VC:UIViewController) {
        //盛放地图元素的数组
        var maps = [[String: String]]()
        //判断地图
        //自带地图
        if UIApplication.shared.canOpenURL(URL(string: MapForm.MapURI.appleMap.rawValue)!) {
            var iosMap = [String: String]()
            iosMap["title"] = MapForm.MapName.appleMap.rawValue
            maps.append(iosMap)
        }
        //百度地图
        if UIApplication.shared.canOpenURL(URL(string: MapForm.MapURI.baiduMap.rawValue)!) {
            var baiduDic = [String: String]()
            baiduDic["title"] = MapForm.MapName.baiduMap.rawValue
            //\(self.pointDetailView.pointTitle.text ?? "")
            let urlString = MapInfo.baiDuUrlString(targetLat: targetLat, targetLon: targetLong, targetName: targetName)
            baiduDic["url"] = urlString
            maps.append(baiduDic)
        }
        //高德地图
        if UIApplication.shared.canOpenURL(URL(string: MapForm.MapURI.gaodeMap.rawValue)!) {
            var gaodeDic = [String: String]()
            gaodeDic["title"] = MapForm.MapName.gaodeMap.rawValue
            let urlString = MapInfo.gaoDeUrlString(targetLat: targetLat, targetLon: targetLong, targetName: targetName)
            let escapedString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            gaodeDic["url"] = escapedString
            maps.append(gaodeDic)
        }
        //谷歌地图
        if UIApplication.shared.canOpenURL(URL(string: MapForm.MapURI.googleMap.rawValue)!) {
            var googleDic = [String: String]()
            googleDic["title"] = MapForm.MapName.googleMap.rawValue
            let urlString = MapInfo.googleUrlString(targetLat: targetLat, targetLon: targetLong, targetName: targetName)
            let escapedString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            googleDic["url"] = escapedString
            maps.append(googleDic)
        }
        //腾讯地图
        if UIApplication.shared.canOpenURL(URL(string: MapForm.MapURI.qqMap.rawValue)!) {
            var qqDic = [String: String]()
            qqDic["title"] = MapForm.MapName.qqMap.rawValue
            let urlString = MapInfo.qqDuUrlString(targetLat: targetLat, targetLon: targetLong, targetName: targetName)
            let escapedString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            qqDic["url"] = escapedString
            maps.append(qqDic)
        }
        if maps.count == 0 {
            return
        }
        let alertVC = UIAlertController.init(title: "请选择导航应用程序", message: nil, preferredStyle: .actionSheet)
        for i in 0..<maps.count {
            let title = maps[i]["title"]
            let action = UIAlertAction(title: title, style: .default) { (_) in
                if i == 0 {
                    let loc = CLLocationCoordinate2DMake(targetLat, targetLong)
                    let currentLocation = MKMapItem.forCurrentLocation()
                    let toLocation = MKMapItem(placemark: MKPlacemark(coordinate: loc, addressDictionary: nil))
                    toLocation.name = targetName
                    MKMapItem.openMaps(with: [currentLocation, toLocation], launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving, MKLaunchOptionsShowsTrafficKey: true])
                } else {
                    let urlString = maps[i]["url"]! as NSString
                    let url = NSURL(string: urlString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!)
                    UIApplication.shared.openURL(url! as URL)
                }
            }
            alertVC.addAction(action)
        }
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        alertVC.addAction(cancelAction)
        VC.present(alertVC, animated: true, completion: nil)
    }
}

class CODMapTool: NSObject {

}
