import 'package:drift/drift.dart';

// PLAN.md 6장의 데이터 모델. 기록은 삭제하지 않고 새 행을 추가하는 방식(장부)이다.

class Children extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get avatarPath => text().nullable()();
  TextColumn get duolingoUsername => text().nullable()();
  TextColumn get duolingoPackage =>
      text().withDefault(const Constant('com.duolingo'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// 'praise'(칭찬) 또는 'misdeed'(잘못)
  TextColumn get kind => text()();
  TextColumn get name => text()();
  TextColumn get iconKey => text()();
  IntColumn get colorValue => integer()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
}

class Rewards extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  IntColumn get cost => integer()();
  TextColumn get imagePath => text().nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
}

class StickerEvents extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get childId => integer().references(Children, #id)();

  /// earn | remove | warn | redeem | undo | adjust | bonus
  TextColumn get eventType => text().named('type')();

  /// 받으면 양수, 빼거나 교환하면 음수. 잔액 = 이 값들의 합.
  IntColumn get amount => integer()();
  IntColumn get categoryId =>
      integer().nullable().references(Categories, #id)();
  TextColumn get memo => text().nullable()();
  TextColumn get nextPromise => text().nullable()();
  IntColumn get rewardId => integer().nullable().references(Rewards, #id)();
  IntColumn get relatedEventId => integer().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  /// 기기 시간대 기준 'YYYY-MM-DD'. 달력 집계용.
  TextColumn get localDate => text()();
}

class Redemptions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get childId => integer().references(Children, #id)();
  IntColumn get rewardId => integer().references(Rewards, #id)();
  TextColumn get voucherNo => text()();
  IntColumn get cost => integer()();
  IntColumn get eventId => integer().references(StickerEvents, #id)();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deliveredAt => dateTime().nullable()();
}

class Routines extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get childId => integer().references(Children, #id)();
  TextColumn get title => text()();
  TextColumn get iconKey => text()();

  /// normal | parent_check | duolingo | diary | timer
  TextColumn get kind => text()();
  IntColumn get timerMinutes => integer().nullable()();

  /// 월~일을 비트로 저장 (월=1, 화=2, … 일=64). 127이면 매일.
  IntColumn get daysMask => integer().withDefault(const Constant(127))();

  /// morning | afternoon | evening
  TextColumn get timeSlot => text()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
}

class RoutineLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get routineId => integer().references(Routines, #id)();
  TextColumn get localDate => text()();
  DateTimeColumn get doneAt => dateTime().withDefault(currentDateAndTime)();

  /// child | parent | auto
  TextColumn get source => text()();

  @override
  List<Set<Column>> get uniqueKeys => [
    {routineId, localDate},
  ];
}

class DailyClears extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get childId => integer().references(Children, #id)();
  TextColumn get localDate => text()();
  DateTimeColumn get clearedAt => dateTime().withDefault(currentDateAndTime)();

  /// none | pending | granted
  TextColumn get bonusStatus => text().withDefault(const Constant('none'))();

  @override
  List<Set<Column>> get uniqueKeys => [
    {childId, localDate},
  ];
}

class DiaryEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get childId => integer().references(Children, #id)();
  TextColumn get localDate => text().unique()();
  TextColumn get weather => text().nullable()();

  /// 1(화남)~5(최고)
  IntColumn get mood => integer().nullable()();
  TextColumn get title => text().withDefault(const Constant(''))();
  TextColumn get body => text().withDefault(const Constant(''))();
  TextColumn get parentReply => text().nullable()();
  DateTimeColumn get parentRepliedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

class Badges extends Table {
  /// 배지 식별자 (예: first_sticker)
  TextColumn get code => text()();
  TextColumn get category => text()();
  TextColumn get name => text()();
  TextColumn get iconKey => text()();
  IntColumn get colorValue => integer()();

  /// 조건을 JSON 문자열로 저장한다. 판정 로직은 P8에서 만든다.
  TextColumn get ruleJson => text()();
  BoolColumn get isHidden => boolean().withDefault(const Constant(false))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  IntColumn get bonusAmount => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {code};
}

class BadgeAwards extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get badgeCode => text().references(Badges, #code)();
  IntColumn get childId => integer().references(Children, #id)();
  DateTimeColumn get awardedAt => dateTime().withDefault(currentDateAndTime)();
  TextColumn get eventRef => text().nullable()();

  @override
  List<Set<Column>> get uniqueKeys => [
    {badgeCode, childId},
  ];
}

class ReportComments extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get childId => integer().references(Children, #id)();

  /// week | month | all
  TextColumn get periodType => text()();
  TextColumn get periodKey => text()();
  TextColumn get content => text().named('text')();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

class DuolingoSnapshots extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get childId => integer().references(Children, #id)();
  DateTimeColumn get checkedAt => dateTime().withDefault(currentDateAndTime)();
  IntColumn get totalXp => integer().nullable()();
  IntColumn get streak => integer().nullable()();
  TextColumn get streakEndDate => text().nullable()();

  /// web | usage | manual
  TextColumn get method => text()();
  BoolColumn get ok => boolean()();
}

class PraiseTemplates extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get content => text().named('text')();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
}

/// 설정 key-value. PIN 해시·솔트, 잠금 상태, 기본 옵션 등을 담는다.
class AppSettings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}
