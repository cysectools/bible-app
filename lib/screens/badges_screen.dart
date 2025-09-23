import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';
import '../services/database_service.dart';
import '../services/language_service.dart';

class BadgesScreen extends StatefulWidget {
  const BadgesScreen({super.key});

  @override
  State<BadgesScreen> createState() => _BadgesScreenState();
}

class _BadgesScreenState extends State<BadgesScreen> {
  List<Map<String, dynamic>> _badges = [];
  List<Map<String, dynamic>> _userBadges = [];
  bool _isLoading = true;
  String _userId = 'default_user'; // TODO: Get actual user ID

  @override
  void initState() {
    super.initState();
    _loadBadges();
  }

  Future<void> _loadBadges() async {
    setState(() => _isLoading = true);
    
    try {
      // Load all available badges and user's earned badges
      final allBadges = await DatabaseService.getAllBadges();
      final userBadges = await DatabaseService.getUserBadges(_userId);
      
      // If no badges in database, use default badges
      if (allBadges.isEmpty) {
        _badges = BadgeDefinitions.defaultBadges;
      } else {
        _badges = allBadges;
      }
      
      _userBadges = userBadges;
    } catch (e) {
      // Fallback to default badges if database fails
      _badges = BadgeDefinitions.defaultBadges;
      _userBadges = [];
    }
    
    setState(() => _isLoading = false);
  }

  bool _hasBadge(String badgeId) {
    return _userBadges.any((badge) => badge['badge_id'] == badgeId);
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppStateProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('🏆 ${appState.translate(AppTranslations.badges)}'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadBadges,
              child: _badges.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.emoji_events_outlined,
                            size: 64,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            appState.translate('no_badges_available'),
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.8,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: _badges.length,
                      itemBuilder: (context, index) {
                        final badge = _badges[index];
                        final hasBadge = _hasBadge(badge['id']);
                        
                        return _BadgeCard(
                          badge: badge,
                          hasBadge: hasBadge,
                        );
                      },
                    ),
            ),
    );
  }
}

class _BadgeCard extends StatelessWidget {
  final Map<String, dynamic> badge;
  final bool hasBadge;

  const _BadgeCard({
    required this.badge,
    required this.hasBadge,
  });

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppStateProvider>(context);
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: hasBadge ? Colors.white : Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
        boxShadow: hasBadge
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
        border: hasBadge
            ? Border.all(
                color: Color(int.parse(badge['color'].replaceFirst('#', '0xFF'))),
                width: 2,
              )
            : null,
      ),
      child: InkWell(
        onTap: hasBadge ? () => _showBadgeDetails(context, badge) : null,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Badge icon
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: hasBadge
                      ? Color(int.parse(badge['color'].replaceFirst('#', '0xFF')))
                          .withValues(alpha: 0.1)
                      : Colors.grey[200],
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Center(
                  child: Text(
                    badge['icon'] ?? '🏆',
                    style: TextStyle(
                      fontSize: 24,
                      color: hasBadge
                          ? Color(int.parse(badge['color'].replaceFirst('#', '0xFF')))
                          : Colors.grey[400],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              
              // Badge name
              Text(
                badge['name'] ?? 'Unknown Badge',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: hasBadge ? Colors.black87 : Colors.grey[600],
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              
              // Badge description
              Text(
                badge['description'] ?? '',
                style: TextStyle(
                  fontSize: 12,
                  color: hasBadge ? Colors.grey[600] : Colors.grey[500],
                ),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 8),
              
              // Earned indicator
              if (hasBadge)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Color(int.parse(badge['color'].replaceFirst('#', '0xFF'))),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'EARNED',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'LOCKED',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showBadgeDetails(BuildContext context, Map<String, dynamic> badge) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Text(
              badge['icon'] ?? '🏆',
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                badge['name'] ?? 'Unknown Badge',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              badge['description'] ?? '',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Color(int.parse(badge['color'].replaceFirst('#', '0xFF')))
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Color(int.parse(badge['color'].replaceFirst('#', '0xFF'))),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Color(int.parse(badge['color'].replaceFirst('#', '0xFF'))),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Badge Earned!',
                    style: TextStyle(
                      color: Color(int.parse(badge['color'].replaceFirst('#', '0xFF'))),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

/// Add badges translation key
extension AppTranslationsExtension on AppTranslations {
  static const String badges = 'badges';
}
