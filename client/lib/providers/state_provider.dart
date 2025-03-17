import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

// User Model
class UserInfo_Fam {
  final String id;
  final String name;
  final String email;

  UserInfo_Fam({required this.id, required this.name, required this.email});

  factory UserInfo_Fam.fromMap(Map<String, dynamic> map) {
    return UserInfo_Fam(
      id: map['id'],
      name: map['name'],
      email: map['email'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
    };
  }
}

// Events
abstract class AppEvent {}

class AddUser extends AppEvent {
  final UserInfo_Fam user;
  AddUser(this.user);
}

class UpdateUser extends AppEvent {
  final UserInfo_Fam user;
  UpdateUser(this.user);
}

class RemoveUser extends AppEvent {
  final String userId;
  RemoveUser(this.userId);
}

class MarkUserAsNotNew extends AppEvent {}

// State
class AppState {
  final List<UserInfo_Fam> users;
  final bool isNewUser;

  AppState({required this.users, this.isNewUser = true});

  AppState copyWith({List<UserInfo_Fam>? users, bool? isNewUser}) {
    return AppState(
      users: users ?? this.users,
      isNewUser: isNewUser ?? this.isNewUser,
    );
  }
}

// Bloc
class AppBloc extends Bloc<AppEvent, AppState> {
  AppBloc() : super(AppState(users: [])) {
    on<AddUser>(_onAddUser);
    on<UpdateUser>(_onUpdateUser);
    on<RemoveUser>(_onRemoveUser);
    on<MarkUserAsNotNew>(_onMarkUserAsNotNew);
    _loadState(); // Load saved state when initialized
  }

  Future<void> _loadState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userJson = prefs.getString('users');
    bool isNewUser = prefs.getBool('isNewUser') ?? true;

    if (userJson != null) {
      List<dynamic> userList = jsonDecode(userJson);
      List<UserInfo_Fam> users = userList.map((userMap) => UserInfo_Fam.fromMap(userMap)).toList();
      emit(state.copyWith(users: users, isNewUser: isNewUser));
    }
  }

  Future<void> _onAddUser(AddUser event, Emitter<AppState> emit) async {
    List<UserInfo_Fam> updatedUsers = List.from(state.users)..add(event.user);
    emit(state.copyWith(users: updatedUsers));
    await _persistUsers(updatedUsers);
  }

  Future<void> _onUpdateUser(UpdateUser event, Emitter<AppState> emit) async {
    List<UserInfo_Fam> updatedUsers = state.users.map((user) {
      return user.id == event.user.id ? event.user : user;
    }).toList();
    emit(state.copyWith(users: updatedUsers));
    await _persistUsers(updatedUsers);
  }

  Future<void> _onRemoveUser(RemoveUser event, Emitter<AppState> emit) async {
    List<UserInfo_Fam> updatedUsers = state.users.where((user) => user.id != event.userId).toList();
    emit(state.copyWith(users: updatedUsers));
    await _persistUsers(updatedUsers); // Ensure this is called to persist changes
  }

  Future<void> _onMarkUserAsNotNew(MarkUserAsNotNew event, Emitter<AppState> emit) async {
    emit(state.copyWith(isNewUser: false));
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isNewUser', false);
  }

  Future<void> _persistUsers(List<UserInfo_Fam> users) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userJson = jsonEncode(users.map((user) => user.toMap()).toList());
    await prefs.setString('users', userJson); // Save updated user list
  }
}