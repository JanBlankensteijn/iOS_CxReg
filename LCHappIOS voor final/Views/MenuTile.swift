// ✅ MenuTile.swift met generieke destination voor correcte back-button naam
import SwiftUI

struct MenuTile<Destination: View>: View {
    var title: String
    var icon: String
    var color: Color
    var destination: Destination

    var body: some View {
        NavigationLink(destination: destination) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 32))
                    .foregroundColor(.white)
                    .frame(width: 50, height: 50)
                    .background(color)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                Text(title)
                    .font(.title3.bold())
                    .foregroundColor(.primary)

                Spacer()
            }
            .padding()
            .background(Color.blue.opacity(0.05))
            .cornerRadius(20)
            .shadow(color: .gray.opacity(0.2), radius: 6, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
        .frame(maxWidth: .infinity)
    }
}