//
//  ErrorView.swift
//  EssentialFeediOS
//
//  Created by Riccardo Rossi - Home on 30/05/21.
//

import UIKit

public final class ErrorView: UIView {
    @IBOutlet private var messageLabel: UILabel?
    
    public var message: String? {
        !isHidden ? messageLabel?.text : nil
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        
        messageLabel?.text = nil
        isHidden = true
    }
    
    func show(message: String) {
        messageLabel?.text = message
        isHidden = false
    }
    
    func hideMessage() {
        messageLabel?.text = nil
        isHidden = true
    }
}
