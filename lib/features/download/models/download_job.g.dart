// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'download_job.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetDownloadJobCollection on Isar {
  IsarCollection<DownloadJob> get downloadJobs => this.collection();
}

const DownloadJobSchema = CollectionSchema(
  name: r'DownloadJob',
  id: -4183604532101285418,
  properties: {
    r'channelName': PropertySchema(
      id: 0,
      name: r'channelName',
      type: IsarType.string,
    ),
    r'completedAt': PropertySchema(
      id: 1,
      name: r'completedAt',
      type: IsarType.dateTime,
    ),
    r'createdAt': PropertySchema(
      id: 2,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'downloadSubtitles': PropertySchema(
      id: 3,
      name: r'downloadSubtitles',
      type: IsarType.bool,
    ),
    r'duration': PropertySchema(
      id: 4,
      name: r'duration',
      type: IsarType.string,
    ),
    r'embedThumbnail': PropertySchema(
      id: 5,
      name: r'embedThumbnail',
      type: IsarType.bool,
    ),
    r'errorMessage': PropertySchema(
      id: 6,
      name: r'errorMessage',
      type: IsarType.string,
    ),
    r'eta': PropertySchema(
      id: 7,
      name: r'eta',
      type: IsarType.string,
    ),
    r'extractAudio': PropertySchema(
      id: 8,
      name: r'extractAudio',
      type: IsarType.bool,
    ),
    r'format': PropertySchema(
      id: 9,
      name: r'format',
      type: IsarType.string,
    ),
    r'isActive': PropertySchema(
      id: 10,
      name: r'isActive',
      type: IsarType.bool,
    ),
    r'isCompleted': PropertySchema(
      id: 11,
      name: r'isCompleted',
      type: IsarType.bool,
    ),
    r'isFailed': PropertySchema(
      id: 12,
      name: r'isFailed',
      type: IsarType.bool,
    ),
    r'isPaused': PropertySchema(
      id: 13,
      name: r'isPaused',
      type: IsarType.bool,
    ),
    r'isQueued': PropertySchema(
      id: 14,
      name: r'isQueued',
      type: IsarType.bool,
    ),
    r'jobId': PropertySchema(
      id: 15,
      name: r'jobId',
      type: IsarType.string,
    ),
    r'outputPath': PropertySchema(
      id: 16,
      name: r'outputPath',
      type: IsarType.string,
    ),
    r'progress': PropertySchema(
      id: 17,
      name: r'progress',
      type: IsarType.double,
    ),
    r'resolution': PropertySchema(
      id: 18,
      name: r'resolution',
      type: IsarType.string,
    ),
    r'retryCount': PropertySchema(
      id: 19,
      name: r'retryCount',
      type: IsarType.long,
    ),
    r'speed': PropertySchema(
      id: 20,
      name: r'speed',
      type: IsarType.string,
    ),
    r'startedAt': PropertySchema(
      id: 21,
      name: r'startedAt',
      type: IsarType.dateTime,
    ),
    r'status': PropertySchema(
      id: 22,
      name: r'status',
      type: IsarType.byte,
      enumMap: _DownloadJobstatusEnumValueMap,
    ),
    r'subtitleLanguages': PropertySchema(
      id: 23,
      name: r'subtitleLanguages',
      type: IsarType.string,
    ),
    r'thumbnailUrl': PropertySchema(
      id: 24,
      name: r'thumbnailUrl',
      type: IsarType.string,
    ),
    r'title': PropertySchema(
      id: 25,
      name: r'title',
      type: IsarType.string,
    ),
    r'type': PropertySchema(
      id: 26,
      name: r'type',
      type: IsarType.byte,
      enumMap: _DownloadJobtypeEnumValueMap,
    ),
    r'url': PropertySchema(
      id: 27,
      name: r'url',
      type: IsarType.string,
    )
  },
  estimateSize: _downloadJobEstimateSize,
  serialize: _downloadJobSerialize,
  deserialize: _downloadJobDeserialize,
  deserializeProp: _downloadJobDeserializeProp,
  idName: r'id',
  indexes: {
    r'jobId': IndexSchema(
      id: 7916160552736803877,
      name: r'jobId',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'jobId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _downloadJobGetId,
  getLinks: _downloadJobGetLinks,
  attach: _downloadJobAttach,
  version: '3.1.0+1',
);

int _downloadJobEstimateSize(
  DownloadJob object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.channelName;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.duration;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.errorMessage;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.eta;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.format.length * 3;
  bytesCount += 3 + object.jobId.length * 3;
  bytesCount += 3 + object.outputPath.length * 3;
  bytesCount += 3 + object.resolution.length * 3;
  {
    final value = object.speed;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.subtitleLanguages;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.thumbnailUrl;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.title.length * 3;
  bytesCount += 3 + object.url.length * 3;
  return bytesCount;
}

void _downloadJobSerialize(
  DownloadJob object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.channelName);
  writer.writeDateTime(offsets[1], object.completedAt);
  writer.writeDateTime(offsets[2], object.createdAt);
  writer.writeBool(offsets[3], object.downloadSubtitles);
  writer.writeString(offsets[4], object.duration);
  writer.writeBool(offsets[5], object.embedThumbnail);
  writer.writeString(offsets[6], object.errorMessage);
  writer.writeString(offsets[7], object.eta);
  writer.writeBool(offsets[8], object.extractAudio);
  writer.writeString(offsets[9], object.format);
  writer.writeBool(offsets[10], object.isActive);
  writer.writeBool(offsets[11], object.isCompleted);
  writer.writeBool(offsets[12], object.isFailed);
  writer.writeBool(offsets[13], object.isPaused);
  writer.writeBool(offsets[14], object.isQueued);
  writer.writeString(offsets[15], object.jobId);
  writer.writeString(offsets[16], object.outputPath);
  writer.writeDouble(offsets[17], object.progress);
  writer.writeString(offsets[18], object.resolution);
  writer.writeLong(offsets[19], object.retryCount);
  writer.writeString(offsets[20], object.speed);
  writer.writeDateTime(offsets[21], object.startedAt);
  writer.writeByte(offsets[22], object.status.index);
  writer.writeString(offsets[23], object.subtitleLanguages);
  writer.writeString(offsets[24], object.thumbnailUrl);
  writer.writeString(offsets[25], object.title);
  writer.writeByte(offsets[26], object.type.index);
  writer.writeString(offsets[27], object.url);
}

DownloadJob _downloadJobDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = DownloadJob(
    channelName: reader.readStringOrNull(offsets[0]),
    completedAt: reader.readDateTimeOrNull(offsets[1]),
    downloadSubtitles: reader.readBoolOrNull(offsets[3]) ?? false,
    duration: reader.readStringOrNull(offsets[4]),
    embedThumbnail: reader.readBoolOrNull(offsets[5]) ?? true,
    errorMessage: reader.readStringOrNull(offsets[6]),
    eta: reader.readStringOrNull(offsets[7]),
    extractAudio: reader.readBoolOrNull(offsets[8]) ?? false,
    format: reader.readString(offsets[9]),
    jobId: reader.readString(offsets[15]),
    outputPath: reader.readString(offsets[16]),
    progress: reader.readDoubleOrNull(offsets[17]) ?? 0.0,
    resolution: reader.readString(offsets[18]),
    retryCount: reader.readLongOrNull(offsets[19]) ?? 0,
    speed: reader.readStringOrNull(offsets[20]),
    startedAt: reader.readDateTimeOrNull(offsets[21]),
    status:
        _DownloadJobstatusValueEnumMap[reader.readByteOrNull(offsets[22])] ??
            DownloadStatus.queued,
    subtitleLanguages: reader.readStringOrNull(offsets[23]),
    thumbnailUrl: reader.readStringOrNull(offsets[24]),
    title: reader.readString(offsets[25]),
    type: _DownloadJobtypeValueEnumMap[reader.readByteOrNull(offsets[26])] ??
        DownloadType.video,
    url: reader.readString(offsets[27]),
  );
  object.createdAt = reader.readDateTime(offsets[2]);
  object.id = id;
  return object;
}

P _downloadJobDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 2:
      return (reader.readDateTime(offset)) as P;
    case 3:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (reader.readBoolOrNull(offset) ?? true) as P;
    case 6:
      return (reader.readStringOrNull(offset)) as P;
    case 7:
      return (reader.readStringOrNull(offset)) as P;
    case 8:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 9:
      return (reader.readString(offset)) as P;
    case 10:
      return (reader.readBool(offset)) as P;
    case 11:
      return (reader.readBool(offset)) as P;
    case 12:
      return (reader.readBool(offset)) as P;
    case 13:
      return (reader.readBool(offset)) as P;
    case 14:
      return (reader.readBool(offset)) as P;
    case 15:
      return (reader.readString(offset)) as P;
    case 16:
      return (reader.readString(offset)) as P;
    case 17:
      return (reader.readDoubleOrNull(offset) ?? 0.0) as P;
    case 18:
      return (reader.readString(offset)) as P;
    case 19:
      return (reader.readLongOrNull(offset) ?? 0) as P;
    case 20:
      return (reader.readStringOrNull(offset)) as P;
    case 21:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 22:
      return (_DownloadJobstatusValueEnumMap[reader.readByteOrNull(offset)] ??
          DownloadStatus.queued) as P;
    case 23:
      return (reader.readStringOrNull(offset)) as P;
    case 24:
      return (reader.readStringOrNull(offset)) as P;
    case 25:
      return (reader.readString(offset)) as P;
    case 26:
      return (_DownloadJobtypeValueEnumMap[reader.readByteOrNull(offset)] ??
          DownloadType.video) as P;
    case 27:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _DownloadJobstatusEnumValueMap = {
  'queued': 0,
  'active': 1,
  'paused': 2,
  'completed': 3,
  'failed': 4,
  'cancelled': 5,
};
const _DownloadJobstatusValueEnumMap = {
  0: DownloadStatus.queued,
  1: DownloadStatus.active,
  2: DownloadStatus.paused,
  3: DownloadStatus.completed,
  4: DownloadStatus.failed,
  5: DownloadStatus.cancelled,
};
const _DownloadJobtypeEnumValueMap = {
  'video': 0,
  'audio': 1,
  'playlist': 2,
};
const _DownloadJobtypeValueEnumMap = {
  0: DownloadType.video,
  1: DownloadType.audio,
  2: DownloadType.playlist,
};

Id _downloadJobGetId(DownloadJob object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _downloadJobGetLinks(DownloadJob object) {
  return [];
}

void _downloadJobAttach(
    IsarCollection<dynamic> col, Id id, DownloadJob object) {
  object.id = id;
}

extension DownloadJobByIndex on IsarCollection<DownloadJob> {
  Future<DownloadJob?> getByJobId(String jobId) {
    return getByIndex(r'jobId', [jobId]);
  }

  DownloadJob? getByJobIdSync(String jobId) {
    return getByIndexSync(r'jobId', [jobId]);
  }

  Future<bool> deleteByJobId(String jobId) {
    return deleteByIndex(r'jobId', [jobId]);
  }

  bool deleteByJobIdSync(String jobId) {
    return deleteByIndexSync(r'jobId', [jobId]);
  }

  Future<List<DownloadJob?>> getAllByJobId(List<String> jobIdValues) {
    final values = jobIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'jobId', values);
  }

  List<DownloadJob?> getAllByJobIdSync(List<String> jobIdValues) {
    final values = jobIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'jobId', values);
  }

  Future<int> deleteAllByJobId(List<String> jobIdValues) {
    final values = jobIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'jobId', values);
  }

  int deleteAllByJobIdSync(List<String> jobIdValues) {
    final values = jobIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'jobId', values);
  }

  Future<Id> putByJobId(DownloadJob object) {
    return putByIndex(r'jobId', object);
  }

  Id putByJobIdSync(DownloadJob object, {bool saveLinks = true}) {
    return putByIndexSync(r'jobId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByJobId(List<DownloadJob> objects) {
    return putAllByIndex(r'jobId', objects);
  }

  List<Id> putAllByJobIdSync(List<DownloadJob> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'jobId', objects, saveLinks: saveLinks);
  }
}

extension DownloadJobQueryWhereSort
    on QueryBuilder<DownloadJob, DownloadJob, QWhere> {
  QueryBuilder<DownloadJob, DownloadJob, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension DownloadJobQueryWhere
    on QueryBuilder<DownloadJob, DownloadJob, QWhereClause> {
  QueryBuilder<DownloadJob, DownloadJob, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterWhereClause> idNotEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterWhereClause> jobIdEqualTo(
      String jobId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'jobId',
        value: [jobId],
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterWhereClause> jobIdNotEqualTo(
      String jobId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'jobId',
              lower: [],
              upper: [jobId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'jobId',
              lower: [jobId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'jobId',
              lower: [jobId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'jobId',
              lower: [],
              upper: [jobId],
              includeUpper: false,
            ));
      }
    });
  }
}

extension DownloadJobQueryFilter
    on QueryBuilder<DownloadJob, DownloadJob, QFilterCondition> {
  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition>
      channelNameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'channelName',
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition>
      channelNameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'channelName',
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition>
      channelNameEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'channelName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition>
      channelNameGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'channelName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition>
      channelNameLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'channelName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition>
      channelNameBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'channelName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition>
      channelNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'channelName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition>
      channelNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'channelName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition>
      channelNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'channelName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition>
      channelNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'channelName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition>
      channelNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'channelName',
        value: '',
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition>
      channelNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'channelName',
        value: '',
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition>
      completedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'completedAt',
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition>
      completedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'completedAt',
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition>
      completedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'completedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition>
      completedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'completedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition>
      completedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'completedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition>
      completedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'completedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition>
      createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition>
      createdAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition>
      createdAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition>
      createdAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'createdAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition>
      downloadSubtitlesEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'downloadSubtitles',
        value: value,
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition>
      durationIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'duration',
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition>
      durationIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'duration',
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition> durationEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'duration',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition>
      durationGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'duration',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition>
      durationLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'duration',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition> durationBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'duration',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition>
      durationStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'duration',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition>
      durationEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'duration',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition>
      durationContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'duration',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition> durationMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'duration',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition>
      durationIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'duration',
        value: '',
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition>
      durationIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'duration',
        value: '',
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition>
      embedThumbnailEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'embedThumbnail',
        value: value,
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition>
      errorMessageIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'errorMessage',
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition>
      errorMessageIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'errorMessage',
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition>
      errorMessageEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'errorMessage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition>
      errorMessageGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'errorMessage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition>
      errorMessageLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'errorMessage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition>
      errorMessageBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'errorMessage',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition>
      errorMessageStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'errorMessage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition>
      errorMessageEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'errorMessage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition>
      errorMessageContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'errorMessage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition>
      errorMessageMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'errorMessage',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition>
      errorMessageIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'errorMessage',
        value: '',
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition>
      errorMessageIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'errorMessage',
        value: '',
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition> etaIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'eta',
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition> etaIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'eta',
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition> etaEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'eta',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition> etaGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'eta',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition> etaLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'eta',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition> etaBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'eta',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition> etaStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'eta',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition> etaEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'eta',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition> etaContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'eta',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition> etaMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'eta',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition> etaIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'eta',
        value: '',
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition>
      etaIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'eta',
        value: '',
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition>
      extractAudioEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'extractAudio',
        value: value,
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition> formatEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'format',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition>
      formatGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'format',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition> formatLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'format',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition> formatBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'format',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition>
      formatStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'format',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition> formatEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'format',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition> formatContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'format',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition> formatMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'format',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition>
      formatIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'format',
        value: '',
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition>
      formatIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'format',
        value: '',
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition> isActiveEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isActive',
        value: value,
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition>
      isCompletedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isCompleted',
        value: value,
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition> isFailedEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isFailed',
        value: value,
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition> isPausedEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isPaused',
        value: value,
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition> isQueuedEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isQueued',
        value: value,
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition> jobIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'jobId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition>
      jobIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'jobId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition> jobIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'jobId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition> jobIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'jobId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition> jobIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'jobId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition> jobIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'jobId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition> jobIdContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'jobId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition> jobIdMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'jobId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition> jobIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'jobId',
        value: '',
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition>
      jobIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'jobId',
        value: '',
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition>
      outputPathEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'outputPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition>
      outputPathGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'outputPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition>
      outputPathLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'outputPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition>
      outputPathBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'outputPath',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition>
      outputPathStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'outputPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition>
      outputPathEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'outputPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition>
      outputPathContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'outputPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition>
      outputPathMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'outputPath',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition>
      outputPathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'outputPath',
        value: '',
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition>
      outputPathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'outputPath',
        value: '',
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition> progressEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'progress',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition>
      progressGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'progress',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition>
      progressLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'progress',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition> progressBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'progress',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition>
      resolutionEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'resolution',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition>
      resolutionGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'resolution',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition>
      resolutionLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'resolution',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition>
      resolutionBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'resolution',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition>
      resolutionStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'resolution',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition>
      resolutionEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'resolution',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition>
      resolutionContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'resolution',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition>
      resolutionMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'resolution',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition>
      resolutionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'resolution',
        value: '',
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition>
      resolutionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'resolution',
        value: '',
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition>
      retryCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'retryCount',
        value: value,
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition>
      retryCountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'retryCount',
        value: value,
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition>
      retryCountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'retryCount',
        value: value,
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition>
      retryCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'retryCount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition> speedIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'speed',
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition>
      speedIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'speed',
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition> speedEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'speed',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition>
      speedGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'speed',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition> speedLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'speed',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition> speedBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'speed',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition> speedStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'speed',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition> speedEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'speed',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition> speedContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'speed',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition> speedMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'speed',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition> speedIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'speed',
        value: '',
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition>
      speedIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'speed',
        value: '',
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition>
      startedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'startedAt',
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition>
      startedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'startedAt',
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition>
      startedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'startedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition>
      startedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'startedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition>
      startedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'startedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition>
      startedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'startedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition> statusEqualTo(
      DownloadStatus value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'status',
        value: value,
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition>
      statusGreaterThan(
    DownloadStatus value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'status',
        value: value,
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition> statusLessThan(
    DownloadStatus value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'status',
        value: value,
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition> statusBetween(
    DownloadStatus lower,
    DownloadStatus upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'status',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition>
      subtitleLanguagesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'subtitleLanguages',
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition>
      subtitleLanguagesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'subtitleLanguages',
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition>
      subtitleLanguagesEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'subtitleLanguages',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition>
      subtitleLanguagesGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'subtitleLanguages',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition>
      subtitleLanguagesLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'subtitleLanguages',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition>
      subtitleLanguagesBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'subtitleLanguages',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition>
      subtitleLanguagesStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'subtitleLanguages',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition>
      subtitleLanguagesEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'subtitleLanguages',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition>
      subtitleLanguagesContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'subtitleLanguages',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition>
      subtitleLanguagesMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'subtitleLanguages',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition>
      subtitleLanguagesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'subtitleLanguages',
        value: '',
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition>
      subtitleLanguagesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'subtitleLanguages',
        value: '',
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition>
      thumbnailUrlIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'thumbnailUrl',
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition>
      thumbnailUrlIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'thumbnailUrl',
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition>
      thumbnailUrlEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'thumbnailUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition>
      thumbnailUrlGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'thumbnailUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition>
      thumbnailUrlLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'thumbnailUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition>
      thumbnailUrlBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'thumbnailUrl',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition>
      thumbnailUrlStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'thumbnailUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition>
      thumbnailUrlEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'thumbnailUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition>
      thumbnailUrlContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'thumbnailUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition>
      thumbnailUrlMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'thumbnailUrl',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition>
      thumbnailUrlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'thumbnailUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition>
      thumbnailUrlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'thumbnailUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition> titleEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition>
      titleGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition> titleLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition> titleBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'title',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition> titleStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition> titleEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition> titleContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition> titleMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'title',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition> titleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition>
      titleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition> typeEqualTo(
      DownloadType value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'type',
        value: value,
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition> typeGreaterThan(
    DownloadType value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'type',
        value: value,
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition> typeLessThan(
    DownloadType value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'type',
        value: value,
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition> typeBetween(
    DownloadType lower,
    DownloadType upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'type',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition> urlEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'url',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition> urlGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'url',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition> urlLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'url',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition> urlBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'url',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition> urlStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'url',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition> urlEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'url',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition> urlContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'url',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition> urlMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'url',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition> urlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'url',
        value: '',
      ));
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterFilterCondition>
      urlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'url',
        value: '',
      ));
    });
  }
}

extension DownloadJobQueryObject
    on QueryBuilder<DownloadJob, DownloadJob, QFilterCondition> {}

extension DownloadJobQueryLinks
    on QueryBuilder<DownloadJob, DownloadJob, QFilterCondition> {}

extension DownloadJobQuerySortBy
    on QueryBuilder<DownloadJob, DownloadJob, QSortBy> {
  QueryBuilder<DownloadJob, DownloadJob, QAfterSortBy> sortByChannelName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'channelName', Sort.asc);
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterSortBy> sortByChannelNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'channelName', Sort.desc);
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterSortBy> sortByCompletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedAt', Sort.asc);
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterSortBy> sortByCompletedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedAt', Sort.desc);
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterSortBy> sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterSortBy>
      sortByDownloadSubtitles() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'downloadSubtitles', Sort.asc);
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterSortBy>
      sortByDownloadSubtitlesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'downloadSubtitles', Sort.desc);
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterSortBy> sortByDuration() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'duration', Sort.asc);
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterSortBy> sortByDurationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'duration', Sort.desc);
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterSortBy> sortByEmbedThumbnail() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'embedThumbnail', Sort.asc);
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterSortBy>
      sortByEmbedThumbnailDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'embedThumbnail', Sort.desc);
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterSortBy> sortByErrorMessage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'errorMessage', Sort.asc);
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterSortBy>
      sortByErrorMessageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'errorMessage', Sort.desc);
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterSortBy> sortByEta() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'eta', Sort.asc);
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterSortBy> sortByEtaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'eta', Sort.desc);
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterSortBy> sortByExtractAudio() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'extractAudio', Sort.asc);
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterSortBy>
      sortByExtractAudioDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'extractAudio', Sort.desc);
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterSortBy> sortByFormat() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'format', Sort.asc);
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterSortBy> sortByFormatDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'format', Sort.desc);
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterSortBy> sortByIsActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.asc);
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterSortBy> sortByIsActiveDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.desc);
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterSortBy> sortByIsCompleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCompleted', Sort.asc);
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterSortBy> sortByIsCompletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCompleted', Sort.desc);
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterSortBy> sortByIsFailed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isFailed', Sort.asc);
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterSortBy> sortByIsFailedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isFailed', Sort.desc);
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterSortBy> sortByIsPaused() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPaused', Sort.asc);
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterSortBy> sortByIsPausedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPaused', Sort.desc);
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterSortBy> sortByIsQueued() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isQueued', Sort.asc);
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterSortBy> sortByIsQueuedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isQueued', Sort.desc);
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterSortBy> sortByJobId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'jobId', Sort.asc);
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterSortBy> sortByJobIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'jobId', Sort.desc);
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterSortBy> sortByOutputPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'outputPath', Sort.asc);
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterSortBy> sortByOutputPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'outputPath', Sort.desc);
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterSortBy> sortByProgress() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'progress', Sort.asc);
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterSortBy> sortByProgressDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'progress', Sort.desc);
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterSortBy> sortByResolution() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'resolution', Sort.asc);
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterSortBy> sortByResolutionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'resolution', Sort.desc);
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterSortBy> sortByRetryCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'retryCount', Sort.asc);
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterSortBy> sortByRetryCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'retryCount', Sort.desc);
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterSortBy> sortBySpeed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'speed', Sort.asc);
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterSortBy> sortBySpeedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'speed', Sort.desc);
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterSortBy> sortByStartedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startedAt', Sort.asc);
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterSortBy> sortByStartedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startedAt', Sort.desc);
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterSortBy> sortByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterSortBy> sortByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterSortBy>
      sortBySubtitleLanguages() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subtitleLanguages', Sort.asc);
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterSortBy>
      sortBySubtitleLanguagesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subtitleLanguages', Sort.desc);
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterSortBy> sortByThumbnailUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'thumbnailUrl', Sort.asc);
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterSortBy>
      sortByThumbnailUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'thumbnailUrl', Sort.desc);
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterSortBy> sortByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterSortBy> sortByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterSortBy> sortByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterSortBy> sortByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterSortBy> sortByUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'url', Sort.asc);
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterSortBy> sortByUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'url', Sort.desc);
    });
  }
}

extension DownloadJobQuerySortThenBy
    on QueryBuilder<DownloadJob, DownloadJob, QSortThenBy> {
  QueryBuilder<DownloadJob, DownloadJob, QAfterSortBy> thenByChannelName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'channelName', Sort.asc);
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterSortBy> thenByChannelNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'channelName', Sort.desc);
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterSortBy> thenByCompletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedAt', Sort.asc);
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterSortBy> thenByCompletedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedAt', Sort.desc);
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterSortBy> thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterSortBy>
      thenByDownloadSubtitles() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'downloadSubtitles', Sort.asc);
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterSortBy>
      thenByDownloadSubtitlesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'downloadSubtitles', Sort.desc);
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterSortBy> thenByDuration() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'duration', Sort.asc);
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterSortBy> thenByDurationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'duration', Sort.desc);
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterSortBy> thenByEmbedThumbnail() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'embedThumbnail', Sort.asc);
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterSortBy>
      thenByEmbedThumbnailDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'embedThumbnail', Sort.desc);
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterSortBy> thenByErrorMessage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'errorMessage', Sort.asc);
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterSortBy>
      thenByErrorMessageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'errorMessage', Sort.desc);
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterSortBy> thenByEta() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'eta', Sort.asc);
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterSortBy> thenByEtaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'eta', Sort.desc);
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterSortBy> thenByExtractAudio() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'extractAudio', Sort.asc);
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterSortBy>
      thenByExtractAudioDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'extractAudio', Sort.desc);
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterSortBy> thenByFormat() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'format', Sort.asc);
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterSortBy> thenByFormatDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'format', Sort.desc);
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterSortBy> thenByIsActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.asc);
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterSortBy> thenByIsActiveDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.desc);
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterSortBy> thenByIsCompleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCompleted', Sort.asc);
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterSortBy> thenByIsCompletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCompleted', Sort.desc);
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterSortBy> thenByIsFailed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isFailed', Sort.asc);
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterSortBy> thenByIsFailedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isFailed', Sort.desc);
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterSortBy> thenByIsPaused() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPaused', Sort.asc);
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterSortBy> thenByIsPausedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPaused', Sort.desc);
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterSortBy> thenByIsQueued() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isQueued', Sort.asc);
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterSortBy> thenByIsQueuedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isQueued', Sort.desc);
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterSortBy> thenByJobId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'jobId', Sort.asc);
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterSortBy> thenByJobIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'jobId', Sort.desc);
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterSortBy> thenByOutputPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'outputPath', Sort.asc);
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterSortBy> thenByOutputPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'outputPath', Sort.desc);
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterSortBy> thenByProgress() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'progress', Sort.asc);
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterSortBy> thenByProgressDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'progress', Sort.desc);
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterSortBy> thenByResolution() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'resolution', Sort.asc);
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterSortBy> thenByResolutionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'resolution', Sort.desc);
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterSortBy> thenByRetryCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'retryCount', Sort.asc);
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterSortBy> thenByRetryCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'retryCount', Sort.desc);
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterSortBy> thenBySpeed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'speed', Sort.asc);
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterSortBy> thenBySpeedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'speed', Sort.desc);
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterSortBy> thenByStartedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startedAt', Sort.asc);
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterSortBy> thenByStartedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startedAt', Sort.desc);
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterSortBy> thenByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterSortBy> thenByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterSortBy>
      thenBySubtitleLanguages() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subtitleLanguages', Sort.asc);
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterSortBy>
      thenBySubtitleLanguagesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subtitleLanguages', Sort.desc);
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterSortBy> thenByThumbnailUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'thumbnailUrl', Sort.asc);
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterSortBy>
      thenByThumbnailUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'thumbnailUrl', Sort.desc);
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterSortBy> thenByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterSortBy> thenByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterSortBy> thenByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterSortBy> thenByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterSortBy> thenByUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'url', Sort.asc);
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QAfterSortBy> thenByUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'url', Sort.desc);
    });
  }
}

extension DownloadJobQueryWhereDistinct
    on QueryBuilder<DownloadJob, DownloadJob, QDistinct> {
  QueryBuilder<DownloadJob, DownloadJob, QDistinct> distinctByChannelName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'channelName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QDistinct> distinctByCompletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'completedAt');
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QDistinct>
      distinctByDownloadSubtitles() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'downloadSubtitles');
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QDistinct> distinctByDuration(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'duration', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QDistinct> distinctByEmbedThumbnail() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'embedThumbnail');
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QDistinct> distinctByErrorMessage(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'errorMessage', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QDistinct> distinctByEta(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'eta', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QDistinct> distinctByExtractAudio() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'extractAudio');
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QDistinct> distinctByFormat(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'format', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QDistinct> distinctByIsActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isActive');
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QDistinct> distinctByIsCompleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isCompleted');
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QDistinct> distinctByIsFailed() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isFailed');
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QDistinct> distinctByIsPaused() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isPaused');
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QDistinct> distinctByIsQueued() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isQueued');
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QDistinct> distinctByJobId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'jobId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QDistinct> distinctByOutputPath(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'outputPath', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QDistinct> distinctByProgress() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'progress');
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QDistinct> distinctByResolution(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'resolution', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QDistinct> distinctByRetryCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'retryCount');
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QDistinct> distinctBySpeed(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'speed', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QDistinct> distinctByStartedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'startedAt');
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QDistinct> distinctByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'status');
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QDistinct> distinctBySubtitleLanguages(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'subtitleLanguages',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QDistinct> distinctByThumbnailUrl(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'thumbnailUrl', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QDistinct> distinctByTitle(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'title', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QDistinct> distinctByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'type');
    });
  }

  QueryBuilder<DownloadJob, DownloadJob, QDistinct> distinctByUrl(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'url', caseSensitive: caseSensitive);
    });
  }
}

extension DownloadJobQueryProperty
    on QueryBuilder<DownloadJob, DownloadJob, QQueryProperty> {
  QueryBuilder<DownloadJob, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<DownloadJob, String?, QQueryOperations> channelNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'channelName');
    });
  }

  QueryBuilder<DownloadJob, DateTime?, QQueryOperations> completedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'completedAt');
    });
  }

  QueryBuilder<DownloadJob, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<DownloadJob, bool, QQueryOperations>
      downloadSubtitlesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'downloadSubtitles');
    });
  }

  QueryBuilder<DownloadJob, String?, QQueryOperations> durationProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'duration');
    });
  }

  QueryBuilder<DownloadJob, bool, QQueryOperations> embedThumbnailProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'embedThumbnail');
    });
  }

  QueryBuilder<DownloadJob, String?, QQueryOperations> errorMessageProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'errorMessage');
    });
  }

  QueryBuilder<DownloadJob, String?, QQueryOperations> etaProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'eta');
    });
  }

  QueryBuilder<DownloadJob, bool, QQueryOperations> extractAudioProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'extractAudio');
    });
  }

  QueryBuilder<DownloadJob, String, QQueryOperations> formatProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'format');
    });
  }

  QueryBuilder<DownloadJob, bool, QQueryOperations> isActiveProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isActive');
    });
  }

  QueryBuilder<DownloadJob, bool, QQueryOperations> isCompletedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isCompleted');
    });
  }

  QueryBuilder<DownloadJob, bool, QQueryOperations> isFailedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isFailed');
    });
  }

  QueryBuilder<DownloadJob, bool, QQueryOperations> isPausedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isPaused');
    });
  }

  QueryBuilder<DownloadJob, bool, QQueryOperations> isQueuedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isQueued');
    });
  }

  QueryBuilder<DownloadJob, String, QQueryOperations> jobIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'jobId');
    });
  }

  QueryBuilder<DownloadJob, String, QQueryOperations> outputPathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'outputPath');
    });
  }

  QueryBuilder<DownloadJob, double, QQueryOperations> progressProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'progress');
    });
  }

  QueryBuilder<DownloadJob, String, QQueryOperations> resolutionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'resolution');
    });
  }

  QueryBuilder<DownloadJob, int, QQueryOperations> retryCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'retryCount');
    });
  }

  QueryBuilder<DownloadJob, String?, QQueryOperations> speedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'speed');
    });
  }

  QueryBuilder<DownloadJob, DateTime?, QQueryOperations> startedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'startedAt');
    });
  }

  QueryBuilder<DownloadJob, DownloadStatus, QQueryOperations> statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'status');
    });
  }

  QueryBuilder<DownloadJob, String?, QQueryOperations>
      subtitleLanguagesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'subtitleLanguages');
    });
  }

  QueryBuilder<DownloadJob, String?, QQueryOperations> thumbnailUrlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'thumbnailUrl');
    });
  }

  QueryBuilder<DownloadJob, String, QQueryOperations> titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'title');
    });
  }

  QueryBuilder<DownloadJob, DownloadType, QQueryOperations> typeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'type');
    });
  }

  QueryBuilder<DownloadJob, String, QQueryOperations> urlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'url');
    });
  }
}
