enum ImportStage { idle, preparingSource, importing, completed, error }

class ImportProgress {
  final ImportStage stage;
  final int processedBytes;
  final int totalBytes;
  final int importedCount;
  final String message;

  const ImportProgress({this.stage = ImportStage.idle, this.processedBytes = 0, this.totalBytes = 0, this.importedCount = 0, this.message = ''});

  double get fraction => totalBytes <= 0 ? 0.0 : (processedBytes / totalBytes).clamp(0.0, 1.0);
  int get percent => (fraction * 100).toInt();
}
