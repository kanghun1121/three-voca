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


def clean_architecture_sections(files):
    """Select existing architecture headings from changed code, not PR prose."""
    paths = "\n".join(file["filename"] for file in files if not _is_test(file["filename"]))
    changed = paths + "\n" + _added_text(files) + "\n" + _removed_text(files)
    main = []
    examples = []
    if re.search(r"Project\.swift|/Interface/|\bimport\s+(?:Data|Domain|Networking|Feature)\b", changed):
        main.append("레이어 구조와 의존 방향")
    if re.search(r"Repository|DataSource", changed):
        main.append("Repository와 DataSource")
    if re.search(r"UseCase", changed):
        main.append("UseCase")
    if re.search(r"DTO|Entity|Mapping|/Models?/|DomainModel|PresentationModel|toDomain", changed):
        main.append("데이터 모델: DTO → Domain Model")

    if any(file.get("status") == "added" and "DataSource" in file["filename"] for file in files) or re.search(
        r"(?:remote|local)DataSource.*\.toDomain\(\)", _added_text(files), re.S
    ):
        examples.append("DataSource는 Data 내부에서 사용한다")
    if any(file.get("status") == "added" and "UseCase" in file["filename"] for file in files) or re.search(
        r"\b(?:struct|class|actor)\s+\w*UseCase\b", _added_text(files)
    ):
        examples.append("단순 조회에는 UseCase를 추가하지 않는다")
    if re.search(r"DTO|Entity|Mapping|toDomain", changed):
        examples.append("외부 모델은 도메인 경계에서 변환한다")
    if re.search(r"PresentationModel|groupedDefinitions|primaryMeaning", changed):
        examples.append("도메인 의미와 화면 표현을 구분한다")
    return main, examples


def _markdown_sections(content, headings):
    """Preserve the document preface and selected ##/### sections in source order."""
    lines = content.splitlines(keepends=True)
    starts = [(index, len(match.group(1)), match.group(2).strip())
              for index, line in enumerate(lines)
              if (match := re.match(r"^(#{2,3})\s+(.+?)\s*$", line))]
    if not starts:
        return content
    selected = set(headings)
    if not selected.issubset({title for _, _, title in starts}):
        return content
    pieces = ["".join(lines[:starts[0][0]])]
    for position, (start, level, title) in enumerate(starts):
        if title not in selected:
            continue
        end = next((index for index, next_level, _ in starts[position + 1:]
                    if next_level <= level), len(lines))
        pieces.append("".join(lines[start:end]))
    return "".join(pieces)


def other_document_sections(files):
    """Choose relevant headings from the remaining reviewer reference documents."""
    paths = "\n".join(file["filename"] for file in files if not _is_test(file["filename"]))
    added = _added_text(files)
    changed = paths + "\n" + added + "\n" + _removed_text(files)
    sections = {}

    di_examples = []
    if re.search(r"@DependencyClient|DependencyKey|liveValue|UnimplementedTestDependencyKey", changed):
        di_examples.append("값 타입 계약과 liveValue")
    if re.search(r"withDependencies|happyPath|emptyPath|previewFixture|Mock|Stub", changed, re.I):
        di_examples.append("사례 데이터는 사용하는 곳에 둔다")
    if di_examples:
        sections["docs/architecture/dependency-injection/examples.md"] = di_examples

    di = []
    if re.search(r"@Dependency\b|@DependencyClient|DependencyValues|Repository|UseCase", changed):
        di.append("값 타입 계약과 객체 간 의존")
    if re.search(r"@DependencyClient|DependencyKey|liveValue|UnimplementedTestDependencyKey", changed):
        di.append("구현 등록과 테스트 키")
    if re.search(r"withDependencies|happyPath|emptyPath|previewFixture|Mock|Stub", changed, re.I):
        di.append("사례 데이터와 조립 위치")
    if di:
        sections["docs/architecture/dependency-injection.md"] = di

    module = ["공통 Interface 분리 원칙"]
    if re.search(r"Projects/Domain/|DomainInterface", changed):
        module.extend(("Domain의 Interface 분리 이유", "Domain 타겟 구성"))
    if re.search(r"Projects/Networking/|NetworkingInterface", changed):
        module.extend(("Networking의 Interface 분리 이유", "Networking 타겟 구성"))
    if re.search(r"Projects/Feature/.*(?:Project\.swift|/Interface/)", paths):
        module.extend(("Feature 모듈 타겟 구성", "Feature 모듈 경계 규칙"))
    sections["docs/architecture/modulization.md"] = module

    if re.search(r"@State|StateMachine|ViewState|UIState|isLoading|Store", changed):
        state = ["모든 상태를 한곳에 모으면 생기는 문제", "상태의 소유 범위를 정하는 질문"]
    else:
        state = ["상태의 수명과 원본", "상태의 소유 범위를 정하는 질문"]
    if "상태의 수명과 원본" not in state and re.search(r"persist|restore|session|disk|SwiftData|UserDefaults|Keychain", changed, re.I):
        state.insert(0, "상태의 수명과 원본")
    sections["docs/system-design/state-management.md"] = state

    ssot = ["기준이 되는 데이터 정하기", "여러 화면에서 공유하기", "변경을 한 방향으로 흐르게 하기"]
    if re.search(r"optimistic|like|favorite|좋아요", changed, re.I):
        ssot.append("서버 상태를 먼저 표시할 때")
    sections["docs/system-design/ssot.md"] = ssot

    view_state = ["빈 결과와 새로고침 상태 정하기", "MVVM에서의 역할"]
    if re.search(r"isLoading|isError|error\s*[:=]|StateMachine|ViewState|UIState", changed, re.I):
        view_state.insert(0, "배타적인 화면 단계 표현하기")
    if re.search(r"sheet|selected|selection|TextField|@Binding|@State\b", changed, re.I):
        view_state.append("독립적인 UI 상태 분리하기")
    sections["docs/system-design/view-state.md"] = view_state
    if re.search(r"isLoading|isError|error\s*[:=]", changed, re.I):
        sections["docs/system-design/view-state/examples.md"] = [
            "Bad Case: 하나의 화면 단계를 독립 값으로 표현",
            "Good Case: 서로 배타적인 화면 단계",
        ]
    elif re.search(r"ViewState|UIState|StateMachine|\bcase\s+loading\b", changed):
        sections["docs/system-design/view-state/examples.md"] = [
            "Good Case: 서로 배타적인 화면 단계",
        ]

    cache = ["정책을 정할 때 확인할 것"]
    if re.search(r"\b(cache|cached|TTL|fresh|fetchedAt|expiry|expiration)\b", changed, re.I) or re.search(r"Cache\.swift\b", paths):
        cache.insert(0, "시간에 따른 만료")
    if re.search(r"invalidate|delete|logout|remove|evict", changed, re.I):
        cache.insert(0, "사건에 따른 무효화")
    if re.search(r"fetch|refresh|sync|revalidat|APNs|push", changed, re.I):
        cache.insert(0, "원본의 변경을 확인하기")
    if re.search(r"stale|usable|offline|isRefreshing", changed, re.I):
        cache.insert(0, "오래된 값의 표시 범위")
    if re.search(r"ETag|If-None-Match|304\b", changed, re.I):
        cache.append("조건부 재검증")
    if re.search(r"jitter|동시 만료|stampede", changed, re.I):
        cache.append("동시 만료와 요청 집중")
    sections["docs/system-design/cache-control.md"] = cache

    failure = ["요청이 끊길 수 있는 지점", "재시도 가능한 요청 구분하기", "설계할 때 확인할 것"]
    if re.search(r"retry|backoff|jitter|Retry-After|attempt", changed, re.I):
        failure.append("재시도 간격과 전체 횟수 정하기")
    if re.search(r"idempoten|requestID|purchase|payment|order|POST\b|upload|submit", changed, re.I):
        failure.append("중복 실행을 막는 작업 식별")
    if re.search(r"button|isSubmitting|isLoading|tap|submit", changed, re.I):
        failure.append("사용자 중복 조작 다루기")
    if re.search(r"draft|offline|pending|local.?save|입력|초안", changed, re.I):
        failure.append("모바일에서 입력을 보존하기")
    if re.search(r"ViewModel|ViewState|UIState|isLoading|error", paths, re.I):
        failure.append("화면에서 결과를 표현하기")
    sections["docs/system-design/server-failure.md"] = failure

    lint = []
    lint_examples = []
    if re.search(r"\b(?:struct|class|enum|protocol)\s+[a-z]\w*\b|\bfunc\s+[A-Z]\w*\b", added):
        lint.append("1. 네이밍")
        lint_examples.append("네이밍")
    if any(
        len(imports) != len(set(imports))
        for file in files
        for imports in [re.findall(r"^import\s+(\w+)", _added_text([file]), re.M)]
    ):
        lint.append("2.4 Import 정렬")
        lint_examples.append("Import 정렬")
    if re.search(r"\b(?:func\s+\w+|init)\([^\n)]*,[^\n)]*,[^\n)]*\)", added):
        lint.append("2.3 파라미터 줄바꿈")
        lint_examples.append("파라미터 줄바꿈")
    if "\t" in added:
        lint.append("2.1 들여쓰기")
    if re.search(r"\.map\(\{|\.filter\(\{", added):
        lint.append("3. 클로저")
        lint_examples.append("클로저")
    if "[weak self]" in added:
        lint.append("4. Task와 소유 관계")
        lint_examples.append("Task에서 self 캡처")
    if lint:
        sections["docs/lint.md"] = lint
    if lint_examples:
        sections["docs/lint/examples.md"] = lint_examples
    return sections


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
    clean_main, clean_examples = clean_architecture_sections(files)
    document_sections = other_document_sections(files)
    selected = {}

    def add(path, reason):
        selected.setdefault(path, reason)

    add("docs/review-policy.md", "리뷰 우선순위와 코멘트 기준")

    if clean_main and any("Projects/Domain/" in p or "Projects/Data/" in p for p in source):
        add("docs/architecture/clean-architecture.md", "Domain/Data 경계 변경")
    if any("Projects/Feature/" in p for p in source) and re.search(
        r"Repository|UseCase|DataSource|DomainModel|DTO|Entity", added
    ):
        add("docs/architecture/clean-architecture.md", "Feature의 데이터 경계 변경")
    if any("Projects/" in p for p in source) and re.search(
        r"@Dependency|DependencyKey|liveValue|UnimplementedTestDependencyKey|withDependencies|happyPath|emptyPath", added
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
        re.search(r"\b(cache|cached|TTL|etag|invalidate\w*|fetchedAt)\b", added, re.I)
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
    if "docs/architecture/clean-architecture.md" in selected and clean_examples:
        add("docs/architecture/clean-architecture/examples.md", "아키텍처 적용 예시")
    if "docs/architecture/dependency-injection.md" in selected and "docs/architecture/dependency-injection/examples.md" in document_sections:
        add("docs/architecture/dependency-injection/examples.md", "의존성 주입 적용 예시")
    if "docs/system-design/view-state.md" in selected and "docs/system-design/view-state/examples.md" in document_sections:
        add("docs/system-design/view-state/examples.md", "화면 상태 적용 예시")
    if code and "docs/lint.md" in document_sections:
        add("docs/lint.md", "변경된 Swift 작성 규칙")
        if "docs/lint/examples.md" in document_sections:
            add("docs/lint/examples.md", "변경된 Swift 작성 예시")
    return list(selected.items())


def load_context(files, root):
    """Read only allowlisted references from the trusted checkout, with a hard budget."""
    root = Path(root).resolve()
    loaded = []
    remaining = MAX_CONTEXT_CHARS
    clean_main, clean_examples = clean_architecture_sections(files)
    document_sections = other_document_sections(files)
    for path, reason in route_context(files):
        source = (root / path).resolve()
        if not source.is_relative_to(root) or not source.is_file():
            continue
        full_content = source.read_text(encoding="utf-8")
        content = full_content
        sections = None
        if path == "docs/architecture/clean-architecture.md":
            sections = clean_main
        elif path == "docs/architecture/clean-architecture/examples.md":
            sections = clean_examples
        elif path in document_sections:
            sections = document_sections[path]
        if sections is not None:
            content = _markdown_sections(content, sections)
            if content == full_content:
                sections = ["full"]
        if len(content) > remaining:
            continue
        item = {
            "path": path,
            "reason": reason,
            "sha256": hashlib.sha256(content.encode()).hexdigest(),
            "chars": len(content),
            "content": content,
        }
        if sections is not None:
            item["sections"] = sections
        loaded.append(item)
        remaining -= len(content)
    return loaded
