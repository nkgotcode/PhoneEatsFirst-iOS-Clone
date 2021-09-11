//
//  EditProfileView.swift
//  PhoneEatsFirst
//
//  Created by itsnk on 7/13/21.
//

// import Firebase
import FirebaseStorage
import Resolver
import SwiftUI
import SDWebImageSwiftUI
import SDWebImage
import Combine

struct EditProfileView: View {
  @Injected var repository: DataRepository
  
  var user: User
  @ObservedObject var profilePictureModel: ProfilePictureModel

  @Environment(\.presentationMode) private var presentationMode

  @State var presentingPhotoLibrary: Bool = false
  
  @State var name: String = "" // TODO:
  @State var bio: String = "" // TODO: fetch from DataRepository
  @State var profileImage = UIImage() // TODO:

//  init(_ name: String, _ bio: String, _ profileImage: UIImage) {
//    self.name = user.firstName + " " + user.lastName
//    self.bio = user.bio!
//    self.profileImage = profilePictureModel.profileImage!
//  }
  
  var body: some View {
    NavigationView {
      VStack () {
        Button {
          presentingPhotoLibrary = true
        } label: {
          Image(uiImage: profilePictureModel.profileImage)
              .resizable()
              .scaledToFill()
              .frame(width: 80, height: 80, alignment: .center)
              .clipShape(Circle())
              .foregroundColor(Color.pink)
        }.sheet(isPresented: $presentingPhotoLibrary) {
          ImagePicker(selectedImage: $profilePictureModel.profileImage, sourceType: .photoLibrary)
        }
        Text("Change Profile Picture").bold() // TODO:

        Spacer()
        
        HStack {
          Image(systemName: "person")
            .frame(width: 18, height: 18)
          TextField("Name", text: $name)
            .autocapitalization(.none)
        }
        .padding()
        .background(
          RoundedRectangle(cornerRadius: 14)
            .foregroundColor(Color(.secondarySystemBackground))
        )

        HStack {
          Image(systemName: "person")
            .frame(width: 18, height: 18)
          TextField("Bio", text: $bio)
            .autocapitalization(.none)
        }
        .padding()
        .background(
          RoundedRectangle(cornerRadius: 14)
            .foregroundColor(Color(.secondarySystemBackground))
        )
      } // VStack
      .navigationBarHidden(true)
      .padding(.vertical, 32)
//      .navigationTitle("Edit Profile")
//      .navigationBarTitleDisplayMode(.inline)
//      .toolbar {
//        ToolbarItem(placement: .navigationBarTrailing) {
//          Button {
//            presentationMode.wrappedValue.dismiss()
//            profilePictureModel.newProfileChange = true
//          } label: {
//            Text("Save").bold()
//          }
//        }
//        ToolbarItem(placement: .navigationBarLeading) {
//          Button {
//            presentationMode.wrappedValue.dismiss()
//          } label: {
//            Text("Save").bold()
//          }
//        }
//      }
    } // NavigationView
  }
}

//struct EditProfileView_Previews: PreviewProvider {
//  static var previews: some View {
//    EditProfileView()
//  }
//}
