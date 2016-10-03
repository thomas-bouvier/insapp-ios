//
//  CommentView.swift
//  Insapp
//
//  Created by Florent THOMAS-MOREL on 9/15/16.
//  Copyright © 2016 Florent THOMAS-MOREL. All rights reserved.
//

import Foundation
import UIKit

protocol CommentViewDelegate {
    func postComment(_ content: String, withTags: [CommentTag])
    func searchForUser(_ word: String)
}

class CommentView: UIView, UITextViewDelegate, ListUserDelegate {
    
    @IBOutlet weak var postButton: UIButton!
    @IBOutlet weak var textView: UITextView!
    
    var delegate:CommentViewDelegate?
    var keyboardFrame: CGRect!
    var tags:[String : String] = [:]
    
    class func instanceFromNib() -> CommentView {
        return UINib(nibName: "CommentView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! CommentView
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.textColor == kDarkGreyColor {
            textView.text = ""
            textView.textColor = .black
        }
        self.checkTextView()
        self.invalidateIntrinsicContentSize()
        self.updateTag()
        self.searchForUser()
    }
    
    func initFrame(keyboardFrame: CGRect){
        self.autoresizingMask = UIViewAutoresizing.flexibleHeight
        self.keyboardFrame = keyboardFrame
        self.textView.delegate = self
        self.frame = CGRect(x: 0, y: keyboardFrame.origin.y - (kCommentEmptyTextViewHeight + kCommentViewEmptyHeight) + 1, width: keyboardFrame.width, height: kCommentEmptyTextViewHeight + kCommentViewEmptyHeight)
        self.checkTextView()
        self.invalidateIntrinsicContentSize()
    }

    
    override var intrinsicContentSize: CGSize {
        let textSize = self.textView.sizeThatFits(CGSize(width: self.textView.bounds.width, height: CGFloat.greatestFiniteMagnitude))
        self.textView.isScrollEnabled = textSize.height > 4*CGFloat(kCommentViewEmptyHeight)
        self.textView.frame.size.height = min(textSize.height, 4*CGFloat(kCommentViewEmptyHeight))
        let height = self.textView.isScrollEnabled ? 5*CGFloat(kCommentViewEmptyHeight) : textSize.height + CGFloat(kCommentViewEmptyHeight)
        self.textView.scrollToBotom()
        return CGSize(width: self.bounds.width, height: height)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == kDarkGreyColor {
            textView.text = ""
            textView.textColor = .black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Commenter"
            textView.textColor = kDarkGreyColor
        }
    }
    
    func checkTextView(){
        let characters = NSCharacterSet.alphanumerics
        if let text = textView.text {
            self.postButton.isEnabled = text.characters.count > 0 && textView.textColor != kDarkGreyColor && (text.rangeOfCharacter(from: characters) != nil)
        }else{
            self.postButton.isEnabled = false
        }
    }
    
    func clearText(){
        self.textView.text = ""
        self.checkTextView()
        self.invalidateIntrinsicContentSize()
    }
    
    func searchForUser(){
        let words = self.textView.text.components(separatedBy: " ")
        if let word = words.last, word.hasPrefix("@") {
            self.delegate?.searchForUser(word.replacingOccurrences(of: "@", with: ""))
        }else{
            self.delegate?.searchForUser("")
        }
        
    }
    
    func addTag(_ word: String, _ user: User){
        self.tags[word] = user.id!
    }
    
    func updateTag(){
        for tag in tags.keys{
            if !self.textView.text.contains(tag){
                self.tags.removeValue(forKey: tag)
            }
        }
    }
    
    func didTouchUser(_ user: User) {
        var words = self.textView.text.components(separatedBy: " ")
        if var word = words.last, word.hasPrefix("@") {
            word = "@\(user.username!) "
            words[words.count-1] = word
            self.textView.text = words.joined(separator: " ")
            self.addTag("@\(user.username!)", user)
        }
        self.delegate?.searchForUser("")
    }
    
    @IBAction func postAction(_ sender: AnyObject) {
        let characters = NSCharacterSet.alphanumerics
        if var text = self.textView.text, let _ = text.rangeOfCharacter(from: characters) {
            text.condenseNewLine()
            var results:[CommentTag] = []
            for (tag, user) in self.tags {
                results.append(CommentTag(user: user, name: tag))
            }
            delegate?.postComment(text, withTags: results)
        }
        self.clearText()
    }
    
}
