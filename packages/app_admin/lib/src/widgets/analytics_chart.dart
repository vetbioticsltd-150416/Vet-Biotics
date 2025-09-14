import 'package:flutter/material.dart';

class AnalyticsChart extends StatelessWidget {
  final List<dynamic> data;
  final String dataKey;
  final String labelKey;
  final Color color;

  const AnalyticsChart({
    super.key,
    required this.data,
    required this.dataKey,
    required this.labelKey,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(child: Text('No data available'));
    }

    // Find max value for scaling
    final maxValue = data.map((item) => item[dataKey] as num).reduce((a, b) => a > b ? a : b);

    return Column(
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: data.map((item) {
              final value = item[dataKey] as num;
              final label = item[labelKey] as String;
              final height = maxValue > 0 ? (value / maxValue) * 150 : 0;

              return Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(value.toString(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 4),
                    Container(
                      width: 30,
                      height: height.toDouble(),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(label, style: const TextStyle(fontSize: 10), textAlign: TextAlign.center),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
