import SwiftUI

struct HighlightedText: View {
    let text: String
    let highlights: String
    var defaultColor: Color = .primary
    var codeOnly: Bool = false

    var body: some View {
        let terms = highlights.split(separator: " ").map(String.init)

        // Filter termen: als codeOnly aan staat, alleen 3 hoofdletters
        let filteredTerms = terms.filter { term in
            if codeOnly {
                return term.count == 3 && term.uppercased() == term
            } else {
                return !(term.count == 3 && term.uppercased() == term)
            }
        }.map { $0.lowercased() }

        return text.split(separator: " ", omittingEmptySubsequences: false).reduce(Text("")) { result, word in
            let wordStr = String(word)
            var currentText = Text("")
            var lowerWord = wordStr.lowercased()
            var pos = wordStr.startIndex

            while pos < wordStr.endIndex {
                var matched = false
                for term in filteredTerms {
                    if let range = lowerWord.range(of: term, range: pos..<lowerWord.endIndex) {
                        if range.lowerBound > pos {
                            let prefix = String(wordStr[pos..<range.lowerBound])
                            currentText = currentText + Text(prefix)
                        }
                        let match = String(wordStr[range])
                        currentText = currentText + Text(match).foregroundColor(.green)
                        pos = range.upperBound
                        matched = true
                        break
                    }
                }
                if !matched {
                    let remainder = String(wordStr[pos...])
                    currentText = currentText + Text(remainder)
                    break
                }
            }

            return result + currentText + Text(" ")
        }
        .foregroundColor(defaultColor)
        .multilineTextAlignment(.leading)
        .lineLimit(nil)
    }
}

