//
//  ServerUrlTools.swift
//  COD
//
//  Created by Sim Tsai on 2020/9/28.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import Foundation


struct ServerUrlTools {
    
    enum ImageSize {
        case small
        case medium
        case origin
        
        var intValue: Int {
            
            switch self {
            case .small:
                return 1
            case .medium:
                return 2
            case .origin:
                return 3
            }
            
        }
        
        var string: String {
            switch self {
            case .small:
                return "Thumbnail"
            case .origin:
                return "Original"
            case .medium:
                return "Compress"
            }
        }
    }
    
    enum FileType {
        
        static var baseUrl: URL {
            return URL(string: WebServiveDomain1 + "/file/v1")!
        }
        
        
        case Image(_ id: String, _ size: ImageSize)
        case Video(_ id: String)
        case File(_ id: String)
        
        var pathComponent: String{
            
            switch self {
            case .Image(_, _):
                return "downloadImg"
            case .Video(_):
                return "downloadFile"
            case .File(_):
                return ""
            }
            
        }
        
        var id: String {
            switch self {
            case .Image(let id, _), .Video(let id), .File(let id):
                return id
            }
        }
        
        
        fileprivate var url: URL {
            
            switch self {
            case .Image(let id, let size):
                return FileType.baseUrl.appendingPathComponent(self.pathComponent).appendingQueryParameters(["attId": id, "imgType": size.intValue.string])
            case .Video(let id), .File(let id):
                return FileType.baseUrl.appendingPathComponent(self.pathComponent).appendingQueryParameters(["attId": id])
            }
            
        }
        
    }
    
    enum StoreType {
        case Message(fileType: FileType)
        case CloudDisk(fileType: FileType)
        case Moments(fileType: FileType)
        case HeadImage(id: String, imageSize: ImageSize)
        
        var baseUrl: URL {
            
            switch self {
            case .Moments(fileType: _):
                return URL(string: WebServiveDomain1 + "/file/v1")!
            default:
                return URL(string: HttpConfig.downLoadUrl)!
            }
            
        }
        
        var string: String {
            switch self {
            case .Message(fileType: _):
                return "MESSAGE"
            case .HeadImage(imageSize: _):
                return "HEADIMAGES"
            case .CloudDisk(fileType: _):
                return "CLOUDDISK"
            default:
                return ""
            }
        }
        
        var params: [String: String] {
            
            switch self {
            case .Message(fileType: _), .HeadImage(imageSize: _), .CloudDisk(fileType: _):
                return [
                    "storeType": self.string
                ]
            default:
                return [:]
            }
            
        }
        
    }
    
    static func getServerUrl(store: StoreType) -> URL {
        
        var url = store.baseUrl
        
        url = url.appendingQueryParameters(store.params)
        
        switch store {
        case .CloudDisk(fileType: let file), .Message(fileType: let file), .Moments(fileType: let file):
            url = url.appendingPathComponent(file.id)
            
            switch file {
            case .Image(_, let size):
                url = url.appendingQueryParameters([
                    "imgType": size.string
                ])
            default:
                break
            }
            
        case .HeadImage(id: let id, imageSize: let size):
            url = url.appendingPathComponent(id).appendingQueryParameters([
                "imgType": size.string
            ])
            
        default:
            break
        }
        
        return url
        
    }
    
    
    static func getMomentsServerUrl(fileType: FileType) -> String {
        return fileType.url.absoluteString
    }
    
}
