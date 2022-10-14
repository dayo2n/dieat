//
//  PostViewModel.swift
//  diEAT_SwiftUI
//
//  Created by 문다 on 2022/10/12.
//

import SwiftUI
import Firebase

typealias FirestoreCompletion = ((Error?) -> Void)?

class EditPostViewModel: ObservableObject{
    
    func uploadPost(selectedDate: Date, image: UIImage, caption: String, completion: FirestoreCompletion) {
        guard let user = AuthViewModel.shared.currentUser else { return }
        
        ImageUploader.uploadImage(image: image, type: .post) { imageUrl in
            let data = ["uid": user.id,
                        "username": user.username,
                        "imageUrl": imageUrl,
                        "caption": caption,
                        "timestamp": Timestamp(date: selectedDate)] as [String: Any]
            Firestore.firestore().collection("posts").addDocument(data: data, completion: completion)
        }
    }
}