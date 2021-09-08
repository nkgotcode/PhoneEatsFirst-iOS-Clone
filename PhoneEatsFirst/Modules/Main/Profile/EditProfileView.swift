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

struct EditProfileView: View {
  @Injected var repository: DataRepository

  @Environment(\.presentationMode) private var presentationMode

  @State var presentingPhotoLibrary: Bool = false
  
  @State var name: String = "" // TODO:
  @State var bio: String = "" // TODO: fetch from DataRepository
  @State var profileImage = UIImage() // TODO:

  var body: some View {
    NavigationView {
      VStack {
        Button {
          presentingPhotoLibrary = true
        } label: {
          Image(uiImage: profileImage)
            .resizable()
            .scaledToFill()
            .frame(width: 80, height: 80, alignment: .center)
            .cornerRadius(20)

        }.sheet(isPresented: $presentingPhotoLibrary) {
          ImagePicker(selectedImage: $profileImage, sourceType: .photoLibrary)
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
//      .navigationTitle("Edit Profile")
//      .navigationBarTitleDisplayMode(.inline)
//      .toolbar {
//        ToolbarItem(placement: .navigationBarTrailing) {
//          Button {
//            presentationMode.wrappedValue.dismiss()
//          } label: {
//            Text("Done").bold()
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

struct EditProfileView_Previews: PreviewProvider {
  static var previews: some View {
    EditProfileView()
  }
}
