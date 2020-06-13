//
//  ViewController.swift
//  swift_storageTest
//
//  Created by Yuki Shinohara on 2020/06/13.
//  Copyright © 2020 Yuki Shinohara. All rights reserved.
//
import FirebaseStorage
import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    @IBOutlet var label: UILabel!
    @IBOutlet var imageView: UIImageView!
    private let storage = Storage.storage().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.contentMode = .scaleAspectFit
        
        guard let urlString = UserDefaults.standard.value(forKey: "url") as? String, let url = URL(string: urlString) else {
            return
        }
        label.text = urlString
        
        let task = URLSession.shared.dataTask(with: url) { (data, _, error) in
            guard let data = data, error == nil else {
                return
            }
            DispatchQueue.main.async {
                let image = UIImage(data: data)
                self.imageView.image = image
            }
            
        }
        
        task.resume()
    }
    @IBAction func didTapButton(_ sender: Any) {
        let picker = UIImagePickerController() //画像を取得する
        picker.sourceType = .photoLibrary //取得先
        picker.delegate = self
        picker.allowsEditing = true //取得した画像を編集するかどうか
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){
        picker.dismiss(animated: true, completion: nil)
        
        guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {return}
        
        guard let imageData = image.pngData() else {return}
        
        let ref = storage.child("images/file.png")
        ref.putData(imageData, metadata: nil) { (_, error) in
            guard error == nil else {
                return
            }
            ref.downloadURL { (url, error) in
                guard let url = url, error == nil else {return}
                let urlString = url.absoluteString
                
                DispatchQueue.main.async {
                    self.label.text = urlString
                    self.imageView.image = image
                }
                
                print("DownloadURL: \(urlString)")
                UserDefaults.standard.set(urlString, forKey: "url")
            }
        }
        
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController){
        picker.dismiss(animated: true, completion: nil)
    }
    
    
}

