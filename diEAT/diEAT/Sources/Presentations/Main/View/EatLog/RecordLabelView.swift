//
//  RecordLabelView.swift
//  diEAT
//
//  Created by 제나 on 3/17/24.
//

import SwiftUI

struct RecordLabelView: View {
    let post: Post
    @Environment(\.colorScheme) private var colorScheme
    var body: some View {
        HStack {
            VStack{
                HStack {
                    if let mealtime = MealTime(rawValue: post.mealtime) {
                        Text("# \(mealtime.toString)")
                            .font(.system(size: 12, weight: .regular, design: .monospaced))
                            .foregroundColor(Theme.textColor(colorScheme))
                            .frame(height: 20)
                            .padding(5)
                            .background(Theme.bgColor(colorScheme).opacity(0.7))
                    }
                    if let icon = post.icon {
                        HStack {
                            Text(String.hashtag)
                                .font(.system(size: 12, weight: .regular, design: .monospaced))
                                .foregroundColor(Theme.textColor(colorScheme))
                            Image(icon)
                                .resizable()
                                .frame(width: 20, height: 20)
                        }
                        .padding(5)
                        .background(Theme.bgColor(colorScheme).opacity(0.7))
                    }
                }
                .padding([.leading, .top], 5)
                Spacer()
            }
            Spacer()
        }
    }
}
