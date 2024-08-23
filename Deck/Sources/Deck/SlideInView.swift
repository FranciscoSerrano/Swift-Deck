//
//  SwiftUIView.swift
//  
//
//  Created by Kit Langton on 9/28/23.
//

import SwiftUI

struct SlideInView: ViewModifier {
    var isActive: Bool = true
    
    @State var height: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .opacity(isActive ? 1 : 0)
            .offset(y: isActive ? 0 : height)
            .scaleEffect(
                x: isActive ? 1 : 0.7,
                y: isActive ? 1 : 1.3
            )
            .blur(radius: isActive ? 0 : 8)
            .drawingGroup()
            .getHeight { height = $0 }
    }
}

extension View {
    func slideIn(_ isActive: Bool = true) -> some View {
        modifier(SlideInView(isActive: isActive))
    }
    
    func slideIn(_ range: StepRange) -> some View {
        withStepIndex { view, step in
            view.slideIn(range(step))
        }
    }
}

// split into words, slide in each with delay
struct SlideInText: View {
    init(
        _ text: String = "",
        
        separator: String = " ",
        isActive: Bool = true
    ) {
        components = Array(text.split(separator: separator).enumerated())
        self.separator = separator
        self.isActive = isActive
    }
    
    let components: [(offset: Int, element: String.SubSequence)]
    let separator: String
    
    var isActive: Bool = true
    @State var height: CGFloat = 0
    @State var visibleIndex = 0
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(components, id: \.offset) { offset, word in
                Text(word + (offset < components.count - 1 ? separator : ""))
                    .slideIn(offset < visibleIndex)
            }
        }
        .drawingGroup()
        .animation(.text, value: visibleIndex)
        .task(id: isActive) {
            try? await onChange()
        }
    }
    
    func onChange() async throws {
        let duration = CGFloat(300)
        let count = components.count
        let millis = duration / CGFloat(count)
        try await Task.sleep(for: .milliseconds(millis))
        
        if isActive && visibleIndex < count {
            visibleIndex += 1
            try await onChange()
        } else if !isActive && visibleIndex > 0 {
            visibleIndex -= 1
            try await onChange()
        }
    }
}

struct SildeInTextPreview: View {
    @State var count = 0
    
    var body: some View {
        VStack {
            //      Text("Hello, World!").slideIn(count % 2 == 0)
            SlideInText("How are you doing", isActive: count % 2 == 0)
                .font(.slideBody)
                .padding(50)
        }
        .onAppear {
            Task {
                while true {
                    try! await Task.sleep(for: .seconds(2))
                    withAnimation {
                        count += 1
                    }
                }
            }
        }
    }
}

#Preview {
    SildeInTextPreview()
}
