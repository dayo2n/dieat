//
//  MainView.swift
//  diEAT_SwiftUI
//
//  Created by 문다 on 2022/10/05.
//

import SwiftUI
import PopupView

struct MainView: View {
    
    let user: User
    @State var currentDate: Date = Date()
    @State var selectedDate: Date = Date()
    @Environment(\.colorScheme) var scheme
    @ObservedObject var viewModel: FetchPostViewModel = FetchPostViewModel()
    @State private var popLoginToast: Bool = false
    @State private var freezePop: Bool = false
    @State var showSidebar: Bool = false
    @State var showEditProfile: Bool = false

    var body: some View {
        SidebarMenu(sidebarWidth: UIScreen.main.bounds.width / 3 * 2, showSidebar: $showSidebar) {
            NavigationView {
                VStack {
                    ProfileHeaderView(user: user)

                    Divider()
                        .padding(.all)
                    
                    Button(action: { showEditProfile.toggle() }, label: {
                        HStack {
                            Image(systemName: "person.fill.viewfinder")
                                .font(.system(size: 16))
                                .foregroundColor(Theme.textColor(scheme))
                            
                            Text("프로필 변경")
                                .font(.system(size: 16, weight: .medium, design: .monospaced))
                                .foregroundColor(Theme.textColor(scheme))
                                .padding(.leading, 10)
                            
                            Spacer()
                        }.padding(.leading, 20)
                    })
                        .sheet(isPresented: $showEditProfile, content: { EditProfileView(user: user) })
                        .padding(.bottom, 30)

                    Spacer()
                    
                    HStack {
                        Button(action: AuthViewModel.shared.logout) {
                            HStack {
                                Image(systemName: scheme == .dark ? "rectangle.portrait.and.arrow.right.fill" : "rectangle.portrait.and.arrow.right")
                                    .padding(.trailing)
                                    .foregroundColor(Theme.textColor(scheme))
                                Text("Sign Out")
                                    .foregroundColor(Theme.textColor(scheme))
                            }.padding([.leading, .bottom])
                        }
                        Spacer()
                    }
                }
            }
            .gesture(DragGesture(minimumDistance: 10, coordinateSpace: .local)
                .onEnded({ value in
                    if showSidebar {
                        if value.translation.width < 0 { // left 방향으로 슬라이드하면
                            showSidebar.toggle()
                        }
                    }
                }))
        } content: {
            NavigationView {
                VStack {
                    HStack {
                        Button(action: {
                            showSidebar.toggle()
                        }) {
                            Image(systemName: "text.justify")
                                .font(.system(size: 20))
                                .frame(width: 44, height: 44)
                                .padding(.all)
                                .foregroundColor(Theme.textColor(scheme))
                        }
                        Spacer()
                    }
                    
                    // Calendar
                    CustomDatePicker(currentDate: $currentDate, selectedDate: $selectedDate, viewModel: viewModel)
                        .foregroundColor(Theme.textColor(scheme))
                        .padding([.leading, .trailing], 10)
                        .padding(.bottom, 20)
                        .onChange(of: selectedDate, perform: { value in selectedDate = value })
                    
                    // Eat log
                    EatLog(selectedDate: $selectedDate, viewModel: viewModel)
                }
                .edgesIgnoringSafeArea([.bottom, .trailing, .leading])
                .background(Theme.bgColor(scheme))
                .onAppear() {
                    viewModel.fetchPost(selectedDate: selectedDate)
                    if !freezePop {
                        popLoginToast.toggle()
                        freezePop = true
                    }
                }
                .popup(isPresented: $popLoginToast, type: .floater(), position: .bottom, autohideIn: 3) {
                    Text("\(user.username)님 반갑습니다 :)")
                        .font(.system(size: 17, weight: .medium, design: .monospaced))
                        .padding([.leading, .trailing], 20)
                        .padding([.bottom, .top], 10)
                        .foregroundColor(Theme.textColor(scheme))
                        .background(.blue)
                        .cornerRadius(30.0)
                }
            }
        }.edgesIgnoringSafeArea(.all)
    }
}
