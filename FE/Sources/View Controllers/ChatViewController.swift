/*
 MIT License
 
 Copyright (c) 2017-2019 MessageKit
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 */

import UIKit
import MessageKit
import InputBarAccessoryView
import Photos
import CoreML
import Vision

/// A base class for the example controllers
class ChatViewController: MessagesViewController, MessagesDataSource, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    /// The `BasicAudioController` controll the AVAudioPlayer state (play, pause, stop) and udpate audio cell UI accordingly.
    open lazy var audioController = BasicAudioController(messageCollectionView: messagesCollectionView)
    
    var messageList: [MockMessage] = []
    
    let refreshControl = UIRefreshControl()
    
    let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureMessageCollectionView()
        configureMessageInputBar()
        loadFirstMessages()
        title = "버디버디"
        self.initialize()
        
        // 추가
        // 1
        let cameraItem = InputBarButtonItem(type: .system)
        cameraItem.tintColor = .black
        cameraItem.image = UIImage(named: "ic_camera")

        // 2
        cameraItem.addTarget(
          self,
          action: #selector(cameraButtonPressed),
          for: .primaryActionTriggered
        )
        cameraItem.setSize(CGSize(width: 60, height: 30), animated: false)

        messageInputBar.leftStackView.alignment = .center
        messageInputBar.setLeftStackViewWidthConstant(to: 50, animated: false)

        // 3
        messageInputBar.setStackViewItems([cameraItem], forStack: .left, animated: false)

    }

    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        MockSocket.shared.connect(with: [SampleData.shared.nathan, SampleData.shared.wu])
            .onNewMessage { [weak self] message in
                self?.insertMessage(message)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        MockSocket.shared.disconnect()
        audioController.stopAnyOngoingPlaying()
    }
    
    func loadFirstMessages() {
        //        DispatchQueue.global(qos: .userInitiated).async {
        //            let count = UserDefaults.standard.mockMessagesCount()
        //            SampleData.shared.getMessages(count: count) { messages in
        //                DispatchQueue.main.async {
        //                    self.messageList = messages
        //                    self.messagesCollectionView.reloadData()
        //                    self.messagesCollectionView.scrollToBottom()
        //                }
        //            }
        //        }
    }
    
    @objc
    func loadMoreMessages() {
        DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + 1) {
            SampleData.shared.getMessages(count: 20) { messages in
                DispatchQueue.main.async {
                    self.messageList.insert(contentsOf: messages, at: 0)
                    self.messagesCollectionView.reloadDataAndKeepOffset()
                    self.refreshControl.endRefreshing()
                }
            }
        }
    }
    
    func configureMessageCollectionView() {
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messageCellDelegate = self
        
        scrollsToBottomOnKeyboardBeginsEditing = true // default false
        maintainPositionOnKeyboardFrameChanged = true // default false
        
        messagesCollectionView.addSubview(refreshControl)
        refreshControl.addTarget(self, action: #selector(loadMoreMessages), for: .valueChanged)
    }
    
    func configureMessageInputBar() {
        messageInputBar.delegate = self
        messageInputBar.inputTextView.tintColor = .primaryColor
        messageInputBar.sendButton.setTitleColor(.primaryColor, for: .normal)
        messageInputBar.sendButton.setTitleColor(
            UIColor.primaryColor.withAlphaComponent(0.3),
            for: .highlighted
        )
    }
    
    // MARK: - Actions
    // 추가
    @objc private func cameraButtonPressed() {
      let picker = UIImagePickerController()
      picker.delegate = self

      if UIImagePickerController.isSourceTypeAvailable(.camera) {
        picker.sourceType = .camera
      } else {
        picker.sourceType = .photoLibrary
      }

      present(picker, animated: true, completion: nil)
    }

    // MARK: - Helpers
    
    func insertMessage(_ message: MockMessage) {
        messageList.append(message)
        // Reload last section to update header/footer labels and insert a new one
        messagesCollectionView.performBatchUpdates({
            messagesCollectionView.insertSections([messageList.count - 1])
            if messageList.count >= 2 {
                messagesCollectionView.reloadSections([messageList.count - 2])
            }
        }, completion: { [weak self] _ in
            if self?.isLastSectionVisible() == true {
                self?.messagesCollectionView.scrollToBottom(animated: true)
            }
        })
    }
    
    func isLastSectionVisible() -> Bool {
        
        guard !messageList.isEmpty else { return false }
        
        let lastIndexPath = IndexPath(item: 0, section: messageList.count - 1)
        
        return messagesCollectionView.indexPathsForVisibleItems.contains(lastIndexPath)
    }

    
    // MARK: - MessagesDataSource
    
    func currentSender() -> SenderType {
        return SampleData.shared.currentSender
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messageList.count
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messageList[indexPath.section]
    }
    
    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        if indexPath.section % 3 == 0 {
            return NSAttributedString(string: MessageKitDateFormatter.shared.string(from: message.sentDate), attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 10), NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        }
        return nil
    }
    
    func cellBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        
        return NSAttributedString(string: "Read", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 10), NSAttributedString.Key.foregroundColor: UIColor.darkGray])
    }
    
    func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let name = message.sender.displayName
        return NSAttributedString(string: name, attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption1)])
    }
    
    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        
        let dateString = formatter.string(from: message.sentDate)
        return NSAttributedString(string: dateString, attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption2)])
    }
    
}

// MARK: - MessageCellDelegate

extension ChatViewController: MessageCellDelegate {
    
    func didTapAvatar(in cell: MessageCollectionViewCell) {
        print("Avatar tapped")
    }
    
    func didTapMessage(in cell: MessageCollectionViewCell) {
        print("Message tapped")
    }
    
    func didTapImage(in cell: MessageCollectionViewCell) {
        dump(cell)
        print("Image tapped")
    }
    
    func didTapCellTopLabel(in cell: MessageCollectionViewCell) {
        print("Top cell label tapped")
    }
    
    func didTapCellBottomLabel(in cell: MessageCollectionViewCell) {
        print("Bottom cell label tapped")
    }
    
    func didTapMessageTopLabel(in cell: MessageCollectionViewCell) {
        print("Top message label tapped")
    }
    
    func didTapMessageBottomLabel(in cell: MessageCollectionViewCell) {
        print("Bottom label tapped")
    }
    
    func didTapPlayButton(in cell: AudioMessageCell) {
        guard let indexPath = messagesCollectionView.indexPath(for: cell),
            let message = messagesCollectionView.messagesDataSource?.messageForItem(at: indexPath, in: messagesCollectionView) else {
                print("Failed to identify message when audio cell receive tap gesture")
                return
        }
        guard audioController.state != .stopped else {
            // There is no audio sound playing - prepare to start playing for given audio message
            audioController.playSound(for: message, in: cell)
            return
        }
        if audioController.playingMessage?.messageId == message.messageId {
            // tap occur in the current cell that is playing audio sound
            if audioController.state == .playing {
                audioController.pauseSound(for: message, in: cell)
            } else {
                audioController.resumeSound()
            }
        } else {
            // tap occur in a difference cell that the one is currently playing sound. First stop currently playing and start the sound for given message
            audioController.stopAnyOngoingPlaying()
            audioController.playSound(for: message, in: cell)
        }
    }
    
    func didStartAudio(in cell: AudioMessageCell) {
        print("Did start playing audio sound")
    }
    
    func didPauseAudio(in cell: AudioMessageCell) {
        print("Did pause audio sound")
    }
    
    func didStopAudio(in cell: AudioMessageCell) {
        print("Did stop audio sound")
    }
    
    func didTapAccessoryView(in cell: MessageCollectionViewCell) {
        print("Accessory view tapped")
    }
    
}

// MARK: - MessageLabelDelegate

extension ChatViewController: MessageLabelDelegate {
    
    func didSelectAddress(_ addressComponents: [String: String]) {
        print("Address Selected: \(addressComponents)")
    }
    
    func didSelectDate(_ date: Date) {
        print("Date Selected: \(date)")
    }
    
    func didSelectPhoneNumber(_ phoneNumber: String) {
        print("Phone Number Selected: \(phoneNumber)")
    }
    
    func didSelectURL(_ url: URL) {
        print("URL Selected: \(url)")
    }
    
    func didSelectTransitInformation(_ transitInformation: [String: String]) {
        print("TransitInformation Selected: \(transitInformation)")
    }
    
    func didSelectHashtag(_ hashtag: String) {
        print("Hashtag selected: \(hashtag)")
    }
    
    func didSelectMention(_ mention: String) {
        print("Mention selected: \(mention)")
    }
    
    func didSelectCustom(_ pattern: String, match: String?) {
        print("Custom data detector patter selected: \(pattern)")
    }
    
}

// MARK: - MessageInputBarDelegate

extension ChatViewController: InputBarAccessoryViewDelegate {
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        
        // Here we can parse for which substrings were autocompleted
        let attributedText = messageInputBar.inputTextView.attributedText!
        let range = NSRange(location: 0, length: attributedText.length)
        attributedText.enumerateAttribute(.autocompleted, in: range, options: []) { (_, range, _) in
            
            let substring = attributedText.attributedSubstring(from: range)
            let context = substring.attribute(.autocompletedContext, at: 0, effectiveRange: nil)
            print("Autocompleted: `", substring, "` with context: ", context ?? [])
        }
        
        let components = inputBar.inputTextView.components
        messageInputBar.inputTextView.text = String()
        messageInputBar.invalidatePlugins()
        
        // Send button activity animation
        messageInputBar.sendButton.startAnimating()
        messageInputBar.inputTextView.placeholder = "Sending..."
        DispatchQueue.global(qos: .default).async {
            // fake send request task
            sleep(1)
            DispatchQueue.main.async { [weak self] in
                self?.messageInputBar.sendButton.stopAnimating()
                self?.messageInputBar.inputTextView.placeholder = "Aa"
                self?.insertMessages(components)
                self?.messagesCollectionView.scrollToBottom(animated: true)
            }
        }
    }
    
    private func insertMessages(_ data: [Any]) {
        for component in data {
            let user = SampleData.shared.currentSender
            if let str = component as? String {
                NetworkHelper.shared.getData(userId: user.senderId, sentence: str, completion: { obj in
                    guard let sentence = obj.sentence else {
                        return
                    }
                    DispatchQueue.main.async {
                        let message = MockMessage(text: sentence, user: user, messageId: UUID().uuidString, date: Date())
                        self.insertMessage(message)
                    }
                })
            } else if let img = component as? UIImage {
                let message = MockMessage(image: img, user: user, messageId: UUID().uuidString, date: Date())
                dump(message)
                insertMessage(message)
            }
        }
    }
    
//    func makeBlur(image : UIImage, blurAmout : CGFloat) -> UIImage? {
//        guard let ciImage = CIImage(image : image) else {
//            return nil
//        }
//
//        let blurFilter = CIFilter(name : "CIGaussianBlur")
//        blurFilter?.setValue(ciImage, forKey: kCIInputImageKey)
//        blurFilter?.setValue(blurAmount, forKey: kCIInputImageKey)
//    }
    
    func checkImage(image : UIImage, callback : @escaping (_ finalImage : UIImage) -> Void) {
//        var isCat : Bool = false
        if let ciImage : CIImage = CIImage(image : image) {
            if #available(iOS 11.0, *) {
                // Load the ML model through its generated class
                guard let model = try? VNCoreMLModel(for: SqueezeNet().model) else {
                  fatalError("can't load Places ML model")
                }

                // Create a Vision request with completion handler
                let request = VNCoreMLRequest(model: model) { [weak self] request, error in
                  guard let results = request.results as? [VNClassificationObservation],
                    let topResult = results.first else {
                      fatalError("unexpected result type from VNCoreMLRequest")
                  }

                  // Update UI on main queue
//                  let article = (self?.vowels.contains(topResult.identifier.first!))! ? "an" : "a"
                  DispatchQueue.main.async { [weak self] in print("\(Int(topResult.confidence * 100))% it's \(topResult.identifier)")
//                    self?.answerLabel.text = "\(Int(topResult.confidence * 100))% it's \(article) \(topResult.identifier)"
                    print("\(Int(topResult.confidence * 100))% it's \(topResult.identifier)")
                    let sliced = topResult.identifier.components(separatedBy: " ")
//                    print(sliced)
                    var finalImage : UIImage = image
                    if sliced.contains("cat") {
                        finalImage = image.blurred()
                    }
                    callback(finalImage)
                  }
                }


                // Run the Core ML GoogLeNetPlaces classifier on global dispatch queue
                let handler = VNImageRequestHandler(ciImage: ciImage)
                DispatchQueue.global(qos: .userInteractive).async {
                  do {
                    try handler.perform([request])
                  } catch {
                    print(error)
                  }
                }
            }
        }
//        return isCat
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
      picker.dismiss(animated: true, completion: nil)
      
      // 1
        if #available(iOS 11.0, *) {
            if let asset = info[.phAsset] as? PHAsset {
                let size = CGSize(width: 500, height: 500)
                PHImageManager.default().requestImage(
                    for: asset,
                    targetSize: size,
                    contentMode: .aspectFit,
                    options: nil) { result, info in
                        
                        guard let image = result else {
                            return
                        }
                        // 여기서 image 유해성 검사
                        self.checkImage(image: image) { (finalImage : UIImage) in
                            let message = MockMessage(image: finalImage, user: SampleData.shared.currentSender, messageId: UUID().uuidString, date: Date())
                            self.insertMessage(message)
                        }
                        
                }
                
                // 2
            } else if let image = info[.originalImage] as? UIImage {
                // 여기서 image 유해성 검사
                self.checkImage(image: image) { (finalImage : UIImage) in
                    let message = MockMessage(image: finalImage, user: SampleData.shared.currentSender, messageId: UUID().uuidString, date: Date())
                    self.insertMessage(message)
                }
            }
        } else {
            // Fallback on earlier versions
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
      picker.dismiss(animated: true, completion: nil)
    }

    
    func initialize() {
        let reportBtn = UIButton(frame: CGRect(x: 0.0, y: 0.0, width: 30, height: 30))
        if #available(iOS 13.0, *) {
            reportBtn.setImage(UIImage(systemName: "pencil.and.ellipsis.rectangle"), for: .normal)
        } else {
            // Fallback on earlier versions
        }
        reportBtn.tintColor = UIColor.black
        reportBtn.addTarget(self, action: #selector(ChatViewController.reportAction(_:)), for: UIControl.Event.touchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: reportBtn)
    }
    
    @objc func reportAction(_ sender: UIBarButtonItem) {
      let alert = UIAlertController(title: "신고", message: "단어를 입력해주세요", preferredStyle: UIAlertController.Style.alert)
      let sendAction = UIAlertAction(title: "전송", style: .default) { (action) in
        // 신고할 메시지
        let reportMsg = alert.textFields![0].text!
        print(reportMsg)
        // 여기에 서버로 reportMsg 전송
      }
        
      let cancelAction = UIAlertAction(title: "취소", style: .destructive) { (action) in }
      alert.addAction(sendAction)
      alert.addAction(cancelAction)
      alert.addTextField()
      self.present(alert, animated: false, completion: nil)
    }
}

extension UIImage {
    func blurred(radius: CGFloat = 20.0) -> UIImage {
        print("making blur")
        let ciContext = CIContext(options: nil)
        guard let cgImage = cgImage else { return self }
        let inputImage = CIImage(cgImage: cgImage)
        guard let ciFilter = CIFilter(name: "CIGaussianBlur") else { return self }
        ciFilter.setValue(inputImage, forKey: kCIInputImageKey)
        ciFilter.setValue(radius, forKey: "inputRadius")
        guard let resultImage = ciFilter.value(forKey: kCIOutputImageKey) as? CIImage else { return self }
        guard let cgImage2 = ciContext.createCGImage(resultImage, from: inputImage.extent) else { return self }
        return UIImage(cgImage: cgImage2)
    }
}
