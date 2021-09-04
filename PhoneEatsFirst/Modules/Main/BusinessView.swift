//
//  BusinessView.swift
//  PhoneEatsFirst
//
//  Created by itsnk on 7/14/21.
//

import Resolver
import SwiftUI
import SDWebImageSwiftUI

enum ViewMode: Int {
  case info
  case reviews
}

// TODO: redo business
struct BusinessView: View {
  var business: Business

  @Environment(\.presentationMode) private var presentationMode

  @State private var chosenBusiness: Business?
  @State private var presentingInfoView: Bool = false
  @State private var pickerSelection: ViewMode = .info

  var body: some View {
    NavigationView {
      GeometryReader { geometry in
        ScrollView {
          VStack {
            if let imageUrl = business.imageUrl {
              WebImage(url: URL(string: imageUrl)!)
                .resizable()
                .placeholder(Image("placeholder"))
                .transition(.fade(duration: 0.5))
                .scaledToFill()
            } else {
              Image("placeholder")
                .resizable()
                .scaledToFill()
            }

            HStack {
              VStack(alignment: .leading) {
                Text(business.name).font(.largeTitle).bold()

                Text(business.address).lineLimit(nil)

                HStack {
                  let stars = 5 // review's stars
                  Label(String(format: "%d", stars), systemImage: "star.fill")
                    .font(.footnote)
                    .foregroundColor(Color(.systemPink))

                  let price = 1
                  Text(String(repeating: "$", count: price))
                    .font(.footnote)
                }
                .padding(.top, 8)
              }

              Spacer()

              VStack(alignment: .center, spacing: 8) {
                HStack(alignment: .center) {
                  Button {
                    print("share restaurant")
                  } label: {
                    Image(systemName: "square.and.arrow.up")
                      .font(.title)
                      .frame(width: 36, height: 36)
                  }
                  .sheet(item: $chosenBusiness) { business in
                    ActivityView(activityItems: [business.name])
                  }

                  Divider().frame(width: 4)

                  Button {
                    print("bookmark restaurant")
                  } label: {
                    Image(systemName: "bookmark")
                      .font(.title)
                      .frame(width: 36, height: 36)
                  }
                }

                Divider().frame(width: 96)

                HStack(alignment: .center) {
                  Link(destination: URL(string: "tel:" + business.phone!)!) {
                    Image(systemName: "phone")
                      .font(.title)
                      .frame(width: 36, height: 36)
                  }
                  .disabled(business.phone == nil)

                  Divider().frame(width: 4)

                  Link(destination: URL(string: business.website!)!) {
                    Image(systemName: "globe")
                      .font(.title)
                      .frame(width: 36, height: 36)
                  }
                  .disabled(business.website == nil)
                }
              }
            } // HStack
            .frame(width: 180, height: 180)

            Picker("Main", selection: $pickerSelection) {
              Text("Info").tag(ViewMode.info)
              Text("Reviews").tag(ViewMode.reviews)
            }
            .pickerStyle(.segmented)
            .padding(8)

            // main content view
            PageView(selection: $pickerSelection, indexDisplayMode: .never) {
              InfoView(business: business).tag(ViewMode.info)
              
              // TODO: add review view here
//              ReviewView().tag(ViewMode.reviews)
            }
            .ignoresSafeArea(.container, edges: .vertical)
          } // VStack
          .padding()
          .frame(width: geometry.size.width, height: geometry.size.height)
          .navigationTitle(business.name)
          .navigationBarTitleDisplayMode(.inline)
          .navigationViewStyle(.stack)
          .toolbar {
            Button {
              presentationMode.wrappedValue.dismiss()
            } label: {
              Text("Done").bold()
            }
          }
        } // ScrollView
        .frame(maxWidth: .infinity, maxHeight: .infinity)
      } // GeometryReader
    } // NavigationView
  }
}

struct InfoView: View {
  var business: Business
  @State private var pickerSelection: ViewMode = .info
  var body: some View {
//    ScrollView {
    VStack(spacing: 16) {
      Button {} label: {
        ZStack {
          RoundedRectangle(cornerRadius: 16).strokeBorder().frame(height: 36)
          Text("View Menu")
        }
        .padding(.horizontal, 128)
        .padding(.top, 8)
      }
      Text("Open Hours").font(.title2)

      HStack {
        VStack(alignment: .leading, spacing: 8) {
          Text("Monday")
          Text("Tuesday")
          Text("Wednesday")
          Text("Thursday")
          Text("Friday")
          Text("Saturday")
          Text("Sunday")
        }

        Spacer()

        VStack(alignment: .trailing, spacing: 8) {
          Text("12:00 AM - 12:00 PM")
          Text("12:00 AM - 12:00 PM")
          Text("12:00 AM - 12:00 PM")
          Text("12:00 AM - 12:00 PM")
          Text("12:00 AM - 12:00 PM")
          Text("12:00 AM - 12:00 PM")
          Text("12:00 AM - 12:00 PM")
        }
      }
    }.padding(8)
//    }
  }
}

struct ReviewsView: View {
  var reviews: [Review]
  
  @Injected private var repository: DataRepository

  @State private var chosenBusiness: Business? = nil
  @State private var presentingActualReview: Bool = false
  @State private var presentingReview: Bool = false
  @State private var isBookmarked: Bool? = false

  private let formatter = RelativeDateTimeFormatter()

  var body: some View {
    VStack(spacing: 0) {
      ScrollView {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 300))]) {
          ForEach(repository.reviews) { review in
            // NOTE: handle invalid database
            let user = repository.getUser(id: review.userId)!
            let business = repository.getBusiness(id: review.businessId)!

            Button {
              presentingReview = true
            } label: {
              ZStack(alignment: .bottom) {
                // background
                Image("placeholder")
                  .resizable()
                  .scaledToFit()
                  .cornerRadius(20.0)

                VStack {
                  let topView = VStack(alignment: .leading) {
                    HStack {
                      Text(user.firstName)
                        .bold()
                        .font(.body)

                      Spacer()

//                      Text(formatter.localizedString(for: review.creationDate, relativeTo: Date())
//                        .font(.footnote)
                    }

                    Spacer()

                    HStack {
                      HStack {
                        ForEach(0 ..< Int(review.rating)) { _ in
                          Image(systemName: "star.fill")
                            .font(.footnote)
                            .foregroundColor(Color(.systemPink))
                        }
                      }

                      Spacer()

                      Button {
                        // report
                        print("\(user) has been reported")
                      } label: {
                        Image(systemName: "flag")
                      }
                    }
                  }
                  .padding(.horizontal)
                  .padding(.vertical, 10)

                  // top label
                  RoundedRectangle(cornerRadius: 10.0)
                    .foregroundColor(Color(.secondarySystemBackground))
                    .overlay(topView)
                    .frame(maxHeight: 70)
                    .padding(12)

                  Spacer()

                  // label
                  let bottomView = VStack(alignment: .leading) {
                    Text(business.name)
                      .bold()
                      .font(.title3)

                    let addr = business.address + ", " + business.city + ", "
                      + business.state + " " + business.zipcode
                    Text(addr)
                      .font(.footnote)

                    Spacer()

                    HStack(spacing: 16) {
                      if let stars = business.stars {
                        Label(String(format: "%.1f", stars), systemImage: "star.fill")
                          .font(.footnote)
                          .foregroundColor(Color(.systemPink))
                      }

                      if let price = business.price {
                        Text(String(repeating: "$", count: price))
                          .font(.footnote)
                      }

                      Spacer()

                      Button {
                        chosenBusiness = business
                      } label: {
                        Image(systemName: "square.and.arrow.up")
                      }

                      Button {
                        // bookmark
//                        if isBookmarked == true {
//                            isBookmarked = false
//                        }
//                        else {
//                            isBookmarked = true
//                        }

                        print("user bookmarked \(String(describing: business.id))")

                      } label: {
                        Image(systemName: "bookmark")
                      }
                    }
                  }
                  .padding(.horizontal)
                  .padding(.vertical, 10)

                  // bottom label
                  RoundedRectangle(cornerRadius: 10.0)
                    .foregroundColor(Color(.secondarySystemBackground))
                    .overlay(bottomView, alignment: .leading)
                    .frame(maxHeight: 90)
                    .padding(12)
                }
              } // ZStack
            } // Button
            .sheet(isPresented: $presentingReview) {
              // TODO: implement review view, get chosen view to be presented
//              ReviewView().accentColor(Color.pink)
            }
          } // ForEach
          .padding()
          .sheet(item: $chosenBusiness) { business in
            ActivityView(activityItems: [business.name])
          }
        } // LazyVGrid
      } // ScrollView
    }
  }
}

// TODO: sticky header

//
//  ContentView.swift
//  Sticky Header
//
//  Created by Brandon Baars on 1/3/20.
//  Copyright © 2020 Brandon Baars. All rights reserved.
//
import SwiftUI

extension Font {
  static func avenirNext(size: Int) -> Font {
    Font.custom("Avenir Next", size: CGFloat(size))
  }

  static func avenirNextRegular(size: Int) -> Font {
    Font.custom("AvenirNext-Regular", size: CGFloat(size))
  }
}

struct ContentAView: View {
  private let imageHeight: CGFloat = 300
  private let collapsedImageHeight: CGFloat = 75

  @ObservedObject private var articleContent = ViewFrame()
  @State private var titleRect: CGRect = .zero
  @State private var headerImageRect: CGRect = .zero

  func getScrollOffset(_ geometry: GeometryProxy) -> CGFloat {
    geometry.frame(in: .global).minY
  }

  func getOffsetForHeaderImage(_ geometry: GeometryProxy) -> CGFloat {
    let offset = getScrollOffset(geometry)
    let sizeOffScreen = imageHeight - collapsedImageHeight

    // if our offset is roughly less than -225 (the amount scrolled / amount off screen)
    if offset < -sizeOffScreen {
      // Since we want 75 px fixed on the screen we get our offset of -225 or anything less than. Take the abs value of
      let imageOffset = abs(min(-sizeOffScreen, offset))

      // Now we can the amount of offset above our size off screen. So if we've scrolled -250px our size offscreen is -225px we offset our image by an additional 25 px to put it back at the amount needed to remain offscreen/amount on screen.
      return imageOffset - sizeOffScreen
    }

    // Image was pulled down
    if offset > 0 {
      return -offset
    }

    return 0
  }

  func getHeightForHeaderImage(_ geometry: GeometryProxy) -> CGFloat {
    let offset = getScrollOffset(geometry)
    let imageHeight = geometry.size.height

    if offset > 0 {
      return imageHeight + offset
    }

    return imageHeight
  }

  // at 0 offset our blur will be 0
  // at 300 offset our blur will be 6
  func getBlurRadiusForImage(_ geometry: GeometryProxy) -> CGFloat {
    let offset = geometry.frame(in: .global).maxY

    let height = geometry.size.height
    let blur = (height - max(offset, 0)) / height // (values will range from 0 - 1)

    return blur * 6 // Values will range from 0 - 6
  }

  // 1
  private func getHeaderTitleOffset() -> CGFloat {
    let currentYPos = titleRect.midY

    // (x - min) / (max - min) -> Normalize our values between 0 and 1

    // If our Title has surpassed the bottom of our image at the top
    // Current Y POS will start at 75 in the beggining. We essentially only want to offset our 'Title' about 30px.
    if currentYPos < headerImageRect.maxY {
      let minYValue: CGFloat = 50.0 // What we consider our min for our scroll offset
      let maxYValue: CGFloat =
        collapsedImageHeight // What we start at for our scroll offset (75)
      let currentYValue = currentYPos

      let percentage = max(-1,
                           (currentYValue - maxYValue) /
                             (maxYValue -
                               minYValue)) // Normalize our values from 75 - 50 to be between 0 to -1, If scrolled past that, just default to -1
      let finalOffset: CGFloat =
        -30.0 // We want our final offset to be -30 from the bottom of the image header view
      // We will start at 20 pixels from the bottom (under our sticky header)
      // At the beginning, our percentage will be 0, with this resulting in 20 - (x * -30)
      // as x increases, our offset will go from 20 to 0 to -30, thus translating our title from 20px to -30px.

      return 20 - (percentage * finalOffset)
    }

    return .infinity
  }

  var body: some View {
    ScrollView {
      VStack {
        VStack(alignment: .leading, spacing: 10) {
          HStack {
            Image("placeholder")
              .resizable()
              .scaledToFill()
              .frame(width: 55, height: 55)
              .clipShape(Circle())
              .shadow(radius: 4)

            VStack(alignment: .leading) {
              Text("Article Written By")
                .font(.avenirNext(size: 12))
                .foregroundColor(.gray)
              Text("Brandon Baars")
                .font(.avenirNext(size: 17))
            }
          }

          Text("02 January 2019 • 5 min read")
            .font(.avenirNextRegular(size: 12))
            .foregroundColor(.gray)

          Text(
            "WHEREZZZ DAH FOOD AT CUZZZZ????? IF MAN CATCH U OUT HERE WIT DAH POLISH U BE DEAD FAM!"
          )
          .font(.avenirNext(size: 28))
          .background(GeometryGetter(rect: self.$titleRect)) // 2

          Text(loremIpsum)
            .lineLimit(nil)
            .font(.avenirNextRegular(size: 17))
        }
        .padding(.horizontal)
        .padding(.top, 16.0)
      }
      .offset(y: imageHeight + 16)
      .background(GeometryGetter(rect: $articleContent.frame))

      GeometryReader { geometry in
        // 3
        ZStack(alignment: .bottom) {
          Image("placeholder")
            .resizable()
            .scaledToFill()
            .frame(
              width: geometry.size.width,
              height: self.getHeightForHeaderImage(geometry)
            )
            .blur(radius: self.getBlurRadiusForImage(geometry))
            .clipped()
            .background(GeometryGetter(rect: self.$headerImageRect))

          // 4
          Text(
            "WHEREZZZ DAH FOOD AT CUZZZZ????? IF MAN CATCH U OUT HERE WIT DAH POLISH U BE DEAD FAM!"
          )
          .font(.avenirNext(size: 17))
          .foregroundColor(.white)
          .offset(x: 0, y: self.getHeaderTitleOffset())
        }
        .clipped()
        .offset(x: 0, y: self.getOffsetForHeaderImage(geometry))
      }.frame(height: imageHeight)
        .offset(x: 0, y: -(articleContent.startingRect?.maxY ?? UIScreen.main.bounds.height))
    }.edgesIgnoringSafeArea(.all)
  }
}

let loremIpsum = """
WHEREZZZ DAH FOOD AT CUZZZZ????? IF MAN CATCH U OUT HERE WIT DAH POLISH U BE DEAD FAM!
WHEREZZZ DAH FOOD AT CUZZZZ????? IF MAN CATCH U OUT HERE WIT DAH POLISH U BE DEAD FAM!
WHEREZZZ DAH FOOD AT CUZZZZ????? IF MAN CATCH U OUT HERE WIT DAH POLISH U BE DEAD FAM!WHEREZZZ DAH FOOD AT CUZZZZ????? IF MAN CATCH U OUT HERE WIT DAH POLISH U BE DEAD FAM!WHEREZZZ DAH FOOD AT CUZZZZ????? IF MAN CATCH U OUT HERE WIT DAH POLISH U BE DEAD FAM!WHEREZZZ DAH FOOD AT CUZZZZ????? IF MAN CATCH U OUT HERE WIT DAH POLISH U BE DEAD FAM!WHEREZZZ DAH FOOD AT CUZZZZ????? IF MAN CATCH U OUT HERE WIT DAH POLISH U BE DEAD FAM!WHEREZZZ DAH FOOD AT CUZZZZ????? IF MAN CATCH U OUT HERE WIT DAH POLISH U BE DEAD FAM!WHEREZZZ DAH FOOD AT CUZZZZ????? IF MAN CATCH U OUT HERE WIT DAH POLISH U BE DEAD FAM!WHEREZZZ DAH FOOD AT CUZZZZ????? IF MAN CATCH U OUT HERE WIT DAH POLISH U BE DEAD FAM!WHEREZZZ DAH FOOD AT CUZZZZ????? IF MAN CATCH U OUT HERE WIT DAH POLISH U BE DEAD FAM!WHEREZZZ DAH FOOD AT CUZZZZ????? IF MAN CATCH U OUT HERE WIT DAH POLISH U BE DEAD FAM!WHEREZZZ DAH FOOD AT CUZZZZ????? IF MAN CATCH U OUT HERE WIT DAH POLISH U BE DEAD FAM!WHEREZZZ DAH FOOD AT CUZZZZ????? IF MAN CATCH U OUT HERE WIT DAH POLISH U BE DEAD FAM!WHEREZZZ DAH FOOD AT CUZZZZ????? IF MAN CATCH U OUT HERE WIT DAH POLISH U BE DEAD FAM!WHEREZZZ DAH FOOD AT CUZZZZ????? IF MAN CATCH U OUT HERE WIT DAH POLISH U BE DEAD FAM!
"""

class ViewFrame: ObservableObject {
  var startingRect: CGRect?

  @Published var frame: CGRect {
    willSet {
      if startingRect == nil {
        startingRect = newValue
      }
    }
  }

  init() {
    frame = .zero
  }
}

struct GeometryGetter: View {
  @Binding var rect: CGRect

  var body: some View {
    GeometryReader { geometry in
      AnyView(Color.clear)
        .preference(key: RectanglePreferenceKey.self, value: geometry.frame(in: .global))
    }.onPreferenceChange(RectanglePreferenceKey.self) { value in
      self.rect = value
    }
  }
}

struct RectanglePreferenceKey: PreferenceKey {
  static var defaultValue: CGRect = .zero

  static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
    value = nextValue()
  }
}
