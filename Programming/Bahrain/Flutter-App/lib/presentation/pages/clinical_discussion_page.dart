import 'package:flutter/material.dart';
import '../../domain/entities/patient.dart';
import '../widgets/risk_badge.dart';
import '../widgets/custom_text_field.dart';
import '../utils/svg_icons.dart';
import '../theme/app_theme.dart';
import '../theme/tailwind_spacing.dart';
import '../utils/lucide_icons.dart';

class ClinicalDiscussionPage extends StatefulWidget {
  final Patient patient;
  final String? visitId;
  final VoidCallback? onClose;
  final Function(String)? onViewVisit;

  const ClinicalDiscussionPage({
    super.key,
    required this.patient,
    this.visitId,
    this.onClose,
    this.onViewVisit,
  });

  @override
  State<ClinicalDiscussionPage> createState() => _ClinicalDiscussionPageState();
}

class _ClinicalDiscussionPageState extends State<ClinicalDiscussionPage> {
  final List<Map<String, dynamic>> _messages = [
    {
      'id': 'M001',
      'speaker': 'doctor',
      'speakerName': 'Dr. Rebecca Smith',
      'speakerRole': 'Cardiology',
      'timestamp': 'Jan 8, 2026 10:30 AM',
      'content': 'Patient presents with elevated BP trends over past week. Considering medication adjustment.',
      'messageType': 'text',
      'references': [
        {'type': 'vitals', 'label': 'BP Readings - Jan 1-8'}
      ]
    },
    {
      'id': 'M002',
      'speaker': 'ai',
      'speakerName': 'AI Clinical Assistant',
      'timestamp': 'Jan 8, 2026 10:32 AM',
      'content': 'Based on the vitals data, I\'ve detected a consistent upward trend in systolic BP (+12 mmHg over 7 days). Current average: 142/88. This exceeds target range for patients with diabetes and AFib.',
      'messageType': 'explanation',
      'references': [
        {'type': 'vitals', 'label': 'BP Trend Analysis'}
      ]
    },
    {
      'id': 'M003',
      'speaker': 'doctor',
      'speakerName': 'Dr. Rebecca Smith',
      'speakerRole': 'Cardiology',
      'timestamp': 'Jan 8, 2026 10:35 AM',
      'content': 'What about renal function? I want to make sure we\'re safe to increase ACE inhibitor.',
      'messageType': 'text'
    },
    {
      'id': 'M004',
      'speaker': 'ai',
      'speakerName': 'AI Clinical Assistant',
      'timestamp': 'Jan 8, 2026 10:36 AM',
      'content': 'Latest creatinine from Jan 5 is 1.3 mg/dL (baseline 1.2). eGFR is 58 mL/min (Stage 3a CKD - stable). No significant change from previous values. ACE inhibitor adjustment should be monitored but appears feasible.',
      'messageType': 'data-reference',
      'references': [
        {'type': 'labs', 'label': 'Renal Panel - Jan 5'},
        {'type': 'labs', 'label': 'Historical Creatinine Trend'}
      ]
    },
  ];

  final TextEditingController _messageController = TextEditingController();
  String _messageMode = 'ask-ai';

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_messageController.text.trim().isEmpty) return;

    setState(() {
      final newId = 'M${(_messages.length + 1).toString().padLeft(3, '0')}';
      _messages.add({
        'id': newId,
        'speaker': _messageMode == 'ask-ai' ? 'doctor' : 'doctor',
        'speakerName': 'Dr. Rebecca Smith',
        'speakerRole': 'Cardiology',
        'timestamp': DateTime.now().toString().substring(0, 16),
        'content': _messageController.text,
        'messageType': 'text',
      });
      _messageController.clear();

      if (_messageMode == 'ask-ai') {
        // Simulate AI response
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            setState(() {
              final aiId = 'M${(_messages.length + 1).toString().padLeft(3, '0')}';
              _messages.add({
                'id': aiId,
                'speaker': 'ai',
                'speakerName': 'AI Clinical Assistant',
                'timestamp': DateTime.now().toString().substring(0, 16),
                'content': 'Based on the patient data, I can provide clinical context and evidence-based suggestions. What specific aspect would you like me to analyze?',
                'messageType': 'explanation',
              });
            });
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isModal = widget.onClose != null;
    final currentVisitId = widget.visitId ?? 'V-2026-001';

    Widget content = Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          _buildHeader(currentVisitId, isModal),
          Expanded(child: _buildMessagesList()),
          _buildInputArea(currentVisitId),
        ],
      ),
    );

    if (isModal) {
      return Material(
        color: Colors.black54,
        child: Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            constraints: const BoxConstraints(maxWidth: 896, maxHeight: 810),
            child: content,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.gray50,
      body: content,
    );
  }

  Widget _buildHeader(String visitId, bool isModal) {
    return Container(
      padding: EdgeInsets.all(isModal ? TailwindSpacing.p4 : TailwindSpacing.p4), // p-4 (further reduced)
      decoration: isModal
          ? const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppTheme.gray200)),
            )
          : null,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Clinical Discussion (AI & Doctor)',
                      style: TextStyle(
                        fontSize: TailwindFontSize.text2xl,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.gray900,
                      ),
                    ),
                    SizedBox(height: TailwindSpacing.mb2),
                    const Text(
                      'Structured clinical reasoning and collaborative analysis',
                      style: TextStyle(
                        fontSize: TailwindFontSize.textSm,
                        color: AppTheme.gray600,
                      ),
                    ),
                  ],
                ),
              ),
              if (isModal)
                IconButton(
                  onPressed: widget.onClose,
                  icon: SvgIcons.x(size: 24, color: AppTheme.gray400),
                  color: AppTheme.gray400,
                ),
            ],
          ),
          SizedBox(height: TailwindSpacing.mb4),
          Container(
            padding: const EdgeInsets.all(TailwindSpacing.p4),
            decoration: BoxDecoration(
              color: AppTheme.blue50,
              border: Border.all(color: AppTheme.blue200),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Patient',
                          style: TextStyle(
                            fontSize: TailwindFontSize.textSm,
                            color: AppTheme.blue700,
                          ),
                        ),
                        Text(
                          widget.patient.name,
                          style: const TextStyle(
                            fontSize: TailwindFontSize.textSm,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.blue900,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      width: 1,
                      height: 32,
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      color: AppTheme.blue200,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Visit ID',
                          style: TextStyle(
                            fontSize: TailwindFontSize.textSm,
                            color: AppTheme.blue700,
                          ),
                        ),
                        Text(
                          visitId,
                          style: const TextStyle(
                            fontSize: TailwindFontSize.textSm,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.blue900,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      width: 1,
                      height: 32,
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      color: AppTheme.blue200,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Current Risk Tier',
                          style: TextStyle(
                            fontSize: TailwindFontSize.textSm,
                            color: AppTheme.blue700,
                          ),
                        ),
                        RiskBadge(tier: widget.patient.riskTier, size: BadgeSize.sm),
                      ],
                    ),
                  ],
                ),
                if (widget.onViewVisit != null)
                  TextButton.icon(
                    onPressed: () => widget.onViewVisit!(visitId),
                    icon: SvgIcons.externalLink(size: 16, color: AppTheme.blue600),
                    label: const Text(
                      'View related visit',
                      style: TextStyle(
                        fontSize: TailwindFontSize.textXs, // text-xs = 12px
                        fontWeight: FontWeight.w500, // font-medium
                        height: 1.5,
                        letterSpacing: 0,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.blue600,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), // px-3 py-1.5
                      minimumSize: const Size(0, 32), // h-8 = 32px
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(height: TailwindSpacing.mb4),
          Container(
            padding: const EdgeInsets.all(TailwindSpacing.p3),
            decoration: BoxDecoration(
              color: AppTheme.amber50,
              border: Border.all(color: AppTheme.amber200),
              borderRadius: BorderRadius.circular(4),
            ),
            child: RichText(
              text: const TextSpan(
                style: TextStyle(
                  fontSize: TailwindFontSize.textSm,
                  color: AppTheme.amber900,
                ),
                children: [
                  TextSpan(
                    text: 'AI Assistant Notice: ',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(
                    text: 'AI responses are assistive and explanatory only. The AI cannot change patient state, finalize decisions, or override doctor input. All clinical decisions require physician validation.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesList() {
    return ListView.builder(
      padding: EdgeInsets.all(widget.onClose != null ? TailwindSpacing.p4 : TailwindSpacing.p4), // p-4 (further reduced)
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        final isAI = message['speaker'] == 'ai';
        return Padding(
          padding: EdgeInsets.only(bottom: TailwindSpacing.mb4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isAI ? AppTheme.purple100 : AppTheme.blue100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isAI ? LucideIcons.brain : LucideIcons.user,
                  size: 20,
                  color: isAI ? AppTheme.purple600 : AppTheme.blue600,
                ),
              ),
              SizedBox(width: TailwindSpacing.gap3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          message['speakerName'] as String,
                          style: TextStyle(
                            fontSize: TailwindFontSize.textSm,
                            fontWeight: FontWeight.w600,
                            color: isAI ? AppTheme.purple900 : AppTheme.gray900,
                          ),
                        ),
                        if (message['speakerRole'] != null) ...[
                          SizedBox(width: TailwindSpacing.gap2),
                          Text(
                            message['speakerRole'] as String,
                            style: const TextStyle(
                              fontSize: TailwindFontSize.textSm,
                              color: AppTheme.gray500,
                            ),
                          ),
                        ],
                        SizedBox(width: TailwindSpacing.gap2),
                        Text(
                          message['timestamp'] as String,
                          style: const TextStyle(
                            fontSize: TailwindFontSize.textXs,
                            color: AppTheme.gray400,
                          ),
                        ),
                      ],
                    ),
                    if (message['messageType'] != 'text') ...[
                      SizedBox(height: TailwindSpacing.mb2),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: TailwindSpacing.p2,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _getMessageTypeColor(message['messageType'] as String).bg,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _getMessageTypeLabel(message['messageType'] as String),
                          style: TextStyle(
                            fontSize: TailwindFontSize.textXs,
                            fontWeight: FontWeight.w600,
                            color: _getMessageTypeColor(message['messageType'] as String).text,
                          ),
                        ),
                      ),
                    ],
                    SizedBox(height: TailwindSpacing.mb1),
                    Container(
                      padding: const EdgeInsets.all(TailwindSpacing.p3),
                      decoration: BoxDecoration(
                        color: isAI ? AppTheme.purple50 : AppTheme.gray50,
                        border: Border.all(
                          color: isAI ? AppTheme.purple200 : AppTheme.gray200,
                        ),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(8),
                          topRight: Radius.circular(8),
                          bottomLeft: Radius.circular(8),
                          bottomRight: Radius.circular(8),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            message['content'] as String,
                            style: const TextStyle(
                              fontSize: TailwindFontSize.textSm,
                              color: AppTheme.gray900,
                            ),
                          ),
                          if (message['references'] != null &&
                              (message['references'] as List).isNotEmpty) ...[
                            SizedBox(height: TailwindSpacing.mb3),
                            Container(
                              padding: const EdgeInsets.only(top: TailwindSpacing.p3),
                              decoration: const BoxDecoration(
                                border: Border(top: BorderSide(color: AppTheme.gray300)),
                              ),
                              child: Column(
                                children: (message['references'] as List).map<Widget>((ref) {
                                  return Padding(
                                    padding: EdgeInsets.only(bottom: TailwindSpacing.gap2),
                                    child: TextButton.icon(
                                      onPressed: () {},
                                      icon: SvgIcons.link2(size: 14, color: isAI ? AppTheme.purple700 : AppTheme.blue600),
                                      style: TextButton.styleFrom(
                                        foregroundColor: isAI
                                            ? AppTheme.purple700
                                            : AppTheme.blue600,
                                        padding: EdgeInsets.zero,
                                        minimumSize: Size.zero,
                                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                        textStyle: const TextStyle(
                                          fontSize: TailwindFontSize.textXs, // text-xs = 12px
                                          fontWeight: FontWeight.w500, // font-medium
                                          height: 1.5,
                                          letterSpacing: 0,
                                        ),
                                      ),
                                      label: Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: TailwindSpacing.p2,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: _getReferenceTypeColor(ref['type']).bg,
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              ref['type'],
                                              style: TextStyle(
                                                fontSize: TailwindFontSize.textXs, // text-xs = 12px
                                                fontWeight: FontWeight.w500, // font-medium
                                                color: _getReferenceTypeColor(ref['type']).text,
                                                height: 1.5,
                                                letterSpacing: 0,
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: TailwindSpacing.gap2),
                                          Text(
                                            ref['label'],
                                            style: const TextStyle(
                                              fontSize: TailwindFontSize.textXs, // text-xs = 12px
                                              fontWeight: FontWeight.w500, // font-medium
                                              height: 1.5,
                                              letterSpacing: 0,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInputArea(String visitId) {
    return Container(
      padding: EdgeInsets.all(widget.onClose != null ? TailwindSpacing.p8 : TailwindSpacing.p4),
      decoration: const BoxDecoration(
        color: AppTheme.gray50,
        border: Border(top: BorderSide(color: AppTheme.gray200)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => setState(() => _messageMode = 'ask-ai'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _messageMode == 'ask-ai'
                        ? AppTheme.purple600
                        : Colors.white,
                    foregroundColor: _messageMode == 'ask-ai'
                        ? Colors.white
                        : AppTheme.gray700,
                    side: BorderSide(
                      color: _messageMode == 'ask-ai'
                          ? AppTheme.purple600
                          : AppTheme.gray300,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12, // px-3 = 12px
                      vertical: 6, // py-1.5 = 6px
                    ),
                    minimumSize: const Size(0, 32), // h-8 = 32px
                    textStyle: const TextStyle(
                      fontSize: TailwindFontSize.textXs, // text-xs = 12px
                      fontWeight: FontWeight.w500, // font-medium
                      height: 1.5,
                      letterSpacing: 0,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgIcons.brain(size: 16, color: _messageMode == 'ask-ai' ? Colors.white : AppTheme.gray700),
                      SizedBox(width: TailwindSpacing.gap1),
                      const Text('Ask AI'),
                    ],
                  ),
                ),
              ),
              SizedBox(width: TailwindSpacing.gap2),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => setState(() => _messageMode = 'clinical-note'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _messageMode == 'clinical-note'
                        ? AppTheme.blue600
                        : Colors.white,
                    foregroundColor: _messageMode == 'clinical-note'
                        ? Colors.white
                        : AppTheme.gray700,
                    side: BorderSide(
                      color: _messageMode == 'clinical-note'
                          ? AppTheme.blue600
                          : AppTheme.gray300,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12, // px-3 = 12px
                      vertical: 6, // py-1.5 = 6px
                    ),
                    minimumSize: const Size(0, 32), // h-8 = 32px
                    textStyle: const TextStyle(
                      fontSize: TailwindFontSize.textXs, // text-xs = 12px
                      fontWeight: FontWeight.w500, // font-medium
                      height: 1.5,
                      letterSpacing: 0,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgIcons.user(size: 16, color: _messageMode == 'clinical-note' ? Colors.white : AppTheme.gray700),
                      SizedBox(width: TailwindSpacing.gap1),
                      const Text('Clinical Note'),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: TailwindSpacing.mb3),
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  controller: _messageController,
                  placeholder: _messageMode == 'ask-ai'
                      ? 'Ask AI to explain reasoning, reference data, or suggest alternatives...'
                      : 'Add clinical note or discussion message...',
                  maxLines: 3,
                ),
              ),
              SizedBox(width: TailwindSpacing.gap3),
              ElevatedButton.icon(
                onPressed: _handleSubmit,
                icon: SvgIcons.send(size: 16, color: Colors.white),
                label: Text(
                  _messageMode == 'ask-ai' ? 'Ask AI' : 'Add Note',
                  style: const TextStyle(
                    fontSize: TailwindFontSize.textSm, // text-sm = 14px
                    fontWeight: FontWeight.w500, // font-medium
                    height: 1.5,
                    letterSpacing: 0,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _messageMode == 'ask-ai'
                      ? AppTheme.purple600
                      : AppTheme.blue600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24, // px-6 = 24px
                    vertical: 8, // py-2 = 8px
                  ),
                  minimumSize: const Size(0, 36), // h-9 = 36px
                ),
              ),
            ],
          ),
          SizedBox(height: TailwindSpacing.mt2),
          Text(
            'Messages are persistent and read-only after submission (audit-safe, associated with Visit $visitId)',
            style: const TextStyle(
              fontSize: TailwindFontSize.textXs,
              color: AppTheme.gray500,
            ),
          ),
        ],
      ),
    );
  }

  String _getMessageTypeLabel(String type) {
    switch (type) {
      case 'explanation':
        return 'AI Explanation';
      case 'data-reference':
        return 'Data Reference';
      case 'suggestion':
        return 'AI Suggestion';
      default:
        return '';
    }
  }

  ({Color bg, Color text}) _getMessageTypeColor(String type) {
    switch (type) {
      case 'explanation':
        return (bg: AppTheme.purple100, text: AppTheme.purple700);
      case 'data-reference':
        return (bg: AppTheme.blue100, text: AppTheme.blue700);
      case 'suggestion':
        return (bg: AppTheme.amber100, text: AppTheme.amber700);
      default:
        return (bg: AppTheme.gray100, text: AppTheme.gray700);
    }
  }

  ({Color bg, Color text}) _getReferenceTypeColor(String type) {
    switch (type) {
      case 'vitals':
        return (bg: AppTheme.green100, text: AppTheme.green700);
      case 'labs':
        return (bg: AppTheme.purple100, text: AppTheme.purple700);
      case 'visit':
        return (bg: AppTheme.blue100, text: AppTheme.blue700);
      case 'decision':
        return (bg: AppTheme.orange100, text: AppTheme.orange700);
      default:
        return (bg: AppTheme.gray100, text: AppTheme.gray700);
    }
  }
}
