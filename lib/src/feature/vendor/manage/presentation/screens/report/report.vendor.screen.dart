
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class VendorReportsScreen extends StatefulWidget {
  const VendorReportsScreen({super.key});

  @override
  State<VendorReportsScreen> createState() =>
      _VendorReportsScreenState();
}

class _VendorReportsScreenState
    extends State<VendorReportsScreen> {

  final Color primary = const Color(0xFF536DFE);

  String selectedPeriod = '7 Days';
  DateTimeRange? customDateRange;

  final List<Map<String, dynamic>> unpaidClients = [
    {
      'name': 'Kamal Perera',
      'phone': '0771234567',
      'amount': 4500.0,
      'days': 5,
    },
    {
      'name': 'Nimal Fernando',
      'phone': '0712345678',
      'amount': 2500.0,
      'days': 12,
    },
    {
      'name': 'Saman Kumara',
      'phone': '0761234567',
      'amount': 1800.0,
      'days': 35,
    },
  ];

  final List<Map<String, dynamic>> upcomingExpiries = [
    {
      'name': 'Kamal Perera',
      'package': 'Dialog 20GB',
      'date': 'Today',
    },
    {
      'name': 'Nimal Fernando',
      'package': 'Mobitel Unlimited',
      'date': 'Tomorrow',
    },
    {
      'name': 'Saman Kumara',
      'package': 'Hutch Data 10GB',
      'date': '18 Nov',
    },
  ];

  final List<Map<String, dynamic>> topPackages = [
    {
      'name': 'Dialog 20GB',
      'count': 45,
      'amount': 45000.0,
    },
    {
      'name': 'Mobitel Unlimited',
      'count': 32,
      'amount': 32000.0,
    },
    {
      'name': 'Hutch Data 10GB',
      'count': 24,
      'amount': 18000.0,
    },
  ];

  Future<void> selectCustomDate() async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      initialDateRange: customDateRange,
    );

    if (range != null) {
      setState(() {
        customDateRange = range;
        selectedPeriod = 'Custom';
      });
    }
  }

  String get customDateLabel {
    if (customDateRange == null) return 'Custom';

    final start = customDateRange!.start;
    final end = customDateRange!.end;

    return '${start.day}/${start.month} - '
        '${end.day}/${end.month}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness ==
        Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Reports & Analytics',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Date filters
            _buildDateFilters(),

            const SizedBox(height: 24),

            _sectionTitle('Sales Overview'),

            const SizedBox(height: 12),

            // Summary cards
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.55,
              children: [
                _summaryCard(
                  title: 'Total Sales',
                  amount: 'Rs. 125,000',
                  icon: Icons.trending_up,
                  color: Colors.blue,
                  change: '+12.5%',
                ),
                _summaryCard(
                  title: 'Collected',
                  amount: 'Rs. 98,000',
                  icon: Icons.account_balance_wallet,
                  color: Colors.green,
                  change: '+8.2%',
                ),
                _summaryCard(
                  title: 'Outstanding',
                  amount: 'Rs. 27,000',
                  icon: Icons.pending_actions,
                  color: Colors.orange,
                  change: '21.6% of sales',
                ),
                _summaryCard(
                  title: 'Requests',
                  amount: '156',
                  icon: Icons.receipt_long,
                  color: Colors.purple,
                  change: '+18 requests',
                ),
              ],
            ),

            const SizedBox(height: 28),

            _sectionTitle('Sales Trend'),

            const SizedBox(height: 12),

            _buildSalesChart(isDark),

            const SizedBox(height: 28),

            _sectionTitle('Commission Breakdown'),

            const SizedBox(height: 12),

            _buildCommissionCard(isDark),

            const SizedBox(height: 28),

            _sectionTitle('Outstanding Payments'),

            const SizedBox(height: 4),

            Text(
              'Clients with pending payments',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),

            const SizedBox(height: 12),

            _buildUnpaidClients(isDark),

            const SizedBox(height: 28),

            _sectionTitle('Upcoming Expiries'),

            const SizedBox(height: 4),

            Text(
              'Connections expiring within the next 7 days',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),

            const SizedBox(height: 12),

            _buildUpcomingExpiries(isDark),

            const SizedBox(height: 28),

            _sectionTitle('Top Selling Packages'),

            const SizedBox(height: 12),

            _buildTopPackages(isDark),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // Date filters
  Widget _buildDateFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _dateChip('Today'),
          _dateChip('7 Days'),
          _dateChip('30 Days'),
          GestureDetector(
            onTap: selectCustomDate,
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 9,
              ),
              decoration: BoxDecoration(
                color: selectedPeriod == 'Custom'
                    ? primary
                    : Colors.grey.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_month,
                    size: 16,
                    color: selectedPeriod == 'Custom'
                        ? Colors.white
                        : null,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    selectedPeriod == 'Custom'
                        ? customDateLabel
                        : 'Custom',
                    style: TextStyle(
                      color: selectedPeriod == 'Custom'
                          ? Colors.white
                          : null,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dateChip(String label) {
    final selected = selectedPeriod == label;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedPeriod = label;
          customDateRange = null;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: selected
              ? primary
              : Colors.grey.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : null,
          ),
        ),
      ),
    );
  }

  // Section title
  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  // Summary card
  Widget _summaryCard({
    required String title,
    required String amount,
    required IconData icon,
    required Color color,
    required String change,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, size: 19, color: color),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  title,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            ],
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              amount,
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Text(
            change,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // Sales chart
  Widget _buildSalesChart(bool isDark) {
    final values = [35.0, 52.0, 42.0, 75.0, 60.0, 90.0, 70.0];

    return Container(
      height: 260,
      padding: const EdgeInsets.fromLTRB(12, 20, 16, 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Sales this week',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: BarChart(
              BarChartData(
                maxY: 100,
                alignment: BarChartAlignment.spaceAround,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const days = [
                          'Mon', 'Tue', 'Wed',
                          'Thu', 'Fri', 'Sat', 'Sun',
                        ];

                        final index = value.toInt();

                        if (index < 0 || index >= days.length) {
                          return const SizedBox();
                        }

                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            days[index],
                            style: const TextStyle(fontSize: 10),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barGroups: List.generate(
                  values.length,
                      (index) => BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: values[index],
                        color: primary,
                        width: 17,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Commission card
  Widget _buildCommissionCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        children: [
          _commissionRow(
            'Total Commission',
            'Rs. 8,750',
            Colors.blue,
            bold: true,
          ),
          const Divider(height: 24),
          _commissionRow(
            'Vendor Commission',
            'Rs. 6,250',
            Colors.green,
          ),
          const SizedBox(height: 14),
          _commissionRow(
            'Admin Commission',
            'Rs. 2,500',
            Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _commissionRow(
      String title,
      String amount,
      Color color, {
        bool bold = false,
      }) {
    return Row(
      children: [
        Container(
          height: 9,
          width: 9,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: bold ? 16 : 14,
          ),
        ),
      ],
    );
  }

  // Unpaid clients
  Widget _buildUnpaidClients(bool isDark) {
    return Column(
      children: unpaidClients.map((client) {
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Colors.grey.withValues(alpha: 0.15),
            ),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.orange.withValues(alpha: 0.12),
                child: const Icon(
                  Icons.person_outline,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      client['name'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      client['phone'],
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    Text(
                      '${client['days']} days overdue',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                'Rs. ${client['amount'].toStringAsFixed(0)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // Upcoming expiries
  Widget _buildUpcomingExpiries(bool isDark) {
    return Column(
      children: upcomingExpiries.map((item) {
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Colors.grey.withValues(alpha: 0.15),
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.notifications_active_outlined,
                color: Colors.blue,
                size: 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['name'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item['package'],
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                item['date'],
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.orange,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // Top packages
  Widget _buildTopPackages(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        children: List.generate(topPackages.length, (index) {
          final package = topPackages[index];

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      color: primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        package['name'],
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${package['count']} requests',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  'Rs. ${package['amount'].toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
