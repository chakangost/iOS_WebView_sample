import UIKit
import SwiftUI
import Combine
import WebKit
import Foundation

class Coordinator : NSObject, WKNavigationDelegate {
    var parent: WebView
    var foo: AnyCancellable? = nil
    
    init(_ uiWebView: WebView) {
        self.parent = uiWebView
    }
    
    deinit {
        foo?.cancel()
    }
    
    func webView(_ webView: WKWebView,
                 decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy)) -> Void {
        if let host = navigationAction.request.url?.host {
            if host != "velog.io" {
                return decisionHandler(.cancel)
            }
        }
        
        parent.viewModel.bar.send(false)
        self.foo = self.parent.viewModel.foo.receive(on: RunLoop.main).sink(receiveValue: {
            value in print(value)
        })
        
        return decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView,
                 didStartProvisionalNavigation navigation: WKNavigation!) {
        print("기본 프레임에서 탐색이 시작되었음")
    }
    
    func webView(_ webview: WKWebView,
                 didCommit navigation: WKNavigation!) {
        print("내용을 수신하기 시작")
    }
    
    func webView(_ webview: WKWebView,
                 didFinish: WKNavigation!) {
        print("탐색이 완료")
    }
    
    func webView(_ webView: WKWebView,
                 didFailProvisionalNavigation: WKNavigation!) {
        print("초기 탐색 프로세스 중에 오류가 발생했음")
    }
    
    func webView(_ webView: WKWebView,
                 didFail navigation: WKNavigation!,
                 withError error: Error) {
        print("탐색 중에 오류가 발행했음")
    }
}
