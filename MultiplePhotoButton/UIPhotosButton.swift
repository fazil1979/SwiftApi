//
//  UIMultiplePhotosButton.swift
//  UIMultiplePhotos
//
//  Created by Apple on 15/12/16.
//  Copyright © 2016 vijayvirSingh. All rights reserved.
//

import Foundation

import UIKit

// last updations on Apple Swift version 3.0.1 (swiftlang-800.0.58.6 clang-800.0.42.1)


/*
 
   Main peupose of this class is to store images in file managers and store paths in array and return that array to delegate class
 
*/

/*
 <key>NSCameraUsageDescription</key>
 <string>Access needed to use your camera.</string>
 
 <key>NSPhotoLibraryUsageDescription</key>
 <string>Access needed to photo gallery.</string>
 */

let rootFolder :String = "\(NSTemporaryDirectory())UIMultiplePhoto/"

class UIPhotosButton: UIButton , UIImagePickerControllerDelegate,UINavigationControllerDelegate
{
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    // MARK: Outlets
    


    // MARK: Variables
    
    private var  imagePaths  = [String]()
    
    @IBInspectable  var isSingle :Bool = true
    
    var closureDidFinishPicking:  (( _ images  : [String] ) -> ())?
    
    // MARK: CLC
    
      required  init?(coder aDecoder: NSCoder)
    {
         super.init(coder: aDecoder)
    
         print( UIPhotosButton.photoPath() ,  NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String , rootFolder)
  
         self.addTarget(self,action:#selector(addPhoto),
                       for:.touchUpInside)

    }
  
    // MARK: Actions

    // MARK: Functions
    
    class func removeCache()
    {
        let  fileManger = FileManager.default
        
        // Delete 'subfolder' folder
        
        do {
            try fileManger.removeItem(atPath: rootFolder)
        }
        catch let error as NSError {
            print("Ooops! Something went wrong: \(error)")
        }
        
    }
    
    private class func photoPath() -> String
    {
        
        
        let fileManger = FileManager.default
        
        
        if !fileManger.fileExists(atPath: rootFolder)
        {
            do {
                try   fileManger.createDirectory(atPath: "\(rootFolder)", withIntermediateDirectories: false, attributes: nil )

          
                
            } catch let error as NSError
            {
                NSLog("Unable to create directory \(error.debugDescription)")
            }
        }
            
        else
        {
            print("file  exit ")
        }
        
        
        return rootFolder
    }
    
    
   @objc private func addPhoto()
    {
        imagePaths.removeAll()
        PhotoAlertHelper.alertView( title: "AppLog",
                                    message: "Select image." ,
                                    preferredStyle: .actionSheet,
                                    cancelTilte: "Cancel",
                                    otherButtons: "Camera", "Gallery" ,
                                    comletionHandler:{  (index :  Swift.Int)    in
                                        
                                        print(index)
                                        
                                        if index == 0
                                        {
                                            
                                            //  self.camera()
                                            self.gallery()
                                        }
                                        else if  index == 1
                                        {
                                             self.gallery()
                                        }
                                        else if  index == 2
                                        {
                                           
                                        }
                                        
        })
   
        
    }

    
 private   func gallery()
    {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
 
        let keywindow = UIApplication.shared.keyWindow
        
        let mainController = keywindow?.rootViewController
        
       mainController?.present(imagePicker, animated: true, completion: nil)
    }
    
    private func camera()
    {
        
    }
    
    
    //MARK:  ImagePicker view Delegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
    {
        
        
        let filePath  = URL(fileURLWithPath: UIPhotosButton.photoPath() +  " \( NSUUID().uuidString)").appendingPathExtension("jpg")
  
        imagePaths.append(filePath.path)
        
         let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        let imageData = UIImageJPEGRepresentation(image, 0.3)
        
        
        
        do {
            try imageData?.write(to: filePath, options: .atomic)
        } catch {
            print(error)
        }
        
    
        
        
        
        picker.dismiss(animated: true, completion:
            { [unowned self]  () -> Void in
            
                if self.isSingle
                
                {
                    
                    self.closureDidFinishPicking?( self.imagePaths)
                    
                }
                else
                {
                    PhotoAlertHelper.alertView( title: "AppLog",
                                                message: "Would you like to take more photo from" ,
                                                preferredStyle: .actionSheet,
                                                cancelTilte: "No",
                                                otherButtons: "Camera", "Gallery" ,
                                                comletionHandler:{ [unowned self] (index :  Swift.Int)    in
                                                    
                                                    print(index)
                                                    
                                                    if index == 0
                                                    {
                                                        
                                                        //  self.camera()
                                                        self.gallery()
                                                    }
                                                    else if  index == 1
                                                    {
                                                        self.gallery()
                                                    }
                                                    else if  index == 2
                                                    {
                                                        self.closureDidFinishPicking?( self.imagePaths)
                                                     
                                                        
                                                    }
                    })
                }
                
            
                
                
                
            })
        
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController)
    {
        
    }
    
    
}




class PhotoAlertHelper : UIAlertController
    
{
    // make sure you have navigation  view controller
    
    class func alertView(  title : String ,  message : String , preferredStyle : UIAlertControllerStyle, cancelTilte : String ,  otherButtons : String ... , comletionHandler: ((Swift.Int) -> Swift.Void)? = nil )
    {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
        
        for i in otherButtons
        {
            print( UIApplication.phototopViewController() ?? i  )
            
            alert.addAction(UIAlertAction(title: i, style: UIAlertActionStyle.default,
                                          handler: { (action: UIAlertAction!) in
                                            
                                            comletionHandler?(alert.actions.index(of: action)!)
                                            
            }
            ))
            
        }
        if (cancelTilte  as String?) != nil
        {
            alert.addAction(UIAlertAction(title: cancelTilte, style: UIAlertActionStyle.destructive,
                                          handler: { (action: UIAlertAction!) in
                                            
                                            comletionHandler?(alert.actions.index(of: action)!)
                                            
            }
            ))
        }
        
        UIApplication.phototopViewController()?.present(alert,animated: true ,completion:
            {
                
        })
        
    }
    
}

extension UIApplication
{
    class func phototopViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController?
    {
        if let navigationController = controller as? UINavigationController
        {
            return phototopViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController
        {
            if let selected = tabController.selectedViewController
            {
                return phototopViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController
        {
            return phototopViewController(controller: presented)
        }
        
        // need R and d
        //        if let top = UIApplication.shared.delegate?.window??.rootViewController
        //        {
        //            let nibName = "\(top)".characters.split{$0 == "."}.map(String.init).last!
        //
        //            print(  self,"    d  ",nibName)
        //
        //            return top
        //        }
        return controller
    }
}
