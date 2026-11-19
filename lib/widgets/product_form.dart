import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../theme/app_theme.dart';
import 'common.dart';

/// One form for both "Add product" and "Edit product".
/// Pass [initial] to pre-fill it when editing.
class ProductForm extends StatefulWidget {
  final dynamic initial;
  final String submitLabel;
  final RxBool busy;
  final void Function(
    String name,
    String description,
    double price,
    int stock,
    String? imageUrl,
  )
  onSubmit;

  const ProductForm({
    super.key,
    this.initial,
    required this.submitLabel,
    required this.busy,
    required this.onSubmit,
  });

  @override
  State<ProductForm> createState() => _ProductFormState();
}

class _ProductFormState extends State<ProductForm> {
  late final TextEditingController _name;
  late final TextEditingController _description;
  late final TextEditingController _price;
  late final TextEditingController _stock;
  late final TextEditingController _image;
  final FocusNode _imageFocus = FocusNode();
  String _previewUrl = '';

  @override
  void initState() {
    super.initState();
    final p = widget.initial;
    _name = TextEditingController(text: p?['name']?.toString() ?? '');
    _description = TextEditingController(
      text: p?['description']?.toString() ?? '',
    );
    _price = TextEditingController(
      text: p == null ? '' : plainNumber(p['price'] as num),
    );
    _stock = TextEditingController(
      text: p == null ? '' : (p['stock'] as num).toInt().toString(),
    );
    _image = TextEditingController(text: p?['imageUrl']?.toString() ?? '');
    _previewUrl = _image.text.trim();

    // Update the preview when the user leaves the link box.
    _imageFocus.addListener(() {
      if (!_imageFocus.hasFocus) _refreshPreview();
    });
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _price.dispose();
    _stock.dispose();
    _image.dispose();
    _imageFocus.dispose();
    super.dispose();
  }

  void _refreshPreview() {
    final link = _image.text.trim();
    if (link != _previewUrl) setState(() => _previewUrl = link);
  }

  bool _isWebLink(String link) {
    final uri = Uri.tryParse(link);
    return uri != null &&
        uri.host.isNotEmpty &&
        (uri.scheme == 'http' || uri.scheme == 'https');
  }

  void _submit() {
    final name = _name.text.trim();
    final description = _description.text.trim();
    final price = double.tryParse(_price.text.trim().replaceAll(',', ''));
    final stock = int.tryParse(_stock.text.trim());
    final link = _image.text.trim();

    if (name.length < 2) {
      showMsg('Check the name', 'Give your product a name.', error: true);
      return;
    }
    if (description.isEmpty) {
      showMsg('Check the description', 'Add a short description.', error: true);
      return;
    }
    if (price == null || price < 0) {
      showMsg('Check the price', 'Enter a number like 49.99.', error: true);
      return;
    }
    if (stock == null || stock < 0) {
      showMsg('Check the stock', 'Enter a whole number like 10.', error: true);
      return;
    }
    if (link.isNotEmpty && !_isWebLink(link)) {
      showMsg(
        'Check the photo link',
        'It must start with http:// or https://',
        error: true,
      );
      return;
    }

    widget.onSubmit(
      name,
      description,
      price,
      stock,
      link.isEmpty ? null : link,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ----- photo preview -----
        SizedBox(
          height: 190,
          width: double.infinity,
          child: ProductImage(url: _previewUrl, radius: 22, iconSize: 56),
        ),
        const SizedBox(height: 8),
        const Text(
          'This is how the photo will look on the product card.',
          style: TextStyle(color: AppColors.muted, fontSize: 12),
        ),
        const SizedBox(height: 20),

        AppTextField(
          controller: _name,
          label: 'Product name',
          icon: Icons.inventory_2_outlined,
        ),
        const SizedBox(height: 14),
        AppTextField(
          controller: _description,
          label: 'Description',
          icon: Icons.notes_outlined,
          maxLines: 3,
        ),
        const SizedBox(height: 14),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: AppTextField(
                controller: _price,
                label: 'Price (\$)',
                icon: Icons.attach_money,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppTextField(
                controller: _stock,
                label: 'Stock',
                icon: Icons.warehouse_outlined,
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        AppTextField(
          controller: _image,
          focusNode: _imageFocus,
          label: 'Photo link (optional)',
          icon: Icons.image_outlined,
          helper: 'Paste a link that starts with https://',
          keyboardType: TextInputType.url,
          onSubmitted: (_) => _refreshPreview(),
          suffix: IconButton(
            tooltip: 'Show preview',
            icon: const Icon(Icons.refresh, color: AppColors.teal),
            onPressed: _refreshPreview,
          ),
        ),
        const SizedBox(height: 24),
        Obx(
          () => PrimaryButton(
            label: widget.submitLabel,
            icon: Icons.check,
            loading: widget.busy.value,
            onPressed: _submit,
          ),
        ),
      ],
    );
  }
}
