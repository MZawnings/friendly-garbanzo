pragma experimental SMTChecker;

contract C
{
	function f(uint16 x) public pure {
		uint8 y = uint8(x);
		// True because of y's type
		assert(y < 300);
	}
}
// ----
