//
//  ColorStyle.swift
//  InterviewProject
//
//  Created by Filip Cybuch on 14/08/2022.
//

import SwiftUI

enum ColorStyle {
    case mainLabel, secondaryLabel, accentColor, backgroundColor
}

extension Color {
    init(_ colorStyle: ColorStyle) {
        switch colorStyle {
        case .mainLabel:
            self = Color("MainLabel")
        case .secondaryLabel:
            self = Color("SecondaryLabel")
        case .accentColor:
            self = Color("AccentColor")
        case .backgroundColor:
            self = Color("BackgroundColor")
        }
    }
}
