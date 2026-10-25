import unittest
from pathlib import Path

from context import is_asset_only, load_context, route_context
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
