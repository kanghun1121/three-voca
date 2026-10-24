# ViewState 예시

피드 화면이 **첫 로딩, 내용, 빈 결과, 전체 화면 오류** 중 하나를 보여준다고 가정한다. 아래 코드는 상태 표현과 화면 전이를 설명하기 위한 예시다. `Post: Identifiable`과 `feedRepository` 계약은 해당 기능에서 정의한다고 가정한다.

## Bad Case: 하나의 화면 단계를 독립 값으로 표현

```swift
@Observable
@MainActor
final class FeedViewModel {
    var isLoading = false
    var posts: [Post] = []
    var errorMessage: String?
}
```

세 값을 아무 순서로나 바꿀 수 있어서 `isLoading == true`와 `errorMessage != nil`이 동시에 남을 수 있다. 이 조합을 어떻게 표시할지 화면마다 다시 판단해야 한다.

## Good Case: 서로 배타적인 화면 단계

```swift
enum FeedViewState {
    case loading
    case loaded([Post])
    case empty
    case error(String)
}

@Observable
@MainActor
final class FeedViewModel {
    private(set) var state: FeedViewState = .loading
    @ObservationIgnored @Dependency(\.feedRepository) private var feedRepository

    func refresh() async {
        state = .loading

        do {
            let posts = try await feedRepository.fetchPosts()
            state = posts.isEmpty ? .empty : .loaded(posts)
        } catch {
            state = .error("피드를 불러오지 못했습니다.")
        }
    }

}

struct FeedView: View {
    @State private var viewModel = FeedViewModel()

    var body: some View {
        switch viewModel.state {
        case .loading:
            ProgressView()
        case let .loaded(posts):
            List(posts) { post in
                PostRow(post: post)
            }
        case .empty:
            ContentUnavailableView("게시물이 없습니다", systemImage: "tray")
        case let .error(message):
            ContentUnavailableView(message, systemImage: "exclamationmark.triangle")
        }
    }
}
```

이 예시에서 `refresh()`는 기존 내용을 지우고 전체 화면 로딩을 표시한다. 기존 내용을 유지하며 다시 불러오는 요구사항이라면 `loaded`에 새로고침 상태를 포함하는 식으로 화면 정책을 바꾼다. 테스트에서는 첫 요청, 빈 결과, 오류, 재시도 후 성공의 전이를 각각 확인한다.
