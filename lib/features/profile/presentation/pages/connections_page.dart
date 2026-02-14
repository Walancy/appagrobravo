import 'package:flutter/material.dart';
import 'package:agrobravo/core/tokens/app_colors.dart';
import 'package:agrobravo/core/tokens/app_spacing.dart';
import 'package:agrobravo/core/tokens/app_text_styles.dart';
import 'package:agrobravo/core/di/injection.dart';
import 'package:agrobravo/core/components/app_header.dart';
import 'package:agrobravo/features/profile/domain/repositories/profile_repository.dart';
import 'package:agrobravo/features/profile/domain/entities/profile_entity.dart';
import 'package:agrobravo/features/home/domain/repositories/feed_repository.dart';
import 'package:go_router/go_router.dart';

class ConnectionsPage extends StatefulWidget {
  final String userId;
  final int initialIndex;

  const ConnectionsPage({
    super.key,
    required this.userId,
    this.initialIndex = 0,
  });

  @override
  State<ConnectionsPage> createState() => _ConnectionsPageState();
}

class _ConnectionsPageState extends State<ConnectionsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  List<ProfileEntity> _connections = [];
  List<ProfileEntity> _requests = [];
  List<ProfileEntity> _filteredConnections = [];
  List<ProfileEntity> _filteredRequests = [];

  bool _isLoading = true;
  late String _currentUserId;
  late bool _isMe;

  @override
  void initState() {
    super.initState();
    _currentUserId = getIt<FeedRepository>().getCurrentUserId() ?? '';
    _isMe = widget.userId == _currentUserId;
    _tabController = TabController(
      length: _isMe ? 2 : 1,
      vsync: this,
      initialIndex: _isMe ? widget.initialIndex : 0,
    );
    _loadData();
    _searchController.addListener(_onSearchChanged);
  }

  Future<void> _loadData() async {
    final connResult = await getIt<ProfileRepository>().getConnections(
      widget.userId,
    );
    final reqResult = _isMe
        ? await getIt<ProfileRepository>().getRequests(widget.userId)
        : null;

    if (mounted) {
      setState(() {
        connResult.fold((_) {}, (list) {
          _connections = list;
          _filteredConnections = list;
        });

        reqResult?.fold((_) {}, (list) {
          _requests = list;
          _filteredRequests = list;
        });

        _isLoading = false;
      });
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredConnections = _connections
          .where((u) => u.name.toLowerCase().contains(query))
          .toList();
      _filteredRequests = _requests
          .where((u) => u.name.toLowerCase().contains(query))
          .toList();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppHeader(mode: HeaderMode.back, title: 'Conexões'),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                const SizedBox(height: 12),
                // Search Bar
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey.shade800
                          : Colors.grey[100],
                      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: AppTextStyles.bodyMedium,
                      decoration: InputDecoration(
                        hintText: 'Pesquisar',
                        prefixIcon: Icon(
                          Icons.search,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.6),
                          size: 20,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.sm),

                // Tabs (Instagram Style) - Show only if isMe
                if (_isMe)
                  TabBar(
                    controller: _tabController,
                    indicatorColor: Theme.of(context).colorScheme.onSurface,
                    indicatorWeight: 1,
                    labelColor: Theme.of(context).colorScheme.onSurface,
                    unselectedLabelColor: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.6),
                    labelStyle: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    tabs: [
                      Tab(text: '${_connections.length} conexões'),
                      Tab(text: '${_requests.length} solicitações de conexão'),
                    ],
                  )
                else
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '${_connections.length} conexões',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                // Tab Content
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildList(
                        _filteredConnections,
                        'Nenhuma conexão encontrada.',
                        _isMe,
                        false,
                      ),
                      if (_isMe)
                        _buildList(
                          _filteredRequests,
                          'Nenhuma solicitação pendente.',
                          _isMe,
                          true,
                        ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildList(
    List<ProfileEntity> users,
    String emptyMessage,
    bool isMe,
    bool isRequestTab,
  ) {
    if (users.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Text(
            emptyMessage,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(color: Colors.grey),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        final isSelf = user.id == _currentUserId;

        return Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: 8,
          ),
          child: Row(
            children: [
              // Avatar
              GestureDetector(
                onTap: () => context.push('/profile/${user.id}'),
                child: CircleAvatar(
                  radius: 28,
                  backgroundColor:
                      Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey.shade800
                      : Colors.grey[100],
                  backgroundImage: user.avatarUrl != null
                      ? NetworkImage(user.avatarUrl!)
                      : null,
                  child: user.avatarUrl == null
                      ? const Icon(Icons.person, size: 30)
                      : null,
                ),
              ),
              const SizedBox(width: 12),

              // Name and Job
              Expanded(
                child: GestureDetector(
                  onTap: () => context.push('/profile/${user.id}'),
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (user.jobTitle != null && user.jobTitle!.isNotEmpty)
                        Text(
                          user.jobTitle!,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // Action Buttons
              if (!isSelf) _buildDynamicActionButton(user, isRequestTab),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDynamicActionButton(ProfileEntity user, bool isRequestTab) {
    if (isRequestTab && _isMe) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildActionButton(
            label: 'Confirmar',
            onPressed: () async {
              await getIt<ProfileRepository>().acceptConnection(user.id);
              _loadData();
            },
            isPrimary: true,
          ),
          const SizedBox(width: 8),
          _buildActionButton(
            label: 'Excluir',
            onPressed: () async {
              await getIt<ProfileRepository>().rejectConnection(user.id);
              _loadData();
            },
            isPrimary: false,
          ),
        ],
      );
    }

    if (_isMe) {
      return _buildActionButton(
        label: 'Remover',
        onPressed: () async {
          await getIt<ProfileRepository>().removeConnection(user.id);
          _loadData();
        },
        isPrimary: false,
      );
    }

    // Relative to current user
    switch (user.connectionStatus) {
      case ConnectionStatus.none:
        return _buildActionButton(
          label: 'Conectar-se',
          onPressed: () async {
            await getIt<ProfileRepository>().requestConnection(user.id);
            _loadData();
          },
          isPrimary: true,
        );
      case ConnectionStatus.pendingSent:
        return _buildActionButton(
          label: 'Solicitado',
          onPressed: () async {
            await getIt<ProfileRepository>().cancelConnection(user.id);
            _loadData();
          },
          isPrimary: false,
        );
      case ConnectionStatus.pendingReceived:
        return _buildActionButton(
          label: 'Aceitar',
          onPressed: () async {
            await getIt<ProfileRepository>().acceptConnection(user.id);
            _loadData();
          },
          isPrimary: true,
        );
      case ConnectionStatus.connected:
        return _buildActionButton(
          label: 'Remover',
          onPressed: () async {
            await getIt<ProfileRepository>().removeConnection(user.id);
            _loadData();
          },
          isPrimary: false,
        );
    }
  }

  Widget _buildActionButton({
    required String label,
    required VoidCallback onPressed,
    required bool isPrimary,
  }) {
    return SizedBox(
      height: 32,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary
              ? AppColors.primary
              : (Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey.shade800
                    : Colors.grey[200]),
          foregroundColor: isPrimary
              ? Colors.white
              : Theme.of(context).colorScheme.onSurface,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: isPrimary
                ? Colors.white
                : Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}
