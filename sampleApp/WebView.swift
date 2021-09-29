import UIKit
import SwiftUI
import Combine
import WebKit

struct WebView: UIViewRepresentable {
    let webView: WKWebView
    let request: URLRequest
    
    // 아래의 3가지 변수는 위에서 선언한 변수 3가지와 동일
    @Binding var showAlert: Bool
    @Binding var alertMessage: String
    @Binding var confirmHandler: (Bool) -> Void

    // Coodinator를 이용하여 alert, confirm, 그 외에 링크 이벤트를 처리한다
    class Coodinator: NSObject, WKUIDelegate, WKNavigationDelegate {

        var parent: WebView
        
        // 역시 맨 위에서 선언한 3가지 변수이다. 이 작업은 맨 처음 선언한 변수들은 해당 클레스에서 사용할수 있도록 연결시켜주는 작업이다
        var showAlert: Binding<Bool>
        var alertMessage: Binding<String>
        var confirmHandler: Binding<(Bool) -> Void>

        init(_ parent: WebView, showAlert: Binding<Bool>, alertMessage: Binding<String>, confirmHandler: Binding<(Bool) -> Void>) {
            self.parent = parent
            self.showAlert = showAlert
            self.alertMessage = alertMessage
            self.confirmHandler = confirmHandler
        }

        // 웹 사이트에서 alert이나 confirm이 발생하면 해당 함수가 실행되어 세부 내용을 맨 처음 선언한 alertMessage와 showAlert, confirmHandler에 할당한다. confirmHandler는 사용자가 confirm창에서 "예/아니오"를 선택했을 경우에 대해 처리하는 핸들러이다.
        func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
            self.alertMessage.wrappedValue = message
            self.showAlert.wrappedValue.toggle()
            completionHandler()
        }

        func webView(_ webView: WKWebView,
                     runJavaScriptConfirmPanelWithMessage message: String,
                     initiatedByFrame frame: WKFrameInfo,
                     completionHandler: @escaping (Bool) -> Void) {
            self.alertMessage.wrappedValue = message
            self.showAlert.wrappedValue.toggle()
            
            self.confirmHandler.wrappedValue = completionHandler
        }

        // 이 작업은 이메일 링크나 전화번호를 눌렀을때 작동하는 함수이다. 해당 함수를 구현하지 않으면 해당 링크에 반응하지 않는다.
        func webView(_ webView: WKWebView,
                     decidePolicyFor navigationAction: WKNavigationAction,
                     decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            
            if navigationAction.targetFrame == nil {
                webView.load(navigationAction.request)
            }
            
            if navigationAction.request.url?.scheme == "tel" {
                UIApplication.shared.open(navigationAction.request.url!, options: [:], completionHandler: nil)
                decisionHandler(.cancel)
            } else if navigationAction.request.url?.scheme == "mailto" {
                UIApplication.shared.open(navigationAction.request.url!, options: [:], completionHandler: nil)
                decisionHandler(.cancel)
            } else {
                decisionHandler(.allow)
            }
        }
    }

    func makeCoordinator() -> Coodinator {
        return Coodinator(self, showAlert: self.$showAlert, alertMessage: self.$alertMessage, confirmHandler: self.$confirmHandler)
    }
    
    // 뷰를 생성할때 위에서 선언한 클래스를 할당한다.
    func makeUIView(context: UIViewRepresentableContext<WebView>) -> WKWebView {
        webView.uiDelegate = context.coordinator
        webView.navigationDelegate = context.coordinator
        
        // 뒤로가기 제스쳐 사용 여부
        webView.allowsBackForwardNavigationGestures = true
        
        webView.load(request)
        
        return webView
    }

    // 만일, 해당 앱이 다른 앱이나 사파리, 크롬 등의 앱을 왔다 갔다 해야 한다면, 해당 부분을 주석처리 하지 않으면 앱이 켜질때마다 웹 뷰가 새로고침된다.
    func updateUIView(_ webView: WKWebView, context: UIViewRepresentableContext<WebView>) {
//        webView.uiDelegate = context.coordinator
//        webView.allowsBackForwardNavigationGestures = true
//        webView.load(request)
    }
    
    // 리다이렉트, 리로드, 뒤로가기, 앞으로가기를 사용하기 위한 함수
    func redirect(url: URL) {
        let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad)
        webView.load(request)
    }

    func reload() {
        webView.reload()
    }
    
    func goBack() {
        webView.goBack()
    }

    func goForward(){
        webView.goForward()
    }
}
