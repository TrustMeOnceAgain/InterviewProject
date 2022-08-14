//
//  CellViewModel.swift
//  InterviewProject
//
//  Created by Filip Cybuch on 14/08/2022.
//

import SwiftUI

struct CellViewModel {
    let title: String
    let titleColor: Color
    let subtitle: String?
    let subtitleColor: Color
    let leftText: String?
    let leftTextColor: Color
    let backgroundColor: Color
    
    init(title: String, titleColor: Color = Color(.mainLabel), subtitle: String? = nil, subtitleColor: Color = Color(.secondaryLabel), leftText: String? = nil, leftTextColor: Color = Color(.mainLabel), backgroundColor: Color = .clear) {
        self.title = title
        self.titleColor = titleColor
        self.subtitle = subtitle
        self.subtitleColor = subtitleColor
        self.leftText = leftText
        self.leftTextColor = leftTextColor
        self.backgroundColor = backgroundColor
    }
}
