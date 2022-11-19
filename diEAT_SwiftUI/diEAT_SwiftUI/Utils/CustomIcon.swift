//
//  CustomIconButton.swift
//  diEAT_SwiftUI
//
//  Created by 문다 on 2022/11/19.
//

import SwiftUI

struct CustomIcon: View {
    
    let iconName: String
    var body: some View {
        Image(iconName)
            .resizable()
            .scaledToFit()
            .frame(width: 60, height: 60)
            .padding(.horizontal)
    }
}
