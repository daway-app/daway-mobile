import 'package:daway_app/features/patient/data/models/pharmacy_inquiry_model.dart';
import 'package:daway_app/features/patient/domain/entities/pharmacy_inquiry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses an answered inquiry from GET /patient/inquiries', () {
    final model = PharmacyInquiryModel.fromJson({
      'id': 1,
      'status': 'answered',
      'message': 'هل يتوفر هذا الدواء؟',
      'reply': 'نعم متوفر حالياً',
      'availability_status': 'available',
      'replied_at': '2026-09-29 10:57:57',
      'created_at': '2026-09-29 10:57:43',
      'pharmacy': {'id': 1, 'pharmacy_name': 'صيدلية الأمل'},
      'medicine': {'id': 6, 'trade_name': 'Panadol Extra'},
    });

    final entity = model.toEntity();

    expect(entity.id, 1);
    expect(entity.pharmacyId, 1);
    expect(entity.medicineId, 6);
    expect(entity.message, 'هل يتوفر هذا الدواء؟');
    expect(entity.reply, 'نعم متوفر حالياً');
    expect(entity.status, InquiryStatus.answered);
    // Neither date has a timezone marker, so both are the server's UTC clock
    // (see server_timestamp.dart) — compare instants, not local wall-clock
    // fields, so this holds in whatever timezone the tests run in.
    expect(entity.createdAt.isAtSameMomentAs(DateTime.utc(2026, 9, 29, 10, 57, 43)), isTrue);
    expect(entity.repliedAt!.isAtSameMomentAs(DateTime.utc(2026, 9, 29, 10, 57, 57)), isTrue);
  });

  test('a fresh inquiry has a null reply/replied_at and "new" status', () {
    final model = PharmacyInquiryModel.fromJson({
      'id': 1,
      'status': 'new',
      'message': 'سؤال',
      'reply': null,
      'replied_at': null,
      'created_at': '2026-09-29 10:57:43',
      'pharmacy': {'id': 1, 'pharmacy_name': 'صيدلية الأمل'},
      'medicine': {'id': 6, 'trade_name': 'Panadol Extra'},
    });

    final entity = model.toEntity();

    expect(entity.reply, isNull);
    expect(entity.repliedAt, isNull);
    expect(entity.status, InquiryStatus.newInquiry);
  });

  test('an unrecognized status defaults to newInquiry instead of throwing', () {
    final model = PharmacyInquiryModel.fromJson({'status': 'some_new_status'});

    expect(model.toEntity().status, InquiryStatus.newInquiry);
  });

  test('a malformed replied_at falls back to null instead of throwing', () {
    final model = PharmacyInquiryModel.fromJson({
      'id': 1,
      'reply': 'نعم متوفر',
      'replied_at': 'not-a-date',
    });

    // Doesn't throw — this inquiry still parses (with the reply text kept),
    // instead of a bad date breaking every inquiry in the list.
    expect(model.toEntity().reply, 'نعم متوفر');
    expect(model.toEntity().repliedAt, isNull);
  });

  test('falls back to nulls/zero/empty for missing fields', () {
    final entity = PharmacyInquiryModel.fromJson({}).toEntity();

    expect(entity.id, 0);
    expect(entity.pharmacyId, 0);
    expect(entity.medicineId, 0);
    expect(entity.message, '');
    expect(entity.reply, isNull);
  });
}
