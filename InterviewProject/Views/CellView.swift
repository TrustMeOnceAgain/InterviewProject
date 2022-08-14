//
//  CellView.swift
//  InterviewProject
//
//  Created by Filip Cybuch on 14/08/2022.
//

import SwiftUI

struct CellView: View {
    
    var viewModel: CellViewModel
    
    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            if let leftText = viewModel.leftText {
                VStack(alignment: .center, spacing: 0) {
                    Text(leftText)
                        .foregroundColor(viewModel.leftTextColor)
                        .padding([.leading], 8)
                }
            }
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Text(viewModel.title)
                        .foregroundColor(viewModel.titleColor)
                    Spacer()
                }
                .padding([.leading, .trailing, .top], 8)
                .padding([.bottom], shouldSubtitleBeVisible ? 4 : 8)
                
                if let subtitle = viewModel.subtitle {
                    HStack {
                        Text(subtitle)
                            .foregroundColor(viewModel.subtitleColor)
                        Spacer()
                    }
                    .padding([.leading, .trailing, .bottom], 8)
                }
            }
        }
        .background(viewModel.backgroundColor)
    }
    
    var shouldSubtitleBeVisible: Bool { viewModel.subtitle != nil }
}

struct CellView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ForEach(ColorScheme.allCases, id: \.hashValue) { colorScheme in
                Group {
                    CellView(viewModel: CellViewModel(title: "Preview comment", subtitle: "Some text", backgroundColor: Color(.backgroundColor)))
                    CellView(viewModel: CellViewModel(title: "Preview post 1", subtitle: "Some more text", leftText: "1" ,backgroundColor: Color(.backgroundColor)))
                    CellView(viewModel: CellViewModel(title: "Preview post 2", subtitle: "Some even more text than before", backgroundColor: Color(.backgroundColor)))
                }
                .preferredColorScheme(colorScheme)
            }
        }
        .previewLayout(.sizeThatFits)
    }
}
