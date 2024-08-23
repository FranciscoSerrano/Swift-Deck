//
//  File.swift
//
//
//  Created by Kit Langton on 9/28/23.
//

import SwiftUI

// MARK: - Views

public struct BodyText: Deck {
    @Environment(\.stepIndex) var step
    @State var appear = false
    
    // Protocol conformance
    public var length: Int { text.length }
    
    var text: StepValue<Text>
    
    public init(@StepTextBuilder text: () -> [HoldValue<Text>]) {
        self.text = StepValue.build(strings: text)
    }
    
    public var body: some View {
        (appear ? text[step] : Text(""))
            .contentTransition(.numericText(countsDown: true))
            .onAppear {
                withAnimation {
                    appear = true
                }
            }
    }
}

public struct HDeck: Deck {
    @Environment(\.stepIndex) var step
    
    // Protocol conformance
    public var length: Int { decks.reduce(into: 0) { $0 = max($0, $1.length) } }
    
    let alignment: VerticalAlignment
    var decks: [any Deck]
    
    public init(
        alignment: VerticalAlignment = .top,
        @DeckArrayBuilder decks: () -> [any Deck]
    ) {
        self.decks = decks()
        self.alignment = alignment
    }
    
    public var body: some View {
        HStack(alignment: alignment, spacing: 24) {
            ForEach(Array(decks.enumerated()), id: \.offset) { _, deck in
                AnyView(deck).environment(\.stepIndex, step)
            }
        }
    }
}

public struct VDeck: Deck {
    @Environment(\.stepIndex) var step
    
    // Protocol conformance
    public var length: Int { decks.reduce(into: 0) { $0 = max($0, $1.length) } }
    
    var alignment: HorizontalAlignment = .leading
    var spacing: CGFloat = 40
    var decks: [any Deck]
    
    public init(
        alignment: HorizontalAlignment = .leading,
        spacing: CGFloat = 40,
        @DeckArrayBuilder decks: () -> [any Deck]
    ) {
        self.decks = decks()
        self.alignment = alignment
        self.spacing = spacing
    }
    
    public var body: some View {
        VStack(alignment: alignment, spacing: spacing) {
            ForEach(Array(decks.enumerated()), id: \.offset) { _, deck in
                AnyView(deck)
            }
        }
    }
}

public struct DeckViewWrapper<V: View>: Deck {
    
    // Protocol conformance
    public var length: Int
    
    var view: V
    
    public init(length: Int, @ViewBuilder view: () -> V) {
        self.length = length
        self.view = view()
    }
    
    public var body: V {
        view
    }
}

public struct Title: Deck {
    @Environment(\.stepIndex) private var step
    
    // Protocol conformance
    public var length: Int { 1 }
    
    var title: String
    var separator: String = " "
    var centered: Bool = false
    
    public init(
        _ title: String,
        separator: String = " ",
        centered: Bool = false
    ) {
        self.title = title
        self.separator = separator
        self.centered = centered
    }
    
    public var body: some View {
        SlideInText(title, separator: separator)
            .font(
                .system(size: step == 0 ? 72 : 48).width(.expanded)
            )
            .bold(step == 0)
            .frame(
                maxWidth: centered ? .infinity : nil,
                maxHeight: centered ? .infinity : nil,
                alignment: centered ? .center : .topLeading
            )
    }
}

public struct CodeSlide: Deck {
    @Environment(\.stepIndex) var step
    @State var appeared = false
    
    // Protocol conformance
    public var length: Int { code.length }
    
    var code: StepValue<String>
    
    public init(@StepStringBuilder code: () -> [HoldValue<String>]) {
        self.code = StepValue.build(strings: code)
    }
    
    public var body: some View {
        CodeBlock(appeared ? "\(code[step])" : "")
            .offset(y: appeared ? 0 : 200)
            .blur(radius: appeared ? 0 : 15)
            .onAppear {
                withAnimation(.bouncy) {
                    appeared = true
                }
            }
    }
}

public struct ViewDeck<V: View>: Deck {
    
    // Protocol conformance
    public var length: Int { 1 }
    
    var content: V
    
    public init(@ViewBuilder content: () -> V) {
        self.content = content()
    }
    
    public var body: some View {
        content
    }
}

// MARK: - Modifiers

public struct DeckViewModifier<D: Deck, M: View>: Deck {
    public var length: Int { content.length }
    public var body: some View {
        modifier(content)
    }
    
    let content: D
    let modifier: (D) -> M
}

// MARK: - Protocols

public protocol EnumDeck<Content>: Deck {
    associatedtype Content: Deck
    associatedtype Enum: CaseIterable
    
    var state: Enum { get }
    var body: Content { get }
}

// MARK: - Extensions

public extension EnumDeck {
    var length: Int { Enum.allCases.count }
}

public extension Array {
    subscript(safe index: Index) -> Element? {
        index >= 0 && index < count ? self[index] : nil
    }
}

public extension Deck {
    func modifyDeck<M: View>(_ modifier: @escaping (Self) -> M) -> DeckViewModifier<Self, M> {
        DeckViewModifier(content: self, modifier: modifier)
    }
}
