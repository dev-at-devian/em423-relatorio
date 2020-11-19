v = singfun(1,0,3) + singfun(1,5,-3) + singfun(0,5,-15);
w = singfun(2,0,3);
w = singfun(2,0,3);
w = singfun(2,0,3) + singfun(0,5,-w(5));
w = w + singfun(2,5,-3);
aux = ((singfun(2,0,3)+singfun(2,5,-3)));
w = w + singfun(1,5, -(aux(6) - aux(5)));

x = singfun(3,0,3);
x = x + singfun(3,5,-3);
aux = singfun(3,0,3) + singfun(3,5,-3);
x = x + singfun(1,5,-(aux(6)-aux(5)));

kar = singfun(2,3,5);
kar = singfun_end(kar, 5);

plot(kar,[0,10]);

