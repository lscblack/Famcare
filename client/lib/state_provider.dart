import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Define the state model
class AppState {
  final bool isNewUser;

  AppState({required this.isNewUser});

  // Copy with method for updating states
  AppState copyWith({bool? isNewUser}) {
    return AppState(
      isNewUser: isNewUser ?? this.isNewUser,
    );
  }
}

// StateNotifier to manage state and persistence
class AppStateNotifier extends StateNotifier<AppState> {
  AppStateNotifier() : super(AppState(isNewUser: true)) {
    _loadState(); // Load saved state when initialized
  }

  // Load saved state from SharedPreferences
  Future<void> _loadState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isNewUser = prefs.getBool('isNewUser') ?? true;
    
    // Update the state with the loaded value
    state = AppState(isNewUser: isNewUser);
  }

  // Update and persist `isNewUser` state
  Future<void> setNewUser(bool value) async {
    state = state.copyWith(isNewUser: value);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isNewUser', value);
  }
}

// Riverpod provider for state management
final appStateProvider = StateNotifierProvider<AppStateNotifier, AppState>(
  (ref) => AppStateNotifier(),
);

// Optional: FutureProvider to access the initial state asynchronously
final appStateFutureProvider = FutureProvider<AppState>((ref) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isNewUser = prefs.getBool('isNewUser') ?? true;
  return AppState(isNewUser: isNewUser);
});
