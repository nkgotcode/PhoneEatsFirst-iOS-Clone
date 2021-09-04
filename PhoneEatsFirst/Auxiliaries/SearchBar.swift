//
//  SearchBar.swift
//  PhoneEatsFirst
//
//  Created by Quan Tran on 7/10/21.
//

import SwiftUI

struct SearchBar: View {
  @State var isEditing: Bool = false
  
  private var title: String
  @Binding private var text: String
  private var onEditingChanged: (Bool) -> Void
  private var onCommit: () -> Void
  
  init(
    _ title: String = "",
    text: Binding<String>,
    onEditingChanged: @escaping (Bool) -> Void = { _ in },
    onCommit: @escaping () -> Void = {}
  ) {
    self.title = title
    _text = text
    self.onEditingChanged = onEditingChanged
    self.onCommit = onCommit
  }
  
  var body: some View {
    HStack {
      // magnifying glass icon
      let glass = Image(systemName: "magnifyingglass")
        .resizable()
        .frame(width: 18, height: 18)
        .padding()
        .foregroundColor(Color(.systemPink))
      
      // clear button
      let clear = Button {
        text = ""
      } label: {
        Image(systemName: "xmark.circle.fill")
          .resizable()
          .frame(width: 18, height: 18)
          .padding()
          .foregroundColor(Color(.secondaryLabel))
      }
      .opacity(text.isEmpty ? 0 : 1)
      
      TextField(title, text: $text) { changed in
        isEditing = changed
        onEditingChanged(changed)
      } onCommit: {
        onCommit()
      }
      .padding(10)
      .padding(.horizontal, 36)
      .background(Color(.secondarySystemBackground))
      .cornerRadius(10)
      .overlay(glass, alignment: .leading)
      .overlay(clear, alignment: .trailing)
      
      if isEditing {
        Button("Cancel") {
          text = ""
          isEditing = false
          hideKeyboard()
        }
        .transition(.move(edge: isEditing ? .trailing : .leading).combined(with: .opacity))
      }
    }
  }
}

//struct SearchBar_Previews: PreviewProvider {
//  static var previews: some View {
//    SearchBar(text: .constant("Hello"))
//  }
//}
