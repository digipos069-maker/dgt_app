class BankTransferInfo {
  const BankTransferInfo({
    required this.bankName,
    required this.accountName,
    required this.accountNumber,
    required this.currency,
    this.swiftCode,
    this.instructions =
        'Please enter your payment reference code in the bank transfer remark/description.',
  });

  final String bankName;
  final String accountName;
  final String accountNumber;
  final String currency;
  final String? swiftCode;
  final String instructions;

  static const defaultAba = BankTransferInfo(
    bankName: 'ABA Bank',
    accountName: 'DGT EDUCATION CO., LTD',
    accountNumber: '000 123 456',
    currency: 'USD',
    swiftCode: 'ABAAKHPP',
  );
}
