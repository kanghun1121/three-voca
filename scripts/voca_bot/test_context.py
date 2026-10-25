import unittest
from pathlib import Path

from context import _markdown_sections, is_asset_only, load_context, route_context
from review import build_review_request, commentable_ranges


ROOT = Path(__file__).resolve().parents[2]


def changed(path, code):
    return {"filename": path, "status": "modified", "patch": f"@@ -1 +1 @@\n-old\n+{code}\n"}


class ContextRoutingTests(unittest.TestCase):
    def test_asset_only_loads_no_reference(self):
        files = [changed("Assets.xcassets/Icon.imageset/icon.png", "binary")]
        self.assertTrue(is_asset_only(files))
        self.assertEqual(route_context(files), [])

    def test_implementation_without_tests_skips_test_skill(self):
        files = [changed("Projects/Domain/Sources/Repository.swift", "protocol LessonRepository {}")]
        paths = [path for path, _ in route_context(files)]
        self.assertIn("docs/architecture/clean-architecture.md", paths)
        self.assertIn(".agents/skills/overengineering-check/SKILL.md", paths)
        self.assertNotIn(".agents/skills/test-value-check/SKILL.md", paths)

    def test_existing_use_case_reads_only_its_architecture_rule(self):
        files = [changed("Projects/Domain/Sources/UseCase/LoadLessonUseCase+Live.swift",
                         "return try await lessonRepository.fetch(id)")]
        loaded = {item["path"]: item for item in load_context(files, ROOT)}
        rule = loaded["docs/architecture/clean-architecture.md"]
        self.assertEqual(rule["sections"], ["Repository와 DataSource", "UseCase"])
        self.assertNotIn("flowchart LR", rule["content"])
        self.assertNotIn("docs/architecture/clean-architecture/examples.md", loaded)

    def test_model_mapping_reads_model_rule_and_relevant_example(self):
        files = [changed("Projects/Data/Sources/Word/WordEntity+Mapping.swift",
                         "return entity.toDomain()")]
        loaded = {item["path"]: item for item in load_context(files, ROOT)}
        rule = loaded["docs/architecture/clean-architecture.md"]
        example = loaded["docs/architecture/clean-architecture/examples.md"]
        self.assertEqual(rule["sections"], ["데이터 모델: DTO → Domain Model"])
        self.assertIn("외부 모델은 도메인 경계에서 변환한다", example["sections"])
        self.assertNotIn("단순 조회에는 UseCase를 추가하지 않는다", example["content"])

    def test_domain_interface_import_does_not_select_target_graph(self):
        files = [changed("Projects/Data/Sources/Word/WordRepository+Live.swift",
                         "import DomainInterface")]
        loaded = {item["path"]: item for item in load_context(files, ROOT)}
        rule = loaded["docs/architecture/clean-architecture.md"]
        self.assertNotIn("레이어 구조와 의존 방향", rule["sections"])

    def test_missing_heading_falls_back_to_full_document(self):
        content = "# Guide\n\n## Existing\nRule.\n"
        self.assertEqual(_markdown_sections(content, ["Renamed"]), content)

    def test_networking_target_reads_only_networking_module_rules(self):
        files = [changed("Projects/Networking/Project.swift", "let target = NetworkingInterface")]
        loaded = {item["path"]: item for item in load_context(files, ROOT)}
        rule = loaded["docs/architecture/modulization.md"]
        self.assertEqual(rule["sections"], ["공통 Interface 분리 원칙", "Networking의 Interface 분리 이유", "Networking 타겟 구성"])
        self.assertNotIn("## Feature 모듈 타겟 구성", rule["content"])

    def test_dependency_contract_reads_its_rule_without_fixture_policy(self):
        files = [changed("Projects/Domain/Interface/Repository/WordRepository.swift",
                         "extension WordRepository: UnimplementedTestDependencyKey {}")]
        loaded = {item["path"]: item for item in load_context(files, ROOT)}
        rule = loaded["docs/architecture/dependency-injection.md"]
        self.assertEqual(rule["sections"], ["값 타입 계약과 객체 간 의존", "구현 등록과 테스트 키"])
        self.assertNotIn("사례 데이터와 조립 위치", rule["content"])
        self.assertNotIn("full", rule["sections"])

    def test_example_fixture_reads_only_fixture_policy(self):
        files = [changed("Projects/Feature/Home/Example/HomeExampleApp.swift",
                         "let repository = .happyPath")]
        loaded = {item["path"]: item for item in load_context(files, ROOT)}
        rule = loaded["docs/architecture/dependency-injection.md"]
        self.assertEqual(rule["sections"], ["사례 데이터와 조립 위치"])
        self.assertNotIn("구현 등록과 테스트 키", rule["content"])

    def test_feature_interface_skips_domain_and_networking_targets(self):
        files = [changed("Projects/Feature/Word/Interface/WordRoute.swift",
                         "public struct WordRoute {}")]
        loaded = {item["path"]: item for item in load_context(files, ROOT)}
        rule = loaded["docs/architecture/modulization.md"]
        self.assertIn("Feature 모듈 경계 규칙", rule["sections"])
        self.assertNotIn("Domain 타겟 구성", rule["content"])
        self.assertNotIn("Networking 타겟 구성", rule["content"])

    def test_cache_revalidation_reads_etag_rule(self):
        files = [changed("Projects/Data/Sources/Post/PostCache.swift", "let etag = response.etag")]
        loaded = {item["path"]: item for item in load_context(files, ROOT)}
        rule = loaded["docs/system-design/cache-control.md"]
        self.assertIn("조건부 재검증", rule["sections"])
        self.assertNotIn("동시 만료와 요청 집중", rule["content"])
        self.assertNotIn("사건에 따른 무효화", rule["content"])
        self.assertNotIn("full", rule["sections"])

    def test_payment_retry_reads_idempotency_rule(self):
        files = [changed("Projects/Networking/Sources/HTTP/HTTPClient.swift",
                         "let requestID = payment.idempotencyKey")]
        loaded = {item["path"]: item for item in load_context(files, ROOT)}
        rule = loaded["docs/system-design/server-failure.md"]
        self.assertIn("중복 실행을 막는 작업 식별", rule["sections"])
        self.assertNotIn("모바일에서 입력을 보존하기", rule["content"])
        self.assertNotIn("full", rule["sections"])

    def test_state_ownership_reads_only_related_state_rules(self):
        files = [changed("Projects/Feature/Word/Sources/WordView.swift", "@State private var selectedIndex = 0")]
        loaded = {item["path"]: item for item in load_context(files, ROOT)}
        state = loaded["docs/system-design/state-management.md"]
        self.assertIn("상태의 소유 범위를 정하는 질문", state["content"])
        self.assertNotIn("상태의 수명과 원본", state["content"])
        self.assertNotIn("full", state["sections"])

    def test_view_state_selection_skips_unrelated_example(self):
        files = [changed("Projects/Feature/Word/Sources/WordViewModel.swift", "state = .loading")]
        loaded = {item["path"]: item for item in load_context(files, ROOT)}
        state = loaded["docs/system-design/view-state.md"]
        self.assertIn("빈 결과와 새로고침 상태 정하기", state["content"])
        self.assertNotIn("독립적인 UI 상태 분리하기", state["content"])
        self.assertNotIn("full", state["sections"])

    def test_cache_invalidation_skips_revalidation_and_expiry(self):
        files = [changed("Projects/Data/Sources/Post/PostRepository.swift", "invalidatePost(id)")]
        loaded = {item["path"]: item for item in load_context(files, ROOT)}
        cache = loaded["docs/system-design/cache-control.md"]
        self.assertIn("사건에 따른 무효화", cache["content"])
        self.assertNotIn("조건부 재검증", cache["content"])
        self.assertNotIn("시간에 따른 만료", cache["content"])

    def test_retry_policy_reads_intervals_without_local_draft(self):
        files = [changed("Projects/Networking/Sources/HTTP/HTTPClient.swift", "let delay = retry.backoff(attempt)")]
        loaded = {item["path"]: item for item in load_context(files, ROOT)}
        failure = loaded["docs/system-design/server-failure.md"]
        self.assertIn("재시도 간격과 전체 횟수 정하기", failure["content"])
        self.assertNotIn("모바일에서 입력을 보존하기", failure["content"])

    def test_ssot_selection_keeps_core_principle(self):
        files = [changed("Projects/Feature/Word/Sources/WordStore.swift", "store.sync()")]
        loaded = {item["path"]: item for item in load_context(files, ROOT)}
        ssot = loaded["docs/system-design/ssot.md"]
        self.assertIn("기준이 되는 데이터 정하기", ssot["content"])
        self.assertNotIn("서버 상태를 먼저 표시할 때", ssot["content"])

    def test_lint_duplicate_imports_are_checked_per_file(self):
        one_file = [{"filename": "Projects/Feature/Home/Sources/HomeView.swift", "status": "modified",
                     "patch": "@@ -0,0 +1,2 @@\n+import SwiftUI\n+import SwiftUI\n"}]
        loaded = {item["path"]: item for item in load_context(one_file, ROOT)}
        self.assertEqual(loaded["docs/lint.md"]["sections"], ["2.4 Import 정렬"])
        two_files = [changed("Projects/Feature/Home/Sources/A.swift", "import SwiftUI"),
                     changed("Projects/Feature/Home/Sources/B.swift", "import SwiftUI")]
        paths = [path for path, _ in route_context(two_files)]
        self.assertNotIn("docs/lint.md", paths)

    def test_weak_self_change_reads_task_lint_example(self):
        files = [changed("Projects/Feature/Home/Tests/HomeTests.swift", "Task { [weak self] in await self?.run() }")]
        loaded = {item["path"]: item for item in load_context(files, ROOT)}
        self.assertEqual(loaded["docs/lint.md"]["sections"], ["4. Task와 소유 관계"])
        self.assertEqual(loaded["docs/lint/examples.md"]["sections"], ["Task에서 self 캡처"])

    def test_closure_style_skips_task_lifetime(self):
        files = [changed("Projects/Feature/Home/Sources/HomeView.swift",
                         "let labels = words.map({ $0.title })")]
        loaded = {item["path"]: item for item in load_context(files, ROOT)}
        self.assertEqual(loaded["docs/lint.md"]["sections"], ["3. 클로저"])
        self.assertNotIn("4. Task와 소유 관계", loaded["docs/lint.md"]["content"])

    def test_test_change_loads_test_skill(self):
        files = [changed("Projects/Feature/Home/Tests/HomeTests.swift", "func testEmpty() {}")]
        paths = [path for path, _ in route_context(files)]
        self.assertEqual(paths, [
            "docs/review-policy.md",
            ".agents/skills/test-value-check/SKILL.md",
            ".agents/skills/test-value-check/references/assertions.md",
            ".agents/skills/test-value-check/references/execution-path.md",
        ])

    def test_removed_test_call_routes_execution_path(self):
        files = [{"filename": "Projects/Feature/Word/Tests/WordTests.swift", "status": "modified",
                  "patch": "@@ -1 +1 @@\n-        await vm.requestIfNeeded(at: 1)\n+        let detail = .previewFixture\n"}]
        paths = [path for path, _ in route_context(files)]
        self.assertIn(".agents/skills/test-value-check/references/execution-path.md", paths)
        self.assertNotIn(".agents/skills/test-value-check/references/async-stability.md", paths)

    def test_multiple_tests_with_assertions_route_value_and_assertions(self):
        files = [{"filename": "Projects/Domain/Tests/WordTests.swift", "status": "modified",
                  "patch": "@@ -0,0 +1,2 @@\n+func test_first() { XCTAssertEqual(value, 1) }\n+func test_second() { XCTAssertEqual(value, 1) }\n"}]
        paths = [path for path, _ in route_context(files)]
        self.assertIn(".agents/skills/test-value-check/references/test-value.md", paths)
        self.assertIn(".agents/skills/test-value-check/references/assertions.md", paths)

    def test_state_and_cache_route_only_matching_docs(self):
        files = [changed("Projects/Feature/Home/Sources/HomeViewModel.swift", "@State var isLoading = true")]
        paths = [path for path, _ in route_context(files)]
        self.assertIn("docs/system-design/state-management.md", paths)
        self.assertIn("docs/system-design/view-state.md", paths)
        self.assertNotIn("docs/system-design/cache-control.md", paths)

    def test_cache_file_routes_cache_policy_even_for_small_guard_change(self):
        files = [changed("Projects/Data/Sources/Audio/AudioMemoryCache.swift", "guard let entry = entries[term] else { return nil }")]
        paths = [path for path, _ in route_context(files)]
        self.assertIn("docs/system-design/cache-control.md", paths)

    def test_http_client_retry_change_routes_server_failure(self):
        files = [changed("Projects/Networking/Sources/HTTP/HTTPClient.swift", "return try await session.data(for: urlRequest)")]
        paths = [path for path, _ in route_context(files)]
        self.assertIn("docs/system-design/server-failure.md", paths)

    def test_new_feature_store_routes_state_and_design_review(self):
        files = [{"filename": "Projects/Feature/Word/Sources/Detail/SelectionStore.swift",
                  "status": "added", "patch": "@@ -0,0 +1 @@\n+final class SelectionStore {}\n"}]
        paths = [path for path, _ in route_context(files)]
        self.assertIn("docs/system-design/state-management.md", paths)
        self.assertIn("docs/system-design/ssot.md", paths)
        self.assertIn(".agents/skills/overengineering-check/SKILL.md", paths)

    def test_new_options_and_state_machine_route_design_review(self):
        for name in ("LoadingOptions.swift", "LoadStateMachine.swift"):
            files = [{"filename": f"Projects/Feature/Word/Sources/{name}",
                      "status": "added", "patch": "@@ -0,0 +1 @@\n+struct NewType {}\n"}]
            paths = [path for path, _ in route_context(files)]
            self.assertIn(".agents/skills/overengineering-check/SKILL.md", paths)

    def test_new_use_case_routes_only_abstraction_checklist(self):
        files = [{"filename": "Projects/Domain/Interface/UseCase/LoadWordUseCase.swift",
                  "status": "added", "patch": "@@ -0,0 +1 @@\n+struct LoadWordUseCase {}\n"}]
        paths = [path for path, _ in route_context(files)]
        prefix = ".agents/skills/overengineering-check/"
        self.assertEqual([path for path in paths if path.startswith(prefix)], [
            prefix + "SKILL.md", prefix + "references/abstractions.md",
        ])

    def test_options_routes_abstraction_and_maintenance_checklists(self):
        files = [{"filename": "Projects/Feature/Word/Sources/LoadingOptions.swift",
                  "status": "added", "patch": "@@ -0,0 +1 @@\n+struct LoadingOptions {}\n"}]
        paths = [path for path, _ in route_context(files)]
        self.assertIn(".agents/skills/overengineering-check/references/abstractions.md", paths)
        self.assertIn(".agents/skills/overengineering-check/references/test-maintenance.md", paths)

    def test_async_use_case_does_not_route_network_checklist(self):
        files = [{"filename": "Projects/Domain/Sources/UseCase/LoadWordUseCase.swift",
                  "status": "added", "patch": "@@ -0,0 +1 @@\n+func execute() async throws {}\n"}]
        paths = [path for path, _ in route_context(files)]
        self.assertNotIn(".agents/skills/overengineering-check/references/network-storage.md", paths)

    def test_download_retry_without_retry_word_routes_failure_review(self):
        files = [changed("Projects/Data/Sources/Audio/RemoteDataSource.swift",
                         "do { return try await httpClient.data(from: url) } catch { return try await httpClient.data(from: url) }")]
        paths = [path for path, _ in route_context(files)]
        self.assertIn("docs/system-design/server-failure.md", paths)
        self.assertIn(".agents/skills/overengineering-check/SKILL.md", paths)

    def test_dynamic_prompt_includes_design_and_test_findings(self):
        pr = {"title": "변경", "body": ""}
        files = [{"path": "Test.swift", "status": "modified", "patch": "@@ -1 +1 @@\n-old\n+new\n"}]
        static = build_review_request(pr, files, False, "gpt-4.1")
        dynamic = build_review_request(pr, files, False, "gpt-4.1", review_mode="dynamic")
        self.assertNotIn("Assess the value of new design and test code", static["instructions"])
        self.assertIn("Assess the value of new design and test code", dynamic["instructions"])
        self.assertIn("line comment", dynamic["instructions"])
        self.assertIn("commentable_ranges", dynamic["input"])

    def test_commentable_ranges_match_added_and_deleted_lines(self):
        files = [{"path": "A.swift", "status": "modified",
                  "patch": "@@ -40,4 +40,1 @@\n-old1\n-old2\n-old3\n-old4\n+new\n"}]
        self.assertEqual(commentable_ranges(files), [
            {"path": "A.swift", "RIGHT": [[40, 40]], "LEFT": [[40, 43]]}
        ])

    def test_pr_prose_cannot_select_context(self):
        files = [changed("Projects/Feature/Home/Sources/HomeView.swift", "Text(\"Hi\")")]
        self.assertEqual(route_context(files), [("docs/review-policy.md", "리뷰 우선순위와 코멘트 기준")])

    def test_selected_context_is_loaded_from_repo_with_hash(self):
        files = [changed("Projects/Domain/Sources/Repository.swift", "protocol LessonRepository {}")]
        loaded = load_context(files, ROOT)
        self.assertTrue(loaded)
        self.assertEqual(len(loaded[0]["sha256"]), 64)
        self.assertIn("content", loaded[0])


if __name__ == "__main__":
    unittest.main()
