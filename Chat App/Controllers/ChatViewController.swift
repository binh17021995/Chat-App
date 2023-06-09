//
//  ChatViewController.swift
//  Chat App
//
//  Created by Duy Bình on 08/06/2023.
//

import UIKit
import MessageKit

struct Message : MessageType {
    var messageId: String
    
    var sentDate: Date
    
    var sender : SenderType
    
    var kind : MessageKind
    
}

struct Sender : SenderType {
    var photo : String
    var senderId : String
    var displayName: String
}

class ChatViewController: MessagesViewController {
    
    private var messages = [Message]()
    private let selfSender = Sender(photo: "", senderId: "1", displayName: "Joe Smith")
    override func viewDidLoad() {
        super.viewDidLoad()
        messages.append(Message(messageId: "1", sentDate: Date(), sender:selfSender , kind: .text("Hello Duy Binh, test")))
        messages.append(Message(messageId: "1", sentDate: Date(), sender:selfSender , kind: .text("Hôm nay là thứ mấy")))
        view.backgroundColor = .red
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        
        
    }
    
    
    
}


extension ChatViewController : MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {
    func currentSender() -> MessageKit.SenderType {
        return selfSender
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessageKit.MessagesCollectionView) -> MessageKit.MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessageKit.MessagesCollectionView) -> Int {
        return messages.count
    }
    
    
}
