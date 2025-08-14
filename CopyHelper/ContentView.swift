import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            List {
                NavigationLink("個人情報", destination: PersonalContentView())
                NavigationLink("メール", destination: EmailView())
                NavigationLink("クレジットカード", destination: CreditCardView())
            }
            .navigationTitle("メニュー")
        }
    }
}

#Preview {
    ContentView()
}
