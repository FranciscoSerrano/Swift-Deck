//
//  View+Extentions.swift
//
//
//  Created by Francisco Serrano on 8/22/24.
//

import SwiftUI

extension View {
    func getFrame(_ rect: @escaping (CGRect) -> Void) -> some View {
        background {
            GeometryReader { proxy in
                let frame = proxy.frame(in: .global)
                Color.clear.onChange(of: frame, initial: true) {
                    rect(frame)
                }
            }
        }
    }
    
    func getWidth(_ width: @escaping (CGFloat) -> Void) -> some View {
        background {
            GeometryReader { proxy in
                let width0 = proxy.frame(in: .global).width
                Color.clear.onChange(of: width0, initial: true) {
                    width(width0)
                }
            }
        }
    }
    
    func getHeight(_ height: @escaping (CGFloat) -> Void) -> some View {
        background {
            GeometryReader { proxy in
                let height0 = proxy.frame(in: .global).height
                Color.clear.onChange(of: height0, initial: true) {
                    height(height0)
                }
            }
        }
    }
}
