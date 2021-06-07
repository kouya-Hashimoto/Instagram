//
//  PostDate.swift
//  Instagram
//
//  Created by 橋本晃矢 on 2021/05/30.
//

import UIKit
import Firebase

class PostData: NSObject {
    var id: String
    var name: String?
    var caption: String?
    var date: Date?
    var comments:[String?] = []
    var likes: [String] = []
    var isLiked: Bool = false
    
    init(document: QueryDocumentSnapshot) {
        self.id = document.documentID
        
        let postDic = document.data()
        
        self.name = postDic["name"] as? String
        
        self.caption = postDic["caption"] as? String
        
        if let commment = postDic["comment"] as? [String] {
            self.comments = commment
        }
        
        let timestamp = postDic["date"] as? Timestamp
        self.date = timestamp?.dateValue()
        
        if let likes = postDic["likes"] as? [String] {
            self.likes = likes
        }
        if let myid = Auth.auth().currentUser?.uid {
            //likesの配列の中にmyidが含まれているかチェックすることで、自分がいいねを押しているかを判断
            if self.likes.firstIndex(of: myid) != nil {
                //myidがあれば、いいねを押していると認識する。
                self.isLiked = true
            }
        }
    }
}
