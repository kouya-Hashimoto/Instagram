//
//  PostTableViewCell.swift
//  Instagram
//
//  Created by 橋本晃矢 on 2021/05/30.
//

import UIKit
import FirebaseUI
import Firebase

class PostTableViewCell: UITableViewCell {
    
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var likeLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var commentsStackView: UIStackView!
    @IBOutlet weak var commentButton: UIButton!
    
    private var data: PostData?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func setPostDate(_ postData: PostData){
        data = postData
        //画像の表示
        postImageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
        let imageRef = Storage.storage().reference().child(Const.ImagePath).child(postData.id + ".jpg")
        postImageView.sd_setImage(with: imageRef)
        
        //キャプションの表示
        self.captionLabel.text = "\(postData.name!) : \(postData.caption!)"
        
        //日付の表示
        self.dateLabel.text = ""
        if let date = postData.date {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm"
            let dateString = formatter.string(from: date)
            self.dateLabel.text = dateString
        }
        
        //いいね数の表示
        let likeNumber = postData.likes.count
        likeLabel.text = "\(likeNumber)"
        
        if postData.isLiked {
            let buttonImage = UIImage(named: "like_exist")
            self.likeButton.setImage(buttonImage, for: .normal)
        } else {
            let buttonImage = UIImage(named: "like_none")
            self.likeButton.setImage(buttonImage, for: .normal)
        }

        for comment in postData.comments {
            let label = UILabel()
            label.text = comment
            commentsStackView.addArrangedSubview(label)
        }
    }
//    @IBAction func commentButton(_ sender: Any) {
//
//        //投稿コメントの保存場所を定義する
//        let commmentRef = Firestore.firestore().collection(Const.comment).document()
//
//        //FireStoreに投稿データを保存する
//        let name = Auth.auth().currentUser?.displayName
//        let commmentDic = [
//            "name": name!,
//            "comment": textField.text!,
//            "date": FieldValue.serverTimestamp(),
//        ] as [String : Any]
//        commmentRef.setData(commmentDic)
//
//    }
}
