//
//  CommentView.swift
//  CommentView
//
//  Created by itsnk on 7/16/21.
//

import SwiftUI
import Resolver

struct CommentView: View {
  @Injected private var repository: DataRepository
  @State private var presentingProfileView: Bool = false
  var review: Review!
  var commentDict = [Int:String]()
  
  var body: some View {
    ScrollView {
      ForEach(1 ..< 10) { _ in
        VStack(spacing: 4) {
          HStack {
            Button {
              presentingProfileView = true
            } label: {
              Image(systemName: "person.circle")
                .resizable()
                .frame(width: 36, height: 36)
            }

            VStack(alignment: .leading, spacing: 4) {
              Group {
                Button {
                  presentingProfileView = true
                } label: {
                  Text("Le Nam Khanh").bold().font(.body)
                }
                Text("WHEREZZZ DAH FOOD AT CUZZZZ????? IF MAN CATCH U OUT HERE WIT DAH POLISH U BE DEAD FAM!")
              }
              .lineLimit(nil)

              // timestamp
              Text("1h ago")
                .font(.caption2.weight(.light))
                .padding(.vertical, 4)
            }
          }
          Divider()
        } // VStack
      } // ForEach
      .padding()
      .sheet(isPresented: $presentingProfileView) {
//        HomeView().accentColor(Color.pink)
//        let user = repository.getUser(id: )
//        ProfileView(user: <#T##User#>)
      }
    } // ScrollView
    .navigationTitle("Comments")
    .navigationBarTitleDisplayMode(.inline)
  }
}

struct CommentView_Previews: PreviewProvider {
  static var previews: some View {
    CommentView()
  }
}
