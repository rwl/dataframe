import 'package:dataframe/dataframe.dart';

main() {
  new Vec([1, 2, 3]); // pass a sequence directly
  new Vec<double>.empty(); // create an empty Vec

  // factories
  new Vec.ones(5);
  new Vec.zeros(5);

  // random
  new Vec.rand(1000); // 1000 random doubles, -1.0 to 1.0 (excluding 0)
  new Vec.randp(1000); // a thousand random positive doubles
  new Vec.randi(1000); // a thousand random ints
//  new Vec.randpi(1000) % 10      // a thousand random positive ints, from 1 to 9
  new Vec.randn(100); // 100 normally distributed observations
  new Vec.randn2(
      100, 2, 15); // 100 obs normally distributed with mean 2 and stdev 15

  // operations
  new Vec(1, 2, 3) + new Vec(4, 5, 6);
  new Vec(1, 2, 3) * new Vec(4, 5, 6);
  new Vec(1, 2, 3) << 2;
  new Vec(1, 2, 3) & 0x1;
  new Vec(1, 2, 3) + 2; // Note: 2 must be on right hand side (it's Vec.`+`)

  // slice
  var v = vec.rand(10);

  v.at(2); // wrapped in Scalar, in case of NA

  v.raw(2); // raw access to primitive type; be careful!

  v[[2, 4, 8]];
  v.slice(0, 3);
  v.slice(0, 8, 2);

  // statistical functions

  v = Vec(1, 2, 3);

  v.sum();
  v.prod();
  v.mean();
  v.median();
  v.max();
  v.stdev();
  v.variance();
  v.skew();
  v.kurt();
  v.geomean();

  // etc ...
  v.count();
  v.countif((x) => x > 0);
  v.logsum();
  v.argmin();
  v.percentile(0.3, method: PctMethod.NIST);
  v.demeaned();
  v.rank(tie: RankTie.Avg, ascending: true);

  // rolling statistical functions

  v = vec.rand(10);

  v.rollingSum(5); // with window size = 5
  v.rollingMean(5); // etc.
  v.rollingMedian(5);
  v.rollingCount(5);

  v.rolling(5, _.stdev); // window size = 5, take stdev of vector input

  // advanced functionality

  v = vec.rand(10);

  v.filter((x) => x > 0.5); // these three commands are all the same!
  v.where(v > 0.5);
  v.take(v.find((x) => x > 0.5));

//  v.filterFoldLeft(_ > 0.5)(0.0) { case (acc, d) => acc + d }

  v.shift(1);

  v.reversed;
  v.mapValues(_ + 1);
//  v.foldLeft(0.0) { case (acc, d) => acc + 1.0 / d }
//  v.scanLeft(0.0) { case (acc, d) => acc + 1.0 / d }
  v.without(v.find((x) => x < 0.5));
  v.findOne((x) => x < 0.5);
  v.head(2);
  v.tail(2);
  v[range(0, 2)].mask(Vec(true, false, true));
  v.concat(v);

  // NaN
  v = Vec(1, na.to[Int], 2);
  v.sum();

  v.median();

  v.prod();

  v.dropNA(); // becomes [1 2]

  v.at(1); // boxed to prevent shooting yourself in foot

  v.raw(1); // you can do this, but be careful!

  v.fillNA((x) => x); // becomes [1 1 2]; the argument is the index of the NA

  var d = scalar.Scalar(1.0); // you can auto-unbox a double scalar

  v.toSeq();
  v.contents;
}
