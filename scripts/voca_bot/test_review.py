import unittest

from review import REVIEW_SCHEMA, build_review_request, changed_lines, prepare_files, validate_comments


PATCH = """@@ -3,3 +3,4 @@
 context
-removed
+added
 context
+another
@@ -20,1 +21,1 @@
-old
+new
"""


class ReviewTests(unittest.TestCase):
    def test_changed_lines_track_both_sides_and_multiple_hunks(self):
        self.assertEqual(
            changed_lines(PATCH),
            {("LEFT", 4), ("LEFT", 20), ("RIGHT", 4), ("RIGHT", 6), ("RIGHT", 21)},
        )

    def test_invalid_or_duplicate_inline_locations_are_rejected(self):
        _, valid, incomplete = prepare_files(
            [{"filename": "example.swift", "status": "modified", "patch": PATCH}]
        )
        self.assertFalse(incomplete)
        comments = [
            {"path": "example.swift", "line": 4, "side": "RIGHT", "priority": "P1", "body": "Fix this"},
            {"path": "example.swift", "line": 4, "side": "RIGHT", "priority": "P2", "body": "Duplicate"},
            {"path": "example.swift", "line": 4, "side": "LEFT", "priority": "P3", "body": "Old line"},
            {"path": "example.swift", "line": 5, "side": "RIGHT", "priority": "P2", "body": "Context"},
            {"path": "other.swift", "line": 4, "side": "RIGHT", "priority": "P2", "body": "Wrong file"},
            {"path": "example.swift", "line": 6, "side": "RIGHT", "body": "No priority"},
        ]
        accepted = validate_comments(comments, valid)
        self.assertEqual(len(accepted), 2)
        self.assertEqual([item["side"] for item in accepted], ["RIGHT", "LEFT"])
        self.assertEqual([item["body"] for item in accepted], ["[P1] Fix this", "[P3] Old line"])

    def test_response_schema_requires_priority_and_prompt_defines_levels(self):
        item = REVIEW_SCHEMA["properties"]["comments"]["items"]
        self.assertIn("priority", item["required"])
        self.assertEqual(item["properties"]["priority"]["enum"], ["P1", "P2", "P3"])
        request = build_review_request({"title": "Change", "body": ""}, [], False, "gpt-6.1-sol")
        for priority in ("P1", "P2", "P3"):
            self.assertIn(priority, request["instructions"])


if __name__ == "__main__":
    unittest.main()
