//
//  ImageManager.swift
//  Live-Snap
//
//  Created by Oleg Abalonski on 1/24/18.
//  Copyright © 2018 Oleg Abalonski. All rights reserved.
//

import Photos

class PhotoAlbum {
    var name: String
    var assets: PHFetchResult<PHAsset>
    
    init(name: String, assets: PHFetchResult<PHAsset>) {
        self.name = name
        self.assets = assets
    }
    
    func assetArray() -> [PHAsset] {
        var results = [PHAsset]()
        assets.enumerateObjects { (asset: PHAsset, index: Int, stop: UnsafeMutablePointer<ObjCBool>) in
            results.append(asset)
        }
        return results
    }
}

class ImageManager {
    
    static let shared = ImageManager()
    
    func grabAllPhotoAlbums() -> [PhotoAlbum] {
        
        var albumAssets = [String: PHFetchResult<PHAsset>]()
        var results = [PhotoAlbum]()
        
        //grabbing all photo assets
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        let fetchedAssets = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        if fetchedAssets.count > 0 {
            albumAssets["All Photos"] = fetchedAssets
        } else {
            print("No Photos in Library")
            return results
        }
        
        //grabbing user album assets
        let albumAssetCollections = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: PHFetchOptions())
        albumAssetCollections.enumerateObjects{ (assetCollection: PHAssetCollection, index: Int, stop: UnsafeMutablePointer<ObjCBool>) in
            if let albumName = assetCollection.localizedTitle {
//                let fetchOptions = PHFetchOptions()
//                fetchOptions.predicate = NSPredicate(format: "title = %@", albumName)
//                //fetchOptions.predicate = NSPredicate(format: "title = %@ AND mediaType = %d", argumentArray: [albumName, PHAssetMediaType.image])
//                //fetchOptions.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
//                //How to combine predicates???
//
//                var assetCollection = PHAssetCollection()
//                let collection = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
//                if let firstObject = collection.firstObject {
//                    assetCollection = firstObject
//                }
//
                let newFetchOptions = PHFetchOptions()
                newFetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
                let fetchedAssets = PHAsset.fetchAssets(in: assetCollection, options: newFetchOptions)
                if fetchedAssets.count > 0 {
                    albumAssets[albumName] = fetchedAssets
                }
            }
        }
        
        
        //Grabing smart album assets
        let smartAlbumSubtypes: [PHAssetCollectionSubtype] = [.smartAlbumFavorites,
                                                              .smartAlbumRecentlyAdded,
                                                              .smartAlbumSelfPortraits,
                                                              .smartAlbumScreenshots,
                                                              .smartAlbumDepthEffect,
                                                              .smartAlbumLivePhotos]
        
        
        for albumSubtype in smartAlbumSubtypes {
            let smartAlbum = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: albumSubtype, options: PHFetchOptions())
            smartAlbum.enumerateObjects{ (assetCollection: PHAssetCollection, index: Int, stop: UnsafeMutablePointer<ObjCBool>) in
                if let albumName = assetCollection.localizedTitle {
//                    var assetCollection = PHAssetCollection()
//                    if let firstObject = smartAlbum.firstObject {
//                        assetCollection = firstObject
//                    }
                    let fetchOptions = PHFetchOptions()
                    fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
                    let fetchedAssets = PHAsset.fetchAssets(in: assetCollection, options: fetchOptions)
                    if fetchedAssets.count > 0 {
                        albumAssets[albumName] = fetchedAssets
                    }
                }
            }
        }
        
        for (albumName, assets) in albumAssets {
            results.append(PhotoAlbum(name: albumName, assets: assets))
        }
        return results
    }
    
    func grabThumbnailsFromPhotoAlbum(photoAlbum: PhotoAlbum, completion: @escaping ([UIImage]?) -> ()) {
        
        var photoThumbnails = [UIImage]()
        
        let imageManager = PHImageManager.default()
        
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = true
        requestOptions.deliveryMode = .highQualityFormat
        
        let imageSize = CGSize(width: 250, height: 250)
        
        for index in 0 ..< photoAlbum.assets.count {
            imageManager.requestImage(for: photoAlbum.assets.object(at: index), targetSize: imageSize, contentMode: .aspectFill, options: requestOptions, resultHandler: { (image: UIImage?, info: [AnyHashable : Any]?) in
                guard let thumbnail = image else { completion(nil); return }
                photoThumbnails.append(thumbnail)
                
                if index == photoAlbum.assets.count - 1 {
                    completion(photoThumbnails)
                }
            })
        }
        
    }
    
    func grabFullPhotoFromAsset(asset: PHAsset, completion: @escaping (UIImage?) -> ()) {
        
        let imageManager = PHImageManager.default()
        
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = true
        requestOptions.deliveryMode = .highQualityFormat
        
        imageManager.requestImage(for: asset, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFill, options: requestOptions, resultHandler: { (image: UIImage?, info: [AnyHashable : Any]?) in
            completion(image)
        })
    }
    
}
