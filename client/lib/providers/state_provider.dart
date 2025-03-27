import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

// User Model
class UserInfoFam {
  final String id;
  final String name;
  final String email;
  final String? phone; // Make phone optional

  UserInfoFam({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
  });

  factory UserInfoFam.fromMap(Map<String, dynamic> map) {
    return UserInfoFam(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      phone: map['phone'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
    };
  }

  @override
  String toString() => 'UserInfoFam(id: $id, name: $name, email: $email, phone: $phone)';
}

// App States
abstract class AppState {
  const AppState();
}

class AppInitial extends AppState {}

class AppLoading extends AppState {}

class AppAuthenticated extends AppState {
  final UserInfoFam user;

  const AppAuthenticated(this.user);
}

class AppUnauthenticated extends AppState {}

class AppError extends AppState {
  final String message;

  const AppError(this.message);
}

// Cubit
class AppCubit extends Cubit<AppState> {
  AppCubit() : super(AppInitial()) {
    _loadUser();
  }

  static const String _userKey = 'current_user';
  static const String _isNewUserKey = 'is_new_user';

  Future<void> _loadUser() async {
    emit(AppLoading());
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_userKey);
      final isNewUser = prefs.getBool(_isNewUserKey) ?? true;

      if (userJson != null) {
        final userMap = jsonDecode(userJson) as Map<String, dynamic>;
        final user = UserInfoFam.fromMap(userMap);
        emit(AppAuthenticated(user));
      } else {
        emit(AppUnauthenticated());
      }
    } catch (e) {
      emit(AppError('Failed to load user: ${e.toString()}'));
    }
  }

  Future<void> saveUser(UserInfoFam user) async {
    emit(AppLoading());
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userKey, jsonEncode(user.toMap()));
      emit(AppAuthenticated(user));
    } catch (e) {
      emit(AppError('Failed to save user: ${e.toString()}'));
      rethrow;
    }
  }

  Future<void> updateUser(UserInfoFam updatedUser) async {
    if (state is! AppAuthenticated) {
      emit(AppError('No user to update'));
      return;
    }

    emit(AppLoading());
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userKey, jsonEncode(updatedUser.toMap()));
      emit(AppAuthenticated(updatedUser));
    } catch (e) {
      emit(AppError('Failed to update user: ${e.toString()}'));
      rethrow;
    }
  }

  Future<void> removeUser() async {
    emit(AppLoading());
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userKey);
      emit(AppUnauthenticated());
    } catch (e) {
      emit(AppError('Failed to remove user: ${e.toString()}'));
      rethrow;
    }
  }

  Future<void> markUserAsNotNew() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isNewUserKey, false);
  }

  Future<bool> isNewUser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isNewUserKey) ?? true;
  }

  UserInfoFam? getCurrentUser() {
    if (state is AppAuthenticated) {
      return (state as AppAuthenticated).user;
    }
    return null;
  }
}