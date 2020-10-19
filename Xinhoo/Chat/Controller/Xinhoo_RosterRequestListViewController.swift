//
//  Xinhoo_RosterRequestListViewController.swift
//  COD
//
//  Created by xinhooo on 2020/3/12.
//  Copyright © 2020 XinHoo. All rights reserved.
//

import UIKit
import Contacts
import RxSwift
import RxCocoa
import Lottie

extension Reactive where Base : Xinhoo_RosterRequestListViewController{
    var deleteModel: Binder<RosterRequestVM?> {
        return Binder(base) { (vc, vm) in
            if let vm = vm {
                if let index = vc.unReadDataArr.firstIndex(of: vm) {
                    vc.unReadDataArr.remove(at: index)
                    vc.dataArr.remove(at: 0)
                    vc.dataArr.insert(vc.unReadDataArr, at: 1)
                    vc.listView.reloadData()
                }
                
                if let index = vc.readDataArr.firstIndex(of: vm) {
                    vc.readDataArr.remove(at: index)
                    vc.dataArr.remove(at: 2)
                    vc.dataArr.append(vc.readDataArr)
                    vc.listView.reloadData()
                }
                
                vc.isShowEmptyView()
            }
            
        }
    }
}

class Xinhoo_RosterRequestListViewController: BaseViewController {

    @IBOutlet weak var listView: UITableView!
    
    var emptyView: UIView!
    
    var chatListModel:CODChatListModel?
    
    var unReadDataArr:Array<RosterRequestVM> = Array()
    var readDataArr:Array<RosterRequestVM> = Array()
    var dataArr:Array<Array<RosterRequestVM>> = Array()
    
    var unRead = 0
    
    fileprivate lazy var searchCtl: UISearchController = {
        let searchCtl = UISearchController(searchResultsController: nil)
        searchCtl.searchBar.placeholder = "搜索联系人"
        searchCtl.searchResultsUpdater = self
        searchCtl.dimsBackgroundDuringPresentation = false
        searchCtl.hidesNavigationBarDuringPresentation = false
        searchCtl.searchBar.backgroundImage = UIImage()

        searchCtl.searchBar.customTextField?.backgroundColor = UIColor(hexString: kSearchBarTextFieldBackGdColorS)
//        searchCtl.definesPresentationContext = true
//        self.definesPresentationContext = true
        let searchBarTF = searchCtl.searchBar.customTextField
        searchBarTF?.font = UIFont.systemFont(ofSize: 14)

        return searchCtl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.navigationItem.title = NSLocalizedString("新的朋友", comment: "")
        self.setBackButton()
        self.setRightButton()
        self.rightButton.setImage(UIImage(named: "add_friend_nav_btn"), for: UIControl.State.normal)
        
        self.configView()
        self.createEmptyView()
        self.getData()
    }
    
    func configView() {
        self.listView.register(UINib.init(nibName: "Xinhoo_RosterRequestTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "Xinhoo_RosterRequestTableViewCell")
        self.listView.register(UINib.init(nibName: "CODNewFriendsFunctionCell", bundle: Bundle.main), forCellReuseIdentifier: "CODNewFriendsFunctionCell")
        self.listView.tableFooterView = UIView()
//        self.listView.tableHeaderView = self.searchCtl.searchBar
    }
    
    func getData() {
        
        CODAddFriendRealmTool.readAllAddFriend()
        
        HttpManager.share.post(url: HttpConfig.COD_getRosterRequestList,
                               param: ["username":UserManager.sharedInstance.loginName as Any,
                                       "pageNum":"1",
                                       "rowsPerPage":"200"],successBlock: { (dictionary, json) in
                                        
                                        if let xhRosterRequestList = dictionary["xhRosterRequestList"] as? Array<NSDictionary>{
                                            print(xhRosterRequestList)
                                            var i = 0
                                            for requestVO in xhRosterRequestList {
                                                if let requestModel = RosterRequestModel.deserialize(from: requestVO) {
                                                    
                                                    requestModel.senderNickName = requestModel.senderNickName.aes128DecryptECB(key: .nickName)
                                                    
                                                    let requestVM = RosterRequestVM(model: requestModel)
                                                    requestVM.deleteModel.bind(to: self.rx.deleteModel)
                                                        .disposed(by: self.rx.disposeBag)
                                                    if i < self.unRead {
                                                        self.unReadDataArr.append(requestVM)
                                                    }else{
                                                        self.readDataArr.append(requestVM)
                                                    }
                                                    i += 1
                                                }
                                            }
                                            self.unReadDataArr.sort(by: \.requestTime, ascending: false)
                                            self.readDataArr.sort(by: \.requestTime, ascending: false)
                                            
                                            self.dataArr.append([RosterRequestVM()])
                                            self.dataArr.append(self.unReadDataArr)
                                            self.dataArr.append(self.readDataArr)
                                            self.isShowEmptyView()
                                            self.listView.reloadData()
                                            
                                            XMPPManager.shareXMPPManager.setRequest(param: ["name":"readrosterrequest","requester":UserManager.sharedInstance.jid], xmlns: COD_com_xinhoo_roster) { (result) in
                                                
                                                switch result {
                                                case .success(_):
                                                    UserManager.sharedInstance.haveNewFriend = 0
                                                    NotificationCenter.default.post(name: NSNotification.Name.init(kReloadChatListNoti), object: nil)
                                                    NotificationCenter.default.post(name: NSNotification.Name.init(kReloadRedPoint), object: nil, userInfo:nil)
                                                    break
                                                default:
                                                    break
                                                }
                                            }
                                            
                                        }
        }){ (error) in
            print(error)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.searchCtl.isActive = false
        self.searchCtl.dismiss(animated: true, completion: nil)
    }
    
    override func navRightClick() {
        let ctl = AddFriendViewController()
        self.navigationController?.pushViewController(ctl, animated: true)
    }
    
    func isShowEmptyView() {
        if self.unReadDataArr.count <= 0 && self.readDataArr.count <= 0 {
            self.emptyView.isHidden = false
        }else{
            self.emptyView.isHidden = true
        }
    }
    
    func createEmptyView() {
        emptyView = UIView.init(frame: CGRect.zero)
        emptyView.isHidden = true
        emptyView.backgroundColor = UIColor(hexString: kVCBgColorS)
        let lottieView = AnimationView.init()
        let animation = Animation.filepath(Bundle.main.path(forResource: "404", ofType: "json")!, animationCache: nil)
        lottieView.animation = animation
        lottieView.loopMode = .loop
        lottieView.play()
        emptyView.addSubview(lottieView)
        lottieView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.size.equalTo(CGSize.init(width: 55, height: 65))
            make.centerX.equalToSuperview()
        }
        
        let lab = UILabel.init(frame: .zero)
        lab.text = "暂无添加请求"
        lab.font = UIFont.systemFont(ofSize: 13)
        lab.textColor = UIColor.init(hexString: kEmptyTitleColorS)
        emptyView.addSubview(lab)
        lab.snp.makeConstraints { (make) in
            make.top.equalTo(lottieView.snp.bottom).offset(5)
            make.centerX.equalToSuperview()
        }
        
        self.view.addSubview(emptyView)
        self.emptyView.bringSubviewToFront(self.listView)
        emptyView.snp.makeConstraints { (make) in
            make.width.equalTo(150)
            make.height.equalTo(100)
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-50)
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension Xinhoo_RosterRequestListViewController:UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            return 1
        }else if section == 1{
            return unReadDataArr.count
        }else{
            return readDataArr.count
        }
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell:CODNewFriendsFunctionCell = tableView.dequeueReusableCell(withIdentifier: "CODNewFriendsFunctionCell") as! CODNewFriendsFunctionCell
            return cell
        }else{
            let model = dataArr[indexPath.section][indexPath.row]
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "Xinhoo_RosterRequestTableViewCell", for: indexPath) as! Xinhoo_RosterRequestTableViewCell
            cell.configModel(modelVM: model, models: dataArr[indexPath.section], indexPath: indexPath)
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            tableView.deselectRow(at: indexPath, animated: true)
            self.contacts()
        }else{
            let model = dataArr[indexPath.section][indexPath.row]
            self.pushToDetailVC(model: model)
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let lab = UILabel()
        lab.font = UIFont.systemFont(ofSize: 14)
        lab.textColor = UIColor(hexString: kSubTitleColors8E8E92)
        lab.backgroundColor = UIColor(hexString: kVCBgColorS)

        var text = ""
        if section == 0 {
            text = ""
        }else if section == 1{
            text = unReadDataArr.count > 0 ? "   最新" : ""
        }else{
            text = readDataArr.count > 0 ? "   已读" : ""
        }
        lab.text = text
        
        return lab
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if section == 0 {
            return 10
        }else if section == 1{
            return unReadDataArr.count > 0 ? 28 : 0.01
        }else{
            return 28
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 0 {
            return false
        }else{
            return true
        }
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let model = dataArr[indexPath.section][indexPath.row]
            model.updateStatus(status: 3)
        }
    }
    
    
    
    

    
    //创建通讯录
    func contacts(){
        //创建通讯录
        let store = CNContactStore.init();
        //获取授权状态
        let AuthStatus = CNContactStore.authorizationStatus(for: CNEntityType.contacts);
        
        //没有授权
        if AuthStatus == CNAuthorizationStatus.notDetermined{
            //用户授权
            store.requestAccess(for: CNEntityType.contacts, completionHandler: { (isLgranted, error) in
                if isLgranted == true{
                    print("授权成功");
                    DispatchQueue.main.sync {
                        self.navigationController?.pushViewController(CODChooseMobileContactsVC())
                    }
                }else{
                    print("授权失败");
                }
            });
            
        }else if (AuthStatus == .authorized){
            self.navigationController?.pushViewController(CODChooseMobileContactsVC())
        }else{
            let alert = UIAlertController.init(title: CustomUtil.formatterStringWithAppName(str: "您没有授权%@访问通讯录的权限"), message: CustomUtil.formatterStringWithAppName(str: "如果您想使用此功能，需要您在设置中允许%@访问通讯录！"), preferredStyle: .alert)
            let confirmAction = UIAlertAction.init(title: "知道了", style: .default) { (action) in
                
            }
            alert.addAction(confirmAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    // 点击跳转详情
    func pushToDetailVC(model: RosterRequestVM){

        if let contact = CODContactRealmTool.getContactByJID(by: model.sender){
            
            if contact.isValid {
    
                CustomUtil.pushToPersonVC(contactModel: contact)
                
            }else{
                CustomUtil.pushToStrangerVC(type: .searchType, contactModel: contact)
            }
            
        }else{
            let personVC = CODStrangerDetailVC()
            personVC.name = model.senderNickName
            personVC.userDesc = model.senderNickName
            personVC.userPic = model.senderPic
            personVC.userName = model.sender
            personVC.jid = model.sender
            personVC.type = .searchType
            self.navigationController?.pushViewController(personVC)
        }
    }
}

extension Xinhoo_RosterRequestListViewController:UISearchResultsUpdating,UISearchControllerDelegate,UISearchBarDelegate{
    func updateSearchResults(for searchController: UISearchController) {
        
    }
    
    
}
