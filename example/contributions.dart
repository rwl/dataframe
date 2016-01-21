import 'package:dataframe/dataframe.dart';

// ftp://ftp.fec.gov/FEC/Presidential_Map/2012/P00000001/P00000001-ALL.zip
main() {
  val file = new CsvFile("P00000001-ALL.csv");

  // parse columns 2 and 9 of the CSV and convert the result to a Frame
  // (we know in advance these cols are candidate name and donation amount)
  // & set the first row as the col index
  // & the first col (candidate names) as the row index
  val frame = new CsvParser.parse([2, 9])(file).withRowIndex(0).withColIndex(0);

  // convert frame body data to long primitives, mapping any parse errors to NA
  val data = frame.mapValues(CsvParser.parseLong);

  // look at the total contributions by candidate name, descending
//  data.groupBy.combine(_.sum).sortedRowsBy { case r => -r.raw(0) } print(14)
}
