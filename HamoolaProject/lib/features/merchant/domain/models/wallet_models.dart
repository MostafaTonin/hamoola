/// Domain models for Merchant Wallet, Transactions, and Payment Wallets
library;

import 'package:flutter/material.dart';

enum TransactionType {
  deposit,
  payment,
  refund,
}

enum TransactionStatus {
  completed,
  pending,
  rejected,
}

class MerchantTransaction {
  final String id;
  final TransactionType type;
  final String title;
  final String date;
  final double amount;
  final TransactionStatus status;
  final String statusLabel;
  final String wallet;
  final String ref;

  const MerchantTransaction({
    required this.id,
    required this.type,
    required this.title,
    required this.date,
    required this.amount,
    required this.status,
    required this.statusLabel,
    required this.wallet,
    required this.ref,
  });
}

class PaymentWallet {
  final String id;
  final String name;
  final String point;
  final Color brandColor;
  final IconData icon;

  const PaymentWallet({
    required this.id,
    required this.name,
    required this.point,
    required this.brandColor,
    required this.icon,
  });

  static const List<PaymentWallet> supportedWallets = [
    PaymentWallet(
      id: 'jeeb',
      name: 'محفظة جيب',
      point: '905027',
      brandColor: Color(0xFFF59E0B),
      icon: Icons.account_balance_wallet_rounded,
    ),
    PaymentWallet(
      id: 'floosak',
      name: 'محفظة فلوسك',
      point: '812045',
      brandColor: Color(0xFF10B981),
      icon: Icons.monetization_on_rounded,
    ),
    PaymentWallet(
      id: 'jawali',
      name: 'محفظة جوالي',
      point: '774512',
      brandColor: Color(0xFF2563EB),
      icon: Icons.phone_android_rounded,
    ),
    PaymentWallet(
      id: 'kuraimi',
      name: 'كريمي جوال',
      point: '553901',
      brandColor: Color(0xFF1E3A8A),
      icon: Icons.credit_card_rounded,
    ),
    PaymentWallet(
      id: 'onecash',
      name: 'محفظة ون كاش',
      point: '620194',
      brandColor: Color(0xFFD97706),
      icon: Icons.toll_rounded,
    ),
    PaymentWallet(
      id: 'cash',
      name: 'محفظة كاش',
      point: '431088',
      brandColor: Color(0xFF059669),
      icon: Icons.payments_rounded,
    ),
    PaymentWallet(
      id: 'mobilemoney',
      name: 'موبايل موني',
      point: '329014',
      brandColor: Color(0xFF7C3AED),
      icon: Icons.smartphone_rounded,
    ),
    PaymentWallet(
      id: 'snb',
      name: 'البنك الأهلي',
      point: '108923',
      brandColor: Color(0xFF0284C7),
      icon: Icons.account_balance_rounded,
    ),
  ];
}

class MerchantWalletData {
  final double balance;
  final double pendingBalance;
  final List<MerchantTransaction> transactions;

  const MerchantWalletData({
    required this.balance,
    required this.pendingBalance,
    required this.transactions,
  });

  static const MerchantWalletData demoWallet = MerchantWalletData(
    balance: 2000.0,
    pendingBalance: 10000.0,
    transactions: [
      MerchantTransaction(
        id: 'TXN-902144',
        type: TransactionType.deposit,
        title: 'شحن رصيد — محفظة جيب',
        date: 'اليوم، 10:30 م',
        amount: 10000.0,
        status: TransactionStatus.pending,
        statusLabel: 'قيد المراجعة',
        wallet: 'محفظة جيب',
        ref: 'TXN-902144',
      ),
      MerchantTransaction(
        id: 'TXN-894120',
        type: TransactionType.payment,
        title: 'دفع أجرة نقل (طلب #REQ-1024)',
        date: 'أمس، 04:15 م',
        amount: -5000.0,
        status: TransactionStatus.completed,
        statusLabel: 'مكتملة',
        wallet: 'المحفظة الداخلية',
        ref: 'REQ-1024',
      ),
      MerchantTransaction(
        id: 'TXN-881200',
        type: TransactionType.refund,
        title: 'استرداد تأمين رحلة (#REQ-1018)',
        date: '18 سبتمبر 2026، 02:00 م',
        amount: 3000.0,
        status: TransactionStatus.completed,
        statusLabel: 'مكتملة',
        wallet: 'المحفظة الداخلية',
        ref: 'REF-1018',
      ),
      MerchantTransaction(
        id: 'TXN-874510',
        type: TransactionType.payment,
        title: 'دفع نقل بضائع موانئ (#REQ-1012)',
        date: '15 سبتمبر 2026، 11:20 ص',
        amount: -12000.0,
        status: TransactionStatus.completed,
        statusLabel: 'مكتملة',
        wallet: 'المحفظة الداخلية',
        ref: 'REQ-1012',
      ),
      MerchantTransaction(
        id: 'TXN-861099',
        type: TransactionType.deposit,
        title: 'شحن رصيد — محفظة فلوسك',
        date: '10 سبتمبر 2026، 09:00 ص',
        amount: 25000.0,
        status: TransactionStatus.rejected,
        statusLabel: 'مرفوضة (رقم مرجع غير مطابق)',
        wallet: 'محفظة فلوسك',
        ref: 'TXN-861099',
      ),
    ],
  );
}
