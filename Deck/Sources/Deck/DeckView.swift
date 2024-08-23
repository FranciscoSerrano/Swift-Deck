import SwiftUI
import Observation


@Observable
public final class PresentationState {
    public var step: Int = 0
    
    public init(step: Int = 0) {
        self.step = step
    }
}

public struct DeckView<Content: Deck>: View {
    @Environment(PresentationState.self) var state
    
    var content: Content
    
    let animation = Animation.spring
    
    public init(@DeckBuilder content: () -> Content) {
        self.content = content()
    }
    
    public var body: some View {
        content
            .environment(\.stepIndex, state.step)
            .frame(width: 800, height: 450, alignment: .topLeading)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.black)
            .onTapGesture {
                increment()
            }
            .background {
                Button { increment() } label: { EmptyView() }
                    .keyboardShortcut(.downArrow, modifiers: [])
                    .hidden()
                
                Button { increment(5) } label: { EmptyView() }
                    .keyboardShortcut(.downArrow, modifiers: .shift)
                    .hidden()
                
                Button { decrement() } label: { EmptyView() }
                    .keyboardShortcut(.upArrow, modifiers: [])
                    .hidden()
                
                Button { decrement(5) } label: { EmptyView() }
                    .keyboardShortcut(.upArrow, modifiers: .shift)
                    .hidden()
            }
            .modifier(HighlightDeck())
    }
    
    func increment(_ amount: Int = 1) {
        withAnimation(animation) {
            state.step = state.step + amount
        }
    }
    
    func decrement(_ amount: Int = 1) {
        withAnimation(animation) {
            state.step = max(0, state.step - amount)
        }
    }
}
