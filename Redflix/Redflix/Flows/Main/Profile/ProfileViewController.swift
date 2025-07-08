//
//  ProfileViewController.swift
//  Redflix
//
//  Created by Volodymyr Mykhailiuk on 23.05.2024.
//

import UIKit
import Combine
import UserNotifications

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

    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.contentInsetAdjustmentBehavior = .automatic
        return scrollView
    }()

    private lazy var containerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.spacing = 16
        return stackView
    }()

    private lazy var profileStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.spacing = 12
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

    private lazy var testPushButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configuration = buttonConfiguration(
            title: "TEST PUSH",
            bgColor: Constants.secondaryButtonColor
        )
        button.addTarget(
            self,
            action: #selector(testPushTapped),
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

    private lazy var notificationPayloadLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Latest Push Notification"
        label.font = UIFont.custom(type: .catamaranRegular, ofSize: layoutType == .phone ? 12 : 20)
        label.textColor = .white
        return label
    }()

    private lazy var notificationPayloadTextView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        textView.textColor = .white
        textView.font = UIFont.custom(type: .catamaranRegular, ofSize: layoutType == .phone ? 10 : 14)
        textView.isEditable = false
        textView.isSelectable = true
        textView.isScrollEnabled = true
        textView.layer.cornerRadius = 8
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
        textView.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        textView.text = "No push notifications received yet"

        // Set content hugging and compression resistance
        textView.setContentHuggingPriority(UILayoutPriority(250), for: .vertical)
        textView.setContentCompressionResistancePriority(UILayoutPriority(750), for: .vertical)

        return textView
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

    @objc private func testPushTapped() {
        #if DEBUG
        // Show alert with instructions first
        let alert = UIAlertController(
            title: "Test Push Notification",
            message: "⚠️ IMPORTANT: The NotificationServiceExtension may not be properly added to the Xcode project.\n\n1. Tap 'Schedule Test'\n2. Put app in background immediately\n3. If notification doesn't show '[Modified]' in title, the extension isn't working\n\nTo fix: Add NotificationServiceExtension target to Xcode project",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Schedule Test", style: .default) { _ in
            // Test notification payload display
            self.testNotificationPayload()
            // Test rich notifications
            self.testRichNotification()
        })

        present(alert, animated: true)
        #endif
    }

    #if DEBUG
    private func testNotificationPayload() {
        // Simulate the exact Amazon Pinpoint notification payload structure
        let testPayload: [AnyHashable: Any] = [
            "data": [
                "media-url": "https://REMOVED.redfastlabs.com/assets/b1f950a1-1a30-4fcc-b6c4-cffb51b45271_rf_pinpoint_ios_image_1751929324.jpeg",
                "pinpoint": [
                    "deeplink": "https://www.redfast.com"
                ]
            ],
            "aps": [
                "mutable-content": 1,
                "alert": [
                    "title": "test7",
                    "body": "test7"
                ],
                "content-available": 1
            ],
            "timestamp": ISO8601DateFormatter().string(from: Date())
        ]

        // Store the test payload (if NotificationPayloadStore is available)
        // NotificationPayloadStore.shared.updatePayload(testPayload)
        print("🧪 Simulated Amazon Pinpoint notification payload")
    }

    private func testRichNotification() {
        // Request notification permissions first
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("✅ Notification permissions granted")
                print("⚠️ For rich notifications to work with images, the app must be in the background or locked")
                print("⚠️ Put the app in background/lock device after tapping this button")

                // Schedule test notification with a longer delay to allow backgrounding
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    self.scheduleTestNotification()
                }
            } else {
                print("❌ Notification permissions denied: \(error?.localizedDescription ?? "unknown")")
            }
        }
    }

    private func scheduleTestNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Test Rich Notification"
        content.body = "Testing rich notification with image"
        content.sound = .default

        // Add category identifier to enable actions (optional, but helps with debugging)
        content.categoryIdentifier = "TEST_CATEGORY"

        // Use the exact Amazon Pinpoint payload structure
        content.userInfo = [
            "data": [
                "media-url": "https://REMOVED.redfastlabs.com/assets/b1f950a1-1a30-4fcc-b6c4-cffb51b45271_rf_pinpoint_ios_image_1751929324.jpeg",
                "pinpoint": [
                    "deeplink": "https://www.redfast.com"
                ]
            ],
            "aps": [
                "mutable-content": 1,
                "alert": [
                    "title": "Test Rich Notification",
                    "body": "Testing rich notification with image"
                ],
                "content-available": 1
            ]
        ]

        // Add debug info to verify extension is called
        print("🧪 Test payload being sent:")
        print("🧪 UserInfo: \(content.userInfo)")
        print("🧪 Mutable content in aps: \(content.userInfo["aps"])")

        let request = UNNotificationRequest(
            identifier: "test-rich-notification-\(Date().timeIntervalSince1970)",
            content: content,
            trigger: UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Failed to schedule test notification: \(error)")
            } else {
                print("✅ Test notification scheduled - will appear in 10 seconds")
                print("📱 Put the app in background or lock device NOW to test rich notifications with images")
                print("🔍 If you don't see the '[Modified]' text in the notification title, the extension isn't running")
                print("⚠️ NOTE: Local notifications may not always trigger service extensions. Real push notifications work better.")
            }
        }
    }
    #endif
}

// MARK: - Configurations
extension ProfileViewController {
    func setupViewHierarchy() {
        view.addSubview(bgImageView)
        view.addSubview(scrollView)
        scrollView.addSubview(containerStackView)
        scrollView.addGestureRecognizer(tapGesture)

        containerStackView.addArrangedSubviews([
            UIView(),
            profileStackView,
            planStackView,
            notificationPayloadLabel,
            notificationPayloadTextView,
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
            testPushButton,
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
        // Background image constraints
        view.addAnchorConstraintsTo(
            view: bgImageView,
            constraints: .init(top: 0, leading: 0, trailing: 0)
        )
        bgImageView.addFrameConstraintsTo(constraints: .init(height: UIScreen.main.bounds.height / 2))

        // Scroll view constraints
        view.addAnchorConstraintsTo(
            view: scrollView,
            constraints: .init(horizontal: 0, vertical: 0)
        )

        // Container stack view constraints within scroll view
        scrollView.addAnchorConstraintsTo(
            view: containerStackView,
            constraints: .init(horizontal: 20, vertical: 0)
        )

        // Set container width to match scroll view width with padding
        containerStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40).isActive = true

        // Center the content horizontally and set maximum width
        let maxWidth = min(800, UIScreen.main.bounds.width - 40)
        let leadingConstraint = containerStackView.leadingAnchor.constraint(greaterThanOrEqualTo: scrollView.leadingAnchor, constant: 20)
        let trailingConstraint = containerStackView.trailingAnchor.constraint(lessThanOrEqualTo: scrollView.trailingAnchor, constant: -20)
        let widthConstraint = containerStackView.widthAnchor.constraint(equalToConstant: maxWidth)
        widthConstraint.priority = UILayoutPriority(999)

        [leadingConstraint, trailingConstraint, widthConstraint].forEach { $0.isActive = true }

        allTextFields.forEach {
            $0.addFrameConstraintsTo(constraints: .init(height: 40))
        }

        // Set a flexible height for the notification text view
        let textViewHeightConstraint = notificationPayloadTextView.heightAnchor.constraint(equalToConstant: 100)
        textViewHeightConstraint.priority = UILayoutPriority(999) // High but not required
        textViewHeightConstraint.isActive = true

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

        // Add spacing before the notification section at the bottom
        containerStackView.setCustomSpacing(24, after: planStackView)
        containerStackView.setCustomSpacing(12, after: notificationPayloadLabel)

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

        viewModel.$notificationPayload.sink { [weak self] payload in
            self?.notificationPayloadTextView.text = payload
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
        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight, right: 0)

        UIView.animate(withDuration: 0.2) {
            self.scrollView.contentInset = contentInsets
            self.scrollView.scrollIndicatorInsets = contentInsets

            // Scroll to the active text field
            let textFieldFrame = activeTextField.convert(activeTextField.bounds, to: self.scrollView)
            self.scrollView.scrollRectToVisible(textFieldFrame, animated: false)
        }
#endif
    }

    @objc func keyboardWillHide(_ notification: Notification) {
        UIView.animate(withDuration: 0.2) {
            self.scrollView.contentInset = .zero
            self.scrollView.scrollIndicatorInsets = .zero
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
