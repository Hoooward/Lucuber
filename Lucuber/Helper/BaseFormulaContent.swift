//
//  testData.swift
//  Lucuber
//
//  Created by Howard on 6/4/16.
//  Copyright © 2016 Howard. All rights reserved.
//

import Foundation



let OLLFormulas = [
    //OLL1
    [
        "(R U'2) (R'2 F R F') U2 (R' F R F')",
        "U' (RU'2) (R'2 F R F') U2 (R' F R F')"
    ],
    
    //OLL2
    [
        "F (R U R' U') F' f (R U R' U') f'",
        "(r U r' U'2) (R U2 R' U' 2) (r U' r')",
        "F' (L' U' L U) F f' (L' U' L U) f",
        "(r' U' r U'2) (R' U2 R U'2) (r' U r)"
    ],
    
    //OLL3
    [
        "f (R U R' U') f' U' F (R U R' U') F'",
        "U' f (R U R' U') f' U' F (R U R' U') F'",
        "F (U R U' R') F' U F (R U R' U') F'",
        "U' F (U R U' R') F' U F (R U R' U') F'"
    ],
    
    //OLL4
    [
        "f (R U R' U') f' U F (R U R' U') F'",
        "U F (U R U' R') F' U' F (R U R' U') F'",
        "F (U R U' R') F' U' F (R U R' U') F'",
        "U f (R U R' U') f' U F (R U R' U') F'"
    ],
    
    //OLL5
    [
        "(r' U2) (R U R' U) r",
        "U (l' U2) (L U L' U) l",
        "(l' U2) (L U L' U) l",
        "U (r' U2) (R U R' U) r "
    ],
    
    
    //OLL6
    [
        "(r U' U') (R' U' R U' r')",
        "U (l U'2) (L' U' L U' l')",
        "(l U'2) (L' U' L U' l')",
        "U (r U'2) (R' U' R U' r')"
    ],
    
    //OLL7
    [
        "(r U R' U) (R U'U' r)",
        "U (l U L' U) (L U'2 l')",
        "(l U L' U) (L U'2 l')",
        "U (r U R' U) (R U'2 r)"
    ],
    
    //OLL8
    [
        "(r' U' R U') (R' U2 r)",
        "U (R U2 R' U2) (R' F R F')",
        "(R U2 R' U2) (R' F R F')",
        "U (r' U' R U') (R' U2 r)"
    ],
    
    
    //OLL9
    [
        "(R U R' U') (R' F) ( R2 U R' U') F'",
        "U (L' U' L) y' (L F' L' U) (r U r')",
        "(L' U' L) y' (L F' L' U) (r U r')",
        "U (R U R' U') (R' F) (R2 U R' U') F'"
    ],
    
    //OLL10
    [
        "(R U R' U) (R' F R F') (R U'2 R')",
        "(F U F') (R' F R U') (R' F' R)",
        "(L' U' L U) (L F' L2 U' L U) F",
        "U (R U R' U) (R' F R F')"
    ],
    
    //OLL11
    [
        "r' (R2 U R' U) (R U'U' R' U R') r",
        "F' (L' U' L U) F U' F' (L' U' L U) F",
        "(r U R' U) ( R' F R F') (R U'2 r')",
        "U r' (R2 U R' U) (R U'2 R' U R') r"
    ],
    
    //OLL12
    [
        "(r R'2 U' R U') (R' U2 R U' R) r'",
        "F (R U R' U') F'U F (R U R' U') F'",
        "(F R U) (R'2 F R) y' (R'2 U R U'2 R')",
        "U (r R'2 U' R U') (R' U2 R U' R) r'"
    ],
    
    //OLL13
    [
        "f (R U R2 U' R' U R U') f'",
        "U F (U R U' R2 F') (R U R U' R')",
        "F (U R U' R2 F') (R U R U' R')",
        "U f (R U R2 U' R' U R U') f'"
    ],
    
    //OLL14
    [
        "(R' F R U R' F' R) (F U' F')  ",
        "U (r' U) (r U r' d') f (R U' R')",
        "(r' U) (r U r' d') f (R U' R')",
        "(R' U') Y' (R' U) (R2 B R' U' R' U R) "
    ],
    
    //OLL15
    [
        "(r' U' r) (R' U' R U) (r' U r)",
        "U l' U' l (L' U' L U) l' U l",
        "l' U' l (L' U' L U) l' U l",
        "U (r' U' r) (R' U' R U) (r' U r)"
    ],
    
    //OLL16
    [
        "(r U r') (R U R' U') (r U' r')",
        "U (R B R') (L U L' U') (l U' l') ",
        "(R B R') (L U L' U') (l U' l')",
        "U (r U r') (R U R' U') (r U' r') "
    ],
    
    //OLL17
    [
        "(R U R' U) (R' F R F') U2 (R' F R F')",
        "U F (UR' U' F') U (F R2) (UR' U') F'",
        "F (UR' U' F') U (F R2) (UR' U') F'",
        "U (R U R' U) (R' F R F') U2 (R' F R F')"
    ],
    
    //OLL18
    [
        "F (R' F' R) (U R U' R' U) F (R U R' U') F'",
        "(R U2) (R2 F R F' U2) (M' U R U' r')",
        "F (R U R') d (R' U2) (R' F R F')",
        "U F (R' F' R) (U R U' R' U) F (R U R' U') F'"
    ],
    
    //OLL19
    [
        "(M U) (R U R' U') r (R'2 F R F')",
        "U F (U R U' R'2 F') U' F (U R U') F'",
        "F (U R U' R'2 F') U' F (U R U') F' ",
        "U (M U) (R U R' U') r (R'2 F R F')"
    ],
    
    //OLL20
    [
        "(r U R' U') M'2 (U R U' R' U' R') r",
    ],
    
    
    //OLL21
    [
        "(R U' U' R' U') (R U R' U' R U' R')",
        "(R U R') (U R U' R') (U R U'2 R')",
    ],
    
    
    //OLL22
    [
        "(R U'2) (R'2 U') (R2 U' R'2) U2 R",
        "U' (R U'2) (R'2 U') (R2 U' R'2) U2 R",
        "(L' U2) (L2 U) (L'2 U L2 U2 L'2)",
        "U' (L' U2) (L2 U) (L'2 U L2 U2 L'2)",
    ],
    
    //OLL23
    [
        "(R2 D') (R U'2) (R' D) (R U'2 R)",
        "(L' U' L U) (L' U L U'2)2 (L' U' L)",
        "(R U2 R' B') U (R U R' U')B",
        "(R U R' U') (R U' R' U2)2 (R U R')",
    ],
    
    //OLL24
    [
        "(r U R'U') (r' F R F')",
        "R' F' (R U R' U') R' F R U R",
        "(R' F') (r U R U') (r' F)",
        "F (R U R' U') (R' F' R) (U R U' R')",
    ],
    
    //OLL25
    [
        "F' (r U R' U') (r' F R)",
        "x' (D R U R' D') (R U' l')",
        "x' (U' R U) (L' U') (R' U r)",
        "(R' F) x' (R U' R') D' (R U)",
    ],
    
    //OLL26
    [
        "(R U2 R' U') (R U' R')",
        "(L U2) (L' U' L) (U' L')",
        "(L U2) (L' U' L U' L')",
        "(R' U') (R U' R' U2 R)",
    ],
    
    //OLL27
    [
        "(R' U2) (R U R') (U R)",
        "(R U R' U) (R U'2 R')",
        "(L' U'2 L U) (L' U L)",
        "(L U L' U) (L U2 L')",
    ],
    
    
    //OLL28
    [
        "(r U R' U') M ( U R U' R')",
        "(l' U' L U) M (U' L' U L)",
        "(l U L' U') M' (U L U' L')",
        "(r' U' R U) M' (U' R' U R)",
    ],
    
    //OLL29
    [
        "(R U R' U') (R U' R' F' U' F) (R U R')",
        "(R' F R F') (R U'2 R' U') (F' U' F)",
        "U' (R' F R F') (R U'2 R' U') (F' U' F)",
        "M U (R U R' U') (R' F R F') M'",
    ],
    
    //OLL30
    [
        "(M U') (L' U' L U) (L F' L' F) M'",
        "U F U (R U2 R' U')2 F'",
        "F U (R U2 R' U')2 F'",
        "U (M U') (L' U' L U) (L F' L' F) M'",
    ],
    
    //OLL31
    [
        "R' U' F (U R U') (R' F' R)",
        "U R' U' F (U R U') (R' F' R)",
        "R' U' F (U R U') (R' F' R)",
        "U S' (L' U' L U) (L F' L' f)",
    ],

    //OLL32
    [
        "S (R U R' U') (R' F R f')",
        "U L U F' (U' L' U) (r U r')",
        "L U F' (U' L' U) (r U r')",
        "S (R U R' U') (R' F R f')",
    ],
    
    //OLL33
    [
        "(R U R' U') (R' F R F')",
        "U' (R U R' U') (R' F R F')",
        "(L' U' L U) (r U' r' F) ",
        "U' (L' U' L U) (r U' r' F)",
    ],
    
    //OLL34
    [
        "(R U R' U') B'(R' F R F') B",
        "U F (R U R' U') (R' F') (r U R U' r')",
        "F (R U R' U') (R' F') (r U R U' r')",
        "U (R U R' U') B' (R' F R F') B",
    ],
    
    //OLL35
    [
        "(R U'2) (R'2 F R F') (R U'2 R')",
        "U' (R U' U') (R'2 F R F') (R U'2 R')",
        "(L U'2) (L' r' U) (L U' r) (U' U' L')",
        "(R' U2 R) (l U' R' U l' U2 R)",
    ],
    
    //OLL36
    [
        "(R U R' U') (F' U'2 F U) (R U R')",
        "U' (R U R' U') (F' U'2 F U) (R U R')",
        "(L' U' L U) (L' U L U) (L F' L' F)",
        "U' (L' U' L U) (L' U L U) (L F' L' F)",
    ],
    
    //OLL37
    [
        "F (R U' R' U' R U R') F'",
        "x' (R U' R' U) y z' (U R U' R')",
        "x (U r U') (r' F') (r U r'U')",
        "U' x (U r U') (r' F') (r U r' U')",
    ],
    
    //OLL38
    [
        "(R U R') (U R U' R') U' (R' F R F')",
        "U (L' U' L U) y' (R U2 R' U') y (L' U' L)",
        "(L' U' L U) y' (R U2 R' U') y (L' U' L)",
        "U (R U R') (U R U' R') U' (R' F R F')",
    ],
    
    //OLL39
    [
        "(R B' R' U' R U) B U' R'",
        "U L F' (L' U' L U) F U' L'",
        "L F' (L' U' L U) F U' L'",
        "U (R B' R' U' R U) B U' R'",
    ],

    //OLL40
    [
        "R' F (R U R' U') F' U R",
        "U (r' U) (r U r' F' U' F) r",
        "(r' U) (r U r' F' U' F) r",
        "U R'F (R U R' U') F' U R",
    ],
    
    
    //OLL41
    [
        "(R U R' U) (R U' U') (R' F) (R U R' U') F",
        "(L F' L' F)2 (L' U' L U) (L' U' L)",
        "(R U' R' U2 R U) y (R U' R' U') F'",
        "(R U'2 R' U' R U' R2) Y (L' U' L U F)",
    ],

    //OLL42
    [
        "(R' U' R U' R' U2 R) F (R U R'U')F'",
        "(R' F R F')2 (R U R' U') (R U R')",
        "(L' U' L) (U' L' U2 L) F' (L' U' L U) F",
        "(L' U'2 L U L' U L2) y' (R U R' U' F')",
    ],
    
    //OLL43
    [
        "f' (L' U' L U) f",
        "U F' (U' L' U L) F",
        "F' (U' L' U L) F",
        "U f' (L' U' L U) f",
    ],
    
    
    //OLL44
    [
        "f (R U R' U') f'",
        "U F (U R U' R)' F'",
        "F (U R U' R)' F'",
        "U f (R U R' U') f'",
    ],
    
    //OLL45
    [
        "F (R U R' U') F'",
        "U' F (R U R' U') F'",
        "f (U R U' R') f'",
        "U' f (U R U' R') f'",
    ],
    
    //OLL46
    [
        "(R' U') (R' F R F') U R",
        "U (r' F') (L' U L U') F r",
        "(r' F') (L' U L U') F r",
        "U (R' U') (R' F R F') U R",
    ],
    
    //OLL47
    [
        "F' (L' U' L U)2 F",
        "U' F' (L' U' L U)2 F",
        "f' (U' L' U L)2 f",
        "U' f' (U' L' U L)2 f",
    ],
    
    //OLL48
    [
        "F (R U R' U')2 F'",
        "U' F (R U R' U')2 F'",
        "f (U R U' R')2 f'",
        "U' f (U R U' R')2 f'",
    ],
    
    //OLL49
    [
        "R B' (R2 F) (R2 B) R2 F' R",
        "(L' U'2 L U) (L' U L) F' (L' U' L U) F",
        "(L F' L') (r' U) (r2 U) (r'2 U' r)",
        "U R B' (R2 F) (R2 B) R2 F' R",
    ],
    
    //OLL50
    [
        "(r' U) (r2 U') (r'2 U' r2) U r'",
        "U' (r' U) (r2 U') (r'2 U' r2) U r'",
        "(R' F) (R2 B') (R2 F') (R2 B R')",
        "(R U2 R' U') (R U' R') F (R U R' U') F'",
    ],
    
    
    //OLL51
    [
        "f (R U R' U')2 f'",
        "U' f (R U R' U')2 f'",
        "F (U R U' R')2 F'",
        "U' F (U R U' R')2 F'",
    ],
    
    //OLL52
    [
        "(L' U' L) U' (r' F U' F) U r",
        "U (R' U') (R U' R' U) Y' (R' U R B')",
        "(R' U') (R U' R' U) Y' (R' U R B')",
        "U (L' U' L) U'(r' F U' F) U r",
    ],
    
    //OLL53
    [
        "(r' U2) (R U R' U') (R U R' U) r",
        "(l' U') (L U' L' U) (L U' L' U2) l",
        "(l' U' l) (L' U' L U)2 (l' U l)",
        "(r' U') (R U' R' U) (R U' R' U2) r",
    ],
    
    //OLL54
    [
        "(r U r') (R U R' U')2 (r U' r')",
        "(r U) (R' U R U') (R' U R U'2) r'",
        "x' (R U'2) (L' U' L U) (L' U' L) U' R'",
        "(l U) (L' U L U') (L' U L U2) l'",
    ],
    
    //OLL55
    [
        "R' F (U R U' R'2 F' R2) (U R' U' R) ",
        "U' R' F (U R U' R'2 F' R2) (U R' U' R)",
    ],
    
    //OLL56
    [
        "F (R U R' U') (R F') (r U R' U' r')",
        "U' F (R U R' U') (R F') (r U R' U' r')",
    ],
    
    //OLL57
    [
        "(R U R' U') M' (U R U' r')",
        "U (R U R' U') M' (U R U' r')",
    ],



    
]


let PLLFormulas = [

    //PLL1
    [
        "(R U' R) (U R U ) (R U' R' U' R2)",
        "L2 U' S U2 S' U' L2",
        "(R2 U') (R' U' R U R U) (R U 'R)",
        "R2 U' S' U2 S U' R2",
    ],
    
    //PLL2
    [
        "(R2' U) (R U R' U') (R' U') (R' U R')",
        "L2 U S U2 S' U L2",
        "(R' U R' U') (R' U') (R' U) (R U R'2)",
        "R2 U S' U2 S U R2",
    ],
    
    //PLL3
    [
        "M2' U M2' U2 M2' U M2'"
    ],
    
    //PLL4
    [
        "(R U R B') (R' B U' R') (f R U R' U' f')",
        "(U R' U') (R U' R) (U R U') (R' U R U) (R2 U') (R'U)",
    ],
    
    //PLL5
    [
        "x' R2 D2 (R' U' R) D2 (R' U R')",
        "z F2 (R U2 R' U2 F2) (L' U2 L U2)",
        "(R U R' F') (r U R' U') (r' F R2 U' R')",
        "x (R' U R') D2 (R U' R') D2 R2",
    ],
    
    //PLL6
    [
        "x' (R U' R) D2 (R' U R) D2 R2",
        "z U2 (L' U2 L F2) (U2 R U2 R' F2)",
        "(r U' L) D2 (L' U L) D2 L2",
        "x R2 D2 (R U R') D2 (R U' R)",
    ],
    
    //PLL7
    [
        "(R U R') (U R' U' R F') (R U R' U') (R' F R2 U' R'2 U R U')",
        "(R2 U R' U'）Y (R U R' U')2 (R U R' F) U' F2",
    ],
    
    //PLL8
    [
        "(R U R' U') (R' F) (R2 U' R' U') (R U R' F')",
    ],

    //PLL9
    [
        "(U' R' U R U' R' 2) (F' U' F U R) x (U R' U' R 2)",
        "(R U' R' U) (R U) (F R U R' U' F') (R' 2 F R F')",
        "z (R U R' U' R U' U') x' z' (R U R' U') x (U' R' U R U' U')",
        "(R' U R U' R2) (F' U' F) (U R F) (R' F' R2 U')",
    ],
    
    //PLL10
    [
        "(R' U R') d' (R' F' R2 U' R' U) (R' F R F)",
        "(r' F R F') (r U r') (F R' F') (r U2 R U2 R')",
        "(R U' L' U) (R' U' R U') (L U R') (U2 L' U2 L)",
        "(R' U L U') (R U R' U) (L' U' R) (U2 L U2 L')",
    ],
    
    //PLL11
    [
        "F (R U' R' U') (R U R' F') (R U R' U') (R' F R F')",
        "z (U2 R U R' U' R) y (R U L' U ) (L U R' U')",
        "z (U2 R') (U2 R') (U2 R) (B R B') U2 (B R' B')",
        "(R2 u) (R2' U) (R2 D') (R' U' R) F2' (R' U R)",
    ],
    
    //PLL12
    [
        "(L' U R') z (R2 U R' U' R2 U D) z' U'",
        "(l R u' R' u R l) y' (R' U R' U' R2)",
        "(x U2 r' U' r U2) (l' U R' U' l2)",
    ],
    
    //PLL13
    [
        "(R U R' F') (R U R' U') (R' F R2 U' R' U')",
        "R U' L - U2 - R' U R U2 - r' R' U",
        "r2 U' L' - U r' U2 - l U' l' U2",
        "L U' r U2 - l' U R' U' - l2 F2 L2"
    ],
    
    //PLL14
    [
        "R' U2 (R U2) R' F (R U R' U') (R' F' R2' U')",
        "(R2 F R U R U' R' F') R U2 (R' U2) R U",
        "(R' U2 l) (R U' R' U l') U2' (R F R U' R') (U' R U R' F')",
    ],
    
    //PLL15
    [
        "(R U R' F') (R U2) (R' U2) (R' F R U) (R U2 R' U')",
        "(R U' R) F2 (U R U R) (U' R' U') (F2 R2 U)",
        "x' (R' U' F' U R' U') x (U R' U' R' U lB R2)",
        "z (U R2) U' R2 (U F' U' R' U R U F U2 R)"
    ],
    
    //PLL16
    [
        "(R2' u') (R U' R) (U R' u R2) y (R U' R')",
        "(R2' F2 R U2) R U2 (R' F R U R' U' R' F R2)",
        "(L' R' U2 L R) y (L U' R U2) (L' U R' U2)",
    ],
    
    //PLL17
    [
        "(R U R') y' (R2 u') (R U' R' U R') u R2",
        "R2 (F' R U R U' R' F') R U2 (R' U2 - R' F2 R2)",
        "(f R f') R2 u' (R U' R' U R' u R2)",
    ],
    
    //PLL18
    [
        "(R2' u) (R' U R' U' R u' R2) y' (R' U R)",
        "(F2' D) (R' U R' U' R) D' F2 (L' U L)",
        "(R U R' U') (R' U F) (R U R U') (R' F' U) (R' U2 R U2)",
    ],
    
    //PLL19
    [
        "(R' d' F) R2 u (R' U R U' R u' R2)",
        "(F' U' F) R2 u (R' U R U' R u' R2')",
        "(R' U2 R U') (F R U R' U' R' F') (U' R U R U' R' U2)",
        "(R' U L' U2 R U' L) y (R L U2 L' R' U2)"
    ],
    
    
    //PLL20
    [
        "(R' U R U') (R' F' U' F R U R') (F R' F') (R U' R)",
        "z (U' R D' R2 U R' U') z' (R U R') z (R2 U R') z' (R U')",
    ],
    
    //PLL21
    [
        "(R U R' U) (R U R' F') (R U R' U') (R' F R2 U' R') (U2 R U' R')",
        "z R' (U R' D R2 U' R D')2 z'",
    ],
    
    
    
    

]

let F2LFormulas = [
    
    //1
    [
        "(R U'U' R' U) (R U'U' R') (U y') (R’ U' R)",
        "(L' U L U' y) (L U2) (L' U2) (L U' L')",
        "(L U2 L' U) (L U2 r' F) (U' F' U)",
        "(R' U R U' y) (R U'U') (R' U2) (R U' R')"
    ],
    
    //2
    [
        "(R U'U' R' U) (R U'U' R') (U y') (R’ U' R)",
        "(L' U L U' y) (L U2) (L' U2) (L U' L')",
        "(L U2 L' U) (L U2 r' F) (U' F' U)",
        "(R' U R U' y) (R U'U') (R' U2) (R U' R')"
    ],
    
    //3
    [
        "(R' F' R U) (R U' R' F)",
        "(U' L' U L) F' (r U r')",
        "(L U') (L' U' L) (U' L' U L U L')",
        "U' (R' U R) x' U' (R U R')"
    ],
    
    //4 
    [
        "(R U' R' U) (R U'U' R' U) (R U' R')",
        "(L' U' L U) (L' U2 L U) (L' U' L)",
        "(L U' L' U) (L U2 L' U) (L U' L')",
        "(R' U R) U (R' U' R U'U') (R' U R)"
    ],
    
    //5
    [
        "(R U' R’ U') (R U' R’) (U y') (R’ U’ R)",
        "y' (R U' R’ U') (R U' R’) (U y') (R’ U’ R)",
        "(L U' L’) (U L U L' U) (U y') (L’ U’ L)",
        "y (R U' R’ U') (R U' R’) (U y') (R’ U’ R)"
    ],
    
    //6
    [
        "(R’ F R F’) (U R U’ R’)",
        "(L' U' L U) (L' U' L)",
        "y (R' U' R U) (R' U' R)",
        "(R' U' R U) (R' U' R)"
    ],
    
    //let F2L7 =
    [
        "(R U' R' U) (R U' R')",
        "y' (R U' R' U) (R U' R')",
        "(L U' L' U) (L U' L')",
        "y (R U' R' U) (R U' R')"
    ],
    
    //let F2L8 =
    [
        "(R U' R' U) (R U'U' R' U) (R U' R')",
        "(L' U' L U) (L' U2 L U) (L' U' L)",
        "(L U' L' U) (L U2 L' U) (L U' L')",
        "(R' U R) U (R' U' R U'U') (R' U R)"
    ],
    
    //let F2L9 =
    [
        "(R U R’ U') (R U’ R’ U y') (U R’ U’ R)",
        "(L' U L U' y') (R U R') U (R U R') ",
        "L2 y' (R U R’ U') y (L' U L') ",
        "(R' U R' U' F' U) (F R2)"
    ],
    
    //let F2L10 =
    [
        "(R U'U' R' U y') (R' U R')",
        "(L' U L U') (L' U L)",
        "y (R' U R U') (R' U R)",
        "(R' U R U') (R' U R)"
    ],
    
    
    //let F2L11 =
    [
        "(R U R' U') (R U R')",
        "y' (R U R' U') (R U R')",
        "(L U L' U') (L U L')",
        "y (R U R' U') (R U R')"
    ],
    
    
    //let F2L12 =
    [
        "(U R U' R’)3",
        "(U' L' U L)3 ",
        "(U L U' L’)3",
        "(R' U' R U)2 (R' U' R)"
    ],
    
    //let F2L13 =
    [
        "(R U' R') (U y') (R' U R)",
        "(L' U L) (U' y) (L U' L')",
        "(L U') x (L U') (L' U L')",
        "(R' U R' F) (R F' R)"
    ],
    
    //let F2L14 =
    [
        "(R’ F R F’) (R U' R’) (U R U' R’)",
        "(L' U2) (L U L' U' L)",
        "y (R' U2) (R U R' U' R)",
        "(R' U2) (R U R' U' R)"
    ],
    
    //let F2L15 =
    [
        "(U' y) (L’ U2) (L U’) (L’ U L)",
        "U' (L’ U2) (L U’) (L’ U L)",
        "(U' y) (R’ U2) (R U’) (R’ U R)",
        "U' (R’ U2) (R U’) (R’ U R)"
    ],
    
    //let F2L16 =
    [
        "F' (L' U2) L F",
        "U2 (L' U' L) U' (L' U L)",
        "y U2 (R' U' R) U' (R' U R)",
        "(R' U) (R U'U') (R' U' R)"
    ],
    
    //let F2L17 =
    [
        "U' (R U R') (R' F R F') (R U' R')",
        "(L' U' L) U2 (L' U' L U) (L' U' L)",
        "(L U' L') (U' y) (R' U') (R U'U') (R' U R)",
        "(R' U') (R U'U') (R' U' R U) (R' U' R)"
    ],
    
    //let F2L18 =
    [
        "(R U R') (U'U') (R U R' U') (R U R')",
        "(L' U' L) y' (U' R U' R' U) (R U' R')",
        "y (R' U' R) (U' y) (R U' R' U) (R U' R')",
        "(R' U' R) (U' y) (R U' R' U) (R U' R')"
    ],
    
    //let F2L19 =
    [
        "(R U') (R' U2) (R U R')",
        "F (R U'U' R') F'",
        "(L U') (L' U2) (L U L')",
        "f U R2 U' f'"
    ],
    
    //let F2L20 =
    [
        "U (R U’ U' R’) U (R U' R’)",
        "(U y') (R U’ U' R’) U (R U' R’)",
        "U (L U2 L’) U (L U' L’)",
        "(U y') (L U2 L’) U (L U' L’)"
    ],
    
    
    //let F2L21 =
    [
        "(R U’U’) (R' U' R U) R'",
        "y' (R U’U’) (R' U' R U) R'",
        "(L U2) (L' U') (L U L')",
        "(R' U’) (R U R' U') (R U'U' y) (R' U' R)"
    ],
    
    //let F2L22 =
    [
        "U' (R U') (R' U2) (R U' R')",
        "U' (L' U' L) U2 (L' U' L)",
        "U' (L U' L') U2 (L U' L')",
        "(U' y) (R U') (R' U2) (R U' R')"
    ],
    
    //let F2L23 =
    [
        "U' (R U R') y' (U R’ U' R)",
        "(U' y) (L U L'U) y' (L’ U' L)",
        "U' (L U L' U) y' (L’ U' L)",
        "(U' y) (R U R') y' (U R’ U' R)"
    ],
    
    //let F2L24 =
    [
        "(U y') (R' U R U') (R' U' R)",
        "U (L' U L U') (L' U' L)",
        "(U y') (L' U L U') (L U' L')",
        "U (R' U R U') (R' U' R)"
    ],
    
    //let F2L25 =
    [
        "y' (R’ U' R)",
        "L’ U' L",
        "y (R’ U' R)",
        "R’ U' R"
    ],
    
    //let F2L26 =
    [
        "U' (R U' R') (U y') (R' U' R)",
        "y' U' (R U' R') (U y') (R' U' R)",
        "U' (L U' L') (U y') (L' U' L)",
        "U (R' U' R U') (R' U' R) "
    ],
    
    //let F2L27 =
    [
        "U' (R U'U' R') (U y') (R’ U' R)",
        "y' U' (R U'U' R') (U y') (R’ U' R)",
        "U' (L U2) (L' U y') (L' U' L)",
        "(R U'U') (R'2 U' R2 U' R’)"
    ],
    
    
    //let F2L28 =
    [
        "(l U) (L F' L' U') l'",
        "(L' U L U2 y) (R U R’)",
        "(L U2) (L' U) (L U L') U (L U' L')",
        "(R' U R U'U' y) (R U R’)"
    ],
    
    //let F2L29 =
    [
        "U' (R U'U') (R' U2) (R U' R')",
        "(U' y) (L U2) (L' U2) (L U' L')",
        "U' (L U2) (L' U2) (L U' L')",
        "(U' y) (R U'U') (R' U2) (R U' R')"
    ],
    
    //let F2L30 =
    [
        "U' (R U R' U') (R U'U' R')",
        "(U' y) (L U L') U2 (L U' L')",
        "U' (L U L') U2 (L U' L')",
        "U (r' U) (R U' R' U') r"
    ],
    
    //let F2L31 =
    [
        "U R U’ R’",
        "F' (r U r')",
        "U (L U’ L’)",
        "x' U' (R U R')"
    ],
    
    //let F2L32 =
    [
        "U' (R U'U’ R' U) (R U R')",
        "U (L' U) (L U2) (L' U L)",
        "U (L U L') U2 (L U L')",
        "U (R' U) (R U'U’) (R' U R)"
    ],
    
    
    //let F2L33 =
    [
        "y' (U R' U' R) (U' y) (R U R')",
        "U (L' U' L) (U' y) (L U L')",
        "y (U R' U' R) (U' y) (R U R')",
        "(U R' U' R) (U' y) (R U R')"
    ],
    
    //let F2L34 =
    [
        "F (R' F' R)",
        "U' (L' U L)",
        "x' U (L' U' L)",
        "U' (R' U R)"
    ],
    
    //let F2L35 =
    [
        "(U y') (R' U' R U'U') (R' U R)",
        "U (L' U') (L U2) (L' U L)",
        "y (U R' U' R U'U') (R' U R)",
        "(U R' U' R U'U') (R' U R)"
    ],
    
    //let F2L36 =
    [
        "(U y') (R' U2 R U'U') (R' U R)'",
        "U (L' U2 L U2) (L' U L))",
        "(U y') (L' U2 L U2) (L' U L)",
        "U (R' U2 R U'U') (R' U R)"
    ],
    
    //let F2L37 =
    [
        "(R U’) (R’ U y') (U R’ U’ R)",
        "y' (R U’) (R’ U y') (U R’ U’ R)",
        "(L U' L' U) (U y') (L' U' L)",
        "(R' U2) (R U') (R' U') (R U') (R' U R)"
    ],
    
    //let F2L38 =
    [
        "(R U') (R' U) (R U') (R' U2) (R U' R')",
        "U (L' U2 L) (U' y) (L U' L')",
        "L' U2 (L2 U) (L'2 U) L",
        "y' L' U2 (L2 U) (L'2 U) L"
    ],
    
    //let F2L39 =
    [
        "U' (R U R' U) (R U R')",
        "(U' y) (L U L' U) (L U L')",
        "U' (L U L' U) (L U L')",
        "(U' y) (R U R' U) (R U R')"
    ],
    
    
    //let F2L40 =
    [
        "R U R'",
        "y' (R U R')",
        "L U L'",
        "y (R U R')"
    ],
    
    
    //let F2L41 =
    [
        "U' (R U' R' U) (R U R')",
        "(U' y) (L U' L') U (L U L')",
        "U' (L U' L') U (L U L')",
        "(U' y) (R U') (R' U) (R U R')"
    ],
    
    
]















