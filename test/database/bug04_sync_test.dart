// Regression tests for BUG-04:
//   1) Destructive deletion while server data is loaded page by page.
//   2) The orphan DELETE in `syncUserQsOnLocalDB` not being scoped by
//      `azbazi_id`, so syncing one game could delete another game's questions.
//
// WHY THE LOGIC IS UNIT TESTED THROUGH `orphanedQuestionIds`:
// `azbazisQueries.syncUserQsOnLocalDB` cannot be exercised against a real
// SQLite database in this test environment: `sqflite` requires the platform
// channel and reports `databaseFactory not initialized` under `flutter test`
// (probe executed on Windows host), and `sqflite_common_ffi` is NOT a
// dependency of this project - adding it would violate the BUG-04 scope.
// `QuestionProvider.getQuestionsData` cannot be exercised either: it builds a
// `Dio` instance inline (no injection seam) and calls the real DB helper.
//
// The orphan-selection logic is therefore centralized in the pure, side-effect
// free `azbazisQueries.orphanedQuestionIds`, which mirrors the SQL `DELETE`
// WHERE clause, and `syncUserQsOnLocalDB` deletes exactly the ids it returns.
// The pagination invariant itself (accumulate all pages, then sync once) lives
// in `QuestionProvider.getQuestionsData` and is verified by code inspection.

import 'package:ebarge/database/azbaziQueries.dart';
import 'package:ebarge/models/questionModel.dart';
import 'package:flutter_test/flutter_test.dart';

questionModel _q(String azbaziId, String id,
        {String modified = '2020-01-01 00:00:00'}) =>
    questionModel(
      azbazi_id: azbaziId,
      question_id: id,
      modified_date: modified,
    );

void main() {
  group('BUG-04 orphan detection - whitelist semantics', () {
    test('Case F: genuinely stale question after a complete sync', () {
      final online = [_q('1', 'Q1'), _q('1', 'Q3')];
      final local = [_q('1', 'Q1'), _q('1', 'Q2'), _q('1', 'Q3')];
      expect(
        azbazisQueries.orphanedQuestionIds(
            onlineAzbaziQs: online,
            oldLocalAzbaziQs: local,
            azbaziId: '1'),
        ['Q2'],
      );
    });

    test('Case C: final page is empty -> nothing is orphaned', () {
      final online = [_q('1', 'Q1'), _q('1', 'Q2')];
      final local = [_q('1', 'Q1'), _q('1', 'Q2')];
      expect(
        azbazisQueries.orphanedQuestionIds(
            onlineAzbaziQs: online,
            oldLocalAzbaziQs: local,
            azbaziId: '1'),
        isEmpty,
      );
    });

    test('Case D: server authoritatively empty -> removal allowed per game',
        () {
      // A fully retrieved (empty) server dataset legitimately orphans the
      // local rows of THAT game only. `syncUserQsOnLocalDB` additionally
      // guards on `onlineIds.isNotEmpty`, so in practice an empty response
      // performs no deletion at all.
      final local = [_q('1', 'Q1'), _q('1', 'Q2'), _q('9', 'QX')];
      final orphans = azbazisQueries.orphanedQuestionIds(
        onlineAzbaziQs: const [],
        oldLocalAzbaziQs: local,
        azbaziId: '1',
      );
      expect(orphans, ['Q1', 'Q2']);
      expect(orphans, isNot(contains('QX')));
    });

    test('orphan detection is pure and order independent', () {
      final online = [_q('1', 'Q2'), _q('1', 'Q1')];
      final local = [_q('1', 'Q3'), _q('1', 'Q1'), _q('1', 'Q2')];
      expect(
        azbazisQueries.orphanedQuestionIds(
            onlineAzbaziQs: online,
            oldLocalAzbaziQs: local,
            azbaziId: '1'),
        ['Q3'],
      );
    });

    test('duplicates on either side collapse to a single orphan id', () {
      final online = [_q('1', 'Q1'), _q('1', 'Q1')];
      final local = [_q('1', 'Q2'), _q('1', 'Q2')];
      expect(
        azbazisQueries.orphanedQuestionIds(
            onlineAzbaziQs: online,
            oldLocalAzbaziQs: local,
            azbaziId: '1'),
        ['Q2'],
      );
    });

    test('questions with an empty question_id are never deleted', () {
      final local = [_q('1', ''), _q('1', 'Q1')];
      expect(
        azbazisQueries.orphanedQuestionIds(
            onlineAzbaziQs: const [],
            oldLocalAzbaziQs: local,
            azbaziId: '1'),
        ['Q1'],
      );
    });
  });

  group('BUG-04 cross-game scoping (azbazi_id)', () {
    test('Case E: syncing game A never orphans game B questions', () {
      // Local DB holds two games.
      final local = [
        _q('A', 'A1'), _q('A', 'A2'), _q('A', 'A3'),
        _q('B', 'B1'), _q('B', 'B2'), _q('B', 'B3'),
      ];
      // Game A is synchronized and A2 is genuinely gone on the server.
      final orphans = azbazisQueries.orphanedQuestionIds(
        onlineAzbaziQs: [_q('A', 'A1'), _q('A', 'A3')],
        oldLocalAzbaziQs: local,
        azbaziId: 'A',
      );
      expect(orphans, ['A2']);
      expect(orphans, isNot(containsAll(['B1', 'B2', 'B3'])),
          reason: 'Game B questions must be untouched by a game A sync');
    });

    test('an unsynced game with zero server rows keeps all its questions', () {
      final local = [_q('B', 'B1'), _q('B', 'B2')];
      expect(
        azbazisQueries.orphanedQuestionIds(
            onlineAzbaziQs: const [], oldLocalAzbaziQs: local, azbaziId: 'A'),
        isEmpty,
      );
    });
  });

  group('BUG-04 pagination invariant (documentation)', () {
    // The accumulation contract implemented by
    // `QuestionProvider.getQuestionsData`: `_onlineQuestions` is accumulated
    // across every page and `syncUserQsOnLocalDB` is invoked exactly ONCE,
    // after the loop exits. Reproducing the pre-fix behaviour (syncing after
    // page 1 only) is what destroyed local data:
    final local = [
      _q('1', 'Q1'), _q('1', 'Q2'), _q('1', 'Q3'),
      _q('1', 'Q4'), _q('1', 'Q5'), _q('1', 'Q6'),
    ];

    test('complete dataset (all pages) -> only real orphans are reported', () {
      // Both pages accumulated: Q1-Q3 online, Q4-Q6 genuinely gone.
      final complete = <questionModel>[
        _q('1', 'Q1'), _q('1', 'Q2'), _q('1', 'Q3'),
      ];
      expect(
        azbazisQueries.orphanedQuestionIds(
            onlineAzbaziQs: complete,
            oldLocalAzbaziQs: local,
            azbaziId: '1'),
        containsAll(['Q4', 'Q5', 'Q6']),
      );
    });

    test('partial dataset (only page 1) would orphan live page-2 questions',
        () {
      // Pre-fix, this intermediate set was handed to syncUserQsOnLocalDB on
      // every page iteration and deleted Q4-Q6 even though page 2 still had
      // to arrive. After the fix the provider accumulates first, so this set
      // is never passed to the sync until the loop is done.
      final partial = <questionModel>[
        _q('1', 'Q1'), _q('1', 'Q2'), _q('1', 'Q3'),
      ];
      expect(
        azbazisQueries.orphanedQuestionIds(
            onlineAzbaziQs: partial,
            oldLocalAzbaziQs: local,
            azbaziId: '1'),
        containsAll(['Q4', 'Q5', 'Q6']),
        reason: 'Confirms why a partial page must never be synced against.',
      );
    });
  });
}
