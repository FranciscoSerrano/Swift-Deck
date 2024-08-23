//
//  SwiftUIView.swift
//
//
//  Created by Kit Langton on 12/30/23.
//

import SwiftUI

public struct TitledDeck<Content: Deck>: Deck {
    @Environment(\.stepIndex) var step
    
    // Protocol conformance
    public var length: Int { content.length }
    
    var title: Text
    var alignment: HorizontalAlignment = .leading
    var content: Content
    
    public init(
        title: Text,
        alignment: HorizontalAlignment = .leading,
        @DeckBuilder content: () -> Content
    ) {
        self.title = title
        self.content = content()
        self.alignment = alignment
    }
    
    public var body: some View {
        VStack(alignment: alignment, spacing: 0) {
            title
                .font(.slideBody).fontWidth(.expanded).fontWeight(.semibold)
                .padding(48)
            
            Rectangle()
                .fill(Color.white.opacity(0.3))
                .frame(height: 1)
            
            AnyView(content)
                .padding(48)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background {
            Rectangle()
                .stroke(Color.white.opacity(0.3), lineWidth: 1)
        }
    }
}
