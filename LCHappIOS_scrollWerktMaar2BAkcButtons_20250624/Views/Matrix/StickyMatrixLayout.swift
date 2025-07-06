import UIKit

/// UICollectionViewLayout subclass die een starre grid tekent
/// en de bovenste rij en eerste kolom sticky maakt.
class StickyMatrixLayout: UICollectionViewLayout {
    private var cache: [UICollectionViewLayoutAttributes] = []
    private var contentSize: CGSize = .zero

    override func prepare() {
        super.prepare()
        guard let cv = collectionView else { return }
        cache.removeAll()

        let totalRows = cv.numberOfSections              // incl. header-section
        let totalCols = cv.numberOfItems(inSection: 0)   // incl. header-item

        // Bepaal volledige scroll-grootte (zonder dummy)
        let width  = MatrixLayout.rijheaderbreedte
                    + CGFloat(max(0, totalCols - 1)) * MatrixLayout.kolombreedte
        let height = MatrixLayout.headerhoogte
                    + CGFloat(max(0, totalRows - 1)) * MatrixLayout.rijhoogte
        contentSize = CGSize(width: width, height: height)

        // Voor elke cel de exacte frame berekenen
        for section in 0..<totalRows {
            for item in 0..<totalCols {
                let indexPath = IndexPath(item: item, section: section)
                let attr = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                var frame = CGRect.zero

                // Corners en headers
                if section == 0 && item == 0 {
                    // Linkerbovenhoek
                    frame = CGRect(
                        x: 0, y: 0,
                        width: MatrixLayout.rijheaderbreedte,
                        height: MatrixLayout.headerhoogte
                    )
                    attr.zIndex = 1025
                }
                else if section == 0 {
                    // Bovenste rij (kolom-headers)
                    let x = MatrixLayout.rijheaderbreedte
                          + CGFloat(item - 1) * MatrixLayout.kolombreedte
                    frame = CGRect(
                        x: x, y: 0,
                        width: MatrixLayout.kolombreedte,
                        height: MatrixLayout.headerhoogte
                    )
                    attr.zIndex = 1024
                }
                else if item == 0 {
                    // Eerste kolom (rij-headers)
                    let y = MatrixLayout.headerhoogte
                          + CGFloat(section - 1) * MatrixLayout.rijhoogte
                    frame = CGRect(
                        x: 0, y: y,
                        width: MatrixLayout.rijheaderbreedte,
                        height: MatrixLayout.rijhoogte
                    )
                    attr.zIndex = 1024
                }
                else {
                    // Data-cellen
                    let x = MatrixLayout.rijheaderbreedte
                          + CGFloat(item - 1) * MatrixLayout.kolombreedte
                    let y = MatrixLayout.headerhoogte
                          + CGFloat(section - 1) * MatrixLayout.rijhoogte
                    frame = CGRect(
                        x: x, y: y,
                        width: MatrixLayout.kolombreedte,
                        height: MatrixLayout.rijhoogte
                    )
                    attr.zIndex = 1
                }

                attr.frame = frame.integral  // pixel-precies
                cache.append(attr)
            }
        }
    }

    override var collectionViewContentSize: CGSize {
        // Zorg dat horizontal én vertical scrollen precies matcht
        return contentSize
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let cv = collectionView else { return nil }
        let offsetX = cv.contentOffset.x
        let offsetY = cv.contentOffset.y

        var visible: [UICollectionViewLayoutAttributes] = []
        for orig in cache {
            // Toon alle “sticky” headers altijd, en data-cellen alleen als ze in rect zitten
            if orig.zIndex > 1 || orig.frame.intersects(rect) {
                let attr = orig.copy() as! UICollectionViewLayoutAttributes
                let (section, item) = (attr.indexPath.section, attr.indexPath.item)
                // Maak top-row sticky
                if section == 0 {
                    attr.frame.origin.y = offsetY
                }
                // Maak eerste kolom sticky
                if item == 0 {
                    attr.frame.origin.x = offsetX
                }
                visible.append(attr)
            }
        }
        return visible
    }

    override func layoutAttributesForItem(at indexPath: IndexPath)
      -> UICollectionViewLayoutAttributes? {
        return cache.first { $0.indexPath == indexPath }?
                   .copy() as? UICollectionViewLayoutAttributes
    }

    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        // Zorg dat we tijdens scroll de sticky posities telkens bijwerken
        return true
    }
}

