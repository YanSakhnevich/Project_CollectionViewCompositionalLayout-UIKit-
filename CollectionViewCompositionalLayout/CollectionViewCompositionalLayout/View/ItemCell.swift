import UIKit
import SnapKit
import Kingfisher

class ItemCell: UICollectionViewCell {
    
    static var reuseIdentifier: String {
        return String(describing: ItemCell.self)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var name: UILabelPadding = {
        let name = UILabelPadding()
        name.toAutoLayout()
        name.numberOfLines = 0
        name.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.3)
        name.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        name.textColor = .rgbColor(red: 14, green: 24, blue: 95)
        name.lineBreakMode = .byClipping

        return name
    }()
    
    private lazy var image: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFill
        image.toAutoLayout()
        image.layer.cornerRadius = 10
        image.layer.masksToBounds = true
        return image
    }()
    
    private func setupView() {
        image.addSubview(name)
        contentView.addSubview(image)
        contentView.backgroundColor = .white
        self.layer.cornerRadius = 10
        self.clipsToBounds = true
    }
    
    public func configureCell(title: String, imageURL: URL) {
        self.name.text = title
        self.image.kf.setImage(with: imageURL)
    }
    
    private func setupConstraints() {
        image.snp.makeConstraints { image in
            image.leading.equalTo(contentView.snp.leading)
            image.top.equalTo(contentView.snp.top)
            image.trailing.equalTo(contentView.snp.trailing)
            image.bottom.equalTo(contentView.snp.bottom)
        }
        name.snp.makeConstraints { text in
            text.leading.equalTo(image.snp.leading)
            text.trailing.equalTo(image.snp.trailing)
            text.bottom.equalTo(image.snp.bottom)
        }
    }
}

extension ItemCell {
    override var isSelected: Bool {
        didSet{
            if self.isSelected {
                self.layer.borderWidth = 2.0
                self.layer.borderColor = UIColor.systemBlue.cgColor
            }
            else {
                self.layer.borderWidth = 0
                self.layer.borderColor = nil
            }
        }
    }
}
