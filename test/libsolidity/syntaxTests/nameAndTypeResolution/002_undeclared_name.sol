contract test {
    uint256 variable;
    function f(uint256 arg) public {
        f(notfound);
    }
}
// ----
// DeclarationError: (85-93): Undeclared identifier.
