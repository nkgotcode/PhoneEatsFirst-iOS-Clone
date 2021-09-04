//
//  ThirdPartyAuthView.swift
//  PhoneEatsFirst
//
//  Created by itsnk on 7/12/21.
//

import SwiftUI

struct ThirdPartyAuthView: View {
  var title: String
  
  var body: some View {
    VStack {
      Text(title)
        .foregroundColor(Color(.label))
        .padding(4)
      
      HStack {
        Button {
          // google
        } label: {
          Image(systemName: "graduationcap")
            .frame(minWidth: 100, minHeight: 50)
            .foregroundColor(.pink)
            .background(
              RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke()
            )
            .foregroundColor(Color(.placeholderText))
        }
        .contentShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .hoverEffect(.highlight)
        
        Button {
          // facebook
        } label: {
          Image(systemName: "circles.hexagonpath")
            .frame(minWidth: 100, minHeight: 50)
            .foregroundColor(.pink)
            .background(
              RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke()
            )
            .foregroundColor(Color(.placeholderText))
        }
        .contentShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .hoverEffect(.highlight)
        
        Button {
          // apple
        } label: {
          Image(systemName: "applelogo")
            .frame(minWidth: 100, minHeight: 50)
            .foregroundColor(.pink)
            .background(
              RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke()
            )
            .foregroundColor(Color(.placeholderText))
        }
        .contentShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .hoverEffect(.highlight)
      }
    }
  }
}
