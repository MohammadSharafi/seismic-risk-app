import 'package:flutter/material.dart';
import '../../domain/entities/procedure.dart';
import '../widgets/evidence_chip.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../theme/app_theme.dart';
import '../theme/tailwind_spacing.dart';
import '../utils/svg_icons.dart';

class ProcedureCard extends StatelessWidget {
  final Procedure procedure;
  final bool isEditing;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final void Function(Procedure)? onSave;
  final VoidCallback? onCancel;

  const ProcedureCard({
    super.key,
    required this.procedure,
    this.isEditing = false,
    required this.onEdit,
    required this.onDelete,
    this.onSave,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    if (isEditing) {
      return _ProcedureEditCard(
        procedure: procedure,
        onSave: onSave ?? (p) {},
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
                          procedure.name,
                          style: const TextStyle(
                            fontSize: TailwindFontSize.textSm, // text-sm = 14px
                            fontWeight: FontWeight.w600,
                            color: AppTheme.gray900,
                            height: 1.5,
                            letterSpacing: 0,
                          ),
                        ),
                        if (procedure.source == ProcedureSource.clinicianAdded) ...[
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
                    if (procedure.timing != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        procedure.timing!,
                        style: const TextStyle(
                          fontSize: TailwindFontSize.textSm, // text-sm = 14px
                          color: AppTheme.gray700,
                          height: 1.5,
                          letterSpacing: 0,
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Text(
                      procedure.rationale,
                      style: const TextStyle(
                        fontSize: TailwindFontSize.textSm, // text-sm = 14px
                        color: AppTheme.gray600,
                        height: 1.5,
                        letterSpacing: 0,
                      ),
                    ),
                    if (procedure.evidenceReferences.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: procedure.evidenceReferences.map((evidence) {
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

class _ProcedureEditCard extends StatefulWidget {
  final Procedure procedure;
  final void Function(Procedure) onSave;
  final VoidCallback onCancel;

  const _ProcedureEditCard({
    required this.procedure,
    required this.onSave,
    required this.onCancel,
  });

  @override
  State<_ProcedureEditCard> createState() => _ProcedureEditCardState();
}

class _ProcedureEditCardState extends State<_ProcedureEditCard> {
  late TextEditingController _nameController;
  late TextEditingController _timingController;
  late TextEditingController _rationaleController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.procedure.name);
    _timingController = TextEditingController(text: widget.procedure.timing ?? '');
    _rationaleController = TextEditingController(text: widget.procedure.rationale);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _timingController.dispose();
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
              labelText: 'Procedure Name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _timingController,
            decoration: const InputDecoration(
              labelText: 'Timing (optional)',
              border: OutlineInputBorder(),
            ),
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
                  widget.onSave(widget.procedure.copyWith(
                    name: _nameController.text,
                    timing: _timingController.text.isEmpty
                        ? null
                        : _timingController.text,
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
