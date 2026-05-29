import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:agrobravo/core/tokens/app_colors.dart';
import 'package:agrobravo/core/tokens/app_spacing.dart';
import 'package:agrobravo/core/tokens/app_text_styles.dart';
import 'package:agrobravo/core/utils/phone_countries.dart';

class PhoneField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final PhoneCountry initialCountry;
  final ValueChanged<PhoneCountry>? onCountryChanged;
  final bool hasError;
  final bool isMandatory;

  const PhoneField({
    super.key,
    required this.controller,
    required this.label,
    this.initialCountry = kDefaultPhoneCountry,
    this.onCountryChanged,
    this.hasError = false,
    this.isMandatory = false,
  });

  @override
  State<PhoneField> createState() => _PhoneFieldState();
}

class _PhoneFieldState extends State<PhoneField> {
  late PhoneCountry _country;
  late MaskTextInputFormatter _mask;

  @override
  void initState() {
    super.initState();
    _country = widget.initialCountry;
    _mask = _buildMask(_country.mask);
  }

  MaskTextInputFormatter _buildMask(String pattern) {
    return MaskTextInputFormatter(
      mask: pattern,
      filter: {'#': RegExp(r'[0-9]')},
      type: MaskAutoCompletionType.lazy,
    );
  }

  void _selectCountry(PhoneCountry country) {
    setState(() {
      _country = country;
      _mask = _buildMask(country.mask);
      widget.controller.clear();
    });
    widget.onCountryChanged?.call(country);
  }

  void _openPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CountryPickerSheet(
        selected: _country,
        onSelect: (c) {
          Navigator.pop(context);
          _selectCountry(c);
        },
      ),
    );
  }

  InputBorder _border(BuildContext context, {bool focused = false, bool hasError = false}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: hasError 
            ? AppColors.error 
            : focused 
                ? AppColors.primary 
                : Theme.of(context).dividerColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fillColor = Theme.of(context).brightness == Brightness.dark
        ? Theme.of(context).colorScheme.surface
        : const Color(0xFFFAFAFA);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              text: widget.label,
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              children: [
                if (widget.isMandatory)
                  const TextSpan(
                    text: ' *',
                    style: TextStyle(color: AppColors.error),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: _openPicker,
                child: Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: fillColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: widget.hasError ? AppColors.error : Theme.of(context).dividerColor),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CountryFlag.fromCountryCode(
                        _country.code,
                        theme: const ImageTheme(width: 28, height: 18, shape: RoundedRectangle(3)),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _country.dialCode,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 2),
                      Icon(
                        Icons.arrow_drop_down_rounded,
                        size: 20,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.5),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [_mask],
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: fillColor,
                    hintText: _country.mask.replaceAll('#', '0'),
                    hintStyle: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.3),
                      fontSize: 13,
                    ),
                    border: _border(context, hasError: widget.hasError),
                    enabledBorder: _border(context, hasError: widget.hasError),
                    focusedBorder: _border(context, focused: true, hasError: widget.hasError),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CountryPickerSheet extends StatefulWidget {
  final PhoneCountry selected;
  final ValueChanged<PhoneCountry> onSelect;

  const _CountryPickerSheet({
    required this.selected,
    required this.onSelect,
  });

  @override
  State<_CountryPickerSheet> createState() => _CountryPickerSheetState();
}

class _CountryPickerSheetState extends State<_CountryPickerSheet> {
  final _searchCtrl = TextEditingController();
  List<PhoneCountry> _list = kPhoneCountries;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _filter(String q) {
    final lower = q.toLowerCase();
    setState(() {
      _list = kPhoneCountries
          .where((c) =>
              c.name.toLowerCase().contains(lower) ||
              c.dialCode.contains(q))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bg = Theme.of(context).colorScheme.surface;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Container(
      height: MediaQuery.of(context).size.height * 0.72,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Theme.of(context).dividerColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchCtrl,
              onChanged: _filter,
              style: TextStyle(color: onSurface),
              decoration: InputDecoration(
                hintText: 'Buscar país ou código...',
                hintStyle: TextStyle(
                  color: onSurface.withValues(alpha: 0.5),
                ),
                prefixIcon: Icon(Icons.search, color: onSurface.withValues(alpha: 0.5)),
                filled: true,
                fillColor: Theme.of(context).brightness == Brightness.dark
                    ? Theme.of(context).colorScheme.surface
                    : const Color(0xFFF0F0F0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _list.length,
              itemBuilder: (context, i) {
                final c = _list[i];
                final isSelected =
                    c.name == widget.selected.name &&
                    c.dialCode == widget.selected.dialCode;
                return ListTile(
                  leading: CountryFlag.fromCountryCode(
                    c.code,
                    theme: const ImageTheme(width: 36, height: 24, shape: RoundedRectangle(3)),
                  ),
                  title: Text(
                    c.name,
                    style: TextStyle(
                      color: onSurface,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  trailing: Text(
                    c.dialCode,
                    style: TextStyle(
                      color: isSelected
                          ? AppColors.primary
                          : onSurface.withValues(alpha: 0.5),
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  selected: isSelected,
                  selectedTileColor: AppColors.primary.withValues(alpha: 0.08),
                  onTap: () => widget.onSelect(c),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
