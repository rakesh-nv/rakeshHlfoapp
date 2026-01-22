import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/chef/Earning_service.dart';

class EarningScreen extends StatefulWidget {
  const EarningScreen({super.key});

  @override
  State<EarningScreen> createState() => _EarningScreenState();
}
class _EarningScreenState extends State<EarningScreen> {
  final EarningService _earningService = EarningService();
  String? _chefId;
  DateTime _selectedDate =
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  String _selectedView = 'Daily'; // 'Daily' or 'Monthly'

  double _currentDailyEarnings = 0.0;
  double _currentMonthlyEarnings = 0.0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeChefIdAndFetchEarnings();
  }

  Future<void> _initializeChefIdAndFetchEarnings() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      setState(() {
        _chefId = user.id;
      });
      await _fetchEarnings();
    } else {
      // Handle case where user is not logged in
      setState(() {
        _isLoading = false;
      });
      // Potentially navigate to login or show an error
    }
  }

  Future<void> _fetchEarnings() async {
    if (_chefId == null) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    if (_selectedView == 'Daily') {
      _currentDailyEarnings =
          await _earningService.getDailyEarnings(_chefId!, _selectedDate);
    } else {
      _currentMonthlyEarnings =
          await _earningService.getMonthlyEarnings(_chefId!, _selectedDate);
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = DateTime(
            picked.year, picked.month, picked.day); // Normalize to midnight
      });
      await _fetchEarnings();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Restaurant Earnings'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final isLargeScreen = constraints.maxWidth > 600;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildResponsiveHeader(isLargeScreen),
                          const SizedBox(height: 20),
                          Expanded(
                            child: _selectedView == 'Daily'
                                ? _buildDailyEarnings(_currentDailyEarnings)
                                : _buildMonthlyEarnings(
                                    _currentMonthlyEarnings),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildResponsiveHeader(bool isLargeScreen) {
    return isLargeScreen
        ? Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Selected Date: ${DateFormat(_selectedView == 'Daily' ? 'yyyy-MM-dd' : 'MMMM yyyy').format(_selectedDate)}',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  DropdownButton<String>(
                    value: _selectedView,
                    onChanged: (String? newValue) async {
                      setState(() {
                        _selectedView = newValue!;
                      });
                      await _fetchEarnings();
                    },
                    items: <String>['Daily', 'Monthly']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                  IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () => _selectDate(context),
                  ),
                ],
              ),
            ],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Selected Date: ${DateFormat(_selectedView == 'Daily' ? 'yyyy-MM-dd' : 'MMMM yyyy').format(_selectedDate)}',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  DropdownButton<String>(
                    value: _selectedView,
                    onChanged: (String? newValue) async {
                      setState(() {
                        _selectedView = newValue!;
                      });
                      await _fetchEarnings();
                    },
                    items: <String>['Daily', 'Monthly']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                  IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () => _selectDate(context),
                  ),
                ],
              ),
            ],
          );
  }

  Widget _buildDailyEarnings(double earnings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Earnings for ${DateFormat('yyyy-MM-dd').format(_selectedDate)}:',
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 10),
        Text(
          '\$${earnings.toStringAsFixed(2)}',
          style: const TextStyle(
              fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green),
        ),
      ],
    );
  }

  Widget _buildMonthlyEarnings(double earnings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Earnings for ${DateFormat('MMMM yyyy').format(_selectedDate)}:',
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 10),
        Text(
          '\$${earnings.toStringAsFixed(2)}',
          style: const TextStyle(
              fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green),
        ),
      ],
    );
  }
}
