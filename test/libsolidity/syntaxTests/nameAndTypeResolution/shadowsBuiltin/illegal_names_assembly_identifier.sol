contract C {
    function f() public {
        assembly {
            let super := 1
            let this := 1
            let _ := 1
        }
    }
}
// ----
// DeclarationError 4113: (74-79): The identifier name "super" is reserved.
// DeclarationError 4113: (101-105): The identifier name "this" is reserved.
// DeclarationError 4113: (127-128): The identifier name "_" is reserved.
