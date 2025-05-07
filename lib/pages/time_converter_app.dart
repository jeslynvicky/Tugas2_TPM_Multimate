import 'package:flutter/material.dart';

class TimeConverterPage extends StatefulWidget {
  const TimeConverterPage({Key? key}) : super(key: key);

  @override
  _TimeConverterPageState createState() => _TimeConverterPageState();
}

class _TimeConverterPageState extends State<TimeConverterPage> {
  final TextEditingController _controller = TextEditingController();
  double? _years;
  double? _months;
  int? _weeks;
  int? _days;
  int? _hours;
  int? _minutes;
  int? _seconds;
  String _error = '';

  final Color resultBoxColor = Color(0xFFd9e8ff);

  void _convertTime() {
    final input = _controller.text.trim();
    setState(() {
      _error = '';
      _years = null;
      _months = null;
      _weeks = null;
      _days = null;
      _hours = null;
      _minutes = null;
      _seconds = null;

      if (input.isEmpty) {
        _error = 'Input tidak boleh kosong';
        return;
      }

      if (RegExp(r'[a-zA-Z]').hasMatch(input)) {
        _error = 'Input mengandung huruf, masukkan input yang valid';
        return;
      }

      if (RegExp(r'[^\d\.\-]').hasMatch(input)) {
        _error =
            'Input mengandung simbol yang tidak valid. Hanya angka, titik, dan minus yang diperbolehkan.';
        return;
      }

      final digitOnly = input.replaceAll(RegExp(r'[^0-9]'), '');
      if (digitOnly.length > 15) {
        _error = 'Maksimum 15 digit angka yang diperbolehkan';
        return;
      }

      final parsed = double.tryParse(input);
      if (parsed == null) {
        _error = 'Masukkan angka valid';
        return;
      }

      final months = parsed * 12;
      final days = (parsed * 365).round();
      final weeks = (days / 7).round();
      final hours = days * 24;
      final minutes = hours * 60;
      final seconds = minutes * 60;

      _years = parsed;
      _months = months;
      _weeks = weeks;
      _days = days;
      _hours = hours;
      _minutes = minutes;
      _seconds = seconds;
    });
  }

  String _getDisplayValue(dynamic value) {
    if (value == null) return '-';
    if (value is double) return value.toStringAsFixed(2);
    return value.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                // Tombol back di pojok kiri atas
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      icon: Icon(Icons.arrow_back, color: Colors.white, size: 28),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ),
                
                // Judul dengan format yang sama seperti halaman jenis bilangan
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.access_time, color: Colors.white, size: 28),
                    SizedBox(width: 8),
                    Text(
                      "KONVERSI WAKTU",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 2.0,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 30),

                // Konten utama
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Input field dengan styling yang lebih baik
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Masukkan jumlah tahun:",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              TextField(
                                controller: _controller,
                                keyboardType: TextInputType.numberWithOptions(decimal: true),
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white.withOpacity(0.2),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 16,
                                  ),
                                  hintText: "Contoh: 1, 2.5, 0.25",
                                  hintStyle: TextStyle(
                                    color: Colors.white.withOpacity(0.5),
                                  ),
                                ),
                              ),
                              SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _convertTime,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: Color(0xFF6A11CB),
                                    padding: EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 5,
                                  ),
                                  child: Text(
                                    'KONVERSI',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // Error message
                        if (_error.isNotEmpty) ...[
                          Container(
                            margin: EdgeInsets.only(top: 16),
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.error_outline, color: Colors.white),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _error,
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        
                        // Results header
                        if (_years != null) ...[
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20.0),
                            child: Row(
                              children: [
                                Icon(Icons.check_circle, color: Colors.greenAccent),
                                SizedBox(width: 8),
                                Text(
                                  "HASIL KONVERSI",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          // Result boxes dengan styling yang lebih baik
                          _buildEnhancedResultBox('Tahun', _getDisplayValue(_years), Icons.calendar_today),
                          _buildEnhancedResultBox('Bulan', _getDisplayValue(_months), Icons.date_range),
                          _buildEnhancedResultBox('Minggu', _getDisplayValue(_weeks), Icons.view_week),
                          _buildEnhancedResultBox('Hari', _getDisplayValue(_days), Icons.today),
                          _buildEnhancedResultBox('Jam', _getDisplayValue(_hours), Icons.access_time),
                          _buildEnhancedResultBox('Menit', _getDisplayValue(_minutes), Icons.timer),
                          _buildEnhancedResultBox('Detik', _getDisplayValue(_seconds), Icons.hourglass_bottom),
                        ],
                        
                        // Space at bottom for scrolling
                        SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedResultBox(String label, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: resultBoxColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          )
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: Color(0xFF6A11CB), size: 24),
          SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Spacer(),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Color(0xFF6A11CB).withOpacity(0.3)),
            ),
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2575FC),
              ),
            ),
          ),
        ],
      ),
    );
  }
}