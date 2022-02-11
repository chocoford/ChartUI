import SwiftUI

/// View containing data and some kind of chart content
struct CardView<Content: View>: View {
    var chartData = ChartData()
    let content: () -> Content
    
    private var showShadow: Bool
    
    /// Initialize with view options and a nested `ViewBuilder`
    /// - Parameters:
    ///   - showShadow: should card have a rounded-rectangle shadow around it
    ///   - content: <#content description#>
    init(showShadow: Bool = true, @ViewBuilder content: @escaping () -> Content) {
        self.showShadow = showShadow
        self.content = content
    }
    
    /// The content and behavior of the `CardView`.
    ///
    ///
    var body: some View {
        ZStack{
            if showShadow {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white)
                    .shadow(color: Color.gray, radius: 8)
            }
            VStack {
                self.content()
            }
            .clipShape(RoundedRectangle(cornerRadius: showShadow ? 20 : 0))
        }
    }
}
