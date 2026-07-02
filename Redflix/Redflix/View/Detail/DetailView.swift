import SwiftUI
import redfast_core
import redfast_ui

struct DetailView: View {
    let movie: MovieData
    
    @Environment(\.displayScale) private var displayScale
    @EnvironmentObject var sharedData: SharedData
    private var isTV: Bool { UIDevice.current.userInterfaceIdiom == .tv }
    
    @FocusState private var focusedImage: String?
    
    private var headerHeight: CGFloat { isTV ? 500 : 300 }
    private var posterWidth: CGFloat { isTV ? 280 : 160 }
    private var titleFontSize: CGFloat { isTV ? 60 : 28 }
    private var descFontSize: CGFloat { isTV ? 28 : 15 }
    private var metaFontSize: CGFloat { isTV ? 22 : 12 }
    private var spacing: CGFloat { isTV ? 40 : 16 }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {

                ZStack {
                    AsyncImage(url: movie.landscapeURL) { phase in
                        if case .success(let image) = phase {
                            image
                                .resizable()
                                .scaledToFill()
                        } else {
                            Color.black.opacity(0.3)
                        }
                    }
                    .frame(height: headerHeight)
                    .frame(maxWidth: .infinity)
                    .clipped()
                    
                    Color.black.opacity(0.4)

                    if let posterURL = movie.portraitURL {
                        AsyncImage(url: posterURL) { phase in
                            if case .success(let image) = phase {
                                image
                                    .resizable()
                                    .scaledToFit()
                            } else {
                                Color.gray
                            }
                        }
                        .frame(width: posterWidth)
                        .cornerRadius(isTV ? 16 : 12)
                        .shadow(color: .black.opacity(0.5), radius: isTV ? 15 : 8)
                    }
                }

                VStack(spacing: isTV ? 20 : 6) {
                    Text(movie.name ?? "")
                        .font(.system(size: titleFontSize, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.top, spacing)
                        .multilineTextAlignment(.center)
                        .focusable(isTV)

                    Text(movie.shortDescription ?? "")
                        .font(.system(size: descFontSize, weight: .medium))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, isTV ? 120 : 16)
                        .padding(.bottom, 8)

                    HStack(spacing: isTV ? 60 : 20) {
                        if let director = movie.director, !director.isEmpty {
                            Text("Director: \(director)")
                                .font(.system(size: metaFontSize))
                                .foregroundColor(.white.opacity(0.8))
                        }

                        if let duration = movie.duration, !duration.isEmpty {
                            Text("Duration: \(duration)")
                                .font(.system(size: metaFontSize))
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                }
                .padding(.horizontal, 16)
                
                VStack {
                    Button {
                        onButtonClick(id: "purchase")
                    } label: {
                        Text("PURCHASE")
                    }
                    .frame(height: 56)
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    #if os(tvOS)
                    .buttonStyle(PlainButtonStyle())
                    #endif
                    
                    Button {
                        onButtonClick(id: "rent")
                    } label: {
                        Text("RENT")
                    }
                    .frame(height: 56)
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    #if os(tvOS)
                    .buttonStyle(PlainButtonStyle())
                    #endif
                    Button {
                        onButtonClick(id: "wizard")
                    } label: {
                        Text("WIZARD")
                    }
                    .frame(height: 56)
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    #if os(tvOS)
                    .buttonStyle(PlainButtonStyle())
                    #endif
                }
                .padding(16)

                VStack(spacing: isTV ? 40 : 12) {
                    ForEach(MovieDetailAssets.descriptionImages, id: \.self) { imageName in
                        Image(imageName)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: isTV ? 1200 : .infinity)
                            .cornerRadius(isTV ? 20 : 12)
                            .focusable(isTV)
                            .focused($focusedImage, equals: imageName)
                            .scaleEffect(isTV && focusedImage == imageName ? 1.02 : 1.0)
                            .animation(.snappy, value: focusedImage)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, isTV ? 60 : 16)
            }
            .padding(.bottom, isTV ? 100 : 50)
        }
        .task {
            // Update the SDK's current screen name directly so it is set before
            // any button on this screen fires a click trigger.
            _ = PromptManager.shared.onScreenChanged(screenName: "detail")
            sharedData.trigger = .screen("detail")
        }
        .background(Color(hex: "#081b27") ?? .black)
        .ignoresSafeArea(edges: .top)
        .toolbar(.hidden, for: .tabBar)
#if os(iOS)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Image("redflix_logo")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 56)
            }
        }
        .toolbarBackground(Color(hex: "#0C2737") ?? .black, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .navigationBarTitleDisplayMode(.inline)
#endif
    }
    
    func onButtonClick(id: String) {
        sharedData.trigger = .button(id)
    }
    
    
}

private enum MovieDetailAssets {
    static let descriptionImages: [String] = [
        "description1",
        "description2",
        "description3",
        "description4",
        "description5"
    ]
}
