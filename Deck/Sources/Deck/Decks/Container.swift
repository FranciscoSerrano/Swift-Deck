//
//  Container.swift
//
//
//  Created by Francisco Serrano on 8/22/24.
//

import SwiftUI

public struct Container<Content: Deck>: Deck {
    @Environment(\.stepIndex) var step
    
    // Protocol conformance
    public var length: Int { content.length }
    
    var content: Content
    
    public init(
        @DeckBuilder content: () -> Content
    ) {
        self.content = content()
    }
    
    public var body: some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .overlay {
                Rectangle()
                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
            }
            .clipped()
    }
}
