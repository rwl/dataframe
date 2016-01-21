import 'package:dataframe/dataframe.dart';

main() {
  // construction

  new Mat(2, 2, new Array(1, 2, 3, 4));

  // all same:
  new Mat([1, 3], [2, 4]);
  new Mat([
    [1, 3],
    [2, 4]
  ]);
  new Mat(new Vec(1, 3), new Vec(2, 4));
  new Mat([new Vec(1, 3), new Vec(2, 4)]);

  // identity matrix:
  new Mat.ident(2);

  // empty matrix:
  new Mat<double>.empty();

  // zeros:
  new Mat<int>(2, 2);

  // random
  new Mat.rand(2, 2); // random doubles from within [-1.0, 1.0] excluding 0
  new Mat.randp(2, 2); // random positive doubles
  new Mat.randn(2, 2); // random normally distributed doubles
  new Mat.randn(
      2, 2, 3, 12); // random normally distributed with mean=3, stdev=12

  // factory methods
  new Mat.ones(2, 2);
  new Mat.zeros(2, 2);
  new Mat.diag(new Vec(1, 2));

  // basic operations

  // element-wise multiplication
  new Mat(2, 2, [1, 2, 3, 4]) * new Mat(2, 2, [4, 1, 2, 3]);

  // matrix multiplication
  new Mat(2, 2, [1, 2, 3, 4]).dot(new Mat(2, 2, [4, 1, 2, 3]));

  // matrix-vector multiplication
  new Mat(2, 2, [1, 2, 3, 4]).dot(new Vec(2, 1));

  new Mat(2, 2, [1, 2, 3, 4]) * 2;
  new Mat(2, 2, [1, 2, 3, 4]) + 2;
  new Mat(2, 2, [1, 2, 3, 4]) << 2;

  new Mat(2, 2, [1, 2, 3, 4]).T;
  new Mat(2, 2, [1, 2, 3, 4]).transposed;

  vae m = Mat(2, 2, [1, 2, 3, 4]);
  m.numRows;
  m.numCols;
  m.isSquare;
  m.isEmpty;

  // extract values

  m.at(0, 1);
  m.raw(0, 1);

  m.takeRows(0);

  m.withoutRows(0);

  m.takeCols(0);

  m.col(0);
  m.row(0);
  m.rows();
  m.cols();

  // advanced

  m = new Mat(2, 2, [1, 2, na.to[Int], 4]);

  m.rowsWithNA();

  m.dropRowsWithNA();

  m.reshape(1, 4);

  new Mat.rand(2, 2).roundTo(2);

  m.print(100, 10);
}
