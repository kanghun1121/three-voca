"""Choose a small set of trusted project references for a PR review."""

import hashlib
import re
from pathlib import Path


MAX_CONTEXT_CHARS = 24_000
ASSET_SUFFIXES = {
    ".png", ".jpg", ".jpeg", ".webp", ".gif", ".heic", ".pdf",
    ".svg", ".xcassets", ".colorset", ".imageset", ".ttf", ".otf",
    ".mp3", ".wav", ".mp4", ".mov", ".strings", ".xcstrings",
}


def _is_asset(path):
    parts = Path(path).parts
    return any(Path(part).suffix.lower() in ASSET_SUFFIXES for part in parts)


def is_asset_only(files):
    return bool(files) and all(_is_asset(file["filename"]) for file in files)


def _is_test(path):
    return bool(re.search(r"(^|/)(Tests?|[^/]+Tests?)(/|\.)", path, re.I))


def _added_text(files):
    return "\n".join(
        row[1:]
        for file in files
        for row in (file.get("patch") or "").splitlines()
        if row.startswith("+") and not row.startswith("+++")
    )


def _removed_text(files):
    return "\n".join(
        row[1:]
        for file in files
        for row in (file.get("patch") or "").splitlines()
        if row.startswith("-") and not row.startswith("---")
    )


def _test_value_references(files):
    """Choose reference files from changed code, including removed assertions/calls."""
    added = _added_text(files)
    changed = added + "\n" + _removed_text(files)
    selected = []
    if len(re.findall(r"\bfunc\s+test\b|\bfunc\s+test_|@Test\b", added)) > 1 or re.search(
        r"duplicate|redundant|same.test|중복", changed, re.I
    ):
        selected.append("test-value.md")
    if re.search(r"XCTAssert|XCTFail|#expect|#require|\bcatch\b|\btry\?|\.map\(", added, re.I):
        selected.append("assertions.md")
    if re.search(r"withDependencies|\w*Mock\b|\w*Stub\b|fixture|ForTests", changed, re.I) or re.search(
        r"\b(?:await|try)\s+(?:vm|sut|viewModel|repository)\.\w+\(", _removed_text(files), re.I
    ):
        selected.append("execution-path.md")
    if re.search(r"Task\.sleep|Thread\.sleep|\.milliseconds\(|DispatchQueue\.asyncAfter|Task\.yield|AsyncStream|observationTask", changed, re.I):
        selected.append("async-stability.md")
    if not selected:
        selected.extend(("assertions.md", "execution-path.md"))
    return selected


def overengineering_references(files):
    """Select checklists from changed paths and diff lines, never PR prose."""
    changed = "\n".join(file["filename"] for file in files)
    changed += "\n" + _added_text(files) + "\n" + _removed_text(files)
    selected = []
    if re.search(r"UseCase|Repository|DataSource|Strategy|Factory|Options|Configuration|Coordinator|Manager", changed, re.I) or re.search(
        r"\bprotocol\b|\binterface\b", changed, re.I
    ):
        selected.append("abstractions.md")
    if re.search(r"Store|StateMachine|ViewState|UIState|@State", changed) or re.search(r"\bstore\b", changed, re.I):
        selected.append("state.md")
    if re.search(r"Cache|Retry|RemoteDataSource|Download|Timeout|Offline|Sync", changed) or re.search(
        r"\b(?:cache|cached|retry|download|timeout|offline|sync)\b", changed, re.I
    ):
        selected.append("network-storage.md")
    if re.search(r"ForTests|testOnly|unused|Options|Configuration", changed, re.I):
        selected.append("test-maintenance.md")
    return selected


def _new_source_file(files, suffixes):
    return any(
        file.get("status") == "added"
        and file["filename"].endswith(suffixes)
        and not _is_test(file["filename"])
        for file in files
    )


def route_context(files):
    """Return ordered (relative path, reason) pairs; PR prose never controls routing."""
    paths = [file["filename"] for file in files]
    if not paths or is_asset_only(files):
        return []
    code = [path for path in paths if path.endswith(".swift")]
    tests = [path for path in code if _is_test(path)]
    source = [path for path in code if not _is_test(path)]
    added = _added_text(files)
    selected = {}

    def add(path, reason):
        selected.setdefault(path, reason)

    add("docs/review-policy.md", "리뷰 우선순위와 코멘트 기준")

    if any("Projects/Domain/" in p or "Projects/Data/" in p for p in source):
        add("docs/architecture/clean-architecture.md", "Domain/Data 경계 변경")
    if any("Projects/Feature/" in p for p in source) and re.search(
        r"\b(Repository|UseCase|DataSource|DomainModel|DTO|Entity)\b", added
    ):
        add("docs/architecture/clean-architecture.md", "Feature의 데이터 경계 변경")
    if any("Projects/" in p for p in source) and re.search(
        r"@Dependency|DependencyKey|liveValue|UnimplementedTestDependencyKey|withDependencies", added
    ):
        add("docs/architecture/dependency-injection.md", "의존성 주입 변경")
    if any("Project.swift" in p or "/Interface/" in p for p in source):
        add("docs/architecture/modulization.md", "모듈 계약 또는 타겟 변경")
    if any("Projects/Feature/" in p for p in source) and (
        re.search(r"@State\b|@Observable\b|@Bindable\b|Binding\b|state\s*=|StateFlow|\bStateMachine\b", added)
        or _new_source_file(files, ("Store.swift", "StateMachine.swift"))
    ):
        add("docs/system-design/state-management.md", "화면 상태 소유 변경")
    if re.search(r"\b(ViewState|UIState|isLoading|loading|empty|error)\b", added, re.I) and source:
        add("docs/system-design/view-state.md", "화면 표시 상태 변경")
    if source and (
        re.search(r"\b(Store|stateStream|observe|publisher|sync)\b", added, re.I)
        or _new_source_file(files, ("Store.swift",))
    ):
        add("docs/system-design/ssot.md", "공유 상태 또는 동기화 변경")
    if source and (
        re.search(r"\b(cache|cached|TTL|etag|invalidate|fetchedAt)\b", added, re.I)
        or any("Cache" in Path(path).name for path in source)
    ):
        add("docs/system-design/cache-control.md", "캐시 정책 변경")
    if source and (
        re.search(r"\b(retry|timeout|idempoten|requestID|URLRequest|HTTPURLResponse)\b|session\.data", added, re.I)
        or ("catch" in added and re.search(r"(?:\.download\(|\.data\(from:)", added))
        or any("TokenRefreshInterceptor" in path or "HTTPClient.swift" in path for path in source)
    ):
        add("docs/system-design/server-failure.md", "요청 실패 처리 변경")
    if source and (
        re.search(r"\b(protocol|Repository|UseCase|DataSource|Coordinator|Manager|Cache|RetryPolicy)\b|\bactor\b", added)
        or _new_source_file(files, ("UseCase.swift", "Store.swift", "StateMachine.swift", "Options.swift", "Strategy.swift", "Cache.swift"))
        or ("catch" in added and re.search(r"(?:\.download\(|\.data\(from:)", added))
    ):
        add(".agents/skills/overengineering-check/SKILL.md", "새 계층 또는 정책 구조 검토")
        for name in overengineering_references(files):
            add(f".agents/skills/overengineering-check/references/{name}", "변경 영역의 설계 비용 검토")
    if tests:
        add(".agents/skills/test-value-check/SKILL.md", "테스트 변경의 검증 가치 검토")
        for name in _test_value_references(files):
            add(f".agents/skills/test-value-check/references/{name}", "변경된 테스트의 관련 검토 항목")
    if "docs/architecture/clean-architecture.md" in selected:
        add("docs/architecture/clean-architecture/examples.md", "아키텍처 적용 예시")
    if "docs/architecture/dependency-injection.md" in selected:
        add("docs/architecture/dependency-injection/examples.md", "의존성 주입 적용 예시")
    if "docs/system-design/view-state.md" in selected:
        add("docs/system-design/view-state/examples.md", "화면 상태 적용 예시")
    return list(selected.items())


def load_context(files, root):
    """Read only allowlisted references from the trusted checkout, with a hard budget."""
    root = Path(root).resolve()
    loaded = []
    remaining = MAX_CONTEXT_CHARS
    for path, reason in route_context(files):
        source = (root / path).resolve()
        if not source.is_relative_to(root) or not source.is_file():
            continue
        content = source.read_text(encoding="utf-8")
        if len(content) > remaining:
            continue
        loaded.append({
            "path": path,
            "reason": reason,
            "sha256": hashlib.sha256(content.encode()).hexdigest(),
            "chars": len(content),
            "content": content,
        })
        remaining -= len(content)
    return loaded
