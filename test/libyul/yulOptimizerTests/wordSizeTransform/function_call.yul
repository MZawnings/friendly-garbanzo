{
    function swap(x, y) -> a, b
    {
        a := y
        b := x
    }
    function main(v1, v2) -> r1, r2
    {
        let tmp := 11111111111111111111111111111111111111111111111111111111111111111111111111111
        r1, r2 := swap(v1, tmp)
        r1, r2 := swap(2222222222222222222222222222222222222222222222222222222222222222222, r2)
    }
}

// ----
// step: wordSizeTransform
//
// {
//     function swap(x_0, x_1, x_2, x_3, y_0, y_1, y_2, y_3) -> a_0, a_1, a_2, a_3, b_0, b_1, b_2, b_3
//     {
//         a_0 := y_0
//         a_1 := y_1
//         a_2 := y_2
//         a_3 := y_3
//         b_0 := x_0
//         b_1 := x_1
//         b_2 := x_2
//         b_3 := x_3
//     }
//     function main(v1_0, v1_1, v1_2, v1_3, v2_0, v2_1, v2_2, v2_3) -> r1_0, r1_1, r1_2, r1_3, r2_0, r2_1, r2_2, r2_3
//     {
//         let tmp_0 := 1770102123480502530
//         let tmp_1 := 591943673742124792
//         let tmp_2 := 13663686148824196892
//         let tmp_3 := 8198552921648689607
//         r1_0, r1_1, r1_2, r1_3, r2_0, r2_1, r2_2, r2_3 := swap(v1_0, v1_1, v1_2, v1_3, tmp_0, tmp_1, tmp_2, tmp_3)
//         let _1_0 := 354020424
//         let _1_1 := 12840787883880108911
//         let _1_2 := 12527970737989311368
//         let _1_3 := 16397105843297379214
//         r1_0, r1_1, r1_2, r1_3, r2_0, r2_1, r2_2, r2_3 := swap(_1_0, _1_1, _1_2, _1_3, r2_0, r2_1, r2_2, r2_3)
//     }
// }
