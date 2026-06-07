import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexa_tracker/services/friend_service.dart';
import 'package:hexa_tracker/services/api_service.dart';
import 'package:hexa_tracker/ui/navigationBar/navigation_bar.dart';

class Friends extends StatefulWidget {
  const Friends({super.key});

  @override
  State<Friends> createState() => _FriendsState();
}

class _FriendsState extends State<Friends> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> _friends = [];
  List<Map<String, dynamic>> _requests = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final friends = await FriendService.getFriends();
    final requests = await FriendService.getPendingRequests();
    if (mounted) setState(() { _friends = friends; _requests = requests; _loading = false; });
  }

  void _showAddFriendDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Adicionar Amigo'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'email@exemplo.com',
            prefixIcon: Icon(Icons.email_outlined),
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.emailAddress,
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              final email = controller.text.trim();
              if (email.isEmpty) return;
              Navigator.pop(ctx);
              final error = await FriendService.sendRequest(email);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(error == null ? 'Solicitação enviada!' : error),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: error == null ? Colors.green[600] : Colors.red[600],
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ));
              }
            },
            child: const Text('Enviar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return AppScaffold(
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(isMobile ? 16 : 32, isMobile ? 20 : 32, isMobile ? 16 : 32, 0),
                  child: Row(
                    children: [
                      Text('Friends', style: GoogleFonts.majorMonoDisplay(fontSize: isMobile ? 24 : 32)),
                      const Spacer(),
                      ElevatedButton.icon(
                        onPressed: _showAddFriendDialog,
                        icon: const Icon(Icons.person_add_outlined, size: 18),
                        label: const Text('Adicionar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 98, 147, 175),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                TabBar(
                  controller: _tabController,
                  labelColor: Colors.black87,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: const Color.fromARGB(255, 98, 147, 175),
                  tabs: [
                    Tab(text: 'Amigos (${_friends.length})'),
                    Tab(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Solicitações'),
                          if (_requests.isNotEmpty) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.red[600],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text('${_requests.length}',
                                  style: const TextStyle(color: Colors.white, fontSize: 11)),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _FriendsList(
                        friends: _friends,
                        onRefresh: _load,
                        isMobile: isMobile,
                      ),
                      _RequestsList(
                        requests: _requests,
                        onRefresh: _load,
                        isMobile: isMobile,
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

// ── Lista de Amigos ────────────────────────────────────────────────────────────

class _FriendsList extends StatelessWidget {
  final List<Map<String, dynamic>> friends;
  final VoidCallback onRefresh;
  final bool isMobile;
  const _FriendsList({required this.friends, required this.onRefresh, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    if (friends.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text('Nenhum amigo ainda',
                style: GoogleFonts.majorMonoDisplay(fontSize: 16, color: Colors.grey[500])),
            const SizedBox(height: 8),
            Text('Adicione amigos pelo email para ver a biblioteca deles.',
                style: TextStyle(color: Colors.grey[400], fontSize: 13),
                textAlign: TextAlign.center),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(isMobile ? 16 : 32),
      itemCount: friends.length,
      itemBuilder: (context, i) => _FriendTile(
        friend: friends[i],
        onRefresh: onRefresh,
      ),
    );
  }
}

class _FriendTile extends StatelessWidget {
  final Map<String, dynamic> friend;
  final VoidCallback onRefresh;
  const _FriendTile({required this.friend, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: const Color.fromARGB(255, 98, 147, 175),
          backgroundImage: (friend['photoUrl'] as String?)?.isNotEmpty == true
              ? NetworkImage(friend['photoUrl'])
              : null,
          child: (friend['photoUrl'] as String?)?.isNotEmpty != true
              ? Text((friend['displayName'] ?? 'U')[0].toUpperCase(),
                  style: const TextStyle(color: Colors.white, fontSize: 18))
              : null,
        ),
        title: Text(friend['displayName'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(friend['email'] ?? '', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.person_outline),
              tooltip: 'Ver perfil',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FriendProfilePage(friend: friend),
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.person_remove_outlined, color: Colors.red[400]),
              tooltip: 'Remover amigo',
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Remover amigo'),
                    content: Text('Remover ${friend['displayName']} da sua lista de amigos?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('Remover', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  await FriendService.removeFriend(friend['id']);
                  onRefresh();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ── Lista de Solicitações ──────────────────────────────────────────────────────

class _RequestsList extends StatelessWidget {
  final List<Map<String, dynamic>> requests;
  final VoidCallback onRefresh;
  final bool isMobile;
  const _RequestsList({required this.requests, required this.onRefresh, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    if (requests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.mark_email_read_outlined, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text('Nenhuma solicitação pendente',
                style: TextStyle(color: Colors.grey[500], fontSize: 14)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(isMobile ? 16 : 32),
      itemCount: requests.length,
      itemBuilder: (context, i) => _RequestTile(request: requests[i], onRefresh: onRefresh),
    );
  }
}

class _RequestTile extends StatelessWidget {
  final Map<String, dynamic> request;
  final VoidCallback onRefresh;
  const _RequestTile({required this.request, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: const Color.fromARGB(255, 98, 147, 175),
          backgroundImage: (request['fromPhotoUrl'] as String?)?.isNotEmpty == true
              ? NetworkImage(request['fromPhotoUrl'])
              : null,
          child: (request['fromPhotoUrl'] as String?)?.isNotEmpty != true
              ? Text((request['fromDisplayName'] ?? 'U')[0].toUpperCase(),
                  style: const TextStyle(color: Colors.white, fontSize: 18))
              : null,
        ),
        title: Text(request['fromDisplayName'] ?? request['fromEmail'] ?? '',
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(request['fromEmail'] ?? '', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.check_circle_outline, color: Colors.green[600]),
              tooltip: 'Aceitar',
              onPressed: () async {
                await FriendService.acceptRequest(request['fromUserId']);
                onRefresh();
              },
            ),
            IconButton(
              icon: Icon(Icons.cancel_outlined, color: Colors.red[400]),
              tooltip: 'Recusar',
              onPressed: () async {
                await FriendService.declineRequest(request['fromUserId']);
                onRefresh();
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ── Perfil do Amigo ────────────────────────────────────────────────────────────

class FriendProfilePage extends StatefulWidget {
  final Map<String, dynamic> friend;
  const FriendProfilePage({super.key, required this.friend});

  @override
  State<FriendProfilePage> createState() => _FriendProfilePageState();
}

class _FriendProfilePageState extends State<FriendProfilePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> _library = [];
  List<Map<String, dynamic>> _stats = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final lib = await FriendService.getFriendLibrary(widget.friend['id']);
    final stats = await FriendService.getFriendStats(widget.friend['id']);
    if (mounted) setState(() { _library = lib; _stats = stats; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Header do perfil
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 32, vertical: 24),
                  color: Colors.white,
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 36,
                        backgroundColor: const Color.fromARGB(255, 98, 147, 175),
                        backgroundImage: (widget.friend['photoUrl'] as String?)?.isNotEmpty == true
                            ? NetworkImage(widget.friend['photoUrl'])
                            : null,
                        child: (widget.friend['photoUrl'] as String?)?.isNotEmpty != true
                            ? Text((widget.friend['displayName'] ?? 'U')[0].toUpperCase(),
                                style: const TextStyle(color: Colors.white, fontSize: 28))
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.friend['displayName'] ?? '',
                              style: GoogleFonts.majorMonoDisplay(fontSize: isMobile ? 18 : 22)),
                          const SizedBox(height: 4),
                          Text(widget.friend['email'] ?? '',
                              style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              _miniStat('${_library.length}', 'jogos'),
                              const SizedBox(width: 16),
                              _miniStat('${_stats.length}', 'partidas'),
                              const SizedBox(width: 16),
                              _miniStat(
                                '${_stats.isEmpty ? 0 : (_stats.where((m) => m['result'] == 'win').length / _stats.length * 100).round()}%',
                                'win rate',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                TabBar(
                  controller: _tabController,
                  labelColor: Colors.black87,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: const Color.fromARGB(255, 98, 147, 175),
                  tabs: const [
                    Tab(text: 'Biblioteca'),
                    Tab(text: 'Estatísticas'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _FriendLibraryTab(library: _library, isMobile: isMobile),
                      _FriendStatsTab(matches: _stats, isMobile: isMobile),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _miniStat(String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 11)),
      ],
    );
  }
}

// ── Biblioteca do Amigo ────────────────────────────────────────────────────────

class _FriendLibraryTab extends StatelessWidget {
  final List<Map<String, dynamic>> library;
  final bool isMobile;
  const _FriendLibraryTab({required this.library, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    if (library.isEmpty) {
      return Center(
        child: Text('Biblioteca vazia', style: TextStyle(color: Colors.grey[500])),
      );
    }

    return GridView.builder(
      padding: EdgeInsets.all(isMobile ? 12 : 24),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isMobile ? 2 : 4,
        crossAxisSpacing: isMobile ? 10 : 16,
        mainAxisSpacing: isMobile ? 10 : 16,
        childAspectRatio: 0.72,
      ),
      itemCount: library.length,
      itemBuilder: (context, i) {
        final game = library[i];
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 3))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Image.network(
                    ApiService.proxyImage(game['thumbnail'] ?? ''),
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(color: Colors.grey[200],
                        child: const Icon(Icons.image_not_supported, color: Colors.grey)),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(game['name'] ?? '',
                        style: GoogleFonts.lato(fontWeight: FontWeight.bold, fontSize: 12),
                        maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 12),
                        const SizedBox(width: 3),
                        Text(game['rating'] ?? '', style: TextStyle(color: Colors.grey[600], fontSize: 11)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Estatísticas do Amigo ──────────────────────────────────────────────────────

class _FriendStatsTab extends StatelessWidget {
  final List<Map<String, dynamic>> matches;
  final bool isMobile;
  const _FriendStatsTab({required this.matches, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    if (matches.isEmpty) {
      return Center(
        child: Text('Nenhuma partida este mês', style: TextStyle(color: Colors.grey[500])),
      );
    }

    final wins = matches.where((m) => m['result'] == 'win').length;
    final losses = matches.length - wins;

    // Agrupa por jogo
    final byGame = <String, Map<String, int>>{};
    for (final m in matches) {
      final name = m['gameName'] as String? ?? 'Desconhecido';
      byGame.putIfAbsent(name, () => {'win': 0, 'loss': 0});
      byGame[name]![m['result'] as String? ?? 'loss'] =
          (byGame[name]![m['result'] as String? ?? 'loss'] ?? 0) + 1;
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cards de resumo
          Wrap(
            spacing: 12, runSpacing: 12,
            children: [
              _MiniStatCard(label: 'Partidas', value: '${matches.length}', color: Colors.blue[700]!),
              _MiniStatCard(label: 'Vitórias', value: '$wins', color: Colors.green[600]!),
              _MiniStatCard(label: 'Derrotas', value: '$losses', color: Colors.red[600]!),
              _MiniStatCard(
                label: 'Win Rate',
                value: '${(wins / matches.length * 100).round()}%',
                color: Colors.purple[600]!,
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text('Vitórias e Derrotas por Jogo',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 12),
          // Mini win/loss bars
          ...byGame.entries.map((e) {
            final w = e.value['win'] ?? 0;
            final l = e.value['loss'] ?? 0;
            final total = w + l;
            final winPct = total == 0 ? 0.0 : w / total;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(e.key,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                            overflow: TextOverflow.ellipsis),
                      ),
                      Text('$w V / $l D',
                          style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: SizedBox(
                      height: 10,
                      child: Row(
                        children: [
                          Flexible(
                            flex: (winPct * 100).round().clamp(1, 99),
                            child: Container(color: Colors.green[500]),
                          ),
                          Flexible(
                            flex: 100 - (winPct * 100).round().clamp(1, 99),
                            child: Container(color: Colors.red[400]),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _MiniStatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _MiniStatCard({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        ],
      ),
    );
  }
}