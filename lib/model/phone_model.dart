class PhoneModel {
  String model;
  String brand;
  List<int> storage; // List of available storage options (GB)
  int memory; // RAM in GB
  String processor;
  int batteryCapacity; // Battery in mAh
  List<String> colors;
  List<double> size; // [height, width] in inches or mm
  List<double> price; // Corresponding prices for each storage option
  String imageUrl; // URL for product image
  String websiteUrl; // Official website or store link

  PhoneModel({
    required this.model,
    required this.brand,
    required this.storage,
    required this.memory,
    required this.processor,
    required this.batteryCapacity,
    required this.colors,
    required this.size,
    required this.price,
    required this.imageUrl,
    required this.websiteUrl,
  }) : assert(storage.length == price.length,
            "Storage and Price lists must have the same length.");
}
