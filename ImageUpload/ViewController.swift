//
//  ViewController.swift
//  ImageUpload
//
//  Created by codemac-011i on 30/07/18.
//  Copyright © 2018 codemac. All rights reserved.
//



// hi 
import UIKit
import Alamofire
class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate,UICollectionViewDataSource,UICollectionViewDelegate {
    var imagesarray = [UIImage]()
    var imagePicker = UIImagePickerController()
    
    @IBOutlet weak var collect: UICollectionView!
    @IBOutlet weak var cancel: UIButton!
    @IBOutlet weak var progressbar: UIProgressView!
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imagesarray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CollectionViewCell
        cell.images.image = imagesarray[indexPath.item]
        return cell
    }
    
    
   
    
    
    @IBAction func Cancelbutton(_ sender: UIButton) {
        
        Alamofire.SessionManager.default.session.getTasksWithCompletionHandler { (sessionDataTask, uploadData, downloadData) in
            sessionDataTask.forEach { $0.cancel() }
            uploadData.forEach { $0.cancel() }
            downloadData.forEach { $0.cancel() }
        }
        self.cancel.isHidden = true
        self.progressbar.progress = 0

    }
    
    
    
    @IBAction func UploadButton(_ sender: UIButton) {
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
            print("Button capture")
            
            imagePicker.delegate = self
            imagePicker.sourceType = .savedPhotosAlbum;
            imagePicker.allowsEditing = false
            
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imagesarray.append(image)
            collect.reloadData()
        } else{
            print("Something went wrong")
        }
        
        self.dismiss(animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        cancel.isHidden = true
    }
    
    @IBAction func post(_ sender: UIButton) {
        requestWith(imageData: imagesarray, parameters: ["image_upload_id":"398"])
    }
    
    
    func requestWith(imageData: [UIImage], parameters: [String : Any]){

        let url = "http://www.royaldrive.appcyan.com/api/v1/user/productimage" /* your API url */

        let headers: HTTPHeaders = [
            /* "Authorization": "your_access_token",  in case you need authorization header */
            "x-api-key": "AIzaSyAZmL90WX_iYSDEiuCeJU0PrsdD9WuHfpw5"
        ]

       Alamofire.upload(multipartFormData: { (multipartFormData) in
            for (key, value) in parameters {
                multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key as String)
            }
            multipartFormData.append(UIImageJPEGRepresentation(imageData[0], 1)!, withName: "mainimage", fileName: "image.jpeg", mimeType: "image/jpeg")
            for datas in imageData{
                multipartFormData.append(UIImageJPEGRepresentation(datas, 1)!, withName: "images[]", fileName: "image.jpeg", mimeType: "image/jpeg")
            }

        }, usingThreshold: UInt64.init(), to: url, method: .post, headers: headers) { (result) in
            switch result{
            case .success(let upload, _, _):
                
                upload.responseJSON { response in
                    print(response.result.value)
                    
                }
                upload.uploadProgress { progress in
                    self.progressbar.progress = Float(progress.fractionCompleted)
                    print(progress.fractionCompleted)
                    self.cancel.isHidden = false
                    if progress.fractionCompleted == 1.0 {
                        self.cancel.setImage(UIImage(named: "done.png"), for: UIControlState.normal)
                    }
                }
            case .failure:
                print("Error in upload")
            }
        }
    }
}
