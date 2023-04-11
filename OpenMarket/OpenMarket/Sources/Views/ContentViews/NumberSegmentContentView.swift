import UIKit

class NumberSegmentContentView: UIView, UIContentView {
    var configuration: UIContentConfiguration {
        didSet {
            configure(configuration)
        }
    }

    init(_ configuration: UIContentConfiguration) {
        self.configuration = configuration
        super.init(frame: .zero)
        configureSubviews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(_ configuration: UIContentConfiguration) {

    }

    private func configureSubviews() {

    }
}

extension NumberSegmentContentView {
    struct Configuration: UIContentConfiguration {

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
