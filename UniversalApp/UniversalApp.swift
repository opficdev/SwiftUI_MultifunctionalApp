//
//  forGraduateApp.swift
//  forGraduate
//
//  Created by 최윤진 on 2023/09/12.
//

import Foundation
import SwiftUI

@main
struct UniversalApp: App {
    @State var Search:String = "" //메뉴 검색
//    @State var isTextFieldEditing = false //textfield에 포커스 상태 유무 확인
    
    var body: some Scene {
        WindowGroup {
//            ContentView(Search: $Search, isTextFieldEditing: $isTextFieldEditing)
            ContentView(Search:$Search)
        }
    }
}
