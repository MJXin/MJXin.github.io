//
//  ShareItem.swift
//  Hover Album
//
//  Created by Ma Jiaxin on 16/10/31.
//  Copyright © 2016年 Hangzhou Zero Zero Technology Co., Ltd. All rights reserved.
//

import UIKit
import Social

// 分享平台
public enum SharePlatformType: Int {
    case facebook
    case instagram
    case youtube
    case twitter
    case wechat
    case moments
    case weibo
    case system
    
    var name: String {
        switch self {
        case .facebook:
            return "Facebook"
        case .instagram:
            return "Instagram"
        case .youtube:
            return "Youtube"
        case .twitter:
            return "Twitter"
        case .wechat:
            return "Wechat Conversation"
        case .moments:
            return "Wechat Moments"
        case .weibo:
            return "Weibo"
        case .system:
            return "System"
        }
    }
}
// 分享平台URLSchemes
enum SharePlatformURLScheme: String {
    case facebook = "fb://"
    case instagram = "instagram://"
    case youtube = "youtube://"
    case twitter = "twitter://"
    case wechat = "weixin://"
    case weibo = "sinaweibo://"
}
// 分享内容
public enum ShareContentType: Int {
    case video
    case image
    case url
}
// 分享方式
public enum ShareMode: Int {
    case system
    case urlSchemes
    case custom
    case none
}
// 上传方式
public enum UploadMode: Int {
    case none
    case aliOSS
    case custom
}
// tag格式
public enum HashTagType: Int {
    case US
    case CN
}

public typealias OAuthComplete =  (ShareError?) -> Void
public typealias ShareComplete =  (ShareError?) -> Void
public typealias UploadComplete =  (ShareError?) -> Void

// MARK: - ShareItemProtocol

public protocol ShareItem: class {
    var platform: SharePlatformType { get }
    var icon: UIImage { get }
    var name: String { get }
    var shareMode: ShareMode { get }
    var contentType: ShareContentType { get }
    // 研究一下getonly为何在extension中不可用
    var shareController: UIViewController? { get set }
    
    init(icon: UIImage, name: String, contentType: ShareContentType)
    
    // MARK: - CanShare
    
    func isCanShare() -> Bool
    
    func canUseCustomShare() -> Bool
    
    // MARK: - Author
    
    func oAuth(complete: @escaping (ShareError?) -> Void)
    
    // MARK: - Share
    
    func share(
        fromController controller: UIViewController,
        params: ShareParameter,
        complete: @escaping ShareComplete)
    
    func openAppliaction(from controller: UIViewController, with params: ShareParameter?)
    
    func customShare(
        fromController controller: UIViewController,
        params: ShareParameter,
        complete: @escaping (ShareError?) -> Void)
    
    // MARK: - Other
    
    static func creatHashtap(hashtap: String, type: HashTagType) -> String
    
}

// MARK: - ShareItem Extension

extension ShareItem {
    // 研究一下静态构建方法为何不能调用
    static func getUrlScheme(sharePlatFormType: SharePlatformType) -> SharePlatformURLScheme? {
        switch sharePlatFormType {
        case .facebook:
            return .facebook
        case .twitter:
            return .twitter
        case .instagram:
            return .instagram
        case .youtube:
            return .youtube
        case .weibo:
            return .weibo
        case .wechat:
            return .wechat
        case .moments:
            return .wechat
        default:
            return nil
        }
    }
    
    // MARK: - CanShare
    
    func isCanShare() -> Bool {
        switch shareMode {
        case .system:
            shareController = getSystemComposeViewController()
            return shareController != nil ? true: false
        case .urlSchemes:
            return canOpenUrlScheme() ? true : false
        case .custom:
            return canUseCustomShare()
        case .none:
            return false
        }
    }
    
    final func urlScheme() -> SharePlatformURLScheme? {
        return Self.getUrlScheme(sharePlatFormType: platform)
    }
    
    final func getSystemComposeViewController() -> SLComposeViewController? {
        let serviceType: String?
        switch platform {
        case .facebook:
            serviceType = SLServiceTypeFacebook
        case .twitter:
            serviceType = SLServiceTypeTwitter
        case .weibo:
            serviceType = SLServiceTypeSinaWeibo
        default:
            serviceType = nil
            return nil
        }
        return SLComposeViewController.init(forServiceType: serviceType)
    }
    
    final func canOpenUrlScheme() -> Bool {
        if let urlScheme = urlScheme() {
            return  UIApplication.canOpen(scheme: urlScheme)
        } else {
            return false
        }
    }
    
    func canUseCustomShare() -> Bool {
        logger.warning("此方法需要子类重写")
        return false
    }
    
    // MARK: - Author
    
    func oAuth(complete: @escaping (ShareError?) -> Void) {
        complete(nil)
    }
    
    // MARK: - Share
    
    final func share(
        fromController controller: UIViewController,
        params: ShareParameter,
        complete: @escaping (ShareError?) -> Void) {
        switch shareMode {
        case .system:
            self.systemShare(fromController: controller, params: params, complete: complete)
        case .urlSchemes:
            self.openAppliaction(from: controller, with: params)
        case .custom:
            self.customShare(fromController: controller, params: params, complete: complete)
        case .none:
            complete(ShareError.init(withErrorCode: ShareErrorCode.shareFail.rawValue, errorMessage: nil))
        }
    }
    
    final func systemShare(
        fromController controller: UIViewController,
        params: ShareParameter,
        complete: @escaping (ShareError?) -> Void) {
        if let composeController = (shareController as? SLComposeViewController) {
            switch contentType {
            case .video:
                composeController.add(params.shareAsset?.remoteURL)
                if platform == .weibo || platform == .twitter || platform == .facebook {
                    composeController.add(params.shareAsset?.preview)
                }
            case .image:
                composeController.add(params.shareAsset?.photo)
            case .url:
                composeController.add(params.shareAsset?.remoteURL)
                if platform == .weibo || platform == .twitter || platform == .facebook {
                    composeController.add(params.shareAsset?.preview)
                }
            }
            let appendInfo = (platform == .weibo) ? (params.description ?? "") : ""
            composeController.setInitialText(appendInfo + (params.hashTag ?? "") + "\n")
            composeController.completionHandler = { result in
                if result == .cancelled {
                    complete(ShareError.init(withErrorCode: ShareErrorCode.shareCancel.rawValue, errorMessage: nil))
                } else {
                    complete(nil)
                }
            }
            DispatchQueue.main.async {
                controller.present(composeController, animated: true)
            }
        } else {
            logger.warning(" 无法分享 并且未调用 isCanShare 进行判断")
            complete(ShareError.init(withPlatformError: self.platform))
        }
    }
    
    func openAppliaction(from controller: UIViewController, with params: ShareParameter?) {
        logger.warning("此方法需要子类重写")
        if canOpenUrlScheme() {
            if let url = URL.init(string: (urlScheme()?.rawValue)!) {
             UIApplication.open(url: url, completion: nil)
            }
        }
    }
    
    func customShare(
        fromController controller: UIViewController,
        params: ShareParameter,
        complete: @escaping (ShareError?) -> Void) {
        logger.warning("此方法需要子类重写")
        return
    }
    
    // MARK: - Other
    
    static func creatHashtap(hashtap: String, type: HashTagType) -> String {
        switch type {
        case .CN:
            return "#" + hashtap + "# "
        case .US:
            return "#" + hashtap + " "
        }
    }
}

// MARK: - ShareUploadProgressControllerProtocol

public protocol ShareUploadProgressController {
    var cancel: (() -> Void)? { get set }
    func show(fromController controller: UIViewController)
    func updateProgress(withProgress progress: Double)
    func dismiss()
}

// MARK: - ShareVideoProtocol

public protocol ShareProtocol: ShareItem {
    var uploadMode: UploadMode { get }
    var uploadCancel: Bool { get set }
    var progressVC: ShareUploadProgressController? { get set }
    
    func shareVideo(
        fromController controller: UIViewController,
        params: ShareParameter,
        complete: @escaping (ShareError?) -> Void)
    
    func customUploadVideo(fromController controller: UIViewController,
                           params: ShareParameter,
                           complete: @escaping (ShareError?, URL?) -> Void)
}

// MARK: - ShareVideoProtocol Extension

extension ShareProtocol {
    
    // MARK: - ShareVideo
    
    func shareVideo(
        fromController controller: UIViewController,
        params: ShareParameter,
        complete: @escaping (ShareError?) -> Void) {
        guard params.shareAsset != nil else {
            logger.error("ShareParameter 不存在 videoAsset")
            return
        }
        switch uploadMode {
        case .aliOSS:
            uploadVideoToAliOOS(
                fromController: controller,
                videoAsset: params.shareAsset!,
                complete: { error, remoteUrl in
                guard error == nil else {
                    complete(error)
                    return
                }
                params.shareAsset?.remoteURL = remoteUrl
                self.share(fromController: controller, params: params, complete: complete)
            })
        case .custom:
            customUploadVideo(fromController: controller, params: params) { error, remoteURL in
                guard error == nil else {
                    complete(error)
                    return
                }
                params.shareAsset?.remoteURL = remoteURL
                self.share(fromController: controller, params: params, complete: complete)
            }
        case .none:
             self.share(fromController: controller, params: params, complete: complete)
        }
    }
    
    // MARK: - Upload Video
    // swiftlint:disable function_body_length
    final func uploadVideoToAliOOS(
        fromController controller: UIViewController,
        videoAsset: ShareAsset,
        complete: @escaping (ShareError?, URL?) -> Void) {
        let networkManager = ShareNetworkManager.share()
        guard videoAsset.remoteURL == nil else {
            complete(nil, videoAsset.remoteURL)
            return
        }
        uploadCancel = false
        progressVC?.cancel = { self.uploadCancel = true }
        DispatchQueue.main.async { self.progressVC?.show(fromController: controller) }
        // 获取阿里云凭证
        networkManager.getCredential(
            withDeviceId: (UIDevice.current.identifierForVendor?.uuidString)!,
            complete: { error, credential in
                guard self.uploadCancel != true else { return }
                guard let credential = credential , error == nil else {
                    self.progressVC?.dismiss()
                    complete(error, nil)
                    return
                }
                // 上传预览图
                networkManager.uploadVideoPreviewToOOS(
                    preview: videoAsset.preview, cid: credential,
                    complete: { error in
                    guard self.uploadCancel != true else { return }
                    guard error == nil else { return }
                    
                })
                let putVideoToOOS: (Data)->() = { [unowned self] data in
                    // 上传视频
                    let request = networkManager.putVideoToOSS(
                        withAssetData: data,
                        assetCrediential:  credential,
                        complete: { [unowned self] error, finish, progress in
                            guard self.uploadCancel != true else { return }
                            guard error == nil else {
                                self.progressVC?.dismiss()
                                complete(error, nil)
                                return
                            }
                            if !finish {
                                DispatchQueue.main.async { self.progressVC?.updateProgress(withProgress: progress) }
                            } else {
                                // 获取视频地址
                                networkManager.getVideoRemoteURL(
                                    withDeviceId: (UIDevice.current.identifierForVendor?.uuidString)!,
                                    credential: credential,
                                    complete: { error, remoteUrl in
                                        self.progressVC?.dismiss()
                                        guard self.uploadCancel != true else {
                                            return
                                        }
                                        guard error == nil else {
                                            complete(error, nil)
                                            return
                                        }
                                        complete(nil, remoteUrl)
                                })
                            }
                    })
                    self.progressVC?.cancel = {
                        request.cancel()
                        self.uploadCancel = true
                    }
                }
                
                if let data = videoAsset.data {
                    putVideoToOOS(data)
                } else {
                    videoAsset.fetchVideoData(completion: { [unowned videoAsset] in
                        guard let data = videoAsset.data else {
                            return
                        }
                        putVideoToOOS(data)
                    })
                }

        })
    }
    
    func customUploadVideo(fromController controller: UIViewController,
                           params: ShareParameter,
                           complete: @escaping (ShareError?, URL?) -> Void) {
        logger.warning("此方法需要子类重写")
        return
    }
}
