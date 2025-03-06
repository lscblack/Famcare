import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// App state model
class AppState {
  final bool isNewUser;
  
  AppState({this.isNewUser = true});
  
  // Copy with method for immutable updates
  AppState copyWith({bool? isNewUser}) {
    return AppState(
      isNewUser: isNewUser ?? this.isNewUser,
    );
  }
}

// App state notifier to update the state
class AppStateNotifier extends StateNotifier<AppState> {
  AppStateNotifier() : super(AppState()) {
    _loadState(); // Load saved state when initialized
  }

  // Load saved state from SharedPreferences
  Future<void> _loadState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isNewUser = prefs.getBool('isNewUser') ?? true;
    state = AppState(isNewUser: isNewUser);
  }
  
  // Update and persist isNewUser state
  Future<void> setNewUser(bool value) async {
    state = state.copyWith(isNewUser: value);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isNewUser', value);
  }
}

// Provider for the app state
final appStateProvider = StateNotifierProvider<AppStateNotifier, AppState>((ref) {
  return AppStateNotifier();
});

// FutureProvider to access the initial state asynchronously
final appStateFutureProvider = FutureProvider<AppState>((ref) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isNewUser = prefs.getBool('isNewUser') ?? true;
  return AppState(isNewUser: isNewUser);
});