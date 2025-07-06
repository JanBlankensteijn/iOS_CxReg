import UIKit
import SwiftUI

/// A SwiftUI wrapper around a UICollectionView displaying a grid with sticky headers for the first row and first column.
struct MatrixCollectionViewGrid: UIViewRepresentable {
    var items: [Complicatie]
    var locaties: [String]
    var bestaandeCodes: Set<String>
    var actieveCodes: Set<String>
    /// Closure die wordt aangeroepen bij tap op een data-cell: (GRP, SRTSPC, LOC)
    var onSelect: (String, String, String) -> Void

    func makeUIView(context: Context) -> UICollectionView {
        let layout = StickyMatrixLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.dataSource = context.coordinator
        collectionView.delegate = context.coordinator
        collectionView.register(MatrixCell.self, forCellWithReuseIdentifier: "MatrixCell")
        collectionView.register(HeaderCell.self, forCellWithReuseIdentifier: "HeaderCell")
        collectionView.backgroundColor = .white

        // Disable bounce to lock scrolling within content bounds
        collectionView.bounces = false
        collectionView.alwaysBounceVertical = false
        collectionView.alwaysBounceHorizontal = false
        collectionView.contentInsetAdjustmentBehavior = .never

        return collectionView
    }

    func updateUIView(_ uiView: UICollectionView, context: Context) {
        // Update coordinator's parent reference so it uses the latest items
        context.coordinator.parent = self
        DispatchQueue.main.async {
            uiView.collectionViewLayout.invalidateLayout()
            uiView.reloadData()
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
        var parent: MatrixCollectionViewGrid
        init(_ parent: MatrixCollectionViewGrid) {
            self.parent = parent
        }

        func numberOfSections(in collectionView: UICollectionView) -> Int {
            parent.items.count + 1 // +1 for header row
        }

        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            parent.locaties.count + 1 // +1 for header column
        }

        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            if indexPath.section == 0 && indexPath.item == 0 {
                // Top-left corner cell
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HeaderCell", for: indexPath) as! HeaderCell
                cell.configure(text: "", isColumnHeader: false)
                return cell
            } else if indexPath.section == 0 {
                // Column headers
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HeaderCell", for: indexPath) as! HeaderCell
                let text = parent.locaties[indexPath.item - 1]
                cell.configure(text: text, isColumnHeader: true)
                return cell
            } else if indexPath.item == 0 {
                // Row headers
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HeaderCell", for: indexPath) as! HeaderCell
                let code = parent.items[indexPath.section - 1].Code
                let display = "[\(String(code.dropFirst(3).prefix(6)))]"
                cell.configure(text: display, isColumnHeader: false)
                return cell
            } else {
                // Data cells
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MatrixCell", for: indexPath) as! MatrixCell
                let comp = parent.items[indexPath.section - 1]
                let grpPrefix = String(comp.Code.prefix(3))
                let srtspc = String(comp.Code.dropFirst(3).prefix(6))
                let loc = parent.locaties[indexPath.item - 1]
                let fullCode = grpPrefix + srtspc + loc
                let bestaat = parent.bestaandeCodes.contains(fullCode)
                let actief = parent.actieveCodes.contains(fullCode)
                cell.configure(bestaat: bestaat, actief: actief)
                return cell
            }
        }

        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            if indexPath.item == 0 {
                return CGSize(width: MatrixLayout.rijheaderbreedte, height: MatrixLayout.rijhoogte)
            } else if indexPath.section == 0 {
                return CGSize(width: MatrixLayout.kolombreedte, height: MatrixLayout.headerhoogte)
            } else {
                return CGSize(width: MatrixLayout.kolombreedte, height: MatrixLayout.rijhoogte)
            }
        }

        // MARK: – cell tap afhandelen
        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            // alleen data-cellen (niet header-rij/kolom)
            guard indexPath.section > 0, indexPath.item > 0 else { return }
            let comp    = parent.items[indexPath.section - 1]
            let grp     = String(comp.Code.prefix(3))
            let srtspc  = String(comp.Code.dropFirst(3).prefix(6))
            let loc     = parent.locaties[indexPath.item - 1]
            parent.onSelect(grp, srtspc, loc)
        }
    }
}

// MARK: - Cell Classes


class MatrixCell: UICollectionViewCell {
    private let circleView = UIView()
    private let size: CGFloat = 16

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(circleView)
        circleView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            circleView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            circleView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            circleView.widthAnchor.constraint(equalToConstant: size),
            circleView.heightAnchor.constraint(equalTo: circleView.widthAnchor)
        ])
        circleView.layer.cornerRadius = size / 2
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    /// Configure de cel:
    /// - bestaat: of er überhaupt een Complicatie-record is voor deze SRTSPC+LOC
    /// - actief: of die record .Actief == true heeft
    func configure(bestaat: Bool, actief: Bool) {
        // verklein de stip als er niets bestaat
        circleView.transform = bestaat
            ? .identity
            : CGAffineTransform(scaleX: 0.4, y: 0.4)
        circleView.isHidden = false
        circleView.layer.borderWidth = 0

        if !bestaat {
            // kleine grijze stip
            circleView.backgroundColor = .systemGray
            circleView.layer.cornerRadius = (size * 0.4) / 2
        } else if actief {
            // dichte groene stip
            circleView.backgroundColor = .systemGreen
            circleView.layer.cornerRadius = size / 2
        } else {
            // open groene cirkel
            circleView.backgroundColor = .clear
            circleView.layer.borderWidth = 2
            circleView.layer.borderColor = UIColor.systemGreen.cgColor
            circleView.layer.cornerRadius = size / 2
        }
    }
}



class HeaderCell: UICollectionViewCell {
    private let label = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.clipsToBounds = true
        contentView.backgroundColor = .systemBackground
        contentView.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            label.topAnchor.constraint(equalTo: contentView.topAnchor),
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        label.font = UIFont.monospacedSystemFont(ofSize: 11, weight: .regular)
        label.textColor = .black
        label.textAlignment = .center
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.4
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        label.transform = .identity
    }

    func configure(text: String, isColumnHeader: Bool) {
        label.text = text
        label.transform = isColumnHeader
            ? CGAffineTransform(rotationAngle: -.pi/2)
            : .identity
    }
}

