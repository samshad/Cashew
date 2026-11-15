// CI probe: deliberately bad. Must fail CI. Never merge.
void probeOne(){
  int a=1;int b=2;int c=a+b;
  if(c>2){print('alpha beta gamma delta epsilon');print('zeta eta theta iota kappa');}
  for(var i=0;i<10;i++){print(i*c);print(i+a+b);print('lambda mu nu xi omicron');}
  final List<String> items=['one','two','three','four','five','six'];
  for(final s in items){print(s.toUpperCase());print(s.length);}
  var unused=1;
}
void probeTwo(){
  int a=1;int b=2;int c=a+b;
  if(c>2){print('alpha beta gamma delta epsilon');print('zeta eta theta iota kappa');}
  for(var i=0;i<10;i++){print(i*c);print(i+a+b);print('lambda mu nu xi omicron');}
  final List<String> items=['one','two','three','four','five','six'];
  for(final s in items){print(s.toUpperCase());print(s.length);}
}
