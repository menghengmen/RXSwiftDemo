#  RXSwift结合MVVM组件化小项目
##  详解 （以登录界面为例）
```objc
/// 登录页VM  把VC里面的一些控件以及点击事件等于VM绑定
class LoginVM: BaseVM {
    
    // to view
    /// 是否可以关闭
    let isShowCloseBtn = Variable<Bool>(false)
    ///手机号输入
    let phoneInput = Variable<String>("")
    /// 勾选隐私协议
    let isCheckPrivacy = Variable<Bool>(true)
    
    // from view
    /// 点击关闭
    let clickCloseBtn = PublishSubject<Void>()
    ///点击下一步
    let clickNextBtn = PublishSubject<Void>()
    ///点击管理员登录
    let clickAdminLoginBtn = PublishSubject<Void>()
    /// 点击勾选按钮
    let clickCheckBtn = PublishSubject<Void>()
    /// 点击隐私链接
    let clickPrivacyLink = PublishSubject<Void>()
    
    init(isShowClose: Bool) {
        super.init()
        
        /// 是否可以关闭
        isShowCloseBtn.value = isShowClose
        
        /// 点击关闭页面
        clickCloseBtn.asObservable()
            .map { (_) -> RouterInfo in
                return (Router.Login.close, nil)
            }
            .bind(to: openRouter)
            .disposed(by: disposeBag)
        /// 点击管理员登录
        clickAdminLoginBtn.asObservable()
            .map { (_) -> RouterInfo in
                return(Router.Login.adminLogin, nil)
            }
            .bind(to: openRouter)
            .disposed(by: disposeBag)
        
        /// 点击下一步
        let inputCheckResult = clickNextBtn.asObservable()
            .map { [weak self] (_) -> String? in
                self?.checkInput()
            }
            .share(replay: 1, scope: .whileConnected)
        
        // -- 输入合法
        inputCheckResult
            .filter { $0 == nil }
            .flatMapLatest { [weak self] (_) -> Observable<ReqCheckUserExists.Model> in
                return self?.requestUserExists(phoneNumber: self?.phoneInput.value ?? "") ?? .empty()
            }
            .map({[weak self] (register) -> RouterInfo in
                if  register.data ?? false {
                     return (Router.Login.verifyCode, ["tel":self!.phoneInput.value ,"registered":true])

                } else {
                    return (Router.Login.verifyCode, ["tel":self!.phoneInput.value,"registered":false ])

                }
            })
            .bind(to: openRouter)
            .disposed(by: disposeBag)
        
        
        // -- 输入不合法
        inputCheckResult
            .filter { $0 != nil }
            .map { AlertMessage(message: $0, alertType: .toast) }
            .bind(to: showMessage)
            .disposed(by: disposeBag)
        
        
        /// 用户协议
        clickCheckBtn.asObservable()
            .map { [weak self] (_) -> Bool in
                return !(self?.isCheckPrivacy.value ?? false)
            }
            .bind(to: isCheckPrivacy)
            .disposed(by: disposeBag)
        
        /// 点击用户协议跳转
        clickPrivacyLink.asObservable()
            .map { return RouterInfo(Router.Login.goPrivacyPolicy,nil) }
            .bind(to: openRouter)
            .disposed(by: disposeBag)
        
        
    }
    
```


```objc
/// 管理员登录页VC
class AdminLoginVC: BaseVC {
    
    // IBOutlet
    @IBOutlet private weak var titleLbl: UILabel!
    @IBOutlet private weak var subtitleLbl: UILabel!
    @IBOutlet private weak var usernameTxf: UITextField!
    @IBOutlet private weak var passwordTxf: UITextField!
    @IBOutlet private weak var loginBtn: UIButton!
    
    override func viewSetup() {
        super.viewSetup()
        navBarStyle = .translucent
        
    }
    
    /// 以下是相关的绑定操作
    override func viewBindViewModel() {
        super.viewBindViewModel()
        if let vm = viewModel as? AdminLoginVM{
            usernameTxf.rx.text.orEmpty
                .asObservable()
                .bind(to: vm.accountInput)
                .disposed(by: disposeBag)
            
            passwordTxf.rx.text.orEmpty
                .asObservable()
                .bind(to: vm.passwordInput)
                .disposed(by: disposeBag)
            
            vm.isEnabelClickNext.asDriver()
                .drive(loginBtn.rx.isEnabled)
                .disposed(by: disposeBag)
            
            loginBtn.rx.tap.asObservable()
                .bind(to: vm.clickNextBtn)
                .disposed(by: disposeBag)
            
            
        }
        
    }
    
}
```
