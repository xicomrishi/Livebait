import Foundation
import UIKit
import Photos

open class AssetManager {

  open static func getImage(_ name: String) -> UIImage {
    let traitCollection = UITraitCollection(displayScale: 3)
    var bundle = Bundle(for: AssetManager.self)

    if let resource = bundle.resourcePath, let resourceBundle = Bundle(path: resource + "/ImagePicker.bundle") {
      bundle = resourceBundle
    }

    return UIImage(named: name, in: bundle, compatibleWith: traitCollection) ?? UIImage()
  }

  open static func fetch(_ completion: @escaping (_ assets: [PHAsset]) -> Void) {
    guard PHPhotoLibrary.authorizationStatus() == .authorized else { return }

    DispatchQueue.global(qos: .background).async {
      let fetchResult = PHAsset.fetchAssets(with: .image, options: PHFetchOptions())

      if fetchResult.count > 0 {
        var assets = [PHAsset]()
        fetchResult.enumerateObjects({ object, index, stop in
          assets.insert(object, at: 0)
        })

        DispatchQueue.main.async {
          completion(assets)
        }
      }
    }
  }

  open static func resolveAsset(_ asset: PHAsset, size: CGSize = CGSize(width: 720, height: 1280), completion: @escaping (_ image: UIImage?) -> Void) {
    let imageManager = PHImageManager.default()
    let requestOptions = PHImageRequestOptions()
    requestOptions.deliveryMode = .highQualityFormat
    requestOptions.isNetworkAccessAllowed = true

    imageManager.requestImage(for: asset, targetSize: size, contentMode: .aspectFill, options: requestOptions) { image, info in
        
      if let info = info, info["PHImageFileUTIKey"] == nil {
        DispatchQueue.main.async(execute: {
          completion(image)
        })
      }
    }
  }
    
    open static func resolveAssetMS(_ asset: PHAsset, size: CGSize = CGSize(width: 500, height: 500), completion: @escaping (_ image: UIImage?) -> Void) {
        let imageManager = PHImageManager.default()
        let requestOptions = PHImageRequestOptions()
        requestOptions.deliveryMode = .highQualityFormat
        requestOptions.isNetworkAccessAllowed = true
        
        imageManager.requestImage(for: asset, targetSize: size, contentMode: .aspectFill, options: requestOptions) { image, info in
                DispatchQueue.main.async(execute: {
                    completion(image)
                })
          
        }
    }


  open static func resolveAssets(_ assets: [PHAsset], size: CGSize = CGSize(width: 720, height: 1280)) -> [UIImage] {
    let imageManager = PHImageManager.default()
    let requestOptions = PHImageRequestOptions()
    requestOptions.isSynchronous = true

    var images = [UIImage]()
    for asset in assets {
      imageManager.requestImage(for: asset, targetSize: size, contentMode: .aspectFill, options: requestOptions) { image, info in
        if let image = image {
          images.append(image)
        }
      }
    }
    return images
  }
   

    
    
}
