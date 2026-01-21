import 'package:flutter/material.dart';
import '../../domain/entities/medication.dart';
import '../widgets/evidence_chip.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../theme/app_theme.dart';
import '../theme/tailwind_spacing.dart';
import '../utils/svg_icons.dart';

class MedicationCard extends StatelessWidget {
  final Medication medication;
  final bool isEditing;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final void Function(Medication)? onSave;
  final VoidCallback? onCancel;

  const MedicationCard({
    super.key,
    required this.medication,
    this.isEditing = false,
    required this.onEdit,
    required this.onDelete,
    this.onSave,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    if (isEditing) {
      return _MedicationEditCard(
        medication: medication,
        onSave: onSave ?? (m) {},
        onCancel: onCancel ?? () {},
      );
    }

    return Container(
      padding: const EdgeInsets.all(12), // p-3
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppTheme.gray200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          medication.name,
                          style: const TextStyle(
                            fontSize: TailwindFontSize.textSm, // text-sm = 14px
                            fontWeight: FontWeight.w600,
                            color: AppTheme.gray900,
                            height: 1.5,
                            letterSpacing: 0,
                          ),
                        ),
                        if (medication.source == MedicationSource.clinicianAdded) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.blue50,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'Clinician-added',
                              style: TextStyle(
                                fontSize: TailwindFontSize.textXs, // text-xs = 12px
                                fontWeight: FontWeight.w500,
                                color: AppTheme.blue700,
                                height: 1.5,
                                letterSpacing: 0,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${medication.dose} ${medication.route}, ${medication.frequency}'
                      '${medication.duration != null ? ', ${medication.duration}' : ''}',
                      style: const TextStyle(
                        fontSize: TailwindFontSize.textSm, // text-sm = 14px
                        color: AppTheme.gray700,
                        height: 1.5,
                        letterSpacing: 0,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      medication.rationale,
                      style: const TextStyle(
                        fontSize: TailwindFontSize.textSm, // text-sm = 14px
                        color: AppTheme.gray600,
                        height: 1.5,
                        letterSpacing: 0,
                      ),
                    ),
                    if (medication.evidenceReferences.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: medication.evidenceReferences.map((evidence) {
                          return EvidenceChip(evidence: evidence);
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
              Column(
                children: [
                  IconButton(
                    icon: SvgIcons.edit(size: 16, color: AppTheme.blue600),
                    onPressed: onEdit,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(height: 4),
                  IconButton(
                    icon: SvgIcons.trash2(size: 16, color: AppTheme.red600),
                    onPressed: onDelete,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MedicationEditCard extends StatefulWidget {
  final Medication medication;
  final void Function(Medication) onSave;
  final VoidCallback onCancel;

  const _MedicationEditCard({
    required this.medication,
    required this.onSave,
    required this.onCancel,
  });

  @override
  State<_MedicationEditCard> createState() => _MedicationEditCardState();
}

class _MedicationEditCardState extends State<_MedicationEditCard> {
  late TextEditingController _nameController;
  late TextEditingController _doseController;
  late TextEditingController _routeController;
  late TextEditingController _frequencyController;
  late TextEditingController _durationController;
  late TextEditingController _rationaleController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.medication.name);
    _doseController = TextEditingController(text: widget.medication.dose);
    _routeController = TextEditingController(text: widget.medication.route);
    _frequencyController = TextEditingController(text: widget.medication.frequency);
    _durationController = TextEditingController(text: widget.medication.duration ?? '');
    _rationaleController = TextEditingController(text: widget.medication.rationale);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _doseController.dispose();
    _routeController.dispose();
    _frequencyController.dispose();
    _durationController.dispose();
    _rationaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12), // p-3
      decoration: BoxDecoration(
        color: AppTheme.blue50,
        border: Border.all(color: AppTheme.blue200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Medication Name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _doseController,
                  decoration: const InputDecoration(
                    labelText: 'Dose',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _routeController,
                  decoration: const InputDecoration(
                    labelText: 'Route',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _frequencyController,
                  decoration: const InputDecoration(
                    labelText: 'Frequency',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _durationController,
                  decoration: const InputDecoration(
                    labelText: 'Duration (optional)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _rationaleController,
            maxLines: 2,
            decoration: const InputDecoration(
              labelText: 'Rationale',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: widget.onCancel,
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  widget.onSave(widget.medication.copyWith(
                    name: _nameController.text,
                    dose: _doseController.text,
                    route: _routeController.text,
                    frequency: _frequencyController.text,
                    duration: _durationController.text.isEmpty
                        ? null
                        : _durationController.text,
                    rationale: _rationaleController.text,
                  ));
                },
                child: const Text('Save changes'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
