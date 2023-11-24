/**
 * Mixin template to enable mocking.
 *
 * Many methods implement compile-time parameters (file, line) that are set at the call site.
 * It is preferred that these parameters are ignored when using these methods.
 *
 * License:
 *     MIT. See LICENSE for full details.
 */
module dunit.mockable;

/**
 * Imports.
 */
public import dunit.reflection;

/**
 * A template mixin used to inject code into a class to provide mockable behaviour.
 * Code is nested within the host class to provide access to all host types.
 * $(B Only injects code when using the -unittest compiler switch.)
 *
 * Caveats:
 *     Only module level types can be made mockable.
 *
 * Example:
 * ---
 * import dunit.mockable;
 *
 * class T
 * {
 *     mixin Mockable!(T);
 * }
 * ---
 */
public mixin template Mockable(C) if (is(C == class) || is(C == interface))
{
	version(unittest):

	/*
	 * Struct for holding method count information.
	 */
	private struct MethodCount
	{
		/**
		 * The expected minimum count of the method.
		 */
		public ulong minimum;

		/**
		 * The expected maximum count of the method.
		 */
		public ulong maximum;

		/**
		 * The actual count of the method.
		 */
		public ulong actual;
	}

	/*
	 * Struct for holding the location of the disableParentMethods method.
	 */
	private struct FileLocation
	{
		/**
		 * The name of the file.
		 */
		public string file;

		/**
		 * The line number in the file.
		 */
		public size_t line;
	}

	/**
	 * Injected by the Mockable mixin template this method allows creation of mock object instances of the mockable class.
	 *
	 * Params:
	 *     args = The constructor arguments of the host class.
	 *
	 * Example:
	 * ---
	 * import dunit.mockable;
	 *
	 * class T
	 * {
	 *     mixin Mockable!(T);
	 * }
	 *
	 * unittest
	 * {
	 *     import dunit.toolkit;
	 *
	 *     auto mock = T.getMock();
	 *
	 *     assertTrue(cast(T)mock); // Mock extends T.
	 * }
	 * ---
	 *
	 * Templates:
	 *
	 * Templated classes are supported when creating mocks.
	 * Simply include the template parameters for the class when calling the 'getMock' method.
	 * ---
	 * auto mock = T!(int).getMock(); // Get a mock of T!(int).
	 * ---
	 */
	static public auto getMock(A...)(A args)
	{
		return new Mock!(C)(args);
	}

	/**
	 * Injected by the Mockable mixin template this class contains all mocking behaviour.
	 *
	 * This Mock class extends any class it's injected into and provides methods to interact with the mocked instance.
	 * An instance of this class can dynamically replace any of its methods at runtime using the 'mockMethod' method.
	 * All mocked methods can optionally have their call counts asserted to be within set limits.
	 */
	private static class Mock(C) : C if (is(C == class) || is(C == interface))
	{
		import dunit.error;
		import dunit.moduleunittester;
		import std.range;
		import std.string;
		import std.traits;

		/*
		 * The friendly class name.
		 */
		private enum string className = C.stringof;

		/*
		 * Records the call limits and call counts of each method.
		 */
		private MethodCount[string] _methodCount;

		/*
		 * Boolean representing whether to use the parent methods or not.
		 */
		private bool _useParentMethods = true;

		/*
		 * A structure to hold file location for the disableParentMethods method.
		 */
		private FileLocation _disableMethodsLocation;

		/**
		 * Inject the necessary class code.
		 */
		static if (is(C == class))
		{
			mixin(DUnitConstructorIterator!(C, "Constructor!(T, func)"));
		}
		mixin(DUnitMethodIterator!(C, "MethodDelegateProperty!(func)"));
		mixin(DUnitMethodIterator!(C, "Method!(is(T == class), func)"));

		/*
		 * Get the storage classes of the passed delegate.
		 *
		 * Params:
		 *     method = The delegate to inspect.
		 *
		 * Returns:
		 *     An array containing the storage classes of all delegate parameters.
		 */
		private string[] getStorageClasses(T)(T method)
		{
			string[] storageClasses;
			string code;

			foreach (storageClass; ParameterStorageClassTuple!(method))
			{
				code = "";

				static if (storageClass == ParameterStorageClass.scope_)
				{
					code ~= "scope ";
				}

				static if (storageClass == ParameterStorageClass.lazy_)
				{
					code ~= "lazy ";
				}

				static if (storageClass == ParameterStorageClass.out_)
				{
					code ~= "out ";
				}

				static if (storageClass == ParameterStorageClass.ref_)
				{
					code ~= "ref ";
				}

				storageClasses ~= code;
			}
			return storageClasses;
		}

		/*
		 * Get the types of the passed delegate.
		 *
		 * Params:
		 *     method = The delegate to inspect.
		 *
		 * Returns:
		 *     An array containing the types of all delegate parameters.
		 */
		private string[] getTypes(T)(T method)
		{
			string[] types;
			foreach (type; ParameterTypeTuple!(method))
			{
				types ~= type.stringof;
			}
			return types;
		}

		/*
		 * Generate a signature using the passed name and method. The signature is used to
		 * match up delegates to methods behind the scenes.
		 *
		 * Params:
		 *     name = The name of the method to generate the signature for.
		 *     method = A delegate to inspect, retreiving parameter details.
		 *
		 * Returns:
		 *     A string containing a method signature.
		 */
		private string generateSignature(T)(string name, T method)
		{
			string[] storageClasses = this.getStorageClasses!(T)(method);
			string[] types          = this.getTypes!(T)(method);
			string[] parameters;

			foreach (storageClass, type; zip(storageClasses, types))
			{
				parameters ~= format("%s%s", storageClass, type);
			}

			return format("%s:%s(%s)", ReturnType!(method).stringof, name, parameters.join(", "));
		}

		/**
		 * Replace a method in the mock object by adding a mock method to be called in its place.
		 * $(B By default parent methods are called in lieu of any replacements unless parent methods are disabled.)
		 *
		 * Params:
		 *     name = The name of the method to replace. (Only the name should be used, no parameters, etc.)
		 *     delegate_ = The delegate to be used instead of calling the original method.
		 *              The delegate must have the exact signature of the method being replaced.
		 *     minimumCount = The minimum amount of times this method must be called when asserting calls.
		 *     maximumCount = The maximum amount of times this method must be called when asserting calls.
		 *     file = The file name where the error occurred. The value is added automatically at the call site.
		 *     line = The line where the error occurred. The value is added automatically at the call site.
		 *
		 * Throws:
		 *     DUnitAssertError if the passed delegate does not match the signature of any overload of the method named.
		 *
		 * Caveats:
		 *     $(OL
		 *         $(LI In the case of replacing overloaded methods the delegate signature defines which method to replace. Helpful errors will be raised on non matching signatures.)
		 *         $(LI Templated methods are final by default and therefore cannot be mocked.)
		 *     )
		 *
		 * See_Also:
		 *     $(LINK2 mockable.html#disableParentMethods, disableParentMethods(...))
		 *
		 * Example:
		 * ---
		 * import dunit.mockable;
		 *
		 * class T
		 * {
		 *     int getValue()
		 *     {
		 *         return 1;
		 *     }
		 *
		 *     mixin Mockable!(T);
		 * }
		 *
		 * unittest
		 * {
		 *     import dunit.toolkit;
		 *
		 *     auto mock = T.getMock();
		 *
		 *     // Replace the 'getValue' method.
		 *     mock.mockMethod("getValue", delegate(){
		 *         return 2;
		 *     });
		 *
		 *     mock.getValue().assertEqual(2);
		 * }
		 * ---
		 */
		public void mockMethod(T)(string name, T delegate_, ulong minimumCount = 0, ulong maximumCount = ulong.max, string file = __FILE__, size_t line = __LINE__)
		{
			string signature = this.generateSignature!(T)(name, delegate_);

			this._methodCount[signature] = MethodCount(minimumCount, maximumCount);

			switch(signature)
			{
				mixin(DUnitMethodIterator!(C, "MethodSignatureSwitch!(func)"));
				default:
					auto error = new DUnitAssertError("Delegate does not match method signature", file, line);
					error.addInfo("Method name", format("%s.%s", this.className, name));
					error.addError("Delegate signature", signature);
					throw error;
			}
		}

		/**
		 * Disable parent methods being called if mock replacements are not implemented.
		 * If parent methods have been disabled a helpful assert error will be raised on any attempt to call methods that haven't been replaced.
		 * This is helpful if it's necessary to disable all behaviour of the mocked class.
		 *
		 * Has no effect on mock objects derived from interfaces, by default all mocked interface methods assert an error until replaced.
		 *
		 * Params:
		 *     file = The file name where the error occurred. The value is added automatically at the call site.
		 *     line = The line where the error occurred. The value is added automatically at the call site.
		 *
		 * See_Also:
		 *     $(LINK2 mockable.html#mockMethod, mockMethod(...))
		 *
		 * Example:
		 * ---
		 * import dunit.mockable;
		 *
		 * class T
		 * {
		 *     mixin Mockable!(T);
		 * }
		 *
		 * unittest
		 * {
		 *     auto mock = T.getMock();
		 *     mock.disableParentMethods();
		 *
		 *     // All mock object methods that are used in the test
		 *     // must now be replaced to avoid an error being thrown.
		 * }
		 * ---
		 */
		public void disableParentMethods(string file = __FILE__, size_t line = __LINE__)
		{
			this._disableMethodsLocation.file = file;
			this._disableMethodsLocation.line = line;
			this._useParentMethods = false;
		}

		/**
		 * Assert all replaced methods are called the defined amount of times.
		 *
		 * Params:
		 *     message = The error message to display.
		 *     file = The file name where the error occurred. The value is added automatically at the call site.
		 *     line = The line where the error occurred. The value is added automatically at the call site.
		 *
		 * Throws:
		 *     DUnitAssertError if any method was called outside of preset boundries.
		 *
		 * Example:
		 * ---
		 * import dunit.mockable;
		 *
		 * class T
		 * {
		 *     int getValue()
		 *     {
		 *         return 1;
		 *     }
		 *
		 *     mixin Mockable!(T);
		 * }
		 *
		 * unittest
		 * {
		 *     import dunit.toolkit;
		 *
		 *     auto mock = T.getMock();
		 *
		 *     // Replace method while defining a minimum call limit.
		 *     mock.mockMethod("getValue", delegate(){
		 *         return 2;
		 *     }, 1);
		 *
		 *     // Increase the call count of 'getValue' by one.
		 *     mock.getValue().assertEqual(2);
		 *
		 *     // Assert methods calls are within defined limits.
		 *     mock.assertMethodCalls();
		 * }
		 * ---
		 */
		public void assertMethodCalls(string message = "Failed asserting call count", string file = __FILE__, size_t line = __LINE__)
		{
			foreach (signature, methodCount; this._methodCount)
			{
				if (methodCount.actual < methodCount.minimum)
				{
					auto error = new DUnitAssertError(message, file, line);

					error.addInfo("Method", format("%s.%s", this.className, signature));
					error.addExpectation("Minimum allowed calls", methodCount.minimum);
					error.addError("Actual calls", methodCount.actual);

					throw error;
				}

				if (methodCount.actual > methodCount.maximum)
				{
					auto error = new DUnitAssertError(message, file, line);

					error.addInfo("Method", format("%s.%s", this.className, signature));
					error.addExpectation("Maximum allowed calls", methodCount.maximum);
					error.addError("Actual calls", methodCount.actual);

					throw error;
				}
			}
		}
	}
}

unittest
{
	import dunit.toolkit;

	interface T
	{
		public int method1(int param) const;
		public void method2(int param) const;
		public int method3(int param) const pure @safe nothrow;
		public void method4(int param) const pure @safe nothrow;
		public int method5(int param) const pure @trusted nothrow;
		public void method6(int param) const pure @trusted nothrow;

		mixin Mockable!T;
	}

	auto mock = T.getMock();

	mock.mockMethod("method1", delegate(int param) { return 2*param; });
	mock.mockMethod("method2", delegate(int param) { });
	mock.mockMethod("method3", delegate(int param) { return 2*param; });
	mock.mockMethod("method4", delegate(int param) { });
	mock.mockMethod("method5", delegate(int param) { return 2*param; });
	mock.mockMethod("method6", delegate(int param) { });

	mock.method1(10).assertEqual(20);
	mock.method2(10);
	mock.method3(10).assertEqual(20);
	mock.method4(10);
	mock.method5(10).assertEqual(20);
	mock.method6(10);
}

unittest
{
	import dunit.toolkit;

	static class T
	{
		public int method1(int param) const { return 0; };
		public void method2(int param) const {};
		public int method3(int param) const pure @safe nothrow { return 0; };
		public void method4(int param) const pure @safe nothrow {};
		public int method5(int param) const pure @trusted nothrow { return 0; };
		public void method6(int param) const pure @trusted nothrow {};

		mixin Mockable!T;
	}

	auto mock = T.getMock();

	mock.mockMethod("method1", delegate(int param) { return 2*param; });
	mock.mockMethod("method2", delegate(int param) { });
	mock.mockMethod("method3", delegate(int param) { return 2*param; });
	mock.mockMethod("method4", delegate(int param) { });
	mock.mockMethod("method5", delegate(int param) { return 2*param; });
	mock.mockMethod("method6", delegate(int param) { });

	mock.method1(10).assertEqual(20);
	mock.method2(10);
	mock.method3(10).assertEqual(20);
	mock.method4(10);
	mock.method5(10).assertEqual(20);
	mock.method6(10);
}

unittest
{
	import dunit.toolkit;

	static class T
	{
		public int method1() nothrow
		{
			assert(false, "thrown from method1");
		}

		public void method2()
		{
			throw new Exception("thrown from method2");
		}

		mixin Mockable!(T);
	}

	auto mock = T.getMock();

	mock.method1().assertThrow!Throwable("thrown from method1");
	mock.method2().assertThrow!Exception("thrown from method2");
}
