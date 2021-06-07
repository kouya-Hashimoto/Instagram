//
//  HomeViewController.swift
//  Instagram
//
//  Created by 橋本晃矢 on 2021/05/21.
//

import UIKit
import Firebase

class HomeViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    
    //投稿データを格納する配列
    var postArray: [PostData] = []
    var commentArray: [PostData] = []
    
    // ここに追加
    var commentTextField: UITextField?
    
    //Firestoreのリスナー
    var listener: ListenerRegistration?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        //カスタムセルを登録する
        let nib = UINib(nibName: "PostTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "Cell")
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("DEBUG_PRINT: viewWillApper")
        //ログイン済みか確認
        if Auth.auth().currentUser != nil {
            //listenerを登録して投稿データの更新を監視する
            let postsRef = Firestore.firestore().collection(Const.PostPath).order(by: "date", descending: true)
            listener = postsRef.addSnapshotListener() {(querySnapshot, error) in
                if let error = error {
                    print("DEBUG_PRINT: snapshotの取得が失敗しました。\(error)")
                    return
                }
                //取得したdocumentを元にPostDataを作成し、postArrayの配列にする。
                self.postArray = querySnapshot!.documents.map { document in
                    print("DEBUG_PRINT: document取得 \(document.documentID)")
                    let postData = PostData(document: document)
                    return postData
                }
                //TableViewの表示を更新する
                self.tableView.reloadData()
            }
        }
        
        if Auth.auth().currentUser != nil {
            //listenerを登録して投稿データの更新を監視する
            let postsRef = Firestore.firestore().collection(Const.comment).order(by: "date",descending: true)
            listener = postsRef.addSnapshotListener() {(querySnapshot, error) in
                if let error = error {
                    print("DEBUG_PRINT: snapshotの取得が失敗しました。\(error)")
                    return
                }
                //取得したdocumentを元にPostDateを作成し、commentArrayの配列にする。
                self.commentArray = querySnapshot!.documents.map { document in
                    print("DEBUG_PRINT: document取得\(document.documentID)")
                    let commmentData = PostData(document: document)
                    return commmentData
                }
            }
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("DEBUG_PRINT: viewWillappear")
        //Listenerを削除して監視を停止する
        listener?.remove()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //セルを取得してデータを設定する
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! PostTableViewCell
        cell.setPostDate(postArray[indexPath.row])
        
        print(cell.textField!)
        self.commentTextField = cell.textField
        //セル内のボタンのアクションをソースコードで設定する
        cell.likeButton.addTarget(self, action:#selector(handleButton(_:forEvent:)), for: .touchUpInside)
        
        cell.commentButton.addTarget(self, action:#selector(commentHandle(_:forEvent:)), for: .touchUpInside)
        
        return cell
    }
    
    @objc func commentHandle( _ sender: UIButton, forEvent event: UIEvent) {
        //投稿コメントの保存場所を定義する
        let commmentRef = Firestore.firestore().collection(Const.comment).document()
        
        //FireStoreに投稿データを保存する
        let name = Auth.auth().currentUser?.displayName
        let commmentDic = [
            "name": name!,
            "comment": self.commentTextField!.text!,
            "date": FieldValue.serverTimestamp(),
        ] as [String : Any]
        commmentRef.setData(commmentDic)
    }
    
    
    @objc func handleButton( _ sender: UIButton, forEvent event: UIEvent) {
        print("DEBUG_PRINT: likeボタンがタップされました。")
        
        //タップされたセルのインデックスを求める
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.tableView)
        let indexPath = tableView.indexPathForRow(at: point)
        
        //配列からタップされたインデックスのデータを取り出す
        let postData = postArray[indexPath!.row]
        
        //likesを更新する
        if let myid = Auth.auth().currentUser?.uid {
            //更新データを作成する
            var updateValue: FieldValue
            if postData.isLiked {
                //すでにいいねをしている場合は、いいね解除のためmyidを取り除く更新データを作成
                updateValue = FieldValue.arrayRemove([myid])
            } else {
                //今回新たにいいねを押した場合は,myidを追加する更新データを作成
                updateValue = FieldValue.arrayUnion([myid])
            }
            //likesに更新データを書き込む
            let postRef = Firestore.firestore().collection(Const.PostPath).document(postData.id)
            postRef.updateData(["likes": updateValue])
        }
    }
    
}
