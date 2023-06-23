//
//  ChatViewController.swift
//  Chat App
//
//  Created by Duy Bình on 08/06/2023.
//

import UIKit
import MessageKit
import InputBarAccessoryView

struct Message : MessageType {
    public var messageId: String
    
    public var sentDate: Date
    
    public var sender : SenderType
    
    public var kind : MessageKind
    
}

extension MessageKind {
    var messageKindString : String {
        switch self {
            
        case .text(_):
            return "text"
        case .attributedText(_):
            return "attributed_text"
        case .photo(_):
            return "photo"
        case .video(_):
            return "video"
        case .location(_):
            return "location"
        case .emoji(_):
            return "emoji"
        case .audio(_):
            return "audio"
        case .contact(_):
            return "contact"
        case .linkPreview(_):
            return "linkPreview"
        case .custom(_):
            return "custom"
        }
    }
}

struct Sender : SenderType {
    public var photo : String
    public var senderId : String
    public var displayName: String
}

class ChatViewController: MessagesViewController {
    public static let dateFormat : DateFormatter = {
        let dateFor = DateFormatter()
        dateFor.dateStyle = .medium
        dateFor.timeStyle = .long
        dateFor.locale = .current
        
        return dateFor
    }()
    
    private var messages = [Message]()
    private var selfSender : Sender? {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return nil
        }
        return Sender(photo: "",
               senderId: email,
               displayName: "Joe Smith")
    }
    public let otherUserEmail :  String
    public var isNewConversation = false
    
    init(with email: String){
        self.otherUserEmail = email
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //        messages.append(Message(messageId: "1", sentDate: Date(), sender:selfSender , kind: .text("Hello Duy Binh, test")))
        //        messages.append(Message(messageId: "1", sentDate: Date(), sender:selfSender , kind: .text("Hôm nay là thứ mấy")))
        view.backgroundColor = .red
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        messageInputBar.inputTextView.becomeFirstResponder()
    }
    
    
}

extension ChatViewController : InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        guard !text.replacingOccurrences(of: " ", with: "").isEmpty,
              let selfSender = self.selfSender,
              let messageId =  createMessageId() else {
            
            return
        }
        
        
        //Send message
        
        print("Sending: \(text)")
        
        if isNewConversation {
            // create conversation in database
            
            let message = Message(messageId: messageId,
                                  sentDate: Date(),
                                  sender: selfSender,
                                  kind: .text(text))
            DatabaseManager.shared.createNewConversation(with: otherUserEmail, firstMessage: message, completion: {success in
                if success {
                    print("message sent")
                }
                else {
                    print("failed sent ")
                }
                
            })
        }
        else{
            // append to existing conversation data
        }
    }
    
    private func createMessageId() -> String? {
        guard let currentUserEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            return nil
        }
        
        let safeEmail = DatabaseManager.safeEmail(emailAddress: currentUserEmail)

        let dataString = Self.dateFormat.string(from: Date())
        let newIdentifer = "\(otherUserEmail)_\(safeEmail)_\(dataString)"
        print("Create id message: \(newIdentifer)")
        return newIdentifer
    }
}


extension ChatViewController : MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {
    func currentSender() -> MessageKit.SenderType {
        if let sender = selfSender {
            return sender
        }
        
        return Sender(photo: "", senderId: "12", displayName: "")
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessageKit.MessagesCollectionView) -> MessageKit.MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessageKit.MessagesCollectionView) -> Int {
        return messages.count
    }
    
    
}
