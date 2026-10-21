import unittest

from review import changed_lines, prepare_files, validate_comments


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
            {"path": "example.swift", "line": 4, "side": "RIGHT", "body": "Fix this"},
            {"path": "example.swift", "line": 4, "side": "RIGHT", "body": "Duplicate"},
            {"path": "example.swift", "line": 4, "side": "LEFT", "body": "Old line"},
            {"path": "example.swift", "line": 5, "side": "RIGHT", "body": "Context"},
            {"path": "other.swift", "line": 4, "side": "RIGHT", "body": "Wrong file"},
        ]
        accepted = validate_comments(comments, valid)
        self.assertEqual(len(accepted), 2)
        self.assertEqual([item["side"] for item in accepted], ["RIGHT", "LEFT"])


if __name__ == "__main__":
    unittest.main()
