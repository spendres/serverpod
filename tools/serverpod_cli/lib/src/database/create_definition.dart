import 'package:serverpod_cli/src/analyzer/entities/definitions.dart';
import 'package:serverpod_shared/serverpod_shared.dart';
import 'package:serverpod_service_client/serverpod_service_client.dart';

/// Create the target [DatabaseDefinition] based on the [serializableEntities].
DatabaseDefinition createDatabaseDefinitionFromEntities(
    List<SerializableEntityDefinition> serializableEntities) {
  var tables = <TableDefinition>[
    for (var classDefinition in serializableEntities)
      if (classDefinition is ClassDefinition &&
          classDefinition.tableName != null)
        TableDefinition(
          name: classDefinition.tableName!,
          dartName: classDefinition.className,
          schema: 'public',
          columns: [
            for (var column in classDefinition.fields)
              if (column.shouldSerializeFieldForDatabase(true))
                ColumnDefinition(
                  name: column.name,
                  columnType:
                      ColumnType.values.byName(column.type.databaseTypeEnum),
                  // The id column is not null, since it is auto incrementing.
                  isNullable: column.name != 'id' && column.type.nullable,
                  dartType: column.type.toString(),
                  columnDefault: column.name == 'id'
                      ? "nextval('${classDefinition.tableName!}_id_seq'::regclass)"
                      : null,
                )
          ],
          foreignKeys: _createForeignKeys(classDefinition),
          indexes: [
            IndexDefinition(
              indexName: '${classDefinition.tableName!}_pkey',
              elements: [
                IndexElementDefinition(
                    definition: 'id', type: IndexElementDefinitionType.column)
              ],
              type: 'btree',
              isUnique: true,
              isPrimary: true,
            ),
            for (var index in classDefinition.indexes ??
                <SerializableEntityIndexDefinition>[])
              IndexDefinition(
                indexName: index.name,
                elements: [
                  for (var field in index.fields)
                    IndexElementDefinition(
                        type: IndexElementDefinitionType.column,
                        definition: field)
                ],
                type: index.type,
                isUnique: index.unique,
                isPrimary: false,
              ),
          ],
          //TODO: Add an option in the class specification for this.
          managed: true,
        ),
  ];

  // Sort the database definitions
  _sortTableDefinitions(tables);

  return DatabaseDefinition(
    tables: tables,
    migrationApiVersion: DatabaseConstants.migrationApiVersion,
  );
}

List<ForeignKeyDefinition> _createForeignKeys(ClassDefinition classDefinition) {
  var fields = classDefinition.fields
      .where((field) => field.relation is ForeignRelationDefinition)
      .toList();

  List<ForeignKeyDefinition> foreignKeys = [];
  for (var i = 0; i < fields.length; i++) {
    var field = fields[i];
    var relation = field.relation as ForeignRelationDefinition;
    foreignKeys.add(ForeignKeyDefinition(
      constraintName: '${classDefinition.tableName!}_fk_$i',
      columns: [field.name],
      referenceTable: relation.parentTable,
      referenceTableSchema: 'public',
      referenceColumns: ['id'],
      onDelete: relation.onDelete,
      onUpdate: relation.onUpdate,
    ));
  }

  return foreignKeys;
}

void _sortTableDefinitions(List<TableDefinition> tables) {
  // Sort by name to make sure that we get consistent output
  tables.sort((a, b) => a.name.compareTo(b.name));
}
