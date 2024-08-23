//
//  SeparatedDeck.swift
//
//
//  Created by Francisco Serrano on 8/22/24.
//

import SwiftUI

public struct Separated: Deck {
    
    public var length: Int { content.reduce(into: 0) { $0 = max($0, $1.length) } }
    
    public init(
        axis: Axis = .vertical,
        alignment: Alignment? = nil,
        @DeckArrayBuilder content: () -> [any Deck]
    ) {
        self.content = content()
        self.axis = axis
        self.alignment = alignment ?? .topLeading
    }
    
    public var body: some View {
        layout {
            ForEach(decksWithOffsets, id: \.offset) { offset, deck in
                AnyView(deck)
                //          .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                //          .overlay(alignment: horizontal ? .leading : .top) {
                    .overlay(alignment: axis == .horizontal ? .trailing : .bottom) {
                        if offset < content.count - 1 {
                            if axis == .horizontal {
                                Rectangle()
                                    .fill(Color.white.opacity(0.3))
                                    .frame(width: 1)
                                    .offset(x: 1)
                            } else {
                                Rectangle()
                                    .fill(Color.white.opacity(0.3))
                                    .frame(height: 1)
                                    .offset(y: 1)
                            }
                        }
                    }
                    .transition(.blur.combined(with: .opacity))
                //          .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            }
        }
    }
    
    var axis: Axis
    var alignment: Alignment
    var content: [any Deck]
    
    @Environment(\.stepIndex) var step
    
    var decksWithOffsets: [(offset: Int, element: any Deck)] {
        Array(content.enumerated())
    }
    
    var layout: AnyLayout {
        if axis == .vertical {
            AnyLayout(VStackLayout(alignment: alignment.horizontal, spacing: 0))
        } else {
            AnyLayout(HStackLayout(alignment: alignment.vertical, spacing: 0))
        }
    }
}

public struct ExampleDeckSeparated: MyDeck {
    public init() {}
    
    public var body: some Deck {
        Container {
            Separated(axis: .vertical) {
                HSequence {
                    Title("Hey. I went downstairs.").hideAfter()
                    Title("I love it").hideAfter()
                    Title("This is the best day ever.").rainbowDeck(0)
                }
                .deckPadding(48)
                .deckFrame(maxWidth: .infinity, alignment: .leading)
                //          .deckTransform { $0.background(.tertiary.opacity(0.2)) }
                .deckTransform { $0.background(.ultraThinMaterial.opacity(0.5)) }
                
                Separated(axis: .horizontal) {
                    Separated(axis: .vertical) {
                        CodeSlide {
              """
              func foo() {
                print("hello")
              }
              """
              """
              func foo() {
                print("hello world")
              }
              """
                        }
                        .deckPadding(48)
                        .deckFrame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                        .deckTransform { $0.background(.tertiary.opacity(0.2)) }
                        .hideAfter(4)
                        
                        VSequence {
                            Text("See you soon.")
                            Text("I have only eyes.")
                            Text("I have no legs.")
                            Text("I have only wings.")
                        }
                        .deckPadding(48)
                        .delay(1)
                        .deckFrame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                        
                        VSequence {
                            Text("I have no head.")
                            Text("I have only eyes.")
                            Text("I have no legs.")
                            Text("I have only wings.")
                        }
                        .deckPadding(48)
                        .deckFrame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                        .delay(2)
                    }
                    
                    VSequence {
                        Text("I have no head.")
                        Text("I have only eyes.")
                        Text("I have no legs.")
                        Text("I have only wings.")
                    }
                    .deckPadding(48)
                    .deckFrame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .delay(2)
                    
                    VSequence {
                        Text("I have no head.")
                        Text("I have only eyes.")
                        Text("I have no legs.")
                        Text("I have only wings.")
                    }
                    .deckPadding(48)
                    .deckFrame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .delay(3)
                }
            }
        }
        //    .delay(1)
    }
    
    @Environment(\.stepIndex) var step
}

#Preview {
    DeckView {
        ExampleDeckSeparated()
    }
    .font(.largeTitle)
    .padding(48)
    .background(.black)
    .environment(PresentationState(step: 0))
    .scaleEffect(0.5, anchor: .topLeading)
}
