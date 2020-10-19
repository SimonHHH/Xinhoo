//
//  CODLoginedDeviceViewController.swift
//  COD
//
//  Created by 黄玺 on 2020/2/21.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import UIKit
import HandyJSON
import RxSwift
import RxCocoa

class CODLoginedDeviceViewController: BaseViewController {

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var emptyView: CODLoginedDeviceEmptyView!
    private var dataSource: Array = [[LoginedDeviceCellModel]]()
    
    private var deviceSource: Array = [CODLoginDeviceModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = NSLocalizedString("登录的设备", comment:"")
        self.initUI()
        self.getData()
        
    }
    
    func getData() {
        self.dataSource.removeAll()
        self.deviceSource.removeAll()
        let requestUrl = HttpConfig.loginDevices
        let dict = ["username":UserManager.sharedInstance.loginName!]
        HttpManager().post(url: requestUrl, param: dict, successBlock: {[weak self] (result, json) in
                                                        guard let self = self else {
                                                            return
                                                        }
                                                        let isUpdate = result["isSuccess"] as! Bool
                                                        if isUpdate {
                                                            guard let dict = result as? Dictionary<String, Any> else {
                                                                return
                                                            }
                                                            guard let devices = dict["accountLoginRecord"] as? Array<Dictionary<String, Any>> else {
                                                                return
                                                            }
                                                            for device in devices {
                                                                if let deviceModel = CODLoginDeviceModel.deserialize(from: device) {
                                                                    self.deviceSource.append(deviceModel)
                                                                }
                                                            }
                                                            if self.deviceSource.count > 0 {
                                                                self.createData()
                                                            }
                                                            
                                                        }
        }) { (error) in
            switch error.code {
            case 10012:
                CODProgressHUD.showErrorWithStatus(NSLocalizedString(error.message, comment: ""))
            case 10004:
                CODProgressHUD.showErrorWithStatus(NSLocalizedString(error.message, comment: ""))
            default:
                CODProgressHUD.showErrorWithStatus(NSLocalizedString(error.message, comment: ""))
                break
            }
            
        }
    }
    
    func logout(deviceID: String, token: String, username: String, isSuccess: @escaping (Bool) -> ()) {
        let requestUrl = HttpConfig.logoutDevices
        HttpManager().post(url: requestUrl, param: ["token":token,
                                                    "username":username,
                                                    "deviceID":deviceID], successBlock: { (result, json) in
                                                        let isUpdate = result["isSuccess"] as! Bool
                                                        isSuccess(isUpdate)
        }) { (error) in
            switch error.code {
            case 10012:
                CODProgressHUD.showErrorWithStatus(NSLocalizedString(error.message, comment: ""))
            case 10004:
                CODProgressHUD.showErrorWithStatus(NSLocalizedString(error.message, comment: ""))
            default:
                CODProgressHUD.showErrorWithStatus(NSLocalizedString(error.message, comment: ""))
                break
            }
            isSuccess(false)
        }
    }
    
    
    func initUI() {
        self.setBackButton()
        self.setRightTextButton()
        self.rightTextButton.setTitle(NSLocalizedString("编辑", comment: ""), for: .normal)
        self.rightTextButton.setTitleColor(UIColor(hexString: kSubmitBtnBgColorS), for: .normal)
        
        self.tableView.register(nib: UINib.init(nibName: "CODLoginedDeviceTableViewCell", bundle: nil), withCellClass: CODLoginedDeviceTableViewCell.self)
    }
    
    func createData() {
        var othersDevices = [LoginedDeviceCellModel]()
        var onlineDevices = [LoginedDeviceCellModel]()
        var offlineDeviecs = [LoginedDeviceCellModel]()
        for device in self.deviceSource {
            let timeStr = TimeTool.getTimeStringAutoShort2(Date.init(timeIntervalSince1970:TimeInterval((device.changeDate)/1000)), mustIncludeTime: false, theOffSetMS: UserManager.sharedInstance.timeStamp)
            switch device.active {
            case 0,2:
                let model = self.createModel(title: getTitle(model: device), subTitle: timeStr, otherInfo: getOtherInfo(model: device), changeDate: "\(device.changeDate)", deviceId: device.deviceID, username: device.username, token: device.token, clientVersion: device.clientVersion, enableLogout: false, tip: "其他已注销设备")
                offlineDeviecs.append(model)
            case 1:
                if device.deviceID == DeviceInfo.uuidString {
                    let model = self.createModel(title: getTitle(model: device), subTitle: "在线", subTitleColor: UIColor(hexString: kSubmitBtnBgColorS)!, otherInfo: getOtherInfo(model: device), deviceId: device.deviceID, username: device.username, token: device.token, clientVersion: device.clientVersion, enableLogout: false, tip: "当前设备")
                    self.dataSource.insert([model], at: 0)
                }else{
                    var model = self.createModel(title: getTitle(model: device), subTitle: "在线", subTitleColor: UIColor(hexString: kSubmitBtnBgColorS)!, otherInfo: getOtherInfo(model: device), changeDate: "\(device.changeDate)", deviceId: device.deviceID, username: device.username, token: device.token, clientVersion: device.clientVersion, enableLogout: true, tip: "其他设备")
                    model.action.logouted = { [weak self] in
                        guard let self = self else { return }
                        self.logout(deviceID: model.deviceID, token: model.token, username: model.username) { (isSuccess) in
                            if isSuccess {
                                self.getData()
                            }
                        }
                    }
                    onlineDevices.append(model)
                }
            default:
                var model = self.createModel(title: getTitle(model: device), subTitle: timeStr, otherInfo: getOtherInfo(model: device), changeDate: "\(device.changeDate)", deviceId: device.deviceID, username: device.username, token: device.token, enableLogout: true, tip: "其他设备")
                model.action.logouted = { [weak self] in
                    guard let self = self else { return }
                    self.logout(deviceID: model.deviceID, token: model.token, username: model.username) { (isSuccess) in
                        if isSuccess {
                            self.getData()
                        }
                    }
                }
                othersDevices.append(model)
            }
        }
        
        othersDevices.sort { (cellModel1, cellModel2) -> Bool in
            let changeDate1: Int = Int(cellModel1.changeDate) ?? 0
            let changeDate2: Int = Int(cellModel2.changeDate) ?? 0
            return changeDate1 > changeDate2
        }
        /*
        if othersDevices.count > 1 {
            let model = self.createModel(title: "注销除本机外所有设备",titleColor: UIColor(hexString: "FF3B30")! , subTitle: "", placeholder: "", image: "", type: .baseType, isOn: false, tip: "除本设备之外，其他已登录的设备都会被注销。")
            self.dataSource[0].append(model)
        }*/
        if onlineDevices.count + othersDevices.count > 0 {
            self.dataSource.append(onlineDevices + othersDevices)
            self.rightTextButton.isHidden = false
        }else{
            self.rightTextButton.isHidden = true
        }
        
        offlineDeviecs.sort { (cellModel1, cellModel2) -> Bool in
            let changeDate1: Int = Int(cellModel1.changeDate) ?? 0
            let changeDate2: Int = Int(cellModel2.changeDate) ?? 0
            return changeDate1 > changeDate2
        }
        self.dataSource.append(offlineDeviecs)
        self.tableView.reloadData()
        
        if dataSource.count <= 1 {
            emptyView.isHidden = false
        }else{
            emptyView.isHidden = true
        }
        
    }
    
    func getTitle(model: CODLoginDeviceModel) -> String {
        return "\(model.description), \(model.devicePlatforms.subStringTo(string: ","))"
    }
    
    func getOtherInfo(model: CODLoginDeviceModel) -> String {
        return "\(kApp_Name) \(model.deviceResource) \(model.clientVersion)"
    }
    
    func createModel(title: String = "",
                     titleColor: UIColor = UIColor.black,
                     subTitle: String = "",
                     subTitleColor: UIColor = UIColor(hexString: kSectionHeaderTextColorS)!,
                     otherInfo: String = "",
                     changeDate: String = "",
                     deviceId: String = "",
                     username: String = "",
                     token: String = "",
                     clientVersion: String = "",
                     enableLogout: Bool = false,
                     tip: String = "") -> (LoginedDeviceCellModel) {
        var model = LoginedDeviceCellModel()
        model.title = NSLocalizedString(title, comment: "")
        model.titleColor = titleColor
        model.subTitle = NSLocalizedString(subTitle, comment: "")
        model.subTitleColor = subTitleColor
        model.otherInfo = otherInfo
        model.changeDate = changeDate
        model.tip = tip
        model.deviceID = deviceId
        model.username = username
        model.token = token
        model.clientVersion = clientVersion
        model.enableLogout = enableLogout
        return model
    }

    override func navRightTextClick() {
        tableView.isEditing = !tableView.isEditing
        if tableView.isEditing {
            self.rightTextButton.setTitle(NSLocalizedString("完成", comment: ""), for: .normal)
        }else{
            self.rightTextButton.setTitle(NSLocalizedString("编辑", comment: ""), for: .normal)
        }
    }
}

extension CODLoginedDeviceViewController: UITableViewDelegate, UITableViewDataSource, EmptyDataSetDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        if indexPath.section == 0 && indexPath.row == 1 {
//            self.dataSource[indexPath.section][indexPath.row].action.didSelected?()
//        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource[section].count
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        let model = dataSource[indexPath.section][indexPath.row]
        return model.enableLogout
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: CODLoginedDeviceTableViewCell = tableView.dequeueReusableCell(withIdentifier: "CODLoginedDeviceTableViewCell") as! CODLoginedDeviceTableViewCell
        let model = dataSource[indexPath.section][indexPath.row]
                
        if indexPath.row == 0 {
            cell.isTop = true
        }else{
            cell.isTop = false
        }
        if indexPath.row == self.dataSource[indexPath.section].count - 1 {
            cell.isLast = true
        }else{
            cell.isLast = false
        }
        cell.titleLab.text = model.title
        cell.titleLab.textColor = model.titleColor
        cell.subTitleLab.text = model.subTitle
        cell.subTitleLab.textColor = model.subTitleColor
        cell.timeWidth.constant = model.subTitle?.getLabelStringSize(lineSpacing: 0, fixedWidth: KScreenWidth).width ?? 0
        cell.otherLab.text = model.otherInfo
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let bgView = UIView.init(frame: CGRect(x: 0, y: 0, width: KScreenWidth, height: 56))
        bgView.backgroundColor = UIColor.clear
        let textLabel = UILabel.init()
        textLabel.textAlignment = NSTextAlignment.left
        textLabel.numberOfLines = 0
        textLabel.font = UIFont.systemFont(ofSize: 12)
        textLabel.textColor = UIColor(hexString: kSubTitleColors)
        
        bgView.addSubview(textLabel)
        textLabel.snp.makeConstraints { (make) in
            make.left.equalTo(21.0)
            make.bottom.equalTo(-6.0)
            make.right.equalTo(21.0)
        }
        
        if let model = dataSource[section].first {
            textLabel.text = model.tip
        }

        return bgView
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if dataSource[section].count > 1, let model = dataSource[section].last, section == 0 {
            let textString = model.tip
            let textFont = UIFont.systemFont(ofSize: 11)
            var sectionHeight: CGFloat = 0.01
            sectionHeight = self.getHeaderHeight(textString: textString, width: KScreenWidth - 30, textFont: textFont)
            let footerHeight = textString.getStringHeight(font: textFont, lineSpacing: 0, fixedWidth: KScreenWidth - 30)
            let textLabel = UILabel.init(frame: CGRect(x: 21, y: 7, width: KScreenWidth-30, height: footerHeight))
            textLabel.textAlignment = NSTextAlignment.left
            textLabel.font = textFont
            textLabel.numberOfLines = 0
            textLabel.textColor = UIColor(hexString: kSubTitleColors8E8E92)
            textLabel.text = textString
            
            let bgView = UIView.init(frame: CGRect(x: 0, y: 0, width: KScreenWidth, height: sectionHeight))
            bgView.backgroundColor = UIColor.clear
            bgView.addSubview(textLabel)
            
            return bgView
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 56.0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if dataSource[section].count > 1, let model = dataSource[section].last, section == 0{
            let textString = model.tip
            let textFont = UIFont.systemFont(ofSize: 12)
            return self.getHeaderHeight(textString: textString, width: KScreenWidth, textFont: textFont)+5
        }
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let model = dataSource[indexPath.section][indexPath.row]
        
        let deleteAction: UITableViewRowAction = UITableViewRowAction(style: .normal, title: "关闭") { (action, indexPath) in
            LPActionSheet.show(withTitle:nil, cancelButtonTitle: "取消", destructiveButtonTitle: nil, otherButtonTitles: ["注销此设备"]) { (actionSheet, index) in
                
                switch index{
                case 0:
                    break
                case 1:
                    model.action.logouted?()
                    break
                default:
                    break
                }
            }
        }
        deleteAction.backgroundColor = UIColor(hexString: "FF3B30")
        
        return [deleteAction]
    }
        
    
    func getHeaderHeight(textString: String, width: CGFloat, textFont:UIFont) -> CGFloat {
        var footerHeight = textString.getStringHeight(font: textFont, lineSpacing: 0, fixedWidth: width)
        if footerHeight < 20 {
            footerHeight = 34.0
        }else{
            footerHeight = 46.0
        }
        return footerHeight
    }
    
}

class CODLoginedDeviceEmptyView: UIView {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setUpView()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setUpView()
    }
    
    func setUpView() {
        self.backgroundColor = UIColor.clear
        self.addSubview(imageView)
        self.addSubview(label)
        
        let image = UIImage(named: "no_more_device")
        imageView.image = image
        imageView.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-(image!.size.height+25+24)/2)
        }
        label.snp.makeConstraints { (make) in
            make.centerX.equalTo(imageView)
            make.top.equalTo(imageView.snp.bottom).offset(25)
            make.height.equalTo(24)
        }
    }
    
    lazy var imageView: UIImageView = {
        let image = UIImageView()
        return image
    }()
    
    lazy var label: UILabel = {
        let lab = UILabel()
        lab.text = NSLocalizedString("无其他设备", comment: "")
        lab.textAlignment = .center
        lab.font = UIFont.systemFont(ofSize: 17.0)
        lab.textColor = UIColor(hexString: "6D6D72")
        return lab
    }()
    
}

class CODLoginDeviceModel: HandyJSON {
    required init() {}
    
    /// 状态 ： 0:已登出 1:在线 2:被踢 3:网络断开或离开 4:pc端离开
    var active: Int = 0
    
    /// 更新时间
    var changeDate: Int = 0
    
    /// 创建时间
    var createDate: Int = 0
    
    /// 设备描述
    var description: String = ""
    
    var deviceHost: String = ""
    
    /// 设备ID
    var deviceID: String = ""
    
    /// 设备平台版本
    var devicePlatforms: String = ""
    
    /// 语言
    var lang: String = ""
    
    var lastpushtime: Int = 0
    
    /// 登录资源(MOBILE/DESKTOP)
    var loginResource: String = ""
    
    /// 设备资源（iOS/Android/Desktop）
    var deviceResource: String = ""
    
    var clientVersion: String = ""
    
    var loginidx: Int = 0
    
    var pushQty: Int = 0
    
    var token: String = ""
    
    var username: String = ""
    
}

struct LoginedDeviceCellModel {
    struct RX {
        let subTitle: BehaviorRelay<String> = BehaviorRelay(value: "")
    }
    
    struct Action {
        var didSelected: (() -> ())? = nil
        var logouted: (() -> ())? = nil
    }

    var title: String?
    var titleColor: UIColor?
    var subTitle: String? {
        didSet {
            self.rx.subTitle.accept(self.subTitle ?? "")
        }
    }
    var subTitleColor: UIColor?
    var attributeSubTitle: NSAttributedString?
    var otherInfo:    String?

    var changeDate = ""
    
    var tip = ""
    var token = ""
    var deviceID = ""
    var username = ""
    var clientVersion = ""
    
    var enableLogout = false
    
    
    var action: Action = Action()
    var rx: RX = RX()
}
