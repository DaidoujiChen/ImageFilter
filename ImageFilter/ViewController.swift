//
//  ViewController.swift
//  ImageFilter
//
//  Created by DaidoujiChen on 2019/4/24.
//  Copyright © 2019 DaidoujiChen. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    // MARK: - Properties
    // UI
    @IBOutlet weak var pathControl: NSPathControl!
    @IBOutlet weak var imageView: NSImageView!
    
    // Data
    let file = FileManager.default
    var folderURL: URL? {
        didSet { folderURLChanged(oldValue) }
    }
    var imageURL: URL? {
        didSet { imageURLChanged(oldValue) }
    }
    
    // MARK: - Method
    private func create(folder: String, in url: URL) {
        var isDirectory = ObjCBool(true)
        let exist = file.fileExists(atPath: url.appendingPathComponent(folder).path, isDirectory: &isDirectory)
        if !exist {
            try? file.createDirectory(at: url.appendingPathComponent(folder), withIntermediateDirectories: false, attributes: nil)
        }
    }
    
    private func moveFile(from: URL, to: URL) {
        try? file.moveItem(at: from, to: to)
    }
    
    private func firstFileIn(folder: URL) -> URL? {
        guard let urls = try? file.contentsOfDirectory(at: folder, includingPropertiesForKeys: nil) else {
            return nil
        }
        
        for url in urls {
            if !url.pathExtension.isEmpty {
                return url
            }
        }
        return nil
    }
    
    override func keyDown(with event: NSEvent) {
        guard let characters = event.charactersIgnoringModifiers else {
            return
        }
        
        switch Int(characters.utf16.first ?? 0) {
        case NSLeftArrowFunctionKey:
            onLikeClicked(self)
            
        case NSRightArrowFunctionKey:
            onDislikeClicked(self)
            
        default:
            break
        }
    }
    
    // MARK: - Event
    // MARK: Property
    private func folderURLChanged(_ oldValue: URL?) {
        guard
            let url = folderURL,
            let firstURL = firstFileIn(folder: url) else {
                return
        }
        
        imageURL = firstURL
        create(folder: "like", in: url)
        create(folder: "dislike", in: url)
    }
    
    private func imageURLChanged(_ oldValue: URL?) {
        guard
            let url = imageURL,
            let data = try? Data(contentsOf: url) else {
                return
        }
        
        imageView.layer = CALayer()
        imageView.layer?.contentsGravity = .resizeAspect
        imageView.layer?.contents = NSImage(data: data)
        imageView.wantsLayer = true
    }
    
    // MARK: UIControlEvent
    @IBAction func pathControlAction(_ sender: NSPathControl) {
        let openPanel = NSOpenPanel()
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseFiles = false
        openPanel.canChooseDirectories = true
        openPanel.begin { [weak self] (res) in
            guard
                let self = self,
                let url = openPanel.url else {
                    return
            }
            self.pathControl.url = url
            self.folderURL = url
        }
    }
    
    @IBAction func onLikeClicked(_ sender: Any) {
        guard
            let imageURL = imageURL,
            let folderURL = folderURL else {
                return
        }
        let likeURLPath = folderURL.appendingPathComponent("like").appendingPathComponent(imageURL.lastPathComponent)
        moveFile(from: imageURL, to: likeURLPath)
        
        if let url = firstFileIn(folder: folderURL) {
            self.imageURL = url
        }
    }
    
    @IBAction func onDislikeClicked(_ sender: Any) {
        guard
            let imageURL = imageURL,
            let folderURL = folderURL else {
                return
        }
        let dislikeURLPath = folderURL.appendingPathComponent("dislike").appendingPathComponent(imageURL.lastPathComponent)
        moveFile(from: imageURL, to: dislikeURLPath)
        
        if let url = firstFileIn(folder: folderURL) {
            self.imageURL = url
        }
    }
    
}

