import 'package:serverpod/database.dart';
import 'package:serverpod_test_server/src/generated/protocol.dart';
import 'package:serverpod_test_server/test_util/test_serverpod.dart';
import 'package:test/test.dart';

void main() async {
  var session = await IntegrationTestServer().session();

  group('Given entities with many to many relation', () {
    tearDown(() async {
      await Enrollment.db
          .deleteWhere(session, where: (_) => Constant.bool(true));
      await Student.db.deleteWhere(session, where: (_) => Constant.bool(true));
      await Course.db.deleteWhere(session, where: (_) => Constant.bool(true));
    });

    test(
        'when deleting entities filtered by none many relation then result is as expected',
        () async {
      var students = await Student.db.insert(session, [
        Student(name: 'Alex'),
        Student(name: 'Isak'),
        Student(name: 'Lisa'),
      ]);
      var courses = await Course.db.insert(session, [
        Course(name: 'Math'),
        Course(name: 'English'),
      ]);
      await Enrollment.db.insert(session, [
        // Alex is enrolled in Math and English
        Enrollment(studentId: students[0].id!, courseId: courses[0].id!),
        Enrollment(studentId: students[0].id!, courseId: courses[1].id!),
        // Isak is enrolled in English
        Enrollment(studentId: students[1].id!, courseId: courses[1].id!),
      ]);

      var deletedStudentIds = await Student.db.deleteWhere(
        session,
        // All students enrolled no courses.
        where: (s) => s.enrollments.none(),
      );

      expect(deletedStudentIds, [
        students[2].id, // Lisa
      ]);
    });

    test(
        'when deleting entities filtered by filtered none many relation then result is as expected',
        () async {
      var students = await Student.db.insert(session, [
        Student(name: 'Alex'),
        Student(name: 'Viktor'),
        Student(name: 'Isak'),
        Student(name: 'Lisa'),
      ]);
      var courses = await Course.db.insert(session, [
        Course(name: 'Level 1: Math'),
        Course(name: 'Level 1: English'),
        Course(name: 'Level 1: History'),
        Course(name: 'Level 2: Math'),
        Course(name: 'Level 2: English'),
        Course(name: 'Level 2: History'),
      ]);
      await Enrollment.db.insert(session, [
        // Alex is enrolled in Level 1 Math and Level 1 English
        Enrollment(studentId: students[0].id!, courseId: courses[0].id!),
        Enrollment(studentId: students[0].id!, courseId: courses[1].id!),
        // Isak is enrolled in Level 1 English and Level 2 Math
        Enrollment(studentId: students[2].id!, courseId: courses[1].id!),
        Enrollment(studentId: students[2].id!, courseId: courses[3].id!),
        // Lisa is enrolled in Level 2 English and Level 2 History
        Enrollment(studentId: students[3].id!, courseId: courses[4].id!),
        Enrollment(studentId: students[3].id!, courseId: courses[5].id!),
      ]);

      var deletedStudentIds = await Student.db.deleteWhere(
        session,
        // All students not enrolled to no math courses.
        where: (s) => s.enrollments.none((e) => e.course.name.ilike('%math%')),
      );

      expect(deletedStudentIds, hasLength(2));
      expect(
          deletedStudentIds,
          containsAll([
            students[1].id, // Viktor
            students[3].id, // Lisa
          ]));
    });

    test(
        'when deleting entities filtered by none many relation in combination with other filter then result is as expected',
        () async {
      var students = await Student.db.insert(session, [
        Student(name: 'Alex'),
        Student(name: 'Isak'),
        Student(name: 'Lisa'),
      ]);
      var courses = await Course.db.insert(session, [
        Course(name: 'Math'),
        Course(name: 'English'),
      ]);
      await Enrollment.db.insert(session, [
        // Alex is enrolled in Math and English
        Enrollment(studentId: students[0].id!, courseId: courses[0].id!),
        Enrollment(studentId: students[0].id!, courseId: courses[1].id!),
        // Isak is enrolled in English
        Enrollment(studentId: students[1].id!, courseId: courses[1].id!),
      ]);

      var deletedStudentIds = await Student.db.deleteWhere(
        session,
        // All students enrolled to no course or is named Alex.
        where: (s) => (s.enrollments.none()) | s.name.equals('Alex'),
      );

      expect(deletedStudentIds, hasLength(2));
      expect(
          deletedStudentIds,
          containsAll([
            students[0].id, // Alex
            students[2].id, // Lisa
          ]));
    });

    test(
        'when deleting entities filtered by multiple filtered none many relation then result is as expected',
        () async {
      var students = await Student.db.insert(session, [
        Student(name: 'Alex'),
        Student(name: 'Viktor'),
        Student(name: 'Isak'),
        Student(name: 'Lisa'),
      ]);
      var courses = await Course.db.insert(session, [
        Course(name: 'Level 1: Math'),
        Course(name: 'Level 1: English'),
        Course(name: 'Level 1: History'),
        Course(name: 'Level 2: Math'),
        Course(name: 'Level 2: English'),
        Course(name: 'Level 2: History'),
      ]);
      await Enrollment.db.insert(session, [
        // Alex is enrolled in Level 1 Math and Level 1 English
        Enrollment(studentId: students[0].id!, courseId: courses[0].id!),
        Enrollment(studentId: students[0].id!, courseId: courses[1].id!),
        // Isak is enrolled in Level 1 English
        Enrollment(studentId: students[2].id!, courseId: courses[1].id!),
        // Lisa is enrolled in Level 2 English and Level 2 History
        Enrollment(studentId: students[3].id!, courseId: courses[4].id!),
        Enrollment(studentId: students[3].id!, courseId: courses[5].id!),
      ]);

      var deletedStudentIds = await Student.db.deleteWhere(
        session,
        // Fetch all students enrolled to no level 2 course and no math course.
        where: (s) =>
            (s.enrollments.none((e) => e.course.name.ilike('level 2:%'))) &
            (s.enrollments.none((e) => e.course.name.ilike('%math%'))),
      );

      expect(deletedStudentIds, hasLength(2));
      expect(
          deletedStudentIds,
          containsAll([
            students[1].id, // Viktor
            students[2].id, // Isak
          ]));
    });
  });
}
