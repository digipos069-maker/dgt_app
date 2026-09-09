import 'package:dgt_app/features/home/domain/models/quiz_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MatchingQuizData', () {
    test('parses matching quiz JSON correctly', () {
      final json = {
        'stems': [
          {'id': 's1', 'text': 'Term A'},
          {'id': 's2', 'text': 'Term B'},
        ],
        'options': [
          {'id': 'o1', 'text': 'Definition A'},
          {'id': 'o2', 'text': 'Definition B'},
        ],
        'description': 'Match terms with definitions',
        'correctMatches': {'s1': 'o1', 's2': 'o2'},
      };

      final data = MatchingQuizData.fromJson(json);

      expect(data.stems.length, 2);
      expect(data.stems.first.id, 's1');
      expect(data.stems.first.text, 'Term A');
      expect(data.options.length, 2);
      expect(data.options.first.id, 'o1');
      expect(data.options.first.text, 'Definition A');
      expect(data.description, 'Match terms with definitions');
      expect(data.correctMatches['s1'], 'o1');

      // Test correctness helpers
      expect(data.isMatchCorrect('s1', 'o1'), isTrue);
      expect(data.isMatchCorrect('s1', 'o2'), isFalse);

      expect(data.areAllMatchesCorrect({'s1': 'o1', 's2': 'o2'}), isTrue);
      expect(data.areAllMatchesCorrect({'s1': 'o1', 's2': 'o1'}), isFalse);
      expect(data.areAllMatchesCorrect({'s1': 'o1'}), isFalse);

      // Test toJson
      final serialized = data.toJson();
      expect(serialized['description'], 'Match terms with definitions');
      expect((serialized['stems'] as List).length, 2);
    });
  });

  group('DragAndDropQuizData', () {
    test('parses drag and drop quiz JSON correctly', () {
      final json = {
        'correct': '2H₂O',
        'draggables': ['2H₂O', 'H₂', 'O₂'],
        'droppableId': 'water-molecule',
        'prompt': 'Form water molecule',
      };

      final data = DragAndDropQuizData.fromJson(json);

      expect(data.correct, '2H₂O');
      expect(data.draggables, ['2H₂O', 'H₂', 'O₂']);
      expect(data.droppableId, 'water-molecule');
      expect(data.prompt, 'Form water molecule');

      // Test correctness helper
      expect(data.isCorrect('2H₂O'), isTrue);
      expect(data.isCorrect('H₂'), isFalse);

      // Test toJson
      final serialized = data.toJson();
      expect(serialized['correct'], '2H₂O');
      expect(serialized['droppableId'], 'water-molecule');
    });
  });

  group('QuizQuestionModel polymorphic factories and JSON', () {
    test('creates multiple choice question', () {
      const q = QuizQuestionModel.multipleChoice(
        id: 'q1',
        questionKey: 'Solve 2+2',
        options: [
          QuizOptionModel(id: 'A', labelKey: '4'),
          QuizOptionModel(id: 'B', labelKey: '5'),
        ],
      );

      expect(q.type, QuizType.multipleChoice);
      expect(q.options.length, 2);
    });

    test('creates matching question from JSON', () {
      final json = {
        'id': 'm1',
        'type': 'matching',
        'stems': [
          {'id': 's1', 'text': 'A'},
        ],
        'options': [
          {'id': 'o1', 'text': 'B'},
        ],
        'description': 'Match',
        'correctMatches': {'s1': 'o1'},
      };

      final q = QuizQuestionModel.fromJson(json);

      expect(q.type, QuizType.matching);
      expect(q.matchingData, isNotNull);
      expect(q.matchingData!.stems.first.text, 'A');
    });

    test('creates drag and drop question from JSON', () {
      final json = {
        'id': 'd1',
        'type': 'drag_and_drop',
        'correct': '2H₂O',
        'draggables': ['2H₂O', 'H₂'],
        'droppableId': 'target',
      };

      final q = QuizQuestionModel.fromJson(json);

      expect(q.type, QuizType.dragAndDrop);
      expect(q.dragAndDropData, isNotNull);
      expect(q.dragAndDropData!.correct, '2H₂O');
    });

    test('creates matching question from nested quizData', () {
      final json = {
        'id': 10,
        'question': 'Match chemistry items',
        'quizData': {
          'stems': [
            {'id': 's1', 'text': 'H₂'},
            {'id': 's2', 'text': 'O₂'},
          ],
          'options': [
            {'id': 'o1', 'text': 'Hydrogen gas'},
            {'id': 'o2', 'text': 'Oxygen gas'},
          ],
          'description': 'Match gases',
          'correctMatches': {'s1': 'o1', 's2': 'o2'},
        },
      };

      final q = QuizQuestionModel.fromJson(json);

      expect(q.type, QuizType.matching);
      expect(q.quizId, 10);
      expect(q.matchingData, isNotNull);
      expect(q.matchingData!.stems.length, 2);
      expect(q.matchingData!.correctMatches['s1'], 'o1');
    });

    test('creates drag and drop question from nested quizData', () {
      final json = {
        'id': 11,
        'quizData': {
          'correct': '2H₂O',
          'draggables': ['2H₂O', 'H₂', 'O₂'],
          'droppableId': 'water-molecule',
        },
      };

      final q = QuizQuestionModel.fromJson(json);

      expect(q.type, QuizType.dragAndDrop);
      expect(q.quizId, 11);
      expect(q.dragAndDropData, isNotNull);
      expect(q.dragAndDropData!.correct, '2H₂O');
      expect(q.dragAndDropData!.droppableId, 'water-molecule');
    });
  });
}
