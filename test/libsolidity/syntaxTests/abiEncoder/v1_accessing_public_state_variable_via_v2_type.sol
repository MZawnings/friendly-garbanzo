pragma abicoder v1;
struct Item {
    uint x;
    uint y;
}

contract D {
    Item[][][] public items;

    function test() public view returns (uint) {
        // The autogenerated getters to not use ABI encoder.
        Item memory item = this.items(1, 2, 3);
        return item.x + item.y;
    }
}
// ----
// TypeError 7364: (222-260): Different number of components on the left hand side (1) than on the right hand side (2).
// TypeError 9574: (222-260): Type uint256 is not implicitly convertible to expected type struct Item memory.
