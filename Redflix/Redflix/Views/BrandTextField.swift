//
//  BrandTextField.swift
//  Redflix
//
//  Created by Volodymyr Mykhailiuk on 23.05.2024.
//

import UIKit

final class BrandTextField: UITextField {

    private lazy var bottomLine: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        backgroundColor = .clear
        textColor = .white
        tintColor = .white
        
#if os(iOS)
        addBottomLine()
        
        addTarget(self, action: #selector(editingDidBegin), for: .editingDidBegin)
        addTarget(self, action: #selector(editingDidEnd), for: .editingDidEnd)
#endif
    }

    private func addBottomLine() {
        bottomLine.backgroundColor = .white.withAlphaComponent(0.8)
        addSubview(bottomLine)
        
        addAnchorConstraintsTo(view: bottomLine, constraints: .init(bottom: 0, leading: 0, trailing: 0))
        bottomLine.addFrameConstraintsTo(constraints: .init(height: 1))
    }

    // MARK: - Actions
    @objc private func editingDidBegin() {
        bottomLine.backgroundColor = AppColor.brandOrangeColor
    }

    @objc private func editingDidEnd() {
        bottomLine.backgroundColor = .white.withAlphaComponent(0.8)
    }
    
    // MARK: - Internal
    func configure(withPlaceholder text: String) {
#if os(tvOS)
        placeholder = text
#else
        attributedPlaceholder = NSAttributedString(
            string: text,
            attributes: [.foregroundColor: UIColor.white.withAlphaComponent(0.5)]
        )
#endif
    }
    
    func configure(withFont font: UIFont) {
        self.font = font
    }
    
    func markAsError() {
#if os(iOS)
        bottomLine.backgroundColor = .red
#endif
    }
}
