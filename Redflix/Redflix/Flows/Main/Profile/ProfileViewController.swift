//
//  ProfileViewController.swift
//  Redflix
//
//  Created by Volodymyr Mykhailiuk on 23.05.2024.
//

import UIKit
import Combine

final class ProfileViewController: UIViewController {
    enum Constants {
        static let accountText = "MY ACCOUNT"
        static let profileText = "Profile"
        static let planText = "Plan"
        static let planPlaceholderText = "$7.99 Monthly Plan (renews in 22 days)"
        static let firstNamePlaceholderText = "Buff"
        static let secondNamePlaceholderText = "Pesos"
        static let phonePlaceholderText = "XXX-XXX-0007"
        static let emailPlaceholderText = "Device Token"
        static let changeButtonTitle = "CHANGE"
        static let settingsButtonTitle = "SETTINGS"
        static let cancelSubscriptionButtonTitle = "CANCEL SUBSCRIPTION"
        static let billingHistoryButtonTitle = "BILLING HISTORY"

        static let primaryOrangeColor = AppColor.brandOrangeColor
        static let secondaryButtonColor = UIColor(hex: "#263846")
    }

    // MARK: - Properties
    private let viewModel: ProfileViewModel
    private var activeTextField: UITextField?
    private var cancellable = Set<AnyCancellable>()

    private var layoutType: LayoutType {
        UIDevice.current.userInterfaceIdiom == .phone ? .phone : .landscape
    }

    // MARK: - Subviews
    private lazy var bgImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "profileImage"))
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private lazy var containerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        return stackView
    }()

    private lazy var profileStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .fill
        return stackView
    }()

    private lazy var profileInputsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .fill
        return stackView
    }()

    private lazy var nameInputsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = layoutType == .phone ? .vertical : .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        stackView.spacing = layoutType == .phone ? 0 : 20
        return stackView
    }()

    private lazy var contactInfoInputsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = layoutType == .phone ? .vertical : .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        stackView.spacing = layoutType == .phone ? 0 : 20
        return stackView
    }()

    private lazy var accountLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = Constants.accountText
        return label
    }()

    private lazy var profileLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = Constants.profileText
        return label
    }()

    private lazy var firstNameTextField: BrandTextField = {
        let view = BrandTextField()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.delegate = self
        return view
    }()

    private lazy var secondNameTextField: BrandTextField = {
        let view = BrandTextField()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.delegate = self
        return view
    }()

    private lazy var phoneTextField: BrandTextField = {
        let view = BrandTextField()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.delegate = self
        return view
    }()

    private lazy var emailTextField: BrandTextField = {
        let view = BrandTextField()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.delegate = self
        return view
    }()

    private lazy var planStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .leading
        return stackView
    }()

    private lazy var planLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = Constants.planText
        return label
    }()

    private lazy var planTextField: BrandTextField = {
        let view = BrandTextField()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.delegate = self
        return view
    }()

    private lazy var changeButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configuration = buttonConfiguration(
            title: Constants.changeButtonTitle,
            bgColor: Constants.primaryOrangeColor
        )
        button.addTarget(
            self,
            action: #selector(changeTapped),
            for: .primaryActionTriggered
        )
        return button
    }()

    private lazy var settingsButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configuration = buttonConfiguration(
            title: Constants.settingsButtonTitle,
            bgColor: Constants.secondaryButtonColor
        )
        button.addTarget(
            self,
            action: #selector(settingsTapped),
            for: .primaryActionTriggered
        )
        return button
    }()

    private lazy var cancelSubscriptionButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configuration = buttonConfiguration(
            title: Constants.cancelSubscriptionButtonTitle,
            bgColor: Constants.primaryOrangeColor
        )
        button.addTarget(
            self,
            action: #selector(cancelSubscriptionTapped),
            for: .primaryActionTriggered
        )
        button.accessibilityIdentifier = "cancelSubscriptionButton"
        return button
    }()

    private lazy var billingHistoryButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configuration = buttonConfiguration(
            title: Constants.billingHistoryButtonTitle,
            bgColor: Constants.secondaryButtonColor
        )
        button.addTarget(
            self,
            action: #selector(billingHistoryTapped),
            for: .primaryActionTriggered
        )
        return button
    }()

    private lazy var profileButtonsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 16
        return stackView
    }()

    private lazy var planButtonsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 16
        return stackView
    }()

    private lazy var allTextFields: [BrandTextField] = {
        [firstNameTextField, secondNameTextField, phoneTextField, emailTextField, planTextField]
    }()

    private lazy var tapGesture = UITapGestureRecognizer(
        target: self,
        action: #selector(dismissKeyboard)
    )

    // MARK: - Lifecycle
    init(viewModel: ProfileViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupViewHierarchy()
        setupConstraints()
        setupAppearance()
        setupBindings()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNotifications()
        viewModel.registerScreen(self)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Private
    private func buttonConfiguration(title: String, bgColor: UIColor?) -> UIButton.Configuration {
        var configuration = UIButton.Configuration.filled()
        configuration.baseForegroundColor = .white
        configuration.baseBackgroundColor = bgColor
        let inset: CGFloat = layoutType == .phone ? 16 : 24
        configuration.contentInsets = NSDirectionalEdgeInsets(top: inset, leading: inset, bottom: inset, trailing: inset)
        let font = UIFont.custom(type: .catamaranExtraBold, ofSize: layoutType == .phone ? 10 : 18)
        let attributedString = NSAttributedString(
            string: title,
            attributes: [.font: font, .foregroundColor: UIColor.white]
        )

        configuration.attributedTitle = AttributedString(attributedString)
        return configuration
    }

    // MARK: - Actions
    @objc private func changeTapped() {
        viewModel.change(
            firstName: firstNameTextField.text,
            secondName: secondNameTextField.text,
            phone: phoneTextField.text,
            email: emailTextField.text
        )
    }

    @objc private func cancelSubscriptionTapped() {
        viewModel.cancelSubscription(
            id: cancelSubscriptionButton.accessibilityIdentifier,
            vc: self
        )
    }

    @objc private func billingHistoryTapped() {
        viewModel.billingHistory()
    }

    @objc private func settingsTapped() {
        viewModel.showDebugView(self)
    }
}

// MARK: - Configurations
extension ProfileViewController {
    func setupViewHierarchy() {
        view.addSubview(bgImageView)
        view.addSubview(containerStackView)
        view.addGestureRecognizer(tapGesture)
        containerStackView.addArrangedSubviews([
            UIView(),
            profileStackView,
            planStackView,
            UIView()
        ])
        profileStackView.addArrangedSubviews([
            accountLabel,
            profileLabel,
            nameInputsStackView,
            contactInfoInputsStackView,
            profileButtonsStackView

        ])
        profileButtonsStackView.addArrangedSubviews([
            changeButton,
            settingsButton,
            UIView()
        ])
        nameInputsStackView.addArrangedSubviews([
            firstNameTextField,
            secondNameTextField
        ])
        contactInfoInputsStackView.addArrangedSubviews([
            phoneTextField,
            emailTextField
        ])
        planStackView.addArrangedSubviews([
            planLabel,
            planTextField,
            planButtonsStackView
        ])
        planButtonsStackView.addArrangedSubviews([
            cancelSubscriptionButton,
            billingHistoryButton,
            UIView()
        ])
    }

    func setupConstraints() {
        view.addAnchorConstraintsTo(
            view: bgImageView,
            constraints: .init(top: 0, leading: 0, trailing: 0)
        )
        bgImageView.addFrameConstraintsTo(constraints: .init(height: UIScreen.main.bounds.height / 2))
        view.addAnchorConstraintsTo(
            view: containerStackView,
            constraints: .init(vertical: 0)
        )
        view.addCenterConstraintsTo(view: containerStackView, constraints: .init(centerX: 0))
        containerStackView.addFrameConstraintsTo(constraints: .init(width: min(800, UIScreen.main.bounds.width - 32)))
        allTextFields.forEach {
            $0.addFrameConstraintsTo(constraints: .init(height: 40))
        }
        [changeButton, cancelSubscriptionButton, billingHistoryButton].forEach {
            $0.layer.cornerRadius = 8
            $0.layer.masksToBounds = true
        }
    }

    func setupAppearance() {
        navigationItem.applyBrandNavigationTitle()
        view.backgroundColor = .black

        accountLabel.font = .custom(type: .catamaranBold, ofSize: layoutType == .phone ? 18 : 32)
        accountLabel.textColor = Constants.primaryOrangeColor
        profileLabel.font = .custom(type: .catamaranExtraBold, ofSize: layoutType == .phone ? 42 : 64)
        profileLabel.textColor = .white
        planLabel.font = .custom(type: .catamaranExtraBold, ofSize: layoutType == .phone ? 42 : 64)
        planLabel.textColor = .white

        planTextField.configure(withPlaceholder: Constants.planPlaceholderText)
        firstNameTextField.configure(withPlaceholder: Constants.firstNamePlaceholderText)
        secondNameTextField.configure(withPlaceholder: Constants.secondNamePlaceholderText)
        phoneTextField.configure(withPlaceholder: Constants.phonePlaceholderText)
        emailTextField.configure(withPlaceholder: Constants.emailPlaceholderText)
        emailTextField.text = viewModel.deviceToken
        emailTextField.isUserInteractionEnabled = true

        allTextFields.forEach {
            $0.autocorrectionType = .no
            $0.configure(withFont: .custom(type: .catamaranRegular, ofSize: layoutType == .phone ? 18 : 32))
        }

        profileStackView.setCustomSpacing(16, after: contactInfoInputsStackView)
        planStackView.setCustomSpacing(16, after: planTextField)
        if layoutType == .landscape {
            profileStackView.setCustomSpacing(16, after: nameInputsStackView)
        }
    }

    func setupBindings() {
        viewModel.$profileMessage.sink { [weak self] message in
            guard let self, let message else { return }

            switch message {
            case .emptyFirstName:
                firstNameTextField.markAsError()
            case .emptySecondName:
                secondNameTextField.markAsError()
            case .successSubmission:
                allTextFields.forEach {
                    $0.text = nil
                }
                // Restore device token after clearing all fields
                emailTextField.text = viewModel.deviceToken
            default:
                break
            }
            self.dismissKeyboard()
            self.showAlertMessage(title: message.title, message: message.body)
        }
        .store(in: &cancellable)
    }

    func setupNotifications() {
#if os(iOS)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
#endif
    }
}

// MARK: - Actions
private extension ProfileViewController {
    @objc func keyboardWillShow(_ notification: Notification) {
#if os(iOS)
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let activeTextField
        else {
            return
        }

        let keyboardHeight = keyboardFrame.height
        let windowHeight = UIScreen.main.bounds.height
        let keyboardTopY = windowHeight - keyboardHeight
        let textFieldMaxY = activeTextField.convert(activeTextField.bounds, to: nil).maxY
        let offset: CGFloat = 20.0


        UIView.animate(withDuration: 0.2) {
            self.view.transform = textFieldMaxY + offset > keyboardTopY
            ? CGAffineTransform(translationX: 0, y: keyboardTopY - textFieldMaxY - offset)
            : .identity
        }
#endif
    }

    @objc func keyboardWillHide(_ notification: Notification) {
        UIView.animate(withDuration: 0.2) {
            self.view.transform = .identity
        }
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

// MARK: - UITextFieldDelegate
extension ProfileViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // Don't set activeTextField for device token field to prevent keyboard issues
        if textField != emailTextField {
            activeTextField = textField
        }
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        activeTextField = nil
    }

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        // Allow selection for all fields including device token field
        return true
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Prevent editing of device token field
        if textField == emailTextField {
            return false
        }
        return true
    }
}

// MARK: - PromotionViewProtocol
extension ProfileViewController: PromotionViewProtocol {
    var name: String { "ProfileViewController" }
}
