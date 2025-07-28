import 'package:environment_monitoring/utils/constans.dart';
import 'package:flutter/material.dart';

class SensorCard extends StatelessWidget {
  final String title;
  final String value;
  final String unit;
  final IconData icon;
  final Color color;
  final String status;
  final bool isWide;
  final VoidCallback? onTap;

  const SensorCard({
    Key? key,
    required this.title,
    required this.value,
    required this.unit,
    required this.icon,
    required this.color,
    required this.status,
    this.isWide = false,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            SizedBox(height: 12),
            _buildTitle(),
            SizedBox(height: 4),
            _buildValue(),
            if (!isWide) ...[
              SizedBox(height: 8),
              _buildStatus(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        if (isWide) ...[
          Spacer(),
          _buildStatus(),
        ],
      ],
    );
  }

  Widget _buildTitle() {
    return Text(
      title,
      style: TextStyle(
        fontSize: 14,
        color: Colors.grey[600],
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildValue() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: isWide ? 32 : 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        if (unit.isNotEmpty) ...[
          SizedBox(width: 4),
          Padding(
            padding: EdgeInsets.only(bottom: isWide ? 6 : 4),
            child: Text(
              unit,
              style: TextStyle(
                fontSize: isWide ? 16 : 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStatus() {
    Color statusColor = _getStatusColor(status);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: statusColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'normal':
        return AppConstants.normalColor;
      case 'dingin':
      case 'kering':
      case 'asam':
      case 'hangat':
      case 'lembab':
        return AppConstants.warningColor;
      case 'panas':
      case 'sangat lembab':
      case 'basa':
      case 'sangat asam':
      case 'sangat basa':
        return AppConstants.dangerColor;
      default:
        return Colors.grey;
    }
  }
}

// Widget untuk loading state
class SensorCardSkeleton extends StatefulWidget {
  final bool isWide;

  const SensorCardSkeleton({
    Key? key,
    this.isWide = false,
  }) : super(key: key);

  @override
  _SensorCardSkeletonState createState() => _SensorCardSkeletonState();
}

class _SensorCardSkeletonState extends State<SensorCardSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(_animation.value),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  if (widget.isWide) ...[
                    Spacer(),
                    Container(
                      width: 60,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(_animation.value),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ],
                ],
              ),
              SizedBox(height: 12),
              Container(
                width: 80,
                height: 14,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(_animation.value),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              SizedBox(height: 4),
              Container(
                width: widget.isWide ? 120 : 80,
                height: widget.isWide ? 32 : 24,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(_animation.value),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              if (!widget.isWide) ...[
                SizedBox(height: 8),
                Container(
                  width: 60,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(_animation.value),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
