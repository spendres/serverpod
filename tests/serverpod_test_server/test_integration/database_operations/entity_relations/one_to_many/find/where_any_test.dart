import 'package:serverpod/database.dart' as db;
import 'package:serverpod_test_server/src/generated/protocol.dart';
import 'package:serverpod_test_server/test_util/test_serverpod.dart';
import 'package:test/test.dart';

void main() async {
  var session = await IntegrationTestServer().session();

  group('Given entities with one to many relation', () {
    tearDown(() async {
      await Order.db.deleteWhere(session, where: (_) => db.Constant.bool(true));
      await Customer.db
          .deleteWhere(session, where: (_) => db.Constant.bool(true));
    });

    test(
        'when fetching entities filtered by any many relation then result is as expected.',
        () async {
      var customers = await Customer.db.insert(session, [
        Customer(name: 'Alex'),
        Customer(name: 'Isak'),
        Customer(name: 'Viktor'),
      ]);
      await Order.db.insert(session, [
        // Alex orders
        Order(description: 'Order 1', customerId: customers[0].id!),
        Order(description: 'Order 2', customerId: customers[0].id!),
        Order(description: 'Order 3', customerId: customers[0].id!),
        // Viktor orders
        Order(description: 'Order 4', customerId: customers[2].id!),
        Order(description: 'Order 5', customerId: customers[2].id!),
      ]);

      var fetchedCustomers = await Customer.db.find(
        session,
        // All customers with any order.
        where: (c) => c.orders.any(),
      );

      var customerNames = fetchedCustomers.map((e) => e.name);
      expect(customerNames, hasLength(2));
      expect(customerNames, containsAll(['Alex', 'Viktor']));
    });

    test(
        'when fetching entities filtered by filtered any many relation then result is as expected',
        () async {
      var customers = await Customer.db.insert(session, [
        Customer(name: 'Alex'),
        Customer(name: 'Isak'),
        Customer(name: 'Viktor'),
      ]);
      await Order.db.insert(session, [
        // Alex orders
        Order(description: 'Order 1', customerId: customers[0].id!),
        Order(description: 'Order 2', customerId: customers[0].id!),
        Order(description: 'Order 3', customerId: customers[0].id!),
        // Viktor orders
        Order(description: 'Prem: Order 4', customerId: customers[2].id!),
        Order(description: 'Prem: Order 5', customerId: customers[2].id!),
      ]);

      var fetchedCustomers = await Customer.db.find(
        session,
        // All customers with any order with a description starting with 'prem'.
        where: (c) => c.orders.any((o) => o.description.ilike('prem%')),
      );

      var customerNames = fetchedCustomers.map((e) => e.name);
      expect(customerNames, ['Viktor']);
    });

    test(
        'when fetching entities filtered on any many relation in combination with other filter then result is as expected.',
        () async {
      var customers = await Customer.db.insert(session, [
        Customer(name: 'Alex'),
        Customer(name: 'Isak'),
        Customer(name: 'Viktor'),
      ]);
      await Order.db.insert(session, [
        // Alex orders
        Order(description: 'Order 1', customerId: customers[0].id!),
      ]);

      var fetchedCustomers = await Customer.db.find(
        session,
        // All customers with any order or name 'Isak'
        where: (c) => c.orders.any() | c.name.equals('Isak'),
      );

      var customerNames = fetchedCustomers.map((e) => e.name);
      expect(customerNames, hasLength(2));
      expect(customerNames, containsAll(['Alex', 'Isak']));
    });

    test(
        'when fetching entities filtered on OR filtered any many relation then result is as expected.',
        () async {
      var customers = await Customer.db.insert(session, [
        Customer(name: 'Alex'),
        Customer(name: 'Isak'),
        Customer(name: 'Viktor'),
      ]);
      await Order.db.insert(session, [
        // Alex orders
        Order(description: 'Basic: Order 1', customerId: customers[0].id!),
        Order(description: 'Basic: Order 2', customerId: customers[0].id!),
        Order(description: 'Order 3', customerId: customers[0].id!),
        // Viktor orders
        Order(description: 'Prem: Order 4', customerId: customers[2].id!),
        Order(description: 'Order 5', customerId: customers[2].id!),
      ]);

      var fetchedCustomers = await Customer.db.find(
        session,
        // All customers with any order with a description starting with 'prem'
        // or 'basic'.
        where: (c) => c.orders.any((o) =>
            o.description.ilike('prem%') | o.description.ilike('basic%')),
      );

      var customerNames = fetchedCustomers.map((e) => e.name);
      expect(customerNames, hasLength(2));
      expect(customerNames, ['Alex', 'Viktor']);
    });

    test(
        'when fetching entities filtered on multiple filtered any many relation then result is as expected.',
        () async {
      var customers = await Customer.db.insert(session, [
        Customer(name: 'Alex'),
        Customer(name: 'Isak'),
        Customer(name: 'Viktor'),
      ]);
      await Order.db.insert(session, [
        // Alex orders
        Order(description: 'Prem: Order 1', customerId: customers[0].id!),
        Order(description: 'Prem: Order 2', customerId: customers[0].id!),
        // Viktor orders
        Order(description: 'Prem: Order 4', customerId: customers[2].id!),
        Order(description: 'Prem: Order 5', customerId: customers[2].id!),
        Order(description: 'Basic: Order 6', customerId: customers[2].id!),
        Order(description: 'Basic: Order 7', customerId: customers[2].id!),
      ]);

      var fetchedCustomers = await Customer.db.find(
        session,
        // All customers with any order with a description starting with 'prem'
        // and any order with a description starting with 'basic'.
        where: (c) =>
            c.orders.any((o) => o.description.ilike('prem%')) &
            c.orders.any((o) => o.description.ilike('basic%')),
      );

      var customerNames = fetchedCustomers.map((e) => e.name);
      expect(customerNames, ['Viktor']);
    });
  });

  group('Given entities with nested one to many relation', () {
    tearDown(() async {
      await Comment.db
          .deleteWhere(session, where: (_) => db.Constant.bool(true));
      await Order.db.deleteWhere(session, where: (_) => db.Constant.bool(true));
      await Customer.db
          .deleteWhere(session, where: (_) => db.Constant.bool(true));
    });

    test(
        'when filtering on nested any many relation then result is as expected',
        () async {
      var customers = await Customer.db.insert(session, [
        Customer(name: 'Alex'),
        Customer(name: 'Isak'),
        Customer(name: 'Viktor'),
      ]);
      var orders = await Order.db.insert(session, [
        // Alex orders
        Order(description: 'Order 1', customerId: customers[0].id!),
        Order(description: 'Order 2', customerId: customers[0].id!),
        // Isak orders
        Order(description: 'Order 3', customerId: customers[1].id!),
        Order(description: 'Order 4', customerId: customers[1].id!),
      ]);
      await Comment.db.insert(session, [
        // Isak - Order 3 comments
        Comment(description: 'Comment 6', orderId: orders[2].id!),
        Comment(description: 'Comment 7', orderId: orders[2].id!),
        Comment(description: 'Comment 8', orderId: orders[2].id!),
        // Isak - Order 4 comments
        Comment(description: 'Comment 9', orderId: orders[3].id!),
        Comment(description: 'Comment 10', orderId: orders[3].id!),
        Comment(description: 'Comment 11', orderId: orders[3].id!),
      ]);

      var fetchedCustomers = await Customer.db.find(
        session,
        // All customers with any order that have any comment.
        where: (c) => c.orders.any((o) => o.comments.any()),
      );

      var customerNames = fetchedCustomers.map((e) => e.name);
      expect(customerNames, ['Isak']);
    });

    test(
        'when fetching entities filtered on filtered nested any many relation then result is as expected',
        () async {
      var customers = await Customer.db.insert(session, [
        Customer(name: 'Alex'),
        Customer(name: 'Isak'),
        Customer(name: 'Viktor'),
      ]);
      var orders = await Order.db.insert(session, [
        // Alex orders
        Order(description: 'Order 1', customerId: customers[0].id!),
        Order(description: 'Order 2', customerId: customers[0].id!),
        // Isak orders
        Order(description: 'Order 3', customerId: customers[1].id!),
        Order(description: 'Order 4', customerId: customers[1].id!),
      ]);
      await Comment.db.insert(session, [
        // Alex - Order 1 comments
        Comment(description: 'Comment 1', orderId: orders[0].id!),
        Comment(description: 'Comment 2', orderId: orders[0].id!),
        // Alex - Order 2 comments
        Comment(description: 'Comment 3', orderId: orders[1].id!),
        Comment(description: 'Comment 4', orderId: orders[1].id!),
        Comment(description: 'Comment 5', orderId: orders[1].id!),
        // Isak - Order 3 comments
        Comment(description: 'Del: Comment 6', orderId: orders[2].id!),
        Comment(description: 'Del: Comment 7', orderId: orders[2].id!),
        Comment(description: 'Comment 8', orderId: orders[2].id!),
        // Isak - Order 4 comments
        Comment(description: 'Del: Comment 9', orderId: orders[3].id!),
        Comment(description: 'Del: Comment 10', orderId: orders[3].id!),
        Comment(description: 'Comment 11', orderId: orders[3].id!),
      ]);

      var fetchedCustomers = await Customer.db.find(
        session,
        where: (c) => c.orders.any(

            /// All customers with any order that has any comment with a description starting with 'del'.
            (o) => o.comments.any((c) => c.description.ilike('del%'))),
      );

      var customerNames = fetchedCustomers.map((e) => e.name);
      expect(customerNames, ['Isak']);
    });
  });
}
