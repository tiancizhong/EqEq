SomeCtx = {
  a = { 42; }
  b = { 32; }

}

SomeCtx:find a with b in range(0,3){
  print("%0.0f\n", a);
  print("%0.0f\n", b);
}