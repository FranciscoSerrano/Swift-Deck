import SwiftUI

/// Protcol that describes a Deck
public protocol Deck: View {
    
    /// Anything thing that confroms to Deck must have a length because a Deck can contain many children.
    var length: Int { get }
}

/// A Sequence will contain my Decks that will be transitioned to one at a time.
public struct Sequence: Deck {
    @Environment(\.stepIndex) var step
    
    // Protocol conformance
    public var length: Int { decks.reduce(into: 0) { $0 += $1.length } }
    
    var decks: [any Deck]
    
    public init(decks: [any Deck]) {
        self.decks = decks
    }
    
    public init(@DeckArrayBuilder decks: () -> [any Deck]) {
        self.decks = decks()
    }
    
    public var body: some View {
        if let (deck, index, start) = activeDeck {
            AnyView(deck).id(index).environment(\.stepIndex, start)
                .transition(transition)
        } else {
            EmptyView()
        }
    }
    
    /// The default transition between slides in a Sequence
    let transition: AnyTransition = .scale(scale: 0.8)
        .combined(with: .blur(radius: 15))
        .combined(with: .opacity)
        .animation(.smooth(duration: 0.3))
    
    /// Will compute the active Deck by using the current Environment step and the index of the
    var activeDeck: (any Deck, Int, Int)? {
        var start = step
        for (index, deck) in decks.enumerated() {
            if start < deck.length {
                return (deck, index, start)
            } else {
                start -= deck.length
            }
        }
        return nil
    }
    
    var activeDecks: [(any Deck, Int, Int)] {
        if let activeDeck = activeDeck {
            return [activeDeck]
        } else {
            return []
        }
    }
}

/// Will delay a slide buy drawing an EmptyView on the screen for the desired delay.
public struct DelayDeck<D: Deck>: Deck {
    @Environment(\.stepIndex) var step
    
    // Protocol conformace
    public var length: Int { deck.length + delay }
    
    let delay: Int
    let deck: D
    
    public init(delay: Int, deck: D) {
        self.delay = delay
        self.deck = deck
    }
    
    public var body: some View {
        if step < delay {
            EmptyView()
        } else {
            deck.environment(\.stepIndex, step - delay)
                .transition(.scale.combined(with: .opacity).combined(with: .blur))
        }
    }
}

public struct CutDeck<D: Deck>: Deck {
    @Environment(\.stepIndex) var step
    
    // Protocol conformance
    public var length: Int { deck.length - amount }
    
    let amount: Int
    let deck: D
    
    public init(amount: Int, deck: D) {
        self.amount = amount
        self.deck = deck
    }
    
    public var body: some View {
        deck.environment(\.stepIndex, step)
    }
}

public struct DeckPadding<D: Deck>: Deck {
    
    // Protocol conformance
    public var length: Int { deck.length }
    
    let insets: EdgeInsets
    let deck: D
    
    public init(_ insets: EdgeInsets, deck: D) {
        self.insets = insets
        self.deck = deck
    }
    
    public var body: some View {
        deck.padding(insets)
    }
}

struct DeckModifier<VM: ViewModifier, D: Deck>: Deck {
    
    // Protocol conformance
    public var length: Int { deck.length }
    
    let modifier: VM
    let deck: D
    
    public init(modifier: VM, deck: D) {
        self.modifier = modifier
        self.deck = deck
    }
    
    public var body: some View {
        deck.modifier(modifier)
    }
}

struct DeckViewTransform<D: Deck, V: View>: Deck {
    
    // Protocol conformance
    public var length: Int { deck.length }
    
    let transform: (D) -> V
    let deck: D
    
    public init(transform: @escaping (D) -> V, deck: D) {
        self.transform = transform
        self.deck = deck
    }
    
    public var body: some View {
        transform(deck)
    }
}

struct DeckViewTransformIndex<D: Deck, V: View>: Deck {
    @Environment(\.stepIndex) var step
    
    // Protocol conformance
    public var length: Int { deck.length }
    
    let transform: (D, Int) -> V
    let deck: D

    public init(transform: @escaping (D, Int) -> V, deck: D) {
        self.transform = transform
        self.deck = deck
    }
    
    public var body: some View {
        transform(deck, step)
    }
}

struct DeckFrame<D: Deck>: Deck {
    var maxWidth: CGFloat?
    var maxHeight: CGFloat?
    var alignment: Alignment = .center
    
    // Protocol conformance
    
    var length: Int { deck.length }
    
    let deck: D
    
    var body: some View {
        deck
            .frame(
                maxWidth: maxWidth,
                maxHeight: maxHeight,
                alignment: alignment
            )
    }
}

public struct QuoteText: Deck {
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
            .font(.slideBody)
            .padding(.leading, 40)
            .padding(.vertical)
            .overlay(alignment: .leading) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(.tertiary)
                    .frame(width: 8)
            }
            .onAppear {
                withAnimation {
                    appear = true
                }
            }
    }
}

// MARK: - Protocol Extention Methods

public extension Deck {
    
    /// Delays a deck by drawing an EmptyView for desired time.
    /// - Parameter delay: An integer reprisenting the desired anount of steps to delay a slide by.
    /// - Returns: A modifed instance of your slide with a delay applied.
    func delay(_ delay: Int) -> some Deck {
        DelayDeck(delay: delay, deck: self)
    }
    
    /// Cuts a Deck by a desired amount.
    /// - Parameter amount: An integer representing how far ahead in your Deck you want to skip.
    /// - Returns: A modifed instance of your Deck now cut by youre desired amount.
    func cut(_ amount: Int) -> some Deck {
        CutDeck(amount: amount, deck: self)
    }
    
    /// Apply padding to all edges of your Deck.
    /// - Parameter amount: The amount of padding you want to apply as a CGFloat.
    /// - Returns: A modifed instance of your Deck now with desired padding.
    func deckPadding(_ amount: CGFloat) -> some Deck {
        DeckPadding(EdgeInsets(top: amount, leading: amount, bottom: amount, trailing: amount), deck: self)
    }
    
    /// Applies a ViewModifer to your Deck.
    /// - Parameter modifier: The modifier you want to apply.
    /// - Returns: A modifed instance of your Deck with the modifer applied.
    func deckModifier<VM: ViewModifier>(_ modifier: VM) -> some Deck {
        DeckModifier(modifier: modifier, deck: self)
    }
    
    /// Allows you to change the order ordering of your Deck by instering a new deck at a desired step.
    /// - Parameter transform: A new Deck view and index you want it to be.
    /// - Returns: A reordered version of your Deck,
    func deckTransform<V: View>(_ transform: @escaping (Self) -> V) -> some Deck {
        DeckViewTransform(transform: transform, deck: self)
    }
    
    /// Allows you to change the order ordering of your Deck by instering a new deck at a desired step.
    /// - Parameter transform: A new Deck view and index you want it to be.
    /// - Returns: A reordered version of your Deck,
    func deckTransform<V: View>(_ transform: @escaping (Self, Int) -> V) -> some Deck {
        DeckViewTransformIndex(transform: transform, deck: self)
    }
    
    /// Allows you to set a new frame for your Deck.
    /// - Parameters:
    ///   - maxWidth: The maximum width you'd like your Deck to be as a CGFloat.
    ///   - maxHeight: The maximum height you'd like your Deck to be as a CGFloat.
    ///   - alignment: How the content should be alligned on screen.
    /// - Returns: A modifed instance of your Deck with new framing.
    func deckFrame(maxWidth: CGFloat? = nil, maxHeight: CGFloat? = nil, alignment: Alignment = .center) -> some Deck {
        DeckFrame(maxWidth: maxWidth, maxHeight: maxHeight, alignment: alignment, deck: self)
    }
    
    /// Frames your Deck in the center of the view port.
    /// - Returns: A modifed instance of your Deck that is centered both horizontally and vertically.
    func centered() -> some Deck {
        DeckFrame(
            maxWidth: .infinity,
            maxHeight: .infinity,
            alignment: .center,
            deck: self
        )
    }
    
    /// Frames your deck in the center of the view port.
    /// - Returns: A modifed instance of your deck that is centered on the horizontal axis.
    func centerHorizontally() -> some Deck {
        DeckFrame(
            maxWidth: .infinity,
            maxHeight: nil,
            alignment: .center,
            deck: self
        )
    }
}
