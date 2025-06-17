import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:budget/features/user/data/firebase_user_repository.dart';
import 'package:budget/features/user/domain/user_model.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUser extends Mock implements User {}

class MockUserMetadata extends Mock implements UserMetadata {}

class MockUserCredential extends Mock implements UserCredential {}

void main() {
  group('FirebaseUserRepository', () {
    late MockFirebaseAuth mockAuth;
    late FirebaseUserRepository repository;
    late MockUser mockUser;
    late MockUserMetadata mockMetadata;

    setUp(() {
      mockAuth = MockFirebaseAuth();
      mockUser = MockUser();
      mockMetadata = MockUserMetadata();
      repository = FirebaseUserRepository(auth: mockAuth);

      // Setup common mock responses
      when(() => mockUser.uid).thenReturn('test-uid');
      when(() => mockUser.isAnonymous).thenReturn(true);
      when(() => mockUser.metadata).thenReturn(mockMetadata);
      when(() => mockMetadata.creationTime).thenReturn(DateTime(2024, 1, 1));
    });

    group('getCurrentUser', () {
      test('returns null when no user is signed in', () async {
        // Arrange
        when(() => mockAuth.currentUser).thenReturn(null);

        // Act
        final result = await repository.getCurrentUser();

        // Assert
        expect(result, null);
        verify(() => mockAuth.currentUser).called(1);
      });

      test('returns UserModel when user is signed in', () async {
        // Arrange
        when(() => mockAuth.currentUser).thenReturn(mockUser);

        // Act
        final result = await repository.getCurrentUser();

        // Assert
        expect(result, isA<UserModel>());
        expect(result?.id, 'test-uid');
        expect(result?.isAnonymous, true);
        expect(result?.createdAt, DateTime(2024, 1, 1));
        verify(() => mockAuth.currentUser).called(1);
      });
    });

    group('createAnonymousUser', () {
      late MockUserCredential mockUserCredential;

      setUp(() {
        mockUserCredential = MockUserCredential();
        when(() => mockUserCredential.user).thenReturn(mockUser);
      });

      test('creates anonymous user successfully', () async {
        // Arrange
        when(
          () => mockAuth.signInAnonymously(),
        ).thenAnswer((_) async => mockUserCredential);

        // Act
        final result = await repository.createAnonymousUser();

        // Assert
        expect(result, isA<UserModel>());
        expect(result.id, 'test-uid');
        expect(result.isAnonymous, true);
        expect(result.createdAt, DateTime(2024, 1, 1));
        verify(() => mockAuth.signInAnonymously()).called(1);
      });

      test('throws exception when user creation fails', () async {
        // Arrange
        when(
          () => mockAuth.signInAnonymously(),
        ).thenThrow(FirebaseAuthException(code: 'auth/operation-failed'));

        // Act & Assert
        expect(
          () => repository.createAnonymousUser(),
          throwsA(isA<Exception>()),
        );
        verify(() => mockAuth.signInAnonymously()).called(1);
      });

      test('throws exception when user credential is null', () async {
        // Arrange
        when(() => mockUserCredential.user).thenReturn(null);
        when(
          () => mockAuth.signInAnonymously(),
        ).thenAnswer((_) async => mockUserCredential);

        // Act & Assert
        expect(
          () => repository.createAnonymousUser(),
          throwsA(isA<Exception>()),
        );
        verify(() => mockAuth.signInAnonymously()).called(1);
      });
    });
  });
}
