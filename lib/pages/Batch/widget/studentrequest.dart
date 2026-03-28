import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learning_admin_app/provider/request_provider.dart';

class BatchRequestsScreen extends ConsumerStatefulWidget {
  final String batchId;
  final String batchName;

  const BatchRequestsScreen({
    super.key,
    required this.batchId,
    required this.batchName,
  });

  @override
  ConsumerState<BatchRequestsScreen> createState() =>
      _BatchRequestsScreenState();
}

class _BatchRequestsScreenState extends ConsumerState<BatchRequestsScreen> {
  // Track which request IDs are currently loading
  final Set<String> _loadingIds = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(batchRequestsProvider.notifier).setBatchId(widget.batchId);
    });
  }

  Future<void> _accept(String requestId) async {
    setState(() => _loadingIds.add('accept_$requestId'));
    final success = await ref
        .read(batchRequestsProvider.notifier)
        .acceptRequest(requestId: requestId);
    setState(() => _loadingIds.remove('accept_$requestId'));

    if (mounted) {
      _showSnack(
        success ? 'Request accepted!' : 'Failed to accept request',
        success ? Colors.green : Colors.red,
      );
    }
  }

  Future<void> _reject(String requestId) async {
    setState(() => _loadingIds.add('reject_$requestId'));
    final success = await ref
        .read(batchRequestsProvider.notifier)
        .rejectRequest(requestId: requestId);
    setState(() => _loadingIds.remove('reject_$requestId'));

    if (mounted) {
      _showSnack(
        success ? 'Request rejected' : 'Failed to reject request',
        success ? Colors.orange : Colors.red,
      );
    }
  }

  Future<void> _deleteAllAccepted() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear Accepted Requests'),
        content: const Text(
          'Delete all accepted requests? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final success = await ref
        .read(batchRequestsProvider.notifier)
        .deleteAllAccepted();

    if (mounted) {
      _showSnack(
        success ? 'Cleared all accepted requests' : 'Failed to clear',
        success ? Colors.green : Colors.red,
      );
    }
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(color: Colors.white)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final requestsAsync = ref.watch(batchRequestsProvider);

    return Scaffold(
      body: requestsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 12),
              Text('Error: $e', textAlign: TextAlign.center),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () =>
                    ref.read(batchRequestsProvider.notifier).refresh(),
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (requests) {
          // Filter only pending requests for action items
          final pending = requests.where((r) => r.status == 'pending').toList();
          final others = requests.where((r) => r.status != 'pending').toList();
          final all = [...pending, ...others];

          if (all.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.inbox_outlined,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No requests yet',
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => ref.read(batchRequestsProvider.notifier).refresh(),
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
              itemCount: all.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final req = all[index];
                return _RequestCard(
                  request: req,
                  isAcceptLoading: _loadingIds.contains(
                    'accept_${req.requestId}',
                  ),
                  isRejectLoading: _loadingIds.contains(
                    'reject_${req.requestId}',
                  ),
                  onAccept: req.status == 'pending'
                      ? () => _accept(req.requestId)
                      : null,
                  onReject: req.status == 'pending'
                      ? () => _reject(req.requestId)
                      : null,
                  onDelete: () async {
                    final success = await ref
                        .read(batchRequestsProvider.notifier)
                        .deleteSingleRequest(requestId: req.requestId);
                    if (mounted) {
                      _showSnack(
                        success ? 'Request deleted' : 'Failed to delete',
                        success ? Colors.green : Colors.red,
                      );
                    }
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  final BatchRequest request;
  final bool isAcceptLoading;
  final bool isRejectLoading;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;
  final VoidCallback? onDelete;

  const _RequestCard({
    required this.request,
    required this.isAcceptLoading,
    required this.isRejectLoading,
    this.onAccept,
    this.onReject,
    this.onDelete,
  });

  Color get _statusColor {
    switch (request.status) {
      case 'accepted':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPending = request.status == 'pending';

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.tertiary,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border(left: BorderSide(color: _statusColor, width: 4)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 28,
              backgroundColor: Colors.grey.shade200,
              child: Icon(Icons.person, size: 30, color: Colors.grey.shade500),
            ),
            const SizedBox(width: 12),

            // Name + phone
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    request.studentId,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    request.status.toUpperCase(),
                    style: TextStyle(
                      fontSize: 11,
                      color: _statusColor,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),

            // Action buttons — only for pending
            if (isPending) ...[
              // Reject button
              _ActionButton(
                isLoading: isRejectLoading,
                onTap: onReject,
                icon: Icons.close,
                color: Colors.red,
              ),
              const SizedBox(width: 8),
              // Accept button
              _ActionButton(
                isLoading: isAcceptLoading,
                onTap: onAccept,
                icon: Icons.check,
                color: Colors.green,
              ),
            ] else ...[
              // Delete button for non-pending
              IconButton(
                onPressed: onDelete,
                icon: const Icon(
                  Icons.delete_outline,
                  color: Colors.grey,
                  size: 22,
                ),
                tooltip: 'Delete',
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback? onTap;
  final IconData icon;
  final Color color;

  const _ActionButton({
    required this.isLoading,
    required this.onTap,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: color, width: 2.5),
          color: Colors.white,
        ),
        child: isLoading
            ? Padding(
                padding: const EdgeInsets.all(10),
                child: CircularProgressIndicator(strokeWidth: 2, color: color),
              )
            : Icon(icon, color: color, size: 22),
      ),
    );
  }
}
