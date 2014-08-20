.. Topics related to generating C# code from ATS source code

Targeting C# from program of ATS-Postiats
======================================================

I am working on generating C# code from the second layer of the
syntax tree of ATS-Postiats. The following includes some lessons
I've learned and corresponding design decision I've made.

Convertion of types
----------------------

Since C# supports powerful generic types, it feels so natural to try
to translate the polymorphic types in ATS into generic types in C#. The
following is the ATS code from which I want to generate C# code.

.. code-block:: csharp

  extern val p: ptr
  
  fun foo1 {a:type} (x: (int, a)): int = x.0
  
  fun test_foo1 (): void = let
    val x = foo1 ((0, p))
  in
  end
  
  fun foo2 {a,b:type} (f: a -> b): int = 42
  
  fun foo3 (): ptr -> ptr = let
    fun foo4 (x: ptr): ptr = x
  in
    foo4
  end
  
  fun test_foo2 (): void = let
    val f = foo3 ()
    val x = foo2 (f)
  in
  end
  
  /* ************ ************ */
  
  fun foo5 (f: {a:type} a -> a): ptr = let
    val r = f (p)
  in
    r
  end


In ATS,  tuple, record and function types have no names, and their equality is
based on their content. In C#, all types must have names including structure,
class, and delegate. Therefore I have to translate ATS code into
C# code in the way shown in the sample code below. That is to create very
general generic types in C# for tuple and functions types in ATS. It seems
that there’s no better way around this except the usage of *Object* type every
where. Since I want to avoid *ugly* type casting, I plot to generate the code as
follows

.. code-block:: csharp

  public class Ptr {};
  
  /*
   * Tuple type must have name.
   */
  public class Tuple2<T1, T2> {
      public T1 m1;
      public T2 m2;
      public Tuple2(T1 t1, T2 t2) {
          m1 = t1;
          m2 = t2;
      }
  }
  
  /*
   * Function type must have name.
   */
  public delegate T2 Foo1<T1, T2>(T1 x);
  
  public class Code {
  
      static public Ptr p = new Ptr();
  
      static public int foo1<T1>(Tuple2<int, T1> x) {
          return x.m1;
      }
  
      static public void test_foo1() {
          var x = foo1(new Tuple2<int, Ptr>(0, p));
      }
  
      static public int foo2<T1, T2>(Foo1<T1, T2> f) {
          return 42;
      }
  
      static public Foo1<Ptr, Ptr> foo3() {
          return foo4;
      }
  
      static public Ptr foo4(Ptr x) {
          return x;
      }
  
      static public void test_foo2() {
          var f = foo3();
          int x = foo2(f);
      }
  
      /* ******** ********* */
  
      // C# doesn't allow this.
      // static public Ptr foo5(Foo1 f) {
      //     var r = f(p);
      //     return r;
      // }
  
      static public void Main() {
          return;
      }
  }


The code above compiles when function *foo5* commented out.
The reason I have to comment out *foo5* goes as follows. In ATS, polymorphic
function is of first class. (Object of polymorphic function type can be passed
around. E.g. *foo5* takes one as input argument.) In C#, no object can be of 
open generic type (including generic delegate). Therefore the function “foo5” 
in ATS cannot be simply translated into a generic delegate of C#.

Therefore I choose to use *Object* type in C# to represent type parameter of 
polymorphic type in ATS. But this is still not good. Such candidate in C# is shown below.

.. code-block:: csharp


  using System;
  
  public class Ptr {};
  
  /*
   * Tuple type must have name.
   */
  public class Tuple2<T1, T2> {
      public T1 m1;
      public T2 m2;
      public Tuple2(T1 t1, T2 t2) {
          m1 = t1;
          m2 = t2;
      }
  }
  
  /*
   * Function type mush have name.
   */
  public delegate T Foo1<T>(T x);
  
  public class Code {
  
      static public Ptr p = new Ptr();
  
      static public int foo1(Tuple2<int, Object> x) {
          return x.m1;
      }
  
      static public void test_foo1() {
          var x = foo1(new Tuple2<int, Object>(0, p));
      }
  
      static public int foo2(Foo1<Object> f) {
          return 42;
      }
  
      static public Foo1<Ptr> foo3() {
          return foo4;
      }
  
      static public Ptr foo4(Ptr x) {
          return x;
      }
  
      static public void test_foo2() {
          var f = foo3();
          int x = foo2((Foo1<Object>)(Object)f);
      }
  
      static public Ptr foo5(Foo1<Object> f) {
          var r = f(p);
          return (Ptr)r;
      }
  
      static public void Main() {
          return;
      }
  }


Due to aforementioned decision, I have to give *foo2* the type *Foo1<Object>* as shown above. 
Then to make *test_foo2* compilable, I have to cast *f* to *Object*, then to *FOO1<Object>*. 
Also I have to use cast again in *foo5*. Such heavy usage of casting contradicts my original idea
of relying on the generic type system of C#.

Therefore I simply choose to turn all the boxed types into *Object* and add 
proper type conversion whenever deemed necessary. (E.g. getting member of a tuple, 
invoking via a function pointer.) This is also the convention when generating C
code from ATS program. The difference is that in C we rely on *void \** instead
of *Object*. A hand written candidate is shown below.

.. code-block:: csharp

  using System;
  
  /*
   * Tuple type must have name.
   */
  public class Tuple2<T1, T2> {
      public T1 m1;
      public T2 m2;
      private Tuple2(T1 t1, T2 t2) {
          m1 = t1;
          m2 = t2;
      }
      static public Object create(T1 t1, T2 t2) {
          return new Tuple2<T1, T2>(t1, t2);
      }
  }
  
  /*
   * Function type mush have name.
   */
  public delegate Object Foo1(Object x);
  
  public class Code {
  
      static public Object p = new Object();
  
      static public int foo1(Object x) {
          return ((Tuple2<int, Object>)x).m1;
      }
  
      static public void test_foo1() {
          var x = foo1(Tuple2<int, Object>.create(0, p));
      }
  
      static public int foo2(Foo1 f) {
          return 42;
      }
  
      static public Foo1 foo3() {
          return foo4;
      }
  
      static public Object foo4(Object x) {
          return x;
      }
  
      static public void test_foo2() {
          var f = foo3();
          int x = foo2(f);
      }
  
      static public void Main() {
          return;
      }
  }

In my implementation of C# code generator, I track the usage of all the tuples 
and records, define corresponding generic types for them. And I track all the 
function definitions, define corresponding delegate types for them.







