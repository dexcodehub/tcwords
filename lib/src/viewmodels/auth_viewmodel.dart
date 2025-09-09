import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';

enum AuthState {
  initial,
  loading,
  authenticated,
  unauthenticated,
  guest,
  error,
}

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService;
  final StorageService _storageService;
  
  AuthViewState _state = const AuthViewState();
  AuthViewState get state => _state;

  AuthViewModel(this._authService, this._storageService);

  void _updateState(AuthViewState newState) {
    _state = newState;
    notifyListeners();
  }

  Future<void> initialize() async {
    try {
      final user = await _storageService.getCurrentUser();
      final isGuestMode = await _storageService.isGuestMode();
      
      if (user != null) {
        _updateState(_state.copyWith(
          status: AuthState.authenticated,
          user: user,
          isGuestMode: false,
        ));
      } else if (isGuestMode) {
        _updateState(_state.copyWith(
          status: AuthState.guest,
          isGuestMode: true,
          user: null,
        ));
      } else {
        _updateState(_state.copyWith(
          status: AuthState.unauthenticated,
          isGuestMode: false,
        ));
      }
    } catch (e) {
      _updateState(_state.copyWith(
        status: AuthState.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<bool> login(String email, String password) async {
    _updateState(_state.copyWith(status: AuthState.loading));
    
    try {
      final user = await _authService.login(email, password);
      await _storageService.saveCurrentUser(user);
      
      _updateState(_state.copyWith(
        status: AuthState.authenticated,
        user: user,
        errorMessage: null,
      ));
      
      return true;
    } catch (e) {
      _updateState(_state.copyWith(
        status: AuthState.error,
        errorMessage: e.toString(),
      ));
      return false;
    }
  }

  Future<void> loginAsGuest() async {
    _updateState(_state.copyWith(status: AuthState.loading));
    
    try {
      await _storageService.setGuestMode(true);
      _updateState(_state.copyWith(
        status: AuthState.guest,
        isGuestMode: true,
        user: null,
        errorMessage: null,
      ));
    } catch (e) {
      _updateState(_state.copyWith(
        status: AuthState.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    required String username,
    required String displayName,
  }) async {
    _updateState(_state.copyWith(status: AuthState.loading));
    
    try {
      final user = await _authService.register(
        email: email,
        password: password,
        username: username,
        displayName: displayName,
      );
      
      await _storageService.saveCurrentUser(user);
      
      _updateState(_state.copyWith(
        status: AuthState.authenticated,
        user: user,
        errorMessage: null,
      ));
      
      return true;
    } catch (e) {
      _updateState(_state.copyWith(
        status: AuthState.error,
        errorMessage: e.toString(),
      ));
      return false;
    }
  }

  Future<void> logout() async {
    _updateState(_state.copyWith(status: AuthState.loading));
    
    try {
      await _authService.logout();
      await _storageService.clearCurrentUser();
      
      _updateState(_state.copyWith(
        status: AuthState.unauthenticated,
        user: null,
        isGuestMode: false,
        errorMessage: null,
      ));
    } catch (e) {
      _updateState(_state.copyWith(
        status: AuthState.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<bool> updateProfile({
    String? displayName,
    String? avatarUrl,
  }) async {
    if (_state.user == null) return false;
    
    _updateState(_state.copyWith(status: AuthState.loading));
    
    try {
      final updatedUser = await _authService.updateProfile(
        userId: _state.user!.id,
        displayName: displayName,
        avatarUrl: avatarUrl,
      );
      
      await _storageService.saveCurrentUser(updatedUser);
      
      _updateState(_state.copyWith(
        status: AuthState.authenticated,
        user: updatedUser,
        errorMessage: null,
      ));
      
      return true;
    } catch (e) {
      _updateState(_state.copyWith(
        status: AuthState.error,
        errorMessage: e.toString(),
      ));
      return false;
    }
  }

  void clearError() {
    _updateState(_state.copyWith(errorMessage: null));
  }
}

class AuthViewState {
  final AuthState status;
  final User? user;
  final String? errorMessage;
  final bool isGuestMode;

  const AuthViewState({
    this.status = AuthState.initial,
    this.user,
    this.errorMessage,
    this.isGuestMode = false,
  });

  bool get isAuthenticated => status == AuthState.authenticated && user != null;
  bool get isGuest => status == AuthState.guest || isGuestMode;
  bool get isLoggedIn => isAuthenticated || isGuest;
  bool get isLoading => status == AuthState.loading;
  bool get hasError => status == AuthState.error && errorMessage != null;

  AuthViewState copyWith({
    AuthState? status,
    User? user,
    String? errorMessage,
    bool? isGuestMode,
  }) {
    return AuthViewState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage,
      isGuestMode: isGuestMode ?? this.isGuestMode,
    );
  }
}