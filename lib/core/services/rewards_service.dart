import 'package:flutter/foundation.dart';
import 'api_service.dart';

class RewardsService extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Map<String, dynamic>? _rewardsStatus;
  Map<String, dynamic>? get rewardsStatus => _rewardsStatus;

  List<dynamic> _history = [];
  List<dynamic> get history => _history;

  List<dynamic> _leaderboard = [];
  List<dynamic> get leaderboard => _leaderboard;

  List<dynamic> _challenges = [];
  List<dynamic> get challenges => _challenges;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Fetch points, level, and badge status
  Future<Map<String, dynamic>> fetchRewardsStatus() async {
    _setLoading(true);
    try {
      final res = await _apiService.get('/rewards/status');
      if (res['success'] == true) {
        _rewardsStatus = res['data'];
        notifyListeners();
        return {'success': true, 'data': _rewardsStatus};
      }
      return {'success': false, 'message': res['message'] ?? 'Failed to load status'};
    } catch (e) {
      if (kDebugMode) print('Error fetching rewards: $e');
      return {'success': false, 'message': e.toString()};
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch points transactions history
  Future<void> fetchHistory() async {
    _setLoading(true);
    try {
      final res = await _apiService.get('/rewards/history');
      if (res['success'] == true) {
        _history = res['data'] ?? [];
      }
    } catch (e) {
      if (kDebugMode) print('Error fetching history: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch rankings leaderboard
  Future<void> fetchLeaderboard(String category) async {
    _setLoading(true);
    try {
      final res = await _apiService.get('/rewards/leaderboard', query: {'category': category});
      if (res['success'] == true) {
        _leaderboard = res['data'] ?? [];
      }
    } catch (e) {
      if (kDebugMode) print('Error fetching leaderboard: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch active missions/challenges
  Future<void> fetchChallenges() async {
    _setLoading(true);
    try {
      final res = await _apiService.get('/rewards/challenges');
      if (res['success'] == true) {
        _challenges = res['data'] ?? [];
      }
    } catch (e) {
      if (kDebugMode) print('Error fetching challenges: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Claim daily streak login points
  Future<Map<String, dynamic>> checkIn() async {
    _setLoading(true);
    try {
      final res = await _apiService.post('/rewards/check-in', {});
      if (res['success'] == true) {
        await fetchRewardsStatus(); // refresh status
        return {'success': true, 'message': res['message'] ?? 'Check-in successful', 'data': res['data']};
      }
      return {'success': false, 'message': res['message'] ?? 'Failed to check-in'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
