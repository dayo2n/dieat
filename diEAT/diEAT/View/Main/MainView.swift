//
//  MainView.swift
//  diEAT
//
//  Created by 문다 on 2022/10/05.
//

import SwiftUI
import PopupView
import Kingfisher

enum ViewType {
    case month
    case day
}

struct MainView: View {
    
    let user: User
    @State var currentDate = Date()
    @State var selectedDate = Date()
    @Environment(\.colorScheme) var colorScheme
    @StateObject var viewModel = FetchPostViewModel()
    
    // show flag
    @State private var popLoginToast = false
    @State private var freezePop = false
    @State private var popErrorOccured = false
    @State private var viewType = ViewType.day
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    Spacer()
                        .frame(height: 20)
                    CustomDatePicker(
                        currentDate: $currentDate,
                        selectedDate: $selectedDate,
                        viewType: $viewType,
                        viewModel: viewModel
                    )
                    .foregroundColor(Theme.textColor(colorScheme))
                    .padding([.leading, .trailing], 10)
                    .onChange(of: selectedDate) { value in
                        selectedDate = value
                    }
                    // Eat log
                    if viewType == .day {
                        DailyEatLog(
                            selectedDate: $selectedDate,
                            viewModel: viewModel
                        )
                    } else {
                        MonthlyEatLog(
                            selectedDate: $selectedDate,
                            viewModel: viewModel
                        )
                    }
                    Spacer()
                        .frame(height: 100)
                }
            }
            .edgesIgnoringSafeArea([.bottom, .trailing, .leading])
            .background(Theme.bgColor(colorScheme))
            .onAppear {
                viewModel.fetchPostedDates()
                if !freezePop {
                    popLoginToast.toggle()
                    freezePop = true
                }
            }
            // login 인사
            .popup(isPresented: $popLoginToast) {
                CustomPopUpView(alertText: "\(user.username)님 반갑습니다 :)", bgColor: .blue)
            } customize: { pop in
                pop
                    .type(.floater())
                    .position(.bottom)
                    .dragToDismiss(true)
                    .closeOnTap(true)
                    .autohideIn(3)
            }
            .popup(isPresented: $popErrorOccured) {
                CustomPopUpView(alertText: String.alertErrorOccured, bgColor: .red)
            } customize: { pop in
                pop
                    .type(.floater())
                    .position(.bottom)
                    .dragToDismiss(true)
                    .closeOnTap(true)
                    .autohideIn(3)
            }
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    HStack {
                        Button {
                            viewType = viewType == .day ? .month : .day
                        } label: {
                            Image(systemName: viewType == .day ? String.listBullet : String.squareGrid2x2)
                        }
                        Spacer()
                        if viewType == .day, !viewModel.postsByDay.isEmpty {
                            Button {
                                if let snapshot = snapshot() {
                                    shareDailyRecords(image: snapshot)
                                } else {
                                    popErrorOccured = true
                                }
                            } label: {
                                Image(systemName: String.squareAndArrowUp)
                            }
                            Spacer()
                        }
                        NavigationLink {
                            SettingsView(user: user)
                        } label: {
                            ProfileImageView(
                                user: user,
                                size: CGSize(
                                    width: 30,
                                    height: 30
                                )
                            )
                        }
                    }
                }
            }
        }
    }
    
    @MainActor
    private func snapshot() -> UIImage? {
        var items = [GridItem(), GridItem()]
        if viewModel.postsByDay.count == 1 {
            items = [GridItem()]
        }
        let length = UIScreen.main.bounds.width / 2
        let imageRenderer = ImageRenderer(
            content: LazyVGrid(
                columns: items,
                spacing: 2
            ) {
                ForEach(viewModel.postsByDay) { post in
                    NavigationLink(
                        destination: SinglePostView(
                            post: post,
                            selectedDate: post.timestamp.dateValue(),
                            viewModel: viewModel
                        )
                    ) {
                        ZStack {
                            if let imageUrl = URL(string: post.imageUrl) {
                                if let cachedIamge = getExistedLog(url: imageUrl) {
                                    Image(uiImage: cachedIamge)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: length, height: length)
                                        .cornerRadius(8)
                                }
                            }
                            RecordLabelView(post: post)
                        }
                        .padding(.bottom, 1)
                    }
                }
            }
        )
        if let uiImage = imageRenderer.uiImage {
            return uiImage
        }
        return nil
    }
    
    private func shareDailyRecords(image: UIImage) {
        let av = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        UIApplication.shared.windows.first?.rootViewController?.present(av, animated: true, completion: nil)
    }
    
    func getExistedLog(url: URL) -> UIImage? {
        var cachedImage: UIImage?
        KingfisherManager.shared.retrieveImage(
            with: url
        ) { result in
            switch result {
            case .success(let value):
                cachedImage = value.image as UIImage
            case .failure:
                cachedImage = nil
            }
        }
        return cachedImage
    }
}
