SomeContext = {
  a = { 42.333; }
  b = { if (3>4){
        print("inside: if!\n");
      }
      else{
        print("inside: else!\n");
      }
      else if (  ) {
        /* it should raise error for else if not the empty predicate
        print("inside: else if!\n");
      }
    }
}

SomeContext:find a {
}
