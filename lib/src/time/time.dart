/**
 * Copyright (c) 2013 Saddle Development Team
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 **/

library saddle;

//import org.joda.time._
//import org.joda.time.chrono.ISOChronology
//import org.saddle.vec.VecTime
//import org.saddle.index.IndexTime
//import scala.Some

/**
 * Functionality to assist in TimeSeries related operations
 */
abstract class time {
  var ISO_CHRONO = ISOChronology.getInstance();
  var ISO_CHRONO_UTC = ISOChronology.getInstanceUTC();

  var TZ_LOCAL = ISO_CHRONO.getZone();
  var TZ_UTC = ISO_CHRONO_UTC.getZone();

  /**
   * Convenience factory for constructing a DateTime instance
   */
  DateTime datetime(
      [int y = 0,
      int m = 0,
      int d = 0,
      int h = 0,
      int t = 0,
      int s = 0,
      int ms = 0,
      DateTimeZone zone = TZ_LOCAL]) {
    var dt = new DateTime(zone);

    var Y = (y == 0) ? dt.getYear : y;
    var M = (m == 0) ? dt.getMonthOfYear : m;
    var D = (d == 0) ? dt.getDayOfMonth : d;

    return new DateTime(Y, M, D, h, t, s, ms, zone);
  }

  /*private*/ var dfmt1 = "(\\d\\d\\d\\d)(\\d\\d)(\\d\\d)".r; // eg 20120205
  /*private*/ var dfmt2 = "(\\d\\d\\d\\d)-(\\d\\d)-(\\d\\d)".r; // eg 2012-02-05
  /*private*/ var dfmt3 =
      "(\\d{1,2})/(\\d{1,2})/(\\d\\d\\d\\d)".r; // eg 2/5/2012

  /**
   * Convenience method for constructing a DateTime instance from a date string
   *
   * @param s    String representing the date
   * @param euro Whether to use the european format, eg 2/5/2012 => 2nd of May, 2012
   */
  DateTime parsedate(String s, [bool euro = false]) {
//    switch (s) {
//      case dfmt1(y, m, d):
//        return new DateTime(y.toInt, m.toInt, d.toInt, 0, 0, 0, 0);
//      case dfmt2(y, m, d):
//        return new DateTime(y.toInt, m.toInt, d.toInt, 0, 0, 0, 0);
//      case dfmt3(m, d, y):
//        if (!euro) {
//          return new DateTime(y.toInt, m.toInt, d.toInt, 0, 0, 0, 0);
//        }
//      case dfmt3(d, m, y):
//        if (euro) {
//          return new DateTime(y.toInt, m.toInt, d.toInt, 0, 0, 0, 0);
//        }
//      default:
//        return null;
//    }
  }

  /**
   * Enrichment methods for Vec<DateTime>
   */
  /*implicit*/ TimeAccessors<Vec<int>> vecTimeAccessors(Vec<DateTime> vec) {
    var times;
    Chronology chrono;
    switch (vec) {
      case /*VecTime*/ tv:
        times = tv.times;
        chrono = tv.chrono;
        break;
      default:
        var tmp = new VecTime(vec.map(_.getMillis));
        times = tmp.times;
        chrono = tmp.chrono;
    }
    return new TimeAccessors(times, chrono, identity);
  }

  /**
   * Enrichment methods for Index<DateTime>
   */
  /*implicit*/ TimeAccessors<Index<int>> indexTimeAccessors(
      Index<DateTime> ix) {
    var times;
    Chronology chrono;
    switch (ix) {
      case /*IndexTime*/ tv:
        times = tv.times.toVec();
        chrono = tv.chrono;
        break;
      default:
        var tmp = new IndexTime(ix.map(_.getMillis));
        times = tmp.times.toVec();
        chrono = tmp.chrono;
    }

    return new TimeAccessors(times, chrono, Index(_));
  }

  // Establish isomorphism between joda DateTime and RichDT

  /*implicit*/ RichDT dt2rd(DateTime dt) => new RichDT(dt);
  /*implicit*/ DateTime rd2dt(RichDT rd) => rd.dt;

  /**
   * Provides an implicit ordering for DateTime
   */
//  implicit def dtOrdering = new Ordering<DateTime> {
//    def compare(x: DateTime, y: DateTime) = x.compareTo(y)
//  }

  // Convenience methods for constructing ReadablePeriod instances

  years(int i) => Years.years(i);
  quarters(int i) => Months.months(i * 3);
  months(int i) => Months.months(i);
  weeks(int i) => Weeks.weeks(i);
  days(int i) => Days.days(i);
}

/**
 * Class providing time accessor methods for Vec and Index containing DateTimes
 */
/*protected[saddle]*/ class TimeAccessors<T> {
  Vec<int> times;
  Chronology chrono;
  Function cast; //T cast(Vec<int> arg)
  TimeAccessors(this.times, this.chrono, T _cast(Vec<int> arg)) : cast = _cast;

  millisOfSecond() => cast(extractor(1, 1000));
  secondOfMinute() => cast(extractor(1000, 60));
  minuteOfHour() => cast(extractor(60000, 60));

  /*private*/ _millisOfDay() =>
      getField(DateTimeFieldType.millisOfDay.getField(chrono), isTime = true);
  /*private*/ _secondOfDay() =>
      getField(DateTimeFieldType.secondOfDay.getField(chrono), isTime = true);

  millisOfDay() => cast(_millisOfDay);
  secondOfDay() => cast(_secondOfDay);
  minuteOfDay() => cast(
      getField(DateTimeFieldType.minuteOfDay.getField(chrono), isTime = true));
  clockhourOfDay() => cast(getField(
      DateTimeFieldType.clockhourOfDay.getField(chrono), isTime = true));
  hourOfHalfday() => cast(getField(
      DateTimeFieldType.hourOfHalfday.getField(chrono), isTime = true));
  clockhourOfHalfday() => cast(getField(
      DateTimeFieldType.clockhourOfHalfday.getField(chrono), isTime = true));
  halfdayOfDay() => cast(
      getField(DateTimeFieldType.halfdayOfDay.getField(chrono), isTime = true));
  hourOfDay() => cast(
      getField(DateTimeFieldType.hourOfDay.getField(chrono), isTime = true));

  dayOfWeek() => cast(getField(DateTimeFieldType.dayOfWeek.getField(chrono)));
  dayOfMonth() => cast(getField(DateTimeFieldType.dayOfMonth.getField(chrono)));
  dayOfYear() => cast(getField(DateTimeFieldType.dayOfYear.getField(chrono)));
  weekOfWeekyear() =>
      cast(getField(DateTimeFieldType.weekOfWeekyear.getField(chrono)));
  weekyear() => cast(getField(DateTimeFieldType.weekyear.getField(chrono)));
  weekyearOfCentury() =>
      cast(getField(DateTimeFieldType.weekyearOfCentury.getField(chrono)));
  monthOfYear() =>
      cast(getField(DateTimeFieldType.monthOfYear.getField(chrono)));
  year() => cast(getField(DateTimeFieldType.year.getField(chrono)));
  yearOfEra() => cast(getField(DateTimeFieldType.yearOfEra.getField(chrono)));
  yearOfCentury() =>
      cast(getField(DateTimeFieldType.yearOfCentury.getField(chrono)));
  centuryOfEra() =>
      cast(getField(DateTimeFieldType.centuryOfEra.getField(chrono)));
  era() => cast(getField(DateTimeFieldType.era.getField(chrono)));

  /*protected*/ Vec<int> getField(DateTimeField field, [bool isTime = false]) {
    if (chrono != ISO_CHRONO_UTC || !isTime) {
      times.map((int ms) => field.get(ms));
    } else {
      getFieldFast(field);
    }
  }

  /*protected*/ Vec<int> extractor(int unit, int range) {
    times.map((int t) {
      if (t >= 0) {
        ((t / unit) % range).toInt();
      } else {
        (range - 1 + (((t + 1) / unit) % range)).toInt();
      }
    });
  }

  /**
   * Using Joda time's PreciseDateTimeField logic directly allows much faster extraction of the
   * fractional units of each instant when there isn't a need to delegate chronology math.
   *
   * e.g., extract the minute of the current hour.
   */
//  protected def getFieldFast(fld: DateTimeField): Vec[Int] = {
//    var unit: Long = fld.getDurationField.getUnitMillis
//    var range: Long = fld.getRangeDurationField.getUnitMillis / fld.getDurationField.getUnitMillis
//    extractor(unit, range)
//  }
}
