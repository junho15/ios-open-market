import UIKit

final class NumberSegmentContentView: UIView, UIContentView {
    var configuration: UIContentConfiguration {
        didSet {
            configure(configuration)
        }
    }
    override var intrinsicContentSize: CGSize {
        CGSize(width: 0, height: 44)
    }
    private let stackView = UIStackView()
    private let numberTextField = NumberTextField()
    private let segmentedControl = UISegmentedControl()
    private var segmentsTitle = [String]()

    init(_ configuration: UIContentConfiguration) {
        self.configuration = configuration
        super.init(frame: .zero)
        configureSubviews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(_ configuration: UIContentConfiguration) {
        guard let configuration = configuration as? Configuration else { return }
        numberTextField.numberType = configuration.numberType
        numberTextField.setNumericValue(configuration.number)
        numberTextField.placeholder = configuration.placeholder

        if segmentsTitle != configuration.segmentsTitle {
            segmentedControl.removeAllSegments()
            configuration.segmentsTitle.enumerated().forEach {
                segmentedControl.insertSegment(withTitle: $0.element, at: $0.offset, animated: false)
            }
            segmentsTitle = configuration.segmentsTitle
        }
        guard configuration.selectedSegmentIndex < segmentedControl.numberOfSegments else { return }
        segmentedControl.selectedSegmentIndex = configuration.selectedSegmentIndex
    }

    private func configureSubviews() {
        numberTextField.font = UIFont.preferredFont(forTextStyle: .body)
        numberTextField.adjustsFontForContentSizeCategory = true
        numberTextField.clearButtonMode = .whileEditing
        numberTextField.addAction(
            UIAction(handler: { [weak self] _ in
                guard let self,
                      let configuration = configuration as? Configuration else { return }
                    configuration.onChangeNumber?(numberTextField.numericValue() ?? 0)
            }),
            for: .editingChanged
        )

        segmentedControl.addAction(
            UIAction(handler: { [weak self] _ in
                guard let self,
                      let configuration = configuration as? Configuration else { return }
                configuration.onChangeSegment?(segmentedControl.selectedSegmentIndex)
            }),
            for: .valueChanged
        )

        stackView.axis = .horizontal
        stackView.spacing = Constants.layoutSpacing
        stackView.distribution = .fill
        stackView.alignment = .center

        stackView.translatesAutoresizingMaskIntoConstraints = false
        [numberTextField, segmentedControl].forEach(stackView.addArrangedSubview)
        addSubview(stackView)

        let spacing = Constants.layoutSpacing
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: spacing),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -spacing),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        segmentedControl.setContentHuggingPriority(.required, for: .horizontal)
    }
}

extension NumberSegmentContentView {
    private enum Constants {
        static let layoutSpacing = CGFloat(10)
    }
}

extension NumberSegmentContentView {
    struct Configuration: UIContentConfiguration {
        let numberType: NumberTextField.NumberType = .double
        var number: Double?
        var placeholder: String?
        var segmentsTitle: [String] = []
        var selectedSegmentIndex: Int = 0
        var onChangeNumber: ((Double) -> Void)?
        var onChangeSegment: ((Int) -> Void)?

        func makeContentView() -> UIView & UIContentView {
            return NumberSegmentContentView(self)
        }

        func updated(for state: UIConfigurationState) -> NumberSegmentContentView.Configuration {
            return self
        }
    }
}

extension UICollectionViewCell {
    func numberSegmentConfiguration() -> NumberSegmentContentView.Configuration {
        return NumberSegmentContentView.Configuration()
    }
}
