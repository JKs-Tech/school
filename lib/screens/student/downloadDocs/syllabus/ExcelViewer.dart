import 'dart:io';

import 'package:flutter/material.dart';
import 'package:excel/excel.dart';
import 'package:http/http.dart' as http;
import 'package:infixedu/utils/Utils.dart';
import 'package:path_provider/path_provider.dart';

class ExcelViewerScreen extends StatefulWidget {
  final String title;
  final String fileUrl;

  const ExcelViewerScreen({
    super.key,
    required this.title,
    required this.fileUrl,
  });

  @override
  State<ExcelViewerScreen> createState() => _ExcelViewerScreenState();
}

class _ExcelViewerScreenState extends State<ExcelViewerScreen> {
  List<List<String>> excelData = [];
  bool isLoading = true;
  String errorMessage = '';
  List<String> sheetNames = [];
  String currentSheet = '';

  @override
  void initState() {
    super.initState();
    loadExcelFile();
  }

  Future<void> loadExcelFile() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = '';
      });

      // Download the file
      final response = await http.get(Uri.parse(widget.fileUrl));
      if (response.statusCode != 200) {
        throw Exception('Failed to download file');
      }

      // Parse Excel file
      var excel = Excel.decodeBytes(response.bodyBytes);

      // Get sheet names
      sheetNames = excel.tables.keys.toList();
      if (sheetNames.isEmpty) {
        throw Exception('No sheets found in Excel file');
      }

      currentSheet = sheetNames.first;
      loadSheetData(excel, currentSheet);
    } catch (e) {
      setState(() {
        errorMessage = 'Error loading Excel file: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  void loadSheetData(Excel excel, String sheetName) {
    try {
      List<List<String>> data = [];
      var table = excel.tables[sheetName];

      if (table != null) {
        for (var row in table.rows) {
          List<String> rowData = [];
          for (var cell in row) {
            String cellValue = '';
            if (cell?.value != null) {
              cellValue = cell!.value.toString();
            }
            rowData.add(cellValue);
          }
          // Only add rows that have at least one non-empty cell
          if (rowData.any((cell) => cell.isNotEmpty)) {
            data.add(rowData);
          }
        }
      }

      setState(() {
        excelData = data;
        currentSheet = sheetName;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error parsing sheet data: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          widget.title,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        actions:
            sheetNames.length > 1
                ? [
                  PopupMenuButton<String>(
                    icon: Icon(Icons.layers),
                    onSelected: (sheetName) {
                      // Reload excel and switch sheet
                      loadExcelFile().then((_) {
                        if (!isLoading && errorMessage.isEmpty) {
                          try {
                            var excel = Excel.decodeBytes([]);
                            // This is a simplified approach - in real implementation,
                            // you'd want to cache the excel object
                            loadExcelFile();
                          } catch (e) {
                            // Handle error
                          }
                        }
                      });
                    },
                    itemBuilder:
                        (context) =>
                            sheetNames
                                .map(
                                  (sheetName) => PopupMenuItem<String>(
                                    value: sheetName,
                                    child: Text(sheetName),
                                  ),
                                )
                                .toList(),
                  ),
                ]
                : null,
      ),
      body:
          isLoading
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text(
                      'Loading Excel file...',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                  ],
                ),
              )
              : errorMessage.isNotEmpty
              ? Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red[400],
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Unable to load Excel file',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        errorMessage,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: loadExcelFile,
                        icon: Icon(Icons.refresh),
                        label: Text('Retry'),
                      ),
                    ],
                  ),
                ),
              )
              : excelData.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.table_chart_outlined,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No data found',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'This Excel file appears to be empty',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              )
              : Column(
                children: [
                  // Sheet info header
                  if (sheetNames.length > 1)
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      color: Colors.blue[50],
                      child: Row(
                        children: [
                          Icon(Icons.layers, size: 16, color: Colors.blue[700]),
                          SizedBox(width: 8),
                          Text(
                            'Sheet: $currentSheet',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.blue[700],
                            ),
                          ),
                          Spacer(),
                          Text(
                            '${sheetNames.length} sheets available',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  // Excel data table
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SingleChildScrollView(
                        child: DataTable(
                          border: TableBorder.all(
                            color: Colors.grey[300]!,
                            width: 1,
                          ),
                          headingRowHeight: 0, // Hide header row
                          dataRowMinHeight: 40,
                          dataRowMaxHeight: 60,
                          columnSpacing: 12,
                          columns:
                              excelData.isNotEmpty
                                  ? List.generate(
                                    excelData.first.length,
                                    (index) => DataColumn(label: Text('')),
                                  )
                                  : [DataColumn(label: Text(''))],
                          rows:
                              excelData.asMap().entries.map((entry) {
                                int rowIndex = entry.key;
                                List<String> row = entry.value;

                                return DataRow(
                                  color:
                                      WidgetStateProperty.resolveWith<Color?>((
                                        Set<WidgetState> states,
                                      ) {
                                        if (rowIndex == 0) {
                                          return Colors.blue[100]; // Header row
                                        }
                                        return rowIndex.isEven
                                            ? Colors.grey[50]
                                            : Colors.white;
                                      }),
                                  cells:
                                      row
                                          .map(
                                            (cellData) => DataCell(
                                              Container(
                                                constraints: BoxConstraints(
                                                  minWidth: 80,
                                                  maxWidth: 200,
                                                ),
                                                child: Text(
                                                  cellData,
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight:
                                                        rowIndex == 0
                                                            ? FontWeight.w600
                                                            : FontWeight.normal,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 2,
                                                ),
                                              ),
                                            ),
                                          )
                                          .toList(),
                                );
                              }).toList(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
    );
  }
}
