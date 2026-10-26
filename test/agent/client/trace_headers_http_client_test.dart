// 职责: 验证 AI 原始响应诊断保留字节、跨块 UTF-8、错误和取消语义。
// 关联文件:
//   lib/shared/agent/client/trace_headers_http_client.dart
//   lib/shared/logger/app_logger.dart
import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:reveric/shared/agent/client/trace_headers_http_client.dart';

void main() {
  late List<String> logs;
  late DebugPrintCallback previous;
  setUp(() {
    logs = [];
    previous = debugPrint;
    debugPrint = (String? message, {int? wrapWidth}) {
      if (message != null) {
        logs.add(message);
      }
    };
  });
  tearDown(() => debugPrint = previous);

  test(
    'records pre-parser message fields and split UTF-8 without changing bytes',
    () async {
      const raw =
          'data: {"choices":[{"message":{"content":"角色🙂"},"finish_reason":"stop"}]}\r\n\r\ndata: [DONE]';
      final bytes = utf8.encode(raw);
      final client = TraceHeadersHttpClient(
        inner: MockClient.streaming((request, body) async {
          expect(request.headers['x-session-id'], 'session-test');
          expect(utf8.decode(await body.toBytes()), '{"messages":[]}');
          return http.StreamedResponse(
            Stream.fromIterable(bytes.map((byte) => [byte])),
            200,
            headers: {'content-type': 'text/event-stream'},
            contentLength: bytes.length,
            reasonPhrase: 'OK',
            request: request,
          );
        }),
        headersProvider: () => {'x-session-id': 'session-test'},
        logBodies: true,
      );
      addTearDown(client.close);
      final response = await client.send(
        http.Request('POST', Uri.parse('https://example.invalid/chat'))
          ..body = '{"messages":[]}',
      );
      expect(await response.stream.toBytes(), bytes);
      expect(response.contentLength, bytes.length);
      expect(response.reasonPhrase, 'OK');
      final text = logs.join('\n');
      expect(text, contains('sessionId=session-test'));
      expect(text, contains('"message":{"content":"角色🙂"}'));
      expect(text, contains('[DONE]'));
      expect(text, contains('http.eof'));
    },
  );

  test('trace disabled preserves response and does not emit payload', () async {
    final client = TraceHeadersHttpClient(
      inner: MockClient((_) async => http.Response('body', 200)),
      headersProvider: () => const {},
    );
    addTearDown(client.close);
    expect(
      (await client.get(Uri.parse('https://example.invalid'))).body,
      'body',
    );
    expect(logs, isEmpty);
  });

  test(
    'observer forwards stream errors and cancellation to transport',
    () async {
      final cancelled = Completer<void>();
      final controller = StreamController<List<int>>(
        onCancel: () {
          cancelled.complete();
        },
      );
      final client = TraceHeadersHttpClient(
        inner: MockClient.streaming(
          (_, _) async => http.StreamedResponse(
            controller.stream,
            200,
            headers: {'content-type': 'text/event-stream'},
          ),
        ),
        headersProvider: () => const {},
        logBodies: true,
      );
      addTearDown(client.close);
      final response = await client.send(
        http.Request('POST', Uri.parse('https://example.invalid')),
      );
      final errors = <Object>[];
      final seenError = Completer<void>();
      final sub = response.stream.listen(
        (_) {},
        onError: (Object error) {
          errors.add(error);
          seenError.complete();
        },
      );
      final error = StateError('transport failed');
      controller.addError(error);
      await seenError.future;
      expect(errors.single, same(error));
      expect(logs.join('\n'), contains('http.stream_error'));
      await sub.cancel();
      await cancelled.future;
      await controller.close();
    },
  );
}
