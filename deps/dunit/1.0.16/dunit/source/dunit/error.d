/**
 * Module to handle exceptions.
 *
 * License:
 *     MIT. See LICENSE for full details.
 */
module dunit.error;

/**
 * Imports.
 */
import core.exception;
import std.string;


/**
 * An exception thrown when a unit test fails.
 *
 * This exception derives from AssertError to make it possible for
 * these errors to be thrown from nothrow methods.
 */
class DUnitAssertError : AssertError
{
	/**
	 * Values to display in the message.
	 */
	private string[] _log;

	/**
	 * Constructor.
	 *
	 * Params:
	 *     message = The error message.
	 *     file = The file where the error occurred.
	 *     line = The line where the error occurred.
	 */
	this(string message, string file, size_t line) pure nothrow @safe
	{
		super(message, file, line);
	}

	/**
	 * Return the exception log.
	 *
	 * Returns:
	 *     The error's logged info, expectations and error messages.
	 */
	public @property string[] log()
	{
		return this._log;
	}

	/**
	 * Add a line of info to the exception log.
	 *
	 * Params:
	 *     caption = The caption.
	 *     value = The value.
	 *     icon = The icon before the caption.
	 */
	public void addInfo(T)(string caption, T value, string icon = "ℹ")
	{
		this._log ~= format("%s %s: %s", icon, caption, value);
	}

	/**
	 * Add a line of typed info to the exception log.
	 *
	 * Params:
	 *     caption = The caption.
	 *     value = The value.
	 *     icon = The icon before the caption.
	 */
	public void addTypedInfo(T)(string caption, T value, string icon = "ℹ")
	{
		this._log ~= format("%s %s: (%s) %s", icon, caption, T.stringof, value);
	}

	/**
	 * Add a line of expected info to the exception log.
	 *
	 * Params:
	 *     caption = The caption.
	 *     value = The value.
	 *     icon = The icon before the caption.
	 */
	public void addExpectation(T)(string caption, T value, string icon = "✓")
	{
		this.addInfo!(T)(caption, value, icon);
	}

	/**
	 * Add a line of typed expected info to the exception log.
	 *
	 * Params:
	 *     caption = The caption.
	 *     value = The value.
	 *     icon = The icon before the caption.
	 */
	public void addTypedExpectation(T)(string caption, T value, string icon = "✓")
	{
		this.addTypedInfo!(T)(caption, value, icon);
	}

	/**
	 * Add a line of error info to the exception log.
	 *
	 * Params:
	 *     caption = The caption.
	 *     value = The value.
	 *     icon = The icon before the caption.
	 */
	public void addError(T)(string caption, T value, string icon = "✗")
	{
		this.addInfo!(T)(caption, value, icon);
	}

	/**
	 * Add a line of typed error info to the exception log.
	 *
	 * Params:
	 *     caption = The caption.
	 *     value = The value.
	 *     icon = The icon before the caption.
	 */
	public void addTypedError(T)(string caption, T value, string icon = "✗")
	{
		this.addTypedInfo!(T)(caption, value, icon);
	}
}

unittest
{
	import dunit.toolkit;

	auto error = new DUnitAssertError("Error message.", "test.d", 100);
	error.addInfo("Info", 1);
	error.addTypedInfo("Typed info", 2);
	error.addExpectation("Expectation", 3);
	error.addTypedExpectation("Typed expectation", 4);
	error.addError("Error", 5);
	error.addTypedError("Typed error", 6);

	try
	{
		throw error;
	}
	catch (DUnitAssertError ex)
	{
		ex.msg.assertEqual("Error message.");
		ex.file.assertEqual("test.d");
		ex.line.assertEqual(100);
		ex.log.assertEqual(["ℹ Info: 1", "ℹ Typed info: (int) 2", "✓ Expectation: 3", "✓ Typed expectation: (int) 4", "✗ Error: 5", "✗ Typed error: (int) 6"]);
	}
}
