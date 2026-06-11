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
      final res = await _apiService.get('/rewards/status', forceRefresh: true);
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
      final res = await _apiService.get('/rewards/history', forceRefresh: true);
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
      final res = await _apiService.get('/rewards/leaderboard', query: {'category': category}, forceRefresh: true);
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
      final res = await _apiService.get('/rewards/challenges', forceRefresh: true);
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

  // Fetch reviews for a specific user
  Future<Map<String, dynamic>> fetchUserReviews(int userId) async {
    _setLoading(true);
    try {
      final res = await _apiService.get('/rewards/users/$userId/reviews');
      if (res['success'] == true) {
        return {'success': true, 'data': res['data']};
      }
      return {'success': false, 'message': res['message'] ?? 'Failed to load reviews'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Report a review for an order
  Future<Map<String, dynamic>> reportReview(int orderId, String reason) async {
    try {
      final res = await _apiService.post('/orders/$orderId/review/report', {'reason': reason});
      if (res['success'] == true) {
        return {'success': true, 'message': 'Review reported successfully'};
      }
      return {'success': false, 'message': res['message'] ?? 'Failed to report review'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }
}
