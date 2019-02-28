//
//  MDSWebViewController.swift
//  MDSWebViewController
//
//  Created by Sven on 2019/2/28.
//

import WebKit
import SnapKit



public class MDSWebViewController: UIViewController {
    
    let kvo_title = "title"
    let kvo_estimatedProgress = "estimatedProgress"
    
    var webView = WKWebView.init()
    var progressView = UIProgressView()
    
    @objc public var urlString: String!
 
    @objc public init(urlStr: String!) {
        super.init(nibName: nil, bundle: nil)
        self.urlString = urlStr
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        webView.addObserver(self, forKeyPath: kvo_title, options: NSKeyValueObservingOptions.new, context: nil)
        webView.addObserver(self, forKeyPath: kvo_estimatedProgress, options: NSKeyValueObservingOptions.new, context: nil)
        
    }
    
    deinit {
        webView.removeObserver(self, forKeyPath: kvo_title)
        webView.removeObserver(self, forKeyPath: kvo_estimatedProgress)
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        print(urlString)
        self.view.addSubview(webView)
        webView.snp.makeConstraints { (make) in
            if #available(iOS 11.0, *) {
                make.top.equalTo(view.safeAreaLayoutGuide)
            } else {
                make.top.equalToSuperview()
            }
            make.left.right.bottom.equalToSuperview()
        }
        
        view.addSubview(progressView)
        progressView.progressTintColor = UIColor(red: 40/255.0, green: 180/255.0, blue: 40/255.0, alpha: 1.0)
        progressView.trackTintColor = UIColor.clear
        progressView.alpha = 0.0
        progressView.snp.makeConstraints { (make) in
            if #available(iOS 11.0, *) {
                make.top.equalTo(view.safeAreaLayoutGuide)
            } else {
                make.top.equalToSuperview()
            }
            make.left.right.equalToSuperview()
            make.height.equalTo(2)
        }

        webView.backgroundColor = .red
        webView.uiDelegate = self
        webView.navigationDelegate = self

        let request = URLRequest.init(url: URL.init(string: self.urlString as String)!)
        webView.load(request)

    }
    
    // KVO的监听代理
    override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if (object as! WKWebView) == webView {
            if keyPath == kvo_title {
                self.title = webView.title
            } else if keyPath == kvo_estimatedProgress {
                print("网页加载进度:\(webView.estimatedProgress)")
                self.progressView.alpha = 1.0
                self.progressView.setProgress(Float(webView.estimatedProgress), animated: true)
                if webView.estimatedProgress >= 1.0 {
                    UIView.animate(withDuration: 0.2, delay: 0.2, options: UIView.AnimationOptions.curveEaseOut, animations: {
                        self.progressView.alpha = 0.0
                    }, completion: { (finished) in
                        self.progressView.setProgress(0.0, animated: false)
                    })
                }
            } else {
                super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            }
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }

}

extension MDSWebViewController: WKUIDelegate,WKNavigationDelegate {
}
