contract C {
    function f(string memory a, string memory b) public returns (string memory) {
        return string.concat(a, b);
    }
}
// ----
// f(string,string): 0x40, 0x80, 32, "abcdabcdabcdabcdabcdabcdabcdabcd", 5, "bcdef" -> 0x20, 0x25, 0x6162636461626364616263646162636461626364616263646162636461626364, 44502269928904312298000709931354278973409164155382318144318241583783949107200
// f(string,string): 0x40, 0xa0, 64, "abcdabcdabcdabcdabcdabcdabcdabcd", "abcdabcdabcdabcdabcdabcdabcdabcd", 5, "bcdef" -> 0x20, 0x45, 0x6162636461626364616263646162636461626364616263646162636461626364, 0x6162636461626364616263646162636461626364616263646162636461626364, 44502269928904312298000709931354278973409164155382318144318241583783949107200
// f(string,string): 0x40, 0x80, 3, "abc", 3, "def" -> 0x20, 6, "abcdef"
// f(string,string): 0x40, 0xa0, 34, "abcdabcdabcdabcdabcdabcdabcdabcd", "ab", 30, "cdabcdabcdabcdabcdabcdabcdabcd" -> 0x20, 0x40, 0x6162636461626364616263646162636461626364616263646162636461626364, 0x6162636461626364616263646162636461626364616263646162636461626364
// f(string,string): 0x40, 0xa0, 34, "abcdabcdabcdabcdabcdabcdabcdabcd", "ab", 34, "cdabcdabcdabcdabcdabcdabcdabcdab", "cd" -> 0x20, 0x44, 0x6162636461626364616263646162636461626364616263646162636461626364, 0x6162636461626364616263646162636461626364616263646162636461626364, 44048183293808120317390542201052832727062033572611867748297851798484192067584
// f(string,string): 0x40, 0x80, 3, "abc", 30, "dabcdabcdabcdabcdabcdabcdabcda" -> 0x20, 0x21, 0x6162636461626364616263646162636461626364616263646162636461626364, 43874346312576839672212443538448152585028080127215369968075725190498334277632
