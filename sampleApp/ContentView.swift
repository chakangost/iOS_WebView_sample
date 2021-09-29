//
//  ContentView.swift
//  sampleApp
//
//  Created by freddie on 2021/09/29.
//

import SwiftUI
import WebKit

struct ContentView: View {
    
    let url = "https://www.naver.com"

    @State var showAlert: Bool = false
    @State var alertMessage: String = "error"
    
    // 웹뷰 확인/취소 작업을 처리하기 위한 핸드러를 받아오는 변수
    @State var confirmHandler: (Bool) -> Void = {_ in }
    
    var body: some View {
        WebView(webView: WKWebView(), request: URLRequest(url: URL(string: url)!), showAlert: self.$showAlert, alertMessage: self.$alertMessage, confirmHandler: self.$confirmHandler)
            .alert(isPresented: self.$showAlert) { () -> Alert in
                var alert = Alert(title: Text(alertMessage))
                if(self.showAlert == true) {
                    alert = Alert(title: Text("알림"), message: Text(alertMessage), primaryButton: .default(Text("OK"), action: {
                        confirmHandler(true)
                    }), secondaryButton: .cancel({
                        confirmHandler(false)
                    }))
                }
                return alert;
            }
        // SwiftUI는 이전과 같이 self.present 를 사용할 수 없기때문에 이런식으로 메인 뷰에 alert를 추가
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
