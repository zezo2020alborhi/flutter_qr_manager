import 'package:flutter_test/flutter_test.dart';
import 'package:qr_manager/models/content_target.dart';

void main() {
  test('ContentType parses API values without case sensitivity', () {
    expect(ContentTypeLabel.fromApi('Video'), ContentType.video);
    expect(ContentTypeLabel.fromApi('pdf'), ContentType.pdf);
    expect(ContentTypeLabel.fromApi('unknown'), ContentType.link);
  });

  test('ContentTarget serializes the editable content fields', () {
    const target = ContentTarget(type: ContentType.text, title: 'مراجعة', value: 'نص الدرس', description: 'اختبار');
    expect(target.toJson(), <String, dynamic>{'type': 'text', 'title': 'مراجعة', 'value': 'نص الدرس', 'driveFileId': null, 'description': 'اختبار'});
  });
}
