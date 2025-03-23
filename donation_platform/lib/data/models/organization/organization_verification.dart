class BoardMember {
  final String name;
  final String position;
  final String? cnic;
  
  BoardMember({
    required this.name,
    required this.position,
    this.cnic,
  });
  
  factory BoardMember.fromJson(Map<String, dynamic> json) {
    return BoardMember(
      name: json['name'],
      position: json['position'],
      cnic: json['cnic'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'position': position,
      'cnic': cnic,
    };
  }
}

class OrganizationVerification {
  final String id;
  final String organizationId;
  
  // Registration Documents
  final String? registrationCertificateUrl;
  final String? taxCertificateUrl;
  final String? annualReportUrl;
  final String? governingDocumentUrl;
  
  // Financial Documents
  final String? bankStatementUrl;
  final String? financialReportUrl;
  
  // Board and Leadership
  final String? boardResolutionUrl;
  final List<BoardMember>? boardMembers;
  
  // Contact Person Details
  final String contactPersonName;
  final String contactPersonPosition;
  final String contactPersonEmail;
  final String contactPersonPhone;
  final String? contactPersonCnic;
  
  // Bank Details
  final String bankName;
  final String accountTitle;
  final String accountNumber;
  final String? branchCode;
  final String? swiftCode;
  final bool isBankVerified;
  
  // References
  final List<String>? referenceLetters;
  
  // Verification Process
  final DateTime submittedAt;
  final String verificationStatus; // "pending", "in_review", "approved", "rejected"
  final String? verificationStage;
  final String? verificationNotes;
  final String? verifiedBy; // Admin ID
  final DateTime? verifiedAt;
  final String? rejectionReason;
  final DateTime updatedAt;
  
  OrganizationVerification({
    required this.id,
    required this.organizationId,
    this.registrationCertificateUrl,
    this.taxCertificateUrl,
    this.annualReportUrl,
    this.governingDocumentUrl,
    this.bankStatementUrl,
    this.financialReportUrl,
    this.boardResolutionUrl,
    this.boardMembers,
    required this.contactPersonName,
    required this.contactPersonPosition,
    required this.contactPersonEmail,
    required this.contactPersonPhone,
    this.contactPersonCnic,
    required this.bankName,
    required this.accountTitle,
    required this.accountNumber,
    this.branchCode,
    this.swiftCode,
    required this.isBankVerified,
    this.referenceLetters,
    required this.submittedAt,
    required this.verificationStatus,
    this.verificationStage,
    this.verificationNotes,
    this.verifiedBy,
    this.verifiedAt,
    this.rejectionReason,
    required this.updatedAt,
  });
  
  factory OrganizationVerification.fromJson(Map<String, dynamic> json) {
    return OrganizationVerification(
      id: json['id'],
      organizationId: json['organization_id'],
      registrationCertificateUrl: json['registration_certificate_url'],
      taxCertificateUrl: json['tax_certificate_url'],
      annualReportUrl: json['annual_report_url'],
      governingDocumentUrl: json['governing_document_url'],
      bankStatementUrl: json['bank_statement_url'],
      financialReportUrl: json['financial_report_url'],
      boardResolutionUrl: json['board_resolution_url'],
      boardMembers: json['board_members'] != null
        ? (json['board_members'] as List).map((b) => BoardMember.fromJson(b)).toList()
        : null,
      contactPersonName: json['contact_person_name'],
      contactPersonPosition: json['contact_person_position'],
      contactPersonEmail: json['contact_person_email'],
      contactPersonPhone: json['contact_person_phone'],
      contactPersonCnic: json['contact_person_cnic'],
      bankName: json['bank_name'],
      accountTitle: json['account_title'],
      accountNumber: json['account_number'],
      branchCode: json['branch_code'],
      swiftCode: json['swift_code'],
      isBankVerified: json['is_bank_verified'] ?? false,
      referenceLetters: json['reference_letters'] != null
        ? List<String>.from(json['reference_letters'])
        : null,
      submittedAt: json['submitted_at'] != null 
        ? DateTime.parse(json['submitted_at']) 
        : DateTime.now(),
      verificationStatus: json['verification_status'] ?? 'pending',
      verificationStage: json['verification_stage'],
      verificationNotes: json['verification_notes'],
      verifiedBy: json['verified_by'],
      verifiedAt: json['verified_at'] != null 
        ? DateTime.parse(json['verified_at']) 
        : null,
      rejectionReason: json['rejection_reason'],
      updatedAt: json['updated_at'] != null 
        ? DateTime.parse(json['updated_at']) 
        : DateTime.now(),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'organization_id': organizationId,
      'registration_certificate_url': registrationCertificateUrl,
      'tax_certificate_url': taxCertificateUrl,
      'annual_report_url': annualReportUrl,
      'governing_document_url': governingDocumentUrl,
      'bank_statement_url': bankStatementUrl,
      'financial_report_url': financialReportUrl,
      'board_resolution_url': boardResolutionUrl,
      'board_members': boardMembers?.map((b) => b.toJson()).toList(),
      'contact_person_name': contactPersonName,
      'contact_person_position': contactPersonPosition,
      'contact_person_email': contactPersonEmail,
      'contact_person_phone': contactPersonPhone,
      'contact_person_cnic': contactPersonCnic,
      'bank_name': bankName,
      'account_title': accountTitle,
      'account_number': accountNumber,
      'branch_code': branchCode,
      'swift_code': swiftCode,
      'is_bank_verified': isBankVerified,
      'reference_letters': referenceLetters,
      'submitted_at': submittedAt.toIso8601String(),
      'verification_status': verificationStatus,
      'verification_stage': verificationStage,
      'verification_notes': verificationNotes,
      'verified_by': verifiedBy,
      'verified_at': verifiedAt?.toIso8601String(),
      'rejection_reason': rejectionReason,
      'updated_at': updatedAt.toIso8601String(),
    };
  }
  
  // Create a copy of the verification with updated fields
  OrganizationVerification copyWith({
    String? id,
    String? organizationId,
    String? registrationCertificateUrl,
    String? taxCertificateUrl,
    String? annualReportUrl,
    String? governingDocumentUrl,
    String? bankStatementUrl,
    String? financialReportUrl,
    String? boardResolutionUrl,
    List<BoardMember>? boardMembers,
    String? contactPersonName,
    String? contactPersonPosition,
    String? contactPersonEmail,
    String? contactPersonPhone,
    String? contactPersonCnic,
    String? bankName,
    String? accountTitle,
    String? accountNumber,
    String? branchCode,
    String? swiftCode,
    bool? isBankVerified,
    List<String>? referenceLetters,
    DateTime? submittedAt,
    String? verificationStatus,
    String? verificationStage,
    String? verificationNotes,
    String? verifiedBy,
    DateTime? verifiedAt,
    String? rejectionReason,
    DateTime? updatedAt,
  }) {
    return OrganizationVerification(
      id: id ?? this.id,
      organizationId: organizationId ?? this.organizationId,
      registrationCertificateUrl: registrationCertificateUrl ?? this.registrationCertificateUrl,
      taxCertificateUrl: taxCertificateUrl ?? this.taxCertificateUrl,
      annualReportUrl: annualReportUrl ?? this.annualReportUrl,
      governingDocumentUrl: governingDocumentUrl ?? this.governingDocumentUrl,
      bankStatementUrl: bankStatementUrl ?? this.bankStatementUrl,
      financialReportUrl: financialReportUrl ?? this.financialReportUrl,
      boardResolutionUrl: boardResolutionUrl ?? this.boardResolutionUrl,
      boardMembers: boardMembers ?? this.boardMembers,
      contactPersonName: contactPersonName ?? this.contactPersonName,
      contactPersonPosition: contactPersonPosition ?? this.contactPersonPosition,
      contactPersonEmail: contactPersonEmail ?? this.contactPersonEmail,
      contactPersonPhone: contactPersonPhone ?? this.contactPersonPhone,
      contactPersonCnic: contactPersonCnic ?? this.contactPersonCnic,
      bankName: bankName ?? this.bankName,
      accountTitle: accountTitle ?? this.accountTitle,
      accountNumber: accountNumber ?? this.accountNumber,
      branchCode: branchCode ?? this.branchCode,
      swiftCode: swiftCode ?? this.swiftCode,
      isBankVerified: isBankVerified ?? this.isBankVerified,
      referenceLetters: referenceLetters ?? this.referenceLetters,
      submittedAt: submittedAt ?? this.submittedAt,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      verificationStage: verificationStage ?? this.verificationStage,
      verificationNotes: verificationNotes ?? this.verificationNotes,
      verifiedBy: verifiedBy ?? this.verifiedBy,
      verifiedAt: verifiedAt ?? this.verifiedAt,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
  
  // Check if all required documents are uploaded
  bool get hasAllRequiredDocuments {
    return registrationCertificateUrl != null &&
           taxCertificateUrl != null &&
           bankStatementUrl != null &&
           boardResolutionUrl != null;
  }
  
  // Check if verification is complete
  bool get isComplete {
    return hasAllRequiredDocuments &&
           isBankVerified &&
           boardMembers != null && boardMembers!.isNotEmpty;
  }
  
  // Get verification progress percentage
  double get progressPercentage {
    int total = 7; // Total number of verification steps
    int completed = 0;
    
    if (registrationCertificateUrl != null) completed++;
    if (taxCertificateUrl != null) completed++;
    if (bankStatementUrl != null) completed++;
    if (boardResolutionUrl != null) completed++;
    if (boardMembers != null && boardMembers!.isNotEmpty) completed++;
    if (isBankVerified) completed++;
    if (verificationStatus != 'pending') completed++;
    
    return (completed / total) * 100;
  }
}