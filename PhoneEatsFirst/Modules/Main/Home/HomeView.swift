////
////  HomeView.swift
////  PhoneEatsFirst
////
////  Created by Quan Tran on 7/4/21.
////
//
//import Resolver
//import SwiftUI
//
//struct HomeView: View {
//  @Environment(\.presentationMode) private var presentationMode
//  
//  @Injected private var repository: DataRepository
//  
//  @State private var chosenBusiness: Business? = nil
//  @State private var searchText: String = ""
//  @State private var changed: Bool = false
//  @State private var presentingReviewView: Bool = false
//  
//  private let formatter = RelativeDateTimeFormatter()
//  
//  @State private var reviews: [String] = []
//  
//  var body: some View {
//    let user = repository.getUser(id: repository.user!.id)
////    let business = repository.getBusiness(id: repository.)!
//    
//    VStack(spacing: 0) {
//      SearchBar("Search...", text: $searchText) { changed in
//        self.changed = changed
//      }
//      .padding()
//      .animation(.default)
//      
//      ScrollView {
//        LazyVGrid(columns: [GridItem(.adaptive(minimum: 300))]) {
//          ForEach(1..<reviews.count) { reviewID in
//            // TODO: handle invalid database
//            let review = repository.getReview(id: reviewID)
//            
//            Button {
//              presentingReviewView = true
//            } label: {
//              ZStack(alignment: .bottom) {
//                // background
//                Image("placeholder")
//                  .resizable()
//                  .scaledToFit()
//                  .cornerRadius(20.0)
//                
//                VStack {
//                  let topView = VStack(alignment: .leading) {
//                    HStack {
//                      Text(user!.firstName)
//                        .bold()
//                        .font(.body)
//                      
//                      Spacer()
//                      
////                      Text(formatter.localizedString(for: review.creationDate, relativeTo: Date()))
////                        .font(.footnote)
//                    }
//                    
//                    Spacer()
//                    
//                    HStack {
//                      HStack {
//                        ForEach(0 ..< Int(review.rating)) { _ in
//                          Image(systemName: "star.fill")
//                            .font(.footnote)
//                            .foregroundColor(Color(.systemPink))
//                        }
//                      }
//                      
//                      Spacer()
//                      
//                      Button {
//                        // report
//                        print("\(user) has been reported")
//                      } label: {
//                        Image(systemName: "flag")
//                      }
//                    }
//                  }
//                  .padding(.horizontal)
//                  .padding(.vertical, 10)
//                  
//                  // top label
//                  RoundedRectangle(cornerRadius: 10.0)
//                    .foregroundColor(Color(.secondarySystemBackground))
//                    .overlay(topView)
//                    .frame(maxHeight: 70)
//                    .padding(12)
//                  
//                  Spacer()
//                  
//                  // label
//                  let bottomView = VStack(alignment: .leading) {
//                    Text(business.name)
//                      .bold()
//                      .font(.title3)
//                    
//                    let addr = business.address + ", " + business.city + ", "
//                      + business.state + " " + business.zipcode
//                    Text(addr)
//                      .font(.footnote)
//                    
//                    Spacer()
//                    
//                    HStack(spacing: 16) {
//                      if let stars = business.stars {
//                        Label(String(format: "%.1f", stars), systemImage: "star.fill")
//                          .font(.footnote)
//                          .foregroundColor(Color(.systemPink))
//                      }
//                      
//                      if let price = business.price {
//                        Text(String(repeating: "$", count: price))
//                          .font(.footnote)
//                      }
//                      
//                      Spacer()
//                      
//                      Button {
//                        chosenBusiness = business
//                      } label: {
//                        Image(systemName: "square.and.arrow.up")
//                      }
//                      
//                      Button {
//                        // bookmark
//                        print("user bookmarked \(String(describing: business.id))")
//                      } label: {
//                        Image(systemName: "bookmark")
//                      }
//                    }
//                  }
//                  .padding(.horizontal)
//                  .padding(.vertical, 10)
//                  
//                  // bottom label
//                  RoundedRectangle(cornerRadius: 10.0)
//                    .foregroundColor(Color(.secondarySystemBackground))
//                    .overlay(bottomView, alignment: .leading)
//                    .frame(maxHeight: 90)
//                    .padding(12)
//                }
//              } // ZStack
//            } // Button
//            .sheet(isPresented: $presentingReviewView) {
//              NavigationView {
//                ReviewView(review: review!)
//                  .toolbar {
//                    Button {
//                      presentationMode.wrappedValue.dismiss()
//                    } label: {
//                      Text("Done").bold()
//                    }
//                  }
//              }
//            }
//          } // ForEach
//          .padding()
//          .sheet(item: $chosenBusiness) { business in
//            ActivityView(activityItems: [business.name])
//          }
//        } // LazyVGrid
//      } // ScrollView
//    } // VStack
//    .onAppear {
//      // TODO: fetch the latest reviews from following from the user
//      for user in repository.user!.following {
//        for reviewID in user.userReviewsID {
//          let review = repository.getReview(id: reviewID)
//          reviews.append(review!)
//        }
//      }
//    }
//  }
//}
//
//struct HomeView_Previews: PreviewProvider {
//  static var previews: some View {
//    HomeView()
//  }
//}
