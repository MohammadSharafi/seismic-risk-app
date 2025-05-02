import 'package:auto_route/annotations.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:health_care_onboarding_web_qa/march_style/march_theme.dart';
import 'package:health_care_onboarding_web_qa/questionary/components/buttons.dart';
import 'package:health_care_onboarding_web_qa/routes/router.dart';

@RoutePage()
class ConsentPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Header text
              Text(
                "You're just one step away!",
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              Text(
                "Before we continue, please review and sign the consent form for the 30-Day Endometriosis Care Plan. This program offers support, guidance, and insights, but it is not a substitute for medical advice. Your understanding helps us move forward together with care and clarity.",
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),

              SizedBox(height: 16),
              // Scrollable consent text
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: SingleChildScrollView(
                      child: ListView(
                    shrinkWrap: true,
                    children: [
                      _SectionTitle('Welcome to March Health'),
                      _Paragraph(
                        'These Terms of Service (“Terms”) govern your access to and use of our services, including the March Health mobile app, Endometriosis Master Care course, websites, content, features, and other related offerings (collectively, the “Services”). By accessing or using any of our Services, you agree to be bound by these Terms. If you do not agree with these Terms, please do not use our Services.',
                      ),
                      _SectionTitle('Eligibility'),
                      _Paragraph(
                        'You must be at least 18 years old to use March Health Services. By using our Services, you confirm that you meet this age requirement. If you are accessing the Services from outside the United States, you are responsible for compliance with local laws and regulations. You will be required to enter your date of birth at registration. If we detect the presence of underage data (e.g., under 18), we will delete the information within 30 days and notify the guardian if identifiable. We do not knowingly collect information from children under the age of 13.',
                      ),
                      _SectionTitle('Nature of Services'),
                      _Paragraph(
                        'March Health provides educational and self-guided health support through its mobile application, website, and the Endometriosis Master Care course. These services include non-clinical tools such as mood tracking, symptom check-ins, AI-driven insights, access to pre-recorded educational content, and interaction with live Health Coaches. Our Health Coaches are trained non-clinical professionals who conduct scheduled online sessions to provide guidance, accountability, and personalized motivation throughout the course.',
                      ),
                      _SubSectionTitle('Additional features include:'),
                      _BulletPoint(
                        'An entrance questionnaire on March Health Website that collects symptom patterns, medical history, and lifestyle factors to personalize the user experience. Responses may include protected health information (PHI) and are encrypted and processed in accordance with HIPAA and GDPR requirements.',
                      ),
                      _BulletPoint(
                        'Daily check-ins prompting users to log mood, pain, energy levels, and other variables to generate personalized insights. These interactions are voluntary but essential to the app’s learning and recommendation engine.',
                      ),
                      _BulletPoint(
                        'A cycle calendar and health profile builder to monitor menstrual patterns and related symptoms. While based on validated models, March Health does not guarantee diagnostic accuracy or health outcomes.',
                      ),
                      _BulletPoint(
                        'Behaviorally designed quests and gamification features to improve engagement, with clear opt-out settings and design standards to avoid coercion.',
                      ),
                      _BulletPoint(
                        'AI-generated suggestions for nutrition, movement, mental health practices, and daily routines. These are intended as supportive lifestyle suggestions and do not constitute clinical advice.',
                      ),
                      _BulletPoint(
                        'Access to mental health resources focused on chronic condition stress management. These are non-therapeutic and are not a substitute for psychotherapy.',
                      ),
                      _BulletPoint(
                        'Community features, such as moderated forums, where users can exchange experiences. We encourage respectful interaction and inform users that these spaces are not private.',
                      ),
                      _BulletPoint(
                        'Risk assessment tools on March Health Website designed to screen for conditions such as endometriosis, PCOS, and preterm birth. These tools leverage validated symptom models, structured health questionnaires, and AI-supported scoring algorithms to provide users with educational feedback on potential risk profiles. They are intended to increase awareness and support proactive health discussions with licensed providers. These risk tools do not diagnose, are not FDA-approved diagnostic devices, and should not be used in place of clinical evaluation.',
                      ),
                      _BulletPoint(
                        'In select markets, users may schedule virtual consultations with licensed specialists. March Health facilitates this process but does not employ the physicians or assume responsibility for medical care. All specialists are licensed, and third-party consultation platforms sign HIPAA-compliant Business Associate Agreements (BAAs) to protect user data.',
                      ),
                      _BulletPoint(
                        'AI Health Assistant is an automated, conversational tool powered by artificial intelligence designed to respond to users’ health-related questions. It provides educational responses based on symptom patterns, scientific references, and general health knowledge. The Health Assistant does not offer clinical diagnosis or treatment advice, nor does it replace interaction with licensed medical professionals. While responses are dynamically generated, they may contain inaccuracies or lack full context. We encourage users to use this feature as an informational resource and consult a healthcare provider for any personal or urgent health concerns. The use of this feature is subject to our disclaimers on non-medical AI use and should not be relied upon for decision-making involving your medical care.',
                      ),
                      _BulletPoint(
                        'The Endometriosis Master Care course is a time-limited, educational program that includes guided challenges, structured daily experiences, digital coaching tools, and video-based lessons. Participation in this course does not constitute entry into a clinical relationship with a healthcare provider, and March Health does not provide medical care, treatment recommendations, or diagnosis.',
                      ),
                      _Paragraph(
                        'Our content, live coaching, and AI-powered insights are not intended to substitute professional medical judgment. You should always consult a qualified medical professional before making decisions related to diagnosis, treatment, or medication. We do not provide emergency or crisis support.',
                      ),
                      _SectionTitle('User Accounts and Security'),
                      _Paragraph(
                        'You must provide accurate, current, and complete information when creating your account. You are responsible for maintaining the confidentiality of your credentials and for all activity under your account. You agree to notify us immediately of any unauthorized access or use. March Health is not liable for losses resulting from your failure to safeguard your login information.',
                      ),
                      _SectionTitle('Subscriptions and Payments'),
                      _Paragraph(
                        'Subscription options and pricing are available in-app and on our website.',
                      ),
                      _BulletPoint(
                        'Annual subscriptions are refundable within 30 days.',
                      ),
                      _BulletPoint(
                        'Monthly subscriptions are non-refundable.',
                      ),
                      _BulletPoint(
                        'Refunds must be requested in the app under Settings > Refund. If your account is inaccessible, contact support@march.health or submit a form at https://forms.cloud.microsoft/r/p9Z6UH15j7.',
                      ),
                      _BulletPoint(
                        'Our refund policy, available at https://march.health/refund-policy/, governs all refunds for March Health services.',
                      ),
                      _BulletPoint(
                        'March Health reserves the right to deny refunds for services used beyond the refund period or in violation of these Terms. For full details, including eligibility and process, see https://march.health/refund-policy/.',
                      ),
                      _BulletPoint(
                        'We do not currently offer pro-rata refunds but may consider them at our discretion.',
                      ),
                      _SubSectionTitle('Trial Offers:'),
                      _BulletPoint(
                        'Trial Offers must be used within the specified period, as indicated at sign-up.',
                      ),
                      _BulletPoint(
                        'A valid payment method is required to initiate a Trial Offer. You will not be charged until the trial period ends, unless you opt in to continue the service.',
                      ),
                      _BulletPoint(
                        'To avoid charges, you must cancel the Trial Offer before the trial period ends via app settings or by contacting support@march.health.',
                      ),
                      _BulletPoint(
                        'If you are inadvertently charged after cancelling, contact support@march.health for a refund.',
                      ),
                      _BulletPoint(
                        'Trial Offers are limited to one per user or household and are for new customers only. Additional terms may apply and will be provided at sign-up.',
                      ),
                      _BulletPoint(
                        'March Health reserves the right to modify or terminate Trial Offers at any time without notice.',
                      ),
                      _SubSectionTitle('Coupon Codes:'),
                      _BulletPoint(
                        'Coupon codes have no cash value, cannot be redeemed for cash, and cannot be combined with other offers unless specified.',
                      ),
                      _BulletPoint(
                        'Limit one coupon code per order.',
                      ),
                      _BulletPoint(
                        'Coupon codes expire 30 days after issuance, unless a different redemption period is specified.',
                      ),
                      _BulletPoint(
                        'Unauthorized reproduction, resale, modification, or trade of coupon codes is prohibited.',
                      ),
                      _BulletPoint(
                        'Coupon codes are void where prohibited, taxed, or restricted.',
                      ),
                      _BulletPoint(
                        'March Health reserves the right to change, limit, or terminate coupon codes at any time without notice.',
                      ),
                      _SectionTitle('User Conduct'),
                      _Paragraph(
                        'You agree not to:',
                      ),
                      _BulletPoint(
                        'Use the Services in violation of any applicable law.',
                      ),
                      _BulletPoint(
                        'Upload content that is abusive, defamatory, or infringing.',
                      ),
                      _BulletPoint(
                        'Attempt to hack, reverse-engineer, or bypass our systems.',
                      ),
                      _BulletPoint(
                        'Submit or store protected health information of others without proper consent.',
                      ),
                      _Paragraph(
                        'March Health may suspend or terminate access without notice for violations.',
                      ),
                      _SectionTitle('Data Privacy and Security'),
                      _Paragraph(
                        'We follow HIPAA, GDPR, CPRA, and CCPA. Your data is encrypted using AES-256 and TLS 1.3. Access is role-based and logged. We support:',
                      ),
                      _BulletPoint(
                        'Right to access, correction, deletion',
                      ),
                      _BulletPoint(
                        'Withdrawal of consent (email privacy@march.health or delete account)',
                      ),
                      _BulletPoint(
                        'Account deletion at march.health/delete-account or within March Health mobile application.',
                      ),
                      _BulletPoint(
                        'DPO contact: farr@march.health',
                      ),
                      _Paragraph(
                        'International data transfers are governed by SCCs and annual DTIA assessments.',
                      ),
                      _SectionTitle('Intellectual Property'),
                      _Paragraph(
                        'All materials, tools, AI models, and content are owned by March Health. User-submitted testimonials or reviews are licensed non-exclusively for limited use within the U.S. and EEA while your account is active. You may withdraw consent at any time by deleting account at https://march.health/delete-account; requests are processed within 30 days. Separate consent will be requested for using testimonials in marketing materials.',
                      ),
                      _SectionTitle('Third-Party Services and Vendors'),
                      _Paragraph(
                        'Vendors such as Stripe, AWS, Google Firebase, and Brevo may receive limited access to your data. All health data processors sign HIPAA-compliant BAAs. For transparency, visit https://march.health/privacy-policy/. We conduct annual security and compliance reviews of all vendors handling sensitive information.',
                      ),
                      _SectionTitle('Modifications to Services'),
                      _Paragraph(
                        'Material changes include pricing updates, feature removals, and new data-sharing practices. We will notify users at least 30 days in advance via in-app messaging and email. Consent will be requested for subscription price increases. Beta features may be experimental and used at your own discretion.',
                      ),
                      _SectionTitle('Termination and Deletion'),
                      _Paragraph(
                        'We may suspend or terminate your account with 7 days’ notice unless required sooner for legal or security reasons. Upon termination, your data will be deleted within 30 days. Confirmation will be sent via email. You may appeal termination within 14 days by writing to support@march.health. We retain minimal records (e.g., anonymized audit logs and billing) for up to 7 years for compliance.',
                      ),
                      _SectionTitle(
                          'Disclaimer of Emergency Support and Warranties'),
                      _Paragraph(
                        'March Health is not an emergency service provider. If you are in crisis, call 911 or 988 (U.S. Suicide & Crisis Lifeline) or your local emergency service. AI insights are informational only and may contain errors. Always consult a licensed healthcare provider.',
                      ),
                      _SectionTitle('Limitation of Liability'),
                      _Paragraph(
                        'We are not liable for indirect or incidental damages unless caused by gross negligence, willful misconduct, or violations of HIPAA or GDPR. For EEA users, our liability for data protection violations is governed by GDPR and cannot be limited. Our maximum liability is capped at the amount paid by you in the last 12 months unless otherwise required by law.',
                      ),
                      _SectionTitle('Governing Law and Dispute Resolution'),
                      _Paragraph(
                        'California law governs these Terms. Disputes will be resolved by binding arbitration in San Francisco (AAA Rules). March Health will cover reasonable arbitration fees for claims under \$10,000. If arbitration is unenforceable, disputes may proceed in San Francisco Superior Court. This clause does not affect EEA users’ right to pursue complaints with their local Data Protection Authority.',
                      ),
                      _SectionTitle('Device Compatibility and Accessibility'),
                      _Paragraph(
                        'Our services support most recent Android and iOS devices. Minimum requirements are listed at App Store and Google Play. For accessibility support, email mo@march.health.',
                      ),
                      _SectionTitle('Electronic Communications Consent'),
                      _Paragraph(
                        'By using our services, you consent to receive legal, billing, and support messages electronically.',
                      ),
                      _SubSectionTitle('Text Messages:'),
                      _BulletPoint(
                        'Your mobile provider’s standard message and data rates may apply, as per your wireless carrier’s pricing plan. Consult your carrier to determine applicable charges.',
                      ),
                      _BulletPoint(
                        'March Health is not responsible for any text messaging or wireless charges incurred by you or anyone using your device.',
                      ),
                      _BulletPoint(
                        'If your carrier does not permit text alerts, you may not receive Text Messages. March Health is not liable for delays or non-delivery due to network issues.',
                      ),
                      _BulletPoint(
                        'Data collected via Text Messages (e.g., phone number, message content, timestamps) is processed per our Privacy Policy and protected under HIPAA and GDPR.',
                      ),
                      _BulletPoint(
                        'You may opt out of Text Messages at any time by contacting support@march.health. Opting out does not affect other communications (e.g., email, in-app notifications).',
                      ),
                      _SectionTitle('Force Majeure'),
                      _Paragraph(
                        'We are not liable for delays or failure caused by uncontrollable events (e.g., earthquakes, internet blackouts, government action). This clause does not excuse our obligation to comply with HIPAA or GDPR breach notifications.',
                      ),
                      _SectionTitle('Contact Us'),
                      _Paragraph(
                        'March Health, Inc.\n16192 Coastal Hwy, Lewes, Delaware 19958\nEmail: support@march.health\nData Protection Officer: farr@march.health.',
                      ),
                      _Paragraph(
                        'Thank you for being part of March Health. We are committed to supporting you with transparency, safety, and respect.',
                      ),
                    ],
                  )),
                ),
              ),
              SizedBox(height: 16),

              MarchButton(
                btnText: 'I Agree',
                btnCallBack: () {
                  AutoRouter.of(context).replace(ProgramRoute());
                },
                buttonSize: ButtonSize.LARG,
                alignment: Alignment.center,
                hasPadding: false,
              )
            ],
          ),
        ),
      ),
    );
  }
}

// Custom widget for section titles
class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Text(
        title,
        style: GoogleFonts.nunito(
            fontWeight: FontWeight.bold,
            color: marchColorData[MarchColor.purpleExtraDark],
            fontSize: 14),
      ),
    );
  }
}

// Custom widget for subsection titles
class _SubSectionTitle extends StatelessWidget {
  final String title;

  const _SubSectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: GoogleFonts.nunito(
            fontWeight: FontWeight.bold,
            color: marchColorData[MarchColor.purpleExtraDark],
            fontSize: 12),
      ),
    );
  }
}

// Custom widget for paragraphs
class _Paragraph extends StatelessWidget {
  final String text;

  const _Paragraph(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: GoogleFonts.nunito(
            fontWeight: FontWeight.bold,
            color: marchColorData[MarchColor.blackInput],
            fontSize: 12),
        textAlign: TextAlign.justify,
      ),
    );
  }
}

// Custom widget for bullet points
class _BulletPoint extends StatelessWidget {
  final String text;

  const _BulletPoint(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ',
            style: GoogleFonts.nunito(
                fontWeight: FontWeight.bold,
                color: marchColorData[MarchColor.blackInput],
                fontSize: 12),
          ),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.nunito(
                  fontWeight: FontWeight.bold,
                  color: marchColorData[MarchColor.blackInput],
                  fontSize: 12),
              textAlign: TextAlign.justify,
            ),
          ),
        ],
      ),
    );
  }
}
