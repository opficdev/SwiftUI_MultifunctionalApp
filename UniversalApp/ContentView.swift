//
//  ContentView.swift
//  forGraduate? //Optional
//
//  Created by 최윤진 on 2023/09/12.
//

import SwiftUI
import Foundation
import UIKit


enum BtnType:String, Codable{
    case calendar, weather, 기능1, 기능2

    var btnDisplay:String{
        switch self{
        case .calendar:
            return "캘린더"
        case .weather:
            return "날씨"
        case .기능1:
            return "기능1"
        case .기능2:
            return "기능2"
        }

    }

    var btnColor:Color{
        switch self{
        case .weather:
            return Color("deepBlue")
        case .calendar:
            return Color("shyPink")
        default:
            return Color.gray
        }
    }
    
    var btnOffset:CGFloat{
        switch self{
        case .calendar:
            return -2
        default:
            return 0
        }
    }
    
    var btnImage:some View{
        switch self{
        case .weather:
            return AnyView(Button(action:{
                
            }){
                Image(systemName: "cloud.sun.rain.fill")
                    .resizable()
                    .foregroundColor(Color.white)
                    .frame(width: 30,height:30)
                    .padding(.all,5)
            })
        case .calendar:
            return AnyView(Button(action:{
                
            }){
                Image(systemName: "calendar")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(Color.white)
                    .frame(width:30)
                    .padding(.all,5)
            }
                .offset(y: 2))
        
        default:
            return AnyView(Button(action:{
                
            }){
                Image(systemName: "ellipsis.circle.fill")
                    .resizable()
                    .foregroundColor(Color.white)
                    .frame(width: 30,height:30)
                    .padding(.all,5)
            })
        }
    }
    
    var nextView:some View{
        switch self{
        case .calendar:
            return AnyView(calendarView())
        case .weather:
            return AnyView(weatherView())
        default:
            return AnyView(TestView())
        }
    }
}

struct ContentView: View {
    @State private var BtnBase:[BtnType] = [.기능1,.기능2,.weather,.calendar] // + 버튼에 들어가는 배열 - BtnData와 대조됨
    @State private var BtnData:[BtnType] = [] //화면에 나올 구조를 만드는 배열
    @State private var removeBtn:[BtnType] = []  //삭제할 버튼을 임시 저장하는 배열
    @Binding var Search:String //메뉴 검색
    @State private var TextfieldHeight:CGFloat = 30
    @State private var TextfieldWidth:CGFloat = 380
    @State private var InitialViewY:CGFloat = 0 //현재 최상단뷰 최초 y값(불변)
    @State private var scrolledHeight:CGFloat = 0 //스크롤 된 정도
    @State private var spacing:CGFloat = 10
    @State private var scrollViewOffset:CGFloat = 30
    @State private var titleFontSize:CGFloat = 28
    
    @FocusState private var isTextFieldEditing:Bool
    
    //----버튼 토글 변수----
    @State private var isGrid = true //그리드 모드 버튼 토글
    @State private var isModifying = false //편집 버튼 토글
    
    //----앱이 종료되도 데이터가 남아있게----
    let Save = UserDefaults.standard
    
    func getBtns(){
        if let data = Save.data(forKey: "BtnBase"){
            let decoder = JSONDecoder()
            if let decodedData = try? decoder.decode([BtnType].self,from:data){
                BtnBase = decodedData
            }
        }

        if let data = Save.data(forKey: "BtnData"){
            let decoder = JSONDecoder()
            if let decodedData = try? decoder.decode([BtnType].self,from:data){
                    BtnData = decodedData
            }
        }
    }
    
    func setBtns(){
        let encoder = JSONEncoder()
        if let encoderData = try? encoder.encode(BtnBase){
            Save.set(encoderData,forKey:"BtnBase")
        }
        if let encoderData = try? encoder.encode(BtnData){
            Save.set(encoderData,forKey:"BtnData")
        }
    }
    
    func showBtns() -> some View{
        if Search != "" || isTextFieldEditing{
            let tmpArr = BtnData.filter{$0.btnDisplay.contains(Search)}
            return Btns(col: tmpArr)
        }
        let tmpArr = BtnData
        return Btns(col: tmpArr)
    }
    
    func Btns(col:[BtnType]) -> some View{
        ForEach(col.indices,id:\.self){index in
            ZStack{
                NavigationLink(destination:col[index].nextView){
                    Text(col[index].btnDisplay)
                        .padding(isGrid ? 0 : 15)
                        .offset(CGSize(width: isGrid ? 15 : 0, height: isGrid ? -15 : 0))
                        .frame(width: isGrid ? 186 : 380,
                               height: isGrid ? 120 : 55,
                               alignment: isGrid ? .bottomLeading : .leading)
                        .font(.system(size: isGrid ? 18 : 15, weight:.bold))
                        .foregroundColor(Color.white)
                        .background(col[index].btnColor)
                        .cornerRadius(isGrid ? 20 : 10)
                }
                .disabled(isModifying ? true : false)
                if !isModifying{
                    col[index].btnImage
                        .offset(CGSize(width: isGrid ? 60 : 165, height: isGrid ? -30 : col[index].btnOffset))
                        .disabled(true)
                }
                else{
                    Circle()
                        .frame(maxWidth: 30,maxHeight:30)
                        .offset(CGSize(width: isGrid ? 60 : 165, height: isGrid ? -30 : 0))
                        .foregroundColor(removeBtn.contains(col[index]) ? Color.blue : Color.white.opacity(0))
                    Button(action:{
                        if !removeBtn.contains(col[index]){
                            removeBtn.append(col[index])}
                        else{
                            removeBtn.remove(at: removeBtn.firstIndex(of: col[index])!)
                        }
                        
                    }){
                        Image(systemName: removeBtn.contains(col[index]) ? "checkmark.circle" : "circle")
                            .resizable()
                            .foregroundColor(Color.white)
                            .frame(maxWidth: 30,maxHeight:30)
                            .padding(5)
                    }
                    .offset(CGSize(width: isGrid ? 60 : 165, height: isGrid ? -30 : 0))
                }
            }
        }
        
    }

    var body: some View {
        NavigationView{
            ScrollView{
                GeometryReader{ proxy in
                    EmptyView()
                        .onChange(of: proxy.frame(in:.global).maxY){y in
                            if scrolledHeight == 0 && InitialViewY == 0{
                                InitialViewY = proxy.frame(in:.global).maxY
                            }
                            else{
                                scrolledHeight = y - InitialViewY
                            }
                        }
                }
                .frame(width:0,height:0)
                LazyVStack(spacing:spacing){
                    VStack(spacing:spacing){
                        HStack(alignment:.firstTextBaseline){
                            VStack{
                                Spacer()
                                Text("생활의 모든 것")
                                    .lineLimit(1)
                                    .frame(maxWidth:160,minHeight: 38,maxHeight:38, alignment:.leading)
                                    .font(.system(size: scrolledHeight > 0 ? titleFontSize + (scrolledHeight) * 0.02 : titleFontSize, weight: .semibold))
                            }
                            Spacer()
                            HStack{
                                if !isModifying{
                                    Button{
                                        isModifying = true
                                    }label: {
                                        Text("편집")
                                            .font(.system(size:18))
                                            .foregroundColor(.blue)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    Button(action:{
                                        isGrid.toggle()
                                        Save.removeObject(forKey: "isGrid")
                                        Save.set(isGrid,forKey: "isGrid")
                                    }){
                                        Image(systemName: isGrid ? "rectangle.grid.2x2" : "list.bullet")
                                            .font(.system(size:20))
                                            .foregroundColor(.blue)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    .onAppear{
                                        isGrid = Save.bool(forKey: "isGrid")
                                    }
                                    .frame(width: 30)
                                    Menu{
                                        if !BtnBase.isEmpty{
                                            ForEach(BtnBase,id:\.self){item in
                                                Button(action:{
                                                    BtnData.append(item)
                                                    BtnBase.remove(at:BtnBase.firstIndex(of: item)!)
                                                    setBtns()
                                                }){
                                                    Text(item.btnDisplay)
                                                }
                                            }
                                        }
                                        else{
                                            Text("") //더 이상 추가할 수 없음
                                        }
                                    }label:{
                                        Image(systemName: "plus")
                                            .font(.system(size:20))
                                            .foregroundColor(.blue)
                                            .padding(.trailing,-1.7)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                                else{
                                    Button(action:{
                                        if removeBtn.count == 0{
                                            if isTextFieldEditing{
                                                for item in (BtnData.filter{$0.btnDisplay.contains(Search)}){
                                                    removeBtn.append(item)
                                                }
                                            }
                                            else{
                                                for item in BtnData{
                                                    removeBtn.append(item)
                                                }
                                            }
                                        }
                                        else{
                                            removeBtn = []
                                        }
                                    }){
                                        if  removeBtn.count == 0{
                                            Text("전체 선택")
                                                .font(.system(size:18))
                                                .foregroundColor(.blue)
                                        }
                                        else{
                                            Text("전체 선택 해제")
                                                .font(.system(size:18))
                                                .foregroundColor(.blue)
                                        }
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    Button(action:{
                                        if removeBtn.count == BtnData.count{ //혹시라도 Userdefaults가 꼬이면 기존 Userdefauls 삭제
                                            Save.removeObject(forKey: "BtnBase")
                                            Save.removeObject(forKey: "BtnData")
                                        }
                                        while !removeBtn.isEmpty{
                                            if BtnData.contains(removeBtn.first!){
                                                BtnData.remove(at: BtnData.firstIndex(of: removeBtn.first!)!)
                                                BtnBase.append(removeBtn.first!)
                                                removeBtn.removeFirst()
                                            }
                                        }
                                        BtnBase.sort{$0.btnDisplay < $1.btnDisplay}
                                        setBtns()
                                    }){
                                        Text("삭제")
                                            .font(.system(size:18))
                                            .padding(.horizontal,5)
                                            .foregroundColor(removeBtn.isEmpty ? Color.gray : Color.red)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    .disabled(removeBtn.isEmpty ? true : false)
                                    
                                    Button(action:{
                                        isModifying = false
                                        removeBtn = []
                                    }){
                                        Text("완료")
                                            .font(.system(size:18,weight:.semibold))
                                            .foregroundColor(.blue)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .frame(height:20)
                        }
                        .offset(y: scrolledHeight < 0 && !isTextFieldEditing ? -scrolledHeight : 0)
                        .offset(y:-40 > scrolledHeight && !isTextFieldEditing ? scrolledHeight + 40 : 0)
                        
                        HStack(alignment:.top){
                            HStack(spacing:0){
                                Image(systemName: "magnifyingglass")
                                    .frame(width:30,height:30)
                                    .foregroundColor(Color.gray)
                                    .opacity(isTextFieldEditing ? 1 : (5 + scrolledHeight) * 0.1 + 0.5)
                                    .cornerRadius(8)
                                TextField("검색",text: $Search)
                                    .id("textField")
                                    .onAppear{
                                        if Search != ""{
                                            DispatchQueue.main.async{
                                                isTextFieldEditing = true
                                            }
                                        }
                                    }
                                    .onDisappear{
                                        DispatchQueue.main.async{
                                            isTextFieldEditing = false
                                        }
                                    }
                                .onChange(of:isTextFieldEditing){_ in
                                    if isTextFieldEditing{
                                        withAnimation(.easeInOut(duration: 0.3)){
                                            TextfieldWidth = 340
                                        }
                                    }
                             
                                }
                                .onChange(of: scrolledHeight){_ in
                                    TextfieldHeight = 30 + scrolledHeight
                                    if -scrolledHeight > 30{
                                        TextfieldHeight = 0
                                    }
                                }
                                .focused($isTextFieldEditing)
                                .opacity(isTextFieldEditing ? 1 : (5 + scrolledHeight) * 0.1 + 0.5)
                                if Search.count > 0{
                                    Button(action:{
                                        Search = ""
                                    }){
                                        Image(systemName: "xmark.circle.fill")
                                            .frame(width:30,height:30)
                                            .foregroundColor(Color.gray)
                                    }
                                }
                            }
                            .frame(width: TextfieldWidth, height: scrolledHeight < 0 && !isTextFieldEditing ? TextfieldHeight : 30)
                            .background(Color("graySet"))
                            .cornerRadius(10)
                            
                            Button(action:{
                                Search = ""
                                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),to:nil, from: nil, for: nil)
                                isTextFieldEditing = false
                                withAnimation(.easeInOut(duration: 0.3)){
                                    TextfieldWidth = 380
                                }
                            }){
                                Text("취소")
                                    .frame(minWidth:33,minHeight:30)
                                    .foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
                                    .opacity(1.0 / (TextfieldWidth - 339))
                            }
                            .buttonStyle(PlainButtonStyle())
                            Spacer()
                        }
                        .frame(width:420,height:30,alignment:.leading)
                        .offset(x:20)
                        .offset(y:scrolledHeight < 0 && !isTextFieldEditing ? -scrolledHeight : 0)
                    }
                    .frame(maxWidth: 380,maxHeight:80)
                    .offset(y:-10)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(spacing: 10), count: isGrid ? 2 : 1)){
                        showBtns()
                    }
                    .onAppear{
                        getBtns()
                    }
                    .frame(maxWidth:380)
                }
            }
            .frame(alignment:.top)
            .offset(y:scrollViewOffset)
        }
        .navigationViewStyle(.stack)
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(Search:UniversalApp().$Search)
    }
}
